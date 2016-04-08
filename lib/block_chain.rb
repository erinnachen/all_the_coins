require "./lib/block"
class BlockChain
  # attr_accessor :current_block, :frequency, :bounds, :precision_level, :coinbase_value
  attr_reader :blocks

  def initialize
    @blocks = []
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
    blocks << block
  end

  def first
    blocks.first
  end

  def last
    blocks.last
  end

  def height
    blocks.count
  end

  def to_json
    chain = blocks.map { |block| block.to_h }
    JSON.generate(chain)
  end

  def get_balance(public_key_pem)
    unspent_transactions = find_unspent_transactions(public_key_pem)
    unspent_transactions.reduce(0) do |sum, unspent|
      sum + find_transaction(unspent[:source_hash]).outputs[unspent[:source_index]][:amount]
    end
  end

  def get_source_blocks(amount, public_key_pem)
    unspent = find_unspent_transactions(public_key_pem)
    i = 0
    txn_amount = 0
    unspent.each do |txn|
      txn_amount += find_transaction(txn[:source_hash]).outputs[txn[:source_index]][:amount]
      break if txn_amount >= amount
      i += 1
    end
    [txn_amount, unspent[0..i]]
  end

  def find_transaction(txn_hash)
    blocks.each do |block|
      txn = block.transactions.find do |txn|
        txn.hash == txn_hash
      end
      return txn if txn
    end
    nil
  end

  def current_target
    return default_target if height == 0 || height == 1
    separations = blocks.last(10).each_cons(2).map { |a,b| b.timestamp-a.timestamp }
    avg_sep = separations.reduce(0,:+)/(separations.length.to_f)
    factor = avg_sep / 120.0
    BigDecimal.new(factor*(last.target.to_i(16)), 15).to_i.to_s(16)
  end

private
  def find_unspent_transactions(public_key_pem)
    unspent_transactions = []
    blocks.each do |block|
      block.transactions.each do |txn|
        txn.inputs.each do |input|
          i = find_index(unspent_transactions, input[:source_hash])
          unspent_transactions.delete_at(i) if i
        end
        txn.outputs.each_with_index do |output, ind|
          if output[:address] == public_key_pem
            unspent_transactions << {source_hash: txn.hash, source_index: ind}
          end
        end
      end
    end
    unspent_transactions
  end

  def find_index(transactions, txn_hash)
    transactions.find_index do |transaction|
      transaction[:source_hash] == txn_hash
    end
  end

  def default_target
    "0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"
  end
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
  # def transaction_hash_valid?(transaction)
  #   hash_transaction(transaction) == transaction.txn_hash
  # end

  # @frequency ||= 120.0
  # @bounds ||= 1
  # @precision_level ||= 15
  # @coinbase_value ||= 25
end
