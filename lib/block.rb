require 'bigdecimal'
require 'json'
require './lib/transaction'

class Block
  attr_reader :hash, :parent_hash, :timestamp,
              :target, :nonce, :transactions, :transactions_hash

  def initialize(headers, transactions)
    @parent_hash = headers[:parent_hash]
    @target = headers[:target]
    @timestamp = headers[:timestamp]
    @nonce = headers[:nonce]
    @transactions = transactions
    @transactions_hash = headers[:transactions_hash] || hash_transactions
    @hash = headers[:hash] || hash_block
  end

  def hashable_string
    "#{parent_hash}#{transactions_hash}#{timestamp}#{target}#{nonce}"
  end

  def self.from_json(json_block)
    block_params = JSON.parse(json_block, symbolize_names: true)
    Block.new(block_params[:header], Block.create_transactions(block_params[:transactions]))
  end

  def self.create_transactions(txns)
    txns.map do |txn|
      txn = JSON.parse(txn, symbolize_names: true) if txn.class == String
      Transaction.new(txn[:inputs], txn[:outputs], txn[:timestamp], txn[:hash])
    end
  end

  def transactions_string
    transactions.map { |txn| txn.hash }.join
  end

  def increment_nonce
    @nonce += 1
  end

  def hash_block
    @hash = Digest::SHA256.hexdigest(hashable_string)
  end

  def hash_transactions
    self.transactions_hash = Digest::SHA256.hexdigest(transactions_string)
  end

  def to_json
    block = { header: generate_headers,
              transactions: transactions.map {|txn| txn.to_json }
            }
    block.to_json
  end

  private
    def generate_headers
      {parent_hash: parent_hash,
       transactions_hash: transactions_hash,
       target: target,
       timestamp: timestamp,
       nonce: nonce,
       hash: hash}
    end
end
