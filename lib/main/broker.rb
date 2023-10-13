
class Broker
  def initialize
    @mqtt = []
    @channels = []
    @broker = PahoMqtt::Client.new()
  end
  def connect!
    @broker.on_message do |packet|
      w = packet.payload.split(' ');
      h = { topic: packet.topic, payload: packet.payload, words: w }
      @broker.each { |e| e.call(h) }
      puts %[[main][MQTT] #{h}]
    end
    @broker.connect(ENV['BROKER'] || 'localhost', 1883)
    @channels.each { |e| subscribe(e) }
  end
  def subscribe(ch)
    @broker.subscribe([ch, 0])
  end
  def channel ch
    @channels << ch
  end
  def mqtt &b
    @mqtt << b
  end
  def publish t, p
    @broker.publish(t, p, false, 0);
  end
end

BROKER = Broker.new
