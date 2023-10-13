
class ICB
  def initialize h={}, &b
    @opts = h
    @opts[:host] = h[:host] || "127.0.0.1"
    @server = Server.new(h) do |server, addr, pkt|
      if block_given?
        b.call(server,addr,pkt);
      end
      puts %[[SERVER] #{pkt}\n]
    end
    puts %[[z4][SERVER] running on port #{h[:port]}]
    @client = TCPSocket.new(@opts[:host],@opts[:port])
  end
  
  def server
    @server
  end
  def client
    @client
  end
  
  def send p
    @client.puts(p)
    return @client.gets.chomp!
  end

  def << i
    send(i)
  end

  class PKT
    def initialize pkt
      @content = pkt[0];
      @protocol = pkt[1][0];
      @port = pkt[1][1];
      @from = pkt[1][2];
      @dest = pkt[1][3];
    end
    def protocol
      @protocol
    end
    def port
      @port
    end
    def from
      @from
    end
    def dest
      @dest
    end
    def content
      @content
    end
  end
  
  class Server
    def initialize h={}, &b
      @handle = b
      @buffer = Hash.new { |h,k| h[k] = [] }
      @client = {}
      @time = 0;
      @tok = Array.new(16,0).join('')
      @token = {}
      server = TCPServer.new h[:port]
      Process.detach( fork {
                        loop do
                          Thread.start(server.accept) do |client|
                            @addr = client.addr[-1]
                            @client[@addr] = client
                            client.puts "OK #{Time.now} #{@addr} #{client}"
                            puts %[[SERVER] OK #{Time.now} #{@addr} #{client}\r]
                            fork {
                              while input = client.gets
                                tk = []; 16.times { tk << rand(16).to_s(16) }
                                @tok = tk.join('');
                                @token[@addr] = @tok
                                r = @handle.call(self, @addr, input)
                                wall(r)
                              end
                              client.close
                            }
                          end
                        end
                      })
    end
    def msg u, m
      @client[u].puts "#{m}\r"
    end
    def wall m
      @client.each_pair { |k,v| msg(k,m) }
    end
  end
end

class Icb
  def initialize n, u, *t
    @from = u
    @node = n
    [t].flatten.each { |e| BROKER.channel("/icb/#{e}"); }
  end
  def publish t, i
    BROKER.publish t,i
  end
end

@n = ICB.new(port: 4913) do |node, addr, pkt|
  puts "[z4][#{addr}] #{pkt}\n"
  
end

BROKER.mqtt do |h|
  puts @n.send("[broker] #{@icb} #{h}");
end
