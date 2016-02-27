class BlockChain
  attr_accessor :current_block, :frequency, :bounds, :precision_level, :coinbase_value

  def initialize
    @chain = []
    # @frequency ||= 120.0
    # @bounds ||= 1
    # @precision_level ||= 15
    # @coinbase_value ||= 25
  end

  def self.from_json(raw_data)
    data = JSON.parse(raw_data, symbolize_names: true)
    bc = BlockChain.new
    data.each do |datum|
      bc.add(Block.new(datum[:header], datum[:transactions]))
    end
    bc
  end

  def add(block)
    chain << block
  end

  def last
    chain.first
  end

  def latest
    chain.last
  end

  # def add(block)
  #   @current_block = block
  #   @chain << current_block if current_block_valid?
  #   self.current_block = nil
  # end

  def height
    chain.count
  end

private
  def chain
    @chain
  end

  # def last
  #   @chain.last
  # end
  #
  # def timestamps
  #   @chain.last(10)
  # end
  #
  # def current_block_valid?
  #   return false unless parent_hash_valid?
  #   return false unless timestamp_valid?
  #   return false unless target_valid?
  #   return false unless all_transactions_valid?
  #   block_hash_valid?
  #
  #   # TRANSACTIONS:
  #   # Coinbase transaction amount is not more than allowed amount
  #   # Not more than one coinbase transaction
  #   # Transactions all valid...they will verify, and have enough money.
  #   # First transaction is a coinbase(?)
  #
  #
  #   # Block as a whole
  #   # Block will hash correctly.
  # end
  #
  # def parent_hash_valid?
  #   return true if height == 0
  #   current_block.parent_hash == last.block_hash
  # end
  #
  # def timestamp_valid?
  #   return true if height == 0
  #   current_block.timestamp > last.timestamp
  # end
  #
  # def target_valid?
  #   return false unless target_is_a_number?
  #   return true if height == 0 || height == 1
  #   target_within_bounds?
  # end
  #
  # def target_is_a_number?
  #   current_block.target.hex.to_s(16).rjust(64,"0") == current_block.target
  # end
  #
  # def optimal_target
  #   separations = timestamps.each_cons(2).map { |a,b| b-a }
  #   avg_sep = separations.reduce(0,:+)/(separations.length.to_f)
  #   factor = avg_sep / frequency
  #   BigDecimal.new(factor*last.target.to_i(16), precision_level).to_i
  # end
  #
  # def target_within_bounds?
  #   range = optimal_target*bound/100
  #   (current_block.target.hex >= optimal_target-range) &&  (current_block.target.hex <= optimal_target+range)
  # end
  #
  # def all_transactions_valid?
  #   #Check coinbases
  #   coinbases = current_block.transactions.find_all do |transaction|
  #     transaction.coinbase?
  #   end
  #   return false unless coinbases.length == 1
  #   coinbase = coinbases.first
  #   return false unless coinbase == current_block.transactions.first
  #   #require 'pry';binding.pry
  #   return false unless coinbase.outputs.first["amount"] <= coinbase_value
  #   # Check transactions hash correctly
  #   return false unless current_block.transactions.all? do |transaction|
  #     transaction_hash_valid?(transaction)
  #   end
  #   # Good inputs and outputs
  #   true
  # end
  #
  # def block_hash_valid?
  #   hash_current_block == current_block.block_hash
  # end
  #
  # def hash_current_block
  #   cb = "#{current_block.parent_hash}#{current_block.trans_hash}#{current_block.timestamp}#{current_block.target}#{current_block.nonce}"
  #   Digest::SHA256.hexdigest(cb)
  # end
  #
  # def block_hash_valid?
  #   hash_current_block == current_block.block_hash
  # end
  #
  # def hash_transaction(transaction)
  #   inputs_string = transaction.inputs.map { |i| i["source_hash"] + i["source_index"].to_s + i["signature"] }.join
  #   outputs_string = transaction.outputs.map { |i| i["amount"].to_s + i["address"] }.join
  #   txn = "#{inputs_string}#{outputs_string}#{transaction.timestamp}"
  #
  #   Digest::SHA256.hexdigest(txn)
  # end
  #
  # def transaction_hash_valid?(transaction)
  #   hash_transaction(transaction) == transaction.txn_hash
  # end
end
