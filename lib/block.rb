class Block
  attr_reader :transactions, :block_hash, :trans_hash, :parent_hash
  attr_accessor :nonce, :timestamp, :target

  def initialize(parent_hash, transactions, opt_inputs = {})
    @transactions = transactions
    @parent_hash = parent_hash
    opt_inputs.each do |key, value|
      send("#{key}=", value)
    end
    @nonce ||= 0
    @timestamp ||= (Time.now.to_f* 1000).to_i
    @target ||= set_target
    set_trans_hash
    set_block_hash
  end

  def set_trans_hash
    trans_to_hash = transactions.map {|trans| trans.txn_hash}.join
    @trans_hash = Digest::SHA256.hexdigest(trans_to_hash)
  end

  def set_block_hash
    block_to_hash = "#{parent_hash}#{trans_hash}#{timestamp}#{target}#{nonce}"
    @block_hash = Digest::SHA256.hexdigest(block_to_hash)
  end

  def set_target
  end

end
