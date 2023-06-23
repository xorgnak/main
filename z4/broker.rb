# example handlers
Z4.topic(:time) do |params|
  puts "TIME: #{params}"
end

Z4.action(:'time-echo') do |params|
  puts "ECHO: #{params}"
end
