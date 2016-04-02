require "./lib/server"
require "./lib/miner"

if __FILE__ == $0
  miner = Miner.new
  server = Server.new
  t1 = Thread.new{server.listen}
  t2 = Thread.new do
    5.times do |n|
      miner.mine
      ptime = rand(5)+1
      sleep(ptime)
      s = TCPSocket.new("localhost", 8334)
      s.write("New block (#{n}, #{ptime}): #{miner.latest_block_hash}" )
      s.close
    end
    s = TCPSocket.new("localhost", 8334)
    s.write("Quit")
    s.close
  end

  t1.join
  t2.join
  puts "End at #{Time.now}"
end
