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
    block_chain.latest.hash
  end

  def read_block_chain(raw_data)
    @block_chain= BlockChain.from_json(raw_data)
  end

  def mine
    # generate_new_block
    new_block = generate_new_block
    # generate_headers
    # generate_coinbase
    # while target.hex > block.hash.hex
    # change nonce in block
    # rehash
    # end
    block_chain.add(new_block)
  end


  private

  def wallet
    @wallet
  end

  def default_parent_hash
    "d5a8ad8149c6e557c94f3cd49c1d13ad4f2c473aea6f97d730283dd1ac1d99c4"
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
    transactions = coinbase
    b = Block.new(headers, transactions)
  end

  def generate_headers
    headers = {parent_hash: default_parent_hash,
      transactions_hash: "TT",
      target: default_target,
      timestamp: timestamp,
      nonce: 0,
      hash: "0"}
  end

  def generate_coinbase
    [{inputs:[],
      outputs:[{amount: default_coinbase_amount, address: public_key_pem}],
      timestamp: timestamp}]
  end


end
