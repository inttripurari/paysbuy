require 'savon'

require 'paysbuy/version'
require 'paysbuy/config'

class Paysbuy
  attr_accessor :psb_id, :biz, :secure_code

  EXTERNAL_CODES = {
    "00" => :completed,
    "99" => :failed,
    "02" => :pending
  }

  def initialize(credentials)
    raise ":psb_id required" unless credentials[:psb_id]
    raise ":biz required" unless credentials[:biz]
    raise ":secure_code required" unless credentials[:secure_code]

    self.psb_id = credentials[:psb_id]
    self.biz = credentials[:biz]
    self.secure_code = credentials[:secure_code]
  end

  def check_status(invoice_id)
    response = client.request(:get_transaction_by_invoice) do
      soap.body = api_required_options.merge(invoice: invoice_id)
    end

    ws_return = response.body[:get_transaction_by_invoice_response][:get_transaction_by_invoice_result][:get_transaction_by_invoice_return]
    result_code = ws_return[:result]
    amount = ws_return[:amt]

    status = if EXTERNAL_CODES[result_code]
      EXTERNAL_CODES[result_code]
    else
      :invalid
    end

    {status: status, amount: amount.to_d, response: prepare_response_for_serialize(ws_return)}
  rescue Net::ReadTimeout, Errno::ECONNRESET, Errno::ETIMEDOUT
    raise Paysbuy::HttpError
  end

  def pay_now(options)
    # pay_client 
    response = pay_client.request(:api_paynow_authentication_new) do
      soap.body = api_required_options.merge(options)
    end

    ws_return = response.body[:api_paynow_authentication_new_response][:api_paynow_authentication_new_result]
    result_code = ws_return[:result]
    amount = ws_return[:amt]

    status = if EXTERNAL_CODES[result_code]
      EXTERNAL_CODES[result_code]
    else
      :invalid
    end

    {status: status, response: prepare_response_for_serialize(ws_return)}
  rescue Net::ReadTimeout, Errno::ECONNRESET, Errno::ETIMEDOUT
    raise Paysbuy::HttpError
  end

  private

  def client
    @client ||= Savon.client("http://www.paysbuy.com/psb_ws/getTransaction.asmx?WSDL")
  end

  def pay_client
    @pay_client ||= Savon.client("https://demo.paysbuy.com/api_paynow/api_paynow.asmx?wsdl")
  end

  def api_required_options
    {
      psbID: psb_id,
      biz: biz,
      secureCode: secure_code
    }
  end

  def prepare_response_for_serialize(original)
    prepared = {}
    original.each { |key, value| prepared[key] = value.to_s }
    prepared
  end
end

class Paysbuy::HttpError < StandardError; end
