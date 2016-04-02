require 'json'
require 'base64'

class Transaction
  attr_accessor :inputs, :outputs, :timestamp, :hash
  def initialize(inputs, outputs, timestamp = Time.now)
    self.inputs = inputs
    self.outputs = outputs
    timestamp = format_timestamp(timestamp) if timestamp.class == Time
    self.timestamp = timestamp
    hash_transaction
  end

  def transaction_string
    inputs_string = inputs.map { |i| i[:source_hash] + i[:source_index].to_s + i[:signature] }.join
    outputs_string = outputs.map { |i| i[:amount].to_s + i[:address] }.join
    "#{inputs_string}#{outputs_string}#{timestamp}"
  end

  def to_json
    tout = {"inputs"=> inputs,
            "outputs"=> outputs,
            "timestamp"=> timestamp,
            "hash"=>txn_hash}
    JSON.generate(tout)
  end

  def coinbase?
    inputs == []
  end

  def outputs_index(public_key_pem)
    outputs.find_index do |output|
      output[:address] == public_key_pem
    end
  end

  private

  def format_timestamp(timestamp)
    (timestamp.to_f*1000).to_i
  end

  def hash_transaction
    self.hash = Digest::SHA256.hexdigest(transaction_string)
  end
end


module TransactionSigner
  def self.sign_transactions(inputs, outputs, private_key, digest = OpenSSL::Digest::SHA256.new)
    signature = generate_signature(inputs, outputs, private_key, digest)
    [sign_inputs(inputs, signature), outputs]
  end

  private

  def self.inputs_string(inputs)
    inputs.map { |i| i[:source_hash] + i[:source_index].to_s }.join
  end

  def self.outputs_string(outputs)
    outputs.map { |i| i[:amount].to_s + i[:address] }.join
  end

  def self.sign_inputs(inputs, signature)
    inputs.each do |input|
      input[:signature] = signature
    end
  end

  def self.generate_signature(inputs, outputs, private_key, digest)
    to_sign = inputs_string(inputs) + outputs_string(outputs)
    signed = private_key.sign(digest, to_sign)
    Base64.encode64(signed)
  end
end
