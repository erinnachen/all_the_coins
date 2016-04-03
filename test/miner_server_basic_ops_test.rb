require 'minitest'
require 'miner'

class MinerServerBasicOpsTest < Minitest::Test
  def setup
    @port = 8334
  end

  def test_miner_can_respond_to_multiple_echo_requests
    puts "ECHO TEST"
    miner = Miner.new(port: @port)
    3.times do |n|
      puts "SENDING REQUEST"
      s = TCPSocket.new("localhost", @port)
      message = {message_type: "echo", payload: "hi #{n}"}
      s.write(message.to_json+"\n\n")
      @response = s.read
      s.close
      puts @response
      assert_equal message, JSON.parse(@response.chomp, symbolize_names: true)
    end
    close_miner_down
    miner.close
  end

  def test_miner_can_respond_to_chat_requests
    puts "CHAT TEST"
    miner = Miner.new(port: @port)
    5.times do |n|
      puts "SENDING REQUEST"
      s = TCPSocket.new("localhost", @port)
      message = {message_type: "chat", payload: "hi #{n}"}
      s.write(message.to_json+"\n\n")
      s.close
    end
    close_miner_down
    miner.close
  end

  def test_miner_can_add_peer
    puts "ADD TEST"
    miner = Miner.new(port: @port)
    5.times do |n|
      s = TCPSocket.new("localhost", @port)
      message = {message_type: "add_peer", payload: 1245+n }
      s.write(message.to_json+"\n\n")
      response = s.read
      s.close
    end
    assert_equal miner.connected_peers, [1245, 1246, 1247, 1248, 1249]
    close_miner_down
    miner.close
  end

  def test_miner_can_remove_peer
    puts "REMOVE TEST"
    miner = Miner.new(port: @port)
    5.times do |n|
      s = TCPSocket.new("localhost", @port)
      message = {message_type: "add_peer", payload: 1245+n }
      s.write(message.to_json+"\n\n")
      response = s.read
      s.close
      puts "RESPONSE: #{response}"
    end
    assert_equal miner.connected_peers, [1245, 1246, 1247, 1248, 1249]

    s = TCPSocket.new("localhost", @port)
    message = {message_type: "remove_peer", payload: 1247}
    s.write(message.to_json+"\n\n")
    response = s.read
    puts "RESPONSE: #{response}"
    s.close
    assert_equal miner.connected_peers, [1245, 1246, 1248, 1249]

    close_miner_down
    miner.close
  end

  def test_miner_can_send_peer_list_in_valid_JSON
    miner = Miner.new(port: @port)
    5.times do |n|
      s = TCPSocket.new("localhost", @port)
      message = {message_type: "add_peer", payload: 1245+n }
      s.write(message.to_json+"\n\n")
      response = s.read
      s.close
      puts "RESPONSE: #{response}"
    end
    assert_equal miner.connected_peers, [1245, 1246, 1247, 1248, 1249]

    s = TCPSocket.new("localhost", @port)
    message = {message_type: "list_peers"}
    s.write(message.to_json+"\n\n")
    response = s.read
    puts "RESPONSE: #{response}"
    s.close
    assert_equal JSON.parse(response, symbolize_names: true), {message_type: "list_peers", payload: [1245, 1246, 1247, 1248, 1249]}
    close_miner_down
    miner.close
  end

  private

  def close_miner_down
    puts "Close down the miner"
    s = TCPSocket.new("localhost", @port)
    s.write("Quit")
    s.close
  end
end
