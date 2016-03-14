require "./lib/block"
class BlockChain
  attr_accessor :current_block, :frequency, :bounds, :precision_level, :coinbase_value

  def initialize
    @chain = []
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

  def first
    chain.first
  end

  def last
    chain.last
  end

  def height
    chain.count
  end

  def get_balance(public_key_pem)
    unspent_transactions = []
    chain.each do |block|
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

    unspent_transactions.reduce(0) do |sum, unspent|
      sum + find_transaction(unspent[:source_hash]).outputs[unspent[:source_index]][:amount]
    end
  end

  def get_source_blocks(amount, public_key_pem)
    unspent_transactions = []
    chain.each do |block|
      block.transactions.each do |txn|
        if txn.coinbase? && txn.outputs.first[:address] == public_key_pem
          unspent_transactions << {source_hash: txn.hash, source_index: 0}
        end
      end
    end
    i = 0
    txn_amount = 0
    unspent_transactions.each do |txn|
      txn_amount += find_transaction(txn[:source_hash]).outputs[txn[:source_index]][:amount]
      break if txn_amount >= amount
      i += 1
    end
    unspent_transactions[0..i]
  end

  def find_transaction(txn_hash)
    chain.each do |block|
      txn = block.transactions.find do |txn|
        txn.hash == txn_hash
      end
      return txn if txn
    end
    nil
  end

  def find_index(transactions, txn_hash)
    transactions.find_index do |transaction|
      transaction[:source_hash] == txn_hash
    end
  end

private
  def chain
    @chain
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
