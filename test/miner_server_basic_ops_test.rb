require 'minitest'
require 'miner'

class MinerServerBasicOpsTest < Minitest::Test
  def setup
    puts "SETUP"
    @port = 8334
    @miner = Miner.new({port: @port, no_mining: true})
  end

  def teardown
    puts "TEARDOWN"
    @miner.close
  end

  def test_miner_can_respond_to_multiple_echo_requests
    puts "ECHO TEST"
    s = TCPSocket.new("localhost", @port)
    3.times do |n|
      puts "SENDING REQUEST #{n}\n"
      message = {message_type: "echo", payload: "hi #{n}"}
      s.write(message.to_json+"\n")
      response = s.gets
      puts "RESPONSE BACK: #{response.inspect}"
      parsed = JSON.parse(response.chomp, symbolize_names: true)
      assert_equal message[:payload], parsed[:response]
    end
    s.close
  end

  def test_miner_can_respond_to_multiple_clients
    puts "MULTIPLE CLIENTS TEST"

    s1 = TCPSocket.new("localhost", @port)
    s2 = TCPSocket.new("localhost", @port)
    message1 = {message_type: "echo", payload: "hi from s1"}
    s1.write(message1.to_json+"\n")
    message2 = {message_type: "echo", payload: "hi from s2"}
    s2.write(message2.to_json+"\n")
    response2 = s2.gets
    response1 = s1.gets
    s1.close
    s2.close

    parsed1 = JSON.parse(response1.chomp, symbolize_names: true)
    parsed2 = JSON.parse(response2.chomp, symbolize_names: true)
    assert_equal message1[:payload], parsed1[:response]
    assert_equal message2[:payload], parsed2[:response]
  end

  def test_miner_can_respond_to_chat_requests
    puts "CHAT TEST"
    5.times do |n|
      puts "SENDING REQUEST"
      s = TCPSocket.new("localhost", @port)
      message = {message_type: "chat", payload: "hi #{n}"}
      s.write(message.to_json+"\n\n")
    end
  end

  def test_miner_can_add_peer
    puts "ADD TEST"
    5.times do |n|
      s = TCPSocket.new("localhost", @port)
      message = {message_type: "add_peer", payload: 1245+n }
      s.write(message.to_json+"\n")
      response = s.gets
      s.close
    end
    assert_equal @miner.connected_peers, [1245, 1246, 1247, 1248, 1249]
  end

  def test_miner_can_remove_peer
    puts "REMOVE TEST"
    5.times do |n|
      s = TCPSocket.new("localhost", @port)
      message = {message_type: "add_peer", payload: 1245+n }
      s.write(message.to_json+"\n\n")
      response = s.read
      s.close
      puts "RESPONSE: #{response}"
    end
    assert_equal @miner.connected_peers, [1245, 1246, 1247, 1248, 1249]

    s = TCPSocket.new("localhost", @port)
    message = {message_type: "remove_peer", payload: 1247}
    s.write(message.to_json+"\n\n")
    response = s.read
    puts "RESPONSE: #{response}"
    s.close
    assert_equal @miner.connected_peers, [1245, 1246, 1248, 1249]
  end

  def test_miner_can_send_peer_list_in_valid_JSON
    puts "LIST PEERS TEST"
    s = TCPSocket.new("localhost", @port)
    5.times do |n|
      message = {message_type: "add_peer", payload: 1245+n }
      s.write(message.to_json+"\n")
      response = s.gets
      puts "RESPONSE: #{response}"
    end
    assert_equal @miner.connected_peers, [1245, 1246, 1247, 1248, 1249]

    message = {message_type: "list_peers"}
    s.write(message.to_json+"\n")
    response = s.gets
    puts "RESPONSE: #{response}"
    s.close
    assert_equal JSON.parse(response, symbolize_names: true), {response: [1245, 1246, 1247, 1248, 1249]}
  end

end
