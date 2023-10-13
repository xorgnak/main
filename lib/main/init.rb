## start everything
if File.exist? "z4/init.rb"
  load "z4/init.rb"
  BROKER.connect!
end
