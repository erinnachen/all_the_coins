require "./lib/block_chain"
class Miner
  attr_reader :block_chain

  def initialize(options = {})
    @block_chain = options[:block_chain] || BlockChain.new
    @wallet = options[:wallet] || Wallet.new
    @digest = options[:digest] || OpenSSL::Digest::SHA256.new
    #@protocol = options[:protocol] || default_protocol
  end

  def chain_height
    block_chain.height
  end

  def public_key_pem
    wallet.public_key.to_pem
  end

  def latest_block_hash
    block_chain.last.hash
  end

  def read_block_chain(raw_data)
    @block_chain= BlockChain.from_json(raw_data)
  end

  def mine
    new_block = generate_new_block
    new_block.hash_block
    until new_block.target.hex > new_block.hash.hex
      new_block.increment_nonce
      new_block.hash_block
    end
    block_chain.add(new_block)
  end

  def get_balance(public_key_pem)
    block_chain.get_balance(public_key_pem)
  end

  private

  def wallet
    @wallet
  end

  def parent_hash
    return block_chain.last.hash if block_chain.last
    "0" * 64
  end

  def default_target
    "0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"
  end

  def default_coinbase_amount
    25
  end

  def timestamp
    (Time.now.to_f* 1000).to_i
  end

  def generate_new_block
    headers = generate_headers
    transactions = [coinbase]
    b = Block.new(headers, transactions)
  end

  def generate_headers
    {parent_hash: parent_hash,
      target: default_target,
      timestamp: timestamp,
      nonce: 0}
  end

  def coinbase
    {inputs:[],
      outputs:[{amount: default_coinbase_amount, address: public_key_pem}],
      timestamp: timestamp}
  end


end
