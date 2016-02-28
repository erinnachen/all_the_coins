require 'bigdecimal'
require 'json'
require 'transaction'

class Block
  attr_accessor :hash, :parent_hash, :timestamp,
                :target, :nonce, :transactions, :transactions_hash

  def initialize(headers, transactions)
    headers.each do |key, value|
      send("#{key}=", value)
    end
    self.transactions = Block.create_transactions(transactions)
  end

  def hashable_string
    "#{parent_hash}#{transactions_hash}#{timestamp}#{target}#{nonce}"
  end

  def self.from_json(json_block)
    block_params = JSON.parse(json_block, symbolize_names: true)
    Block.new(block_params[:header], block_params[:transactions])
  end

  def self.create_transactions(txns)
    txns.map do |txn|
      Transaction.new(txn[:inputs], txn[:outputs], txn[:timestamp])
    end
  end

  def rehash_block
    self.hash = Digest::SHA256.hexdigest(hashable_string)
  end
  # attr_reader :transactions, :block_hash, :trans_hash, :parent_hash, :block_chain
  # attr_accessor :nonce, :timestamp, :target, :frequency
  #
  # def initialize(parent_hash, transactions, block_chain, opt_inputs = {})
  #   @transactions = transactions
  #   @parent_hash = parent_hash
  #   @block_chain = block_chain
  #   opt_inputs.each do |key, value|
  #     send("#{key}=", value)
  #   end
  #   @nonce ||= 0
  #   @timestamp ||= (Time.now.to_f* 1000).to_i
  #   @frequency ||= 120.0
  #   @target ||= get_target
  #
  #   set_trans_hash
  #   set_block_hash
  # end
  #
  # def set_trans_hash
  #   trans_to_hash = transactions.map {|trans| trans.txn_hash}.join
  #   @trans_hash = Digest::SHA256.hexdigest(trans_to_hash)
  # end
  #
  # def set_block_hash
  #   block_to_hash = "#{parent_hash}#{trans_hash}#{timestamp}#{target}#{nonce}"
  #   @block_hash = Digest::SHA256.hexdigest(block_to_hash)
  # end
  #
  # def get_target
  #   return "0000100000000000000000000000000000000000000000000000000000000000" if block_zero? || timestamps.length == 1
  #   separations = timestamps.each_cons(2).map { |a,b| b-a }
  #   avg_sep = separations.reduce(0,:+)/(separations.length.to_f)
  #   factor = avg_sep / frequency
  #   target = BigDecimal.new(factor*block_chain.find(parent_hash).target.to_i(16), 16)
  #   target.to_i.to_s(16).rjust(64,'0')
  # end
  #
  # def timestamps
  #   block_chain.last_timestamps.last(10)
  # end
  #
  # def work
  #   until block_hash.hex < target.hex do
  #     self.nonce += 1
  #     set_block_hash
  #   end
  # end
  #
  # def to_json
  #   bout = {"header"=> generate_headers,
  #           "transactions"=>transactions.map {|trans| trans.to_json} }
  #   JSON.generate(bout)
  # end
  #
  # def generate_headers
  #   {"parent_hash" => parent_hash,
  #    "transactions_hash" => trans_hash,
  #    "target" => target,
  #    "timestamp" => timestamp,
  #    "nonce" => nonce,
  #    "hash" => block_hash}
  # end

# private
#   def set_optional_inputs(opt_inputs)
#     opt_inputs.each do |key, value|
#       send("#{key}=", value)
#     end
#   end

end
