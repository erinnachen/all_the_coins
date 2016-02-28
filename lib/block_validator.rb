class BlockValidator

  def initialize(block, block_chain)
    @block = block
    @block_chain = block_chain
    #@protocol = protocol
  end

  def block_valid?
    return false unless parent_hash_valid?
    return false unless timestamp_valid?
    return false unless target_valid?
    return false unless all_transactions_valid?
    #   # TRANSACTIONS:
    #   # Coinbase transaction amount is not more than allowed amount
    #   # Not more than one coinbase transaction
    #   # Transactions all valid...they will verify, and have enough money.
    #   # First transaction is a coinbase(?)
    #
    #
    #   # Block as a whole
    #   # Block will hash correctly.
    block_hash_valid?
  end

  private

  def block
    @block
  end

  def block_chain
    @block_chain
  end

  def last_block
    block_chain.latest
  end

  def current_time
    (Time.now.to_f* 1000).to_i
  end

  def parent_hash_valid?
    return true if block_chain.height == 0
    block.parent_hash == last_block.hash
  end

  def timestamp_valid?
    return true if block_chain.height == 0 && block.timestamp <= current_time
    block.timestamp > last_block.timestamp
  end

  def target_valid?
    return false unless target_is_a_number?
    return true if block_chain.height == 0 || block_chain.height == 1
    #target_within_bounds?
  end

  def target_is_a_number?
    block.target.hex.to_s(16).rjust(64,"0") == block.target
  end

  def all_transactions_valid?
    coinbases = block.transactions.find_all do |transaction|
      transaction.coinbase?
    end
    return false unless coinbases.length == 1
    coinbase = coinbases.first
    return false unless coinbase == block.transactions.first
    return false unless coinbase.outputs.first[:amount] <= protocol[:coinbase]
    return false unless block.transactions.all? do |transaction|
      transaction_hash_valid?(transaction)
    end
    # Good inputs and outputs
    true
  end

  def protocol
    p = {coinbase: 25,
    }
  end
  # def current_block_valid?
  #   return false unless parent_hash_valid?
  #   return false unless timestamp_valid?
  #   return false unless target_valid?
  #   return false unless all_transactions_valid?
  #   block_hash_valid?
  #
  # end
end
