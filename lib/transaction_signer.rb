require 'base64'

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
