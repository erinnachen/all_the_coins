require "socket"
require "json"

class Server
  attr_reader :port
  def initialize(port = nil)
    @port = port || 8334
  end

  def listen
    Socket.tcp_server_loop(port) do |conn, client_addrinfo|
      t1 = Thread.new do
        input = conn.gets
        if input == "Quit"
          puts "QUITTING"
          conn.close
          break
        end
        puts "MESSAGE RECEIVED"
        parsed = JSON.parse(input.chomp, symbolize_names: true)
        if parsed[:message_type] == "echo"
          response = parsed
          conn.write(response.to_json+"\n\n")
          puts "MESSAGE SENT"
        elsif parsed[:message_type] == "chat"
          puts parsed[:payload]
        elsif parsed[:message_type] == "add_peer"
          binding.pry
          conn.write(response.to_json+"\n\n")
          puts "MESSAGE SENT"
        end
        conn.close
      end
    end
  end
end

if __FILE__ == $0
  server = Server.new(ARGV[0])
  server.listen
end
