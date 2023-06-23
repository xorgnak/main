
class Broker
  def initialize h={}, b
    @b = PahoMqtt::Client.new()
    @b.on_message do |packet|
      b.call(packet)
    end
    @b.connect(h[:host] || 'localhost', h[:port] || 1883)
    @b.subscribe(['#', 0])
  end
  def publish t, p
    @b.publish(t, p, false, 1);
  end
end

module BROKER
  def self.begin h={}, &b
    @@B = Broker.new h, b
  end
  def self.emit t, p
    @@B.publish(t,p)
  end
  def self.client
    @@B.client
  end
end

BROKER.begin do |pkt|
  w = pkt.payload.split(' ');
  h = { topic: pkt.topic, payload: pkt.payload, words: w }
  if Z4.topics.keys.include? pkt.topic
    Z4.topic(pkt.topic, h)
    t = "#{pkt.topic}-#{w[0].downcase}"
    if Z4.actions.keys.include? t
      Z4.action(t, h)
    end
  end
end

module Z4
  ##
  # publish a +payload+ to a +topic+
  def self.emit h={}
    BROKER.emit(h[:topic], h[:payload])
  end
end
