require 'set'
require 'json'
require 'pstore'
require 'webrick'
require 'paho-mqtt'
require 'net-telnet'
require 'discordrb'
require 'serialport'
require 'hugging_face'
require 'open-weather-ruby-client'

module Z4
  def self.every n, &b
    Process.detach( fork do
                      loop do
                        b.call();
                        sleep(n);
                      end
                    end);
  end
end

require_relative 'main/broker'

require_relative 'main/db'

require_relative 'main/dev'

require_relative 'main/bingo'

require_relative 'main/match'

require_relative 'main/weather'

require_relative 'main/app'

require_relative 'main/logic'

require_relative 'main/ai'

require_relative 'main/bot'

require_relative 'main/init'

include Z4
