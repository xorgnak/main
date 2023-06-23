
module Z4
  @@ACTIONS = {}
  ##
  # create a response to a +keyword+.
  def self.action k, h={}, &v
    if block_given?
      @@ACTIONS[k.to_s] = v
    else
      @@ACTIONS[k.to_s].call(h)
    end
  end
  def self.actions
    @@ACTIONS
  end
  
  @@TOPICS = {}
  ##
  # handle traffic within a topic
  def self.topic k, h={}, &v
    if block_given?
      @@TOPICS[k.to_s] = v
    else
      @@TOPICS[k.to_s].call(h)
    end
  end
  def topics
    @@TOPICS
  end
end

if File.exist? "z4/logic.rb"
  load "z4/logic.rb"
end

