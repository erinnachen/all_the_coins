class Transaction

  def initialize(inputs, outputs, wallet)
    @inputs = inputs
    @outputs = outputs
    @wallet = wallet
  end

  def signature
    inputs_string = inputs.map do |input|
      input["source_hash"] + input["source_index"].to_s
    end.join
    outputs_string = outputs.map do |input|
      input["amount"].to_s + input["address"]
    end.join
    signable_transaction = inputs_string + outputs_string

    wallet.private_key.sign(OpenSSL::Digest::SHA256.new, signable_transaction)
  end

  def sign_inputs
    inputs.each { |input| input["signature"] = signature }
  end

  def to_json
  end

end
