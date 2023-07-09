
BROKER = PahoMqtt::Client.new()
BROKER.on_message do |packet|
  w = packet.payload.split(' ');
  h = { topic: packet.topic, payload: packet.payload, words: w }


  
#  puts %[[MQTT] #{h}]
end
BROKER.connect(ENV['BROKER'] || 'localhost', 1883)
BROKER.subscribe(['#', 0])

def publish t, p
  BROKER.publish(t, p, false, 1);
end

module Z4
  ##
  # publish a +payload+ to a +topic+
  def self.emit h={}
    publish(h[:topic], h[:payload])
  end
end
