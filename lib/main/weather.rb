class Weather
  def initialize
    @client = OpenWeather::Client.new(api_key: ENV['OPENWEATHER_API_KEY'], user_agent: "z4 framework.")
  end
  def now h={}
    @client.current_weather(h)
  end
end

module Z4
  @@WEATHER = Weather.new
  def self.weather
    @@WEATHER
  end
end
