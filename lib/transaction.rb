require 'json'
require 'base64'

class Transaction
  attr_accessor :inputs, :outputs, :timestamp
  attr_reader :txn_hash
  def initialize(inputs, outputs, timestamp = Time.now)
    self.inputs = inputs
    self.outputs = outputs
    self.timestamp = format_timestamp(timestamp)
  end

  def format_timestamp(timestamp)
    (timestamp.to_f*1000).to_i
  end

  def input_signature
    inputs_string = inputs.map do |input|
      input["source_hash"] + input["source_index"].to_s
    end.join
    outputs_string = outputs.map do |input|
      input["amount"].to_s + input["address"]
    end.join
    signable_transaction = inputs_string + outputs_string
    Base64.encode64(wallet.private_key.sign(OpenSSL::Digest::SHA256.new, signable_transaction))
  end

  def sign_inputs
    inputs.each { |input| input["signature"] = input_signature }
  end

  def hash_transaction
    @txn_hash = Digest::SHA256.hexdigest(transaction_string)
  end

  def transaction_string
    inputs_string = inputs.map { |i| i["source_hash"] + i["source_index"].to_s + i["signature"] }.join
    outputs_string = outputs.map { |i| i["amount"].to_s + i["address"] }.join
    "#{inputs_string}#{outputs_string}#{timestamp}"
  end

  def coinbase?
    inputs.empty? && outputs.length == 1
  end

  def to_json
    # sign_inputs
    # hash_transaction
    tout = {"inputs"=> inputs,
            "outputs"=> outputs,
            "timestamp"=> timestamp,
            "hash"=>txn_hash}
    JSON.generate(tout)
  end

end
