require 'json'

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
    tout = {inputs: inputs,
            outputs: outputs,
            timestamp: timestamp,
            hash: txn_hash}
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
