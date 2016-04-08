require "./lib/block_chain"
require './lib/wallet'
require './lib/server'

class Miner
  attr_reader :block_chain, :transactions, :connected_peers

  def initialize(options = {})
    @block_chain = options[:block_chain] || BlockChain.new
    @wallet = options[:wallet] || Wallet.new
    @digest = options[:digest] || OpenSSL::Digest::SHA256.new
    @port = options[:port] || 8334
    @transactions = []
    @threads = []
    @connected_peers = []
    @listen = Thread.new{ self.listen }
    self.mine unless options[:no_mining]
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
    @mining = Thread.new do
      loop { mine_new_block }
    end
  end

  def mine_new_block
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

  def transfer(amount, source_public_key, target_public_key)
    input_totals, inputs = block_chain.get_source_blocks(amount, public_key_pem)
    outputs = [{amount: amount, address: target_public_key}]
    outputs << {amount: input_totals - amount, address: source_public_key} if input_totals - amount > 0
    [inputs, outputs]
  end

  def listen
    puts "LISTENING"
    @mutex = Mutex.new
    Socket.tcp_server_loop(@port) do |conn, client_addrinfo|
      @threads << Thread.new do
        puts "Connection established: #{client_addrinfo.getnameinfo[0]}:#{client_addrinfo.getnameinfo[1]}"
        while input = conn.gets
          puts "RECEIVED: #{input.inspect}"
          break if input == "\n"
          parsed = JSON.parse(input.chomp, symbolize_names: true)
          if parsed[:message_type] == "echo"
            response = {response: parsed[:payload]}
            conn.write(response.to_json+"\n")
            puts "MESSAGE SENT #{response.to_json+"\n"}"
          elsif parsed[:message_type] == "chat"
            puts parsed[:payload]
          elsif parsed[:message_type] == "add_peer"
            @mutex.synchronize do
              connected_peers << parsed[:payload].to_i
            end
            response = {response: "Added port #{parsed[:payload]} to peer list!"}
            conn.write(response.to_json+"\n")
            puts "MESSAGE SENT #{response.to_json}"
          elsif parsed[:message_type] == "remove_peer"
            connected_peers.delete(parsed[:payload].to_i)
            response = {message_type: "remove_peer", payload: "Removed port #{parsed[:payload]} to peer list!"}
            conn.write(response.to_json+"\n")
          elsif parsed[:message_type] == "list_peers"
            response = {response: connected_peers}
            conn.write(response.to_json+"\n")
          elsif parsed[:message_type] == "get_height"
            response = {response: chain_height}
            conn.write(response.to_json+"\n")
          end
        end
        puts "Closing connection: #{client_addrinfo.getnameinfo[0]}:#{client_addrinfo.getnameinfo[1]}"
        conn.close
      end
    end
  end

  def close
    puts "WAITING ON: #{@threads.count} threads"
    @threads.each do |thread|
      thread.join
    end
    Thread.kill(@listen)
    @listen.join
    Thread.kill(@mining) if @mining
    puts "DONE"
  end

  private

  def wallet
    @wallet
  end

  def parent_hash
    return block_chain.last.hash if block_chain.last
    "0" * 64
  end

  def default_coinbase_amount
    25
  end

  def timestamp
    (Time.now.to_f* 1000).to_i
  end

  def generate_new_block
    headers = generate_headers
    txns = [coinbase] + transactions
    b = Block.new(headers, txns)
  end

  def generate_headers
    {parent_hash: parent_hash,
      target: block_chain.current_target,
      timestamp: timestamp,
      nonce: 0}
  end

  def coinbase
    Transaction.new([],[{amount: default_coinbase_amount, address: public_key_pem}])
  end
end
