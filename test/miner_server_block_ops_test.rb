require 'minitest'
require 'miner'

class MinerServerBlockOpsTest < Minitest::Test
  def setup
    puts "SETUP"
    @port = 8334
    @miner = Miner.new(port: @port, mine: false)
  end

  def teardown
    puts "TEARING DOWN"
    @miner.close
  end

  def test_can_get_height_of_miner_block_chain
    s = TCPSocket.new("localhost", @port)
    message = {message_type: "get_height"}
    s.write(message.to_json+"\n")
    response = s.gets
    puts "RESPONSE: #{response}"
    s.close
    parsed = JSON.parse(response.chomp, symbolize_names: true)[:response]
    assert_equal parsed, 0
  end
end
