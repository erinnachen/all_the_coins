require 'minitest'
require 'miner'

class MinerServerTest < Minitest::Test
  def setup
    @port = 8334
  end

  def test_miner_can_respond_to_an_echo
    miner = Miner.new(port: @port)
    t1 = Thread.new { miner.listen }
    puts "SENDING REQUEST"
    t2 = Thread.new do |message|
      s = TCPSocket.new("localhost", @port)
      message = {message_type: "echo", payload: "hi again"}
      s.write(message.to_json+"\n\n")
      @response = s.read
      s.close
    end
    puts @response
    t2.join
    close_miner_down
    t1.join
    message = {message_type: "echo", payload: "hi again"}
    assert_equal message, JSON.parse(@response.chomp, symbolize_names: true)
  end

  private

  def close_miner_down
    puts "Close down the miner"
    s = TCPSocket.new("localhost", @port)
    s.write("Quit")
    s.close
  end
end
