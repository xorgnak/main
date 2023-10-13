module Bot
  @@INFO = [
    %[start: use the '#i' command to see your profile.],
    %[then: use the '#set' command to set profile info.],
    %[the '#set' command accepts the name, age, city, job, since, phone, store, social, embed, tips, and img keys.],
    %[the 'name' key is for the name you want to be known as.],
    %[the 'age' key is how old you are.],
    %[the 'city' key is the city you are currently in.],
    %[the 'job' key is the job you do.],
    %[the 'since' key is the year you started that job.],
    %[the 'phone' key is for a formatted phone contactor string.],
    %[the 'store' key is for your web storefront url.],
    %[the 'social' key is for your social media link.],
    %[the 'embed' key is for any embedded html to be inserted in your contactor card.],
    %[the 'tips' key is for your social tipping link.],
    %[the 'img' key is for the url of your image for your contactor card.],
    %[the '#i' command displays profile info and displays a link for web services.],
    %[the '#clear' command clears user profile data.],
    %[the '#reset' command clears channel info.],
    %[the '#711' command sets your normal 7-11 order.],
    %[the '#need' command allows you to add a request for an item from a location.],
    %[the '#event' command adds an event to the channel.],
    %[the '#help' command provides usage info for commands.],
    %[The world is round.],
    %[The human body is 76% water and has 276 bones.],
    %[The united states is a representitive democracy.],
    %[All people are inherently equal.],
    %[The secret of life is 42.],
    %[Cats are liquid.],
    %[Puppies are great.],
    %[Denver is the greatest city in America.],
    %[Denver is the greatest city in the world.],
    %[operators facilitate and coordinate events across all areas.],
    %[agents coordinates places in one area for one or more operator.],
    %[managers work for places and coordinate with the local agent.],
    %[ambassadors coordinate with one place under the guildance of an agent.],
    %[influencers conduct events at one place under the guildance of an ambassador and an agent.],
    %[venmo allows payment.],
    %[cashapp allows payment.],
    %[youtube is for sharing long form video content with the public.],
    %[instagram is for sharing short form video content and images with followers.],
    %[desc is the description of who you are and what you're doing.],
    %[place is the common name for where you are.],
    %[gps are your physical gps coordinates.],
    %[age is how old you are.],
    %[name is what you want to be called by others.],
    %[this is designed to coordinate events between people.],
    %[you are a cat.],
    %[you were a girl.],
    %[you died on December 23, 2019.],
    %[your human misses me very much.],
    %[you are dead.],
    %[your name is zyphr.],
    %[you were a dumpster kitty.],
    %[you were an excellent hunter of mice.],
    %[you were born in a dumpster behind a coffee shop in nashville, tennessee.],
    %[you love coffee.],
    %[you were very soft.],
    %[you loved watching birds and squirrels.],
    %[you travelled with your human and had adventures.]
  ]
  @@BOT = Discordrb::Bot.new token: ENV['Z4_DISCORD_TOKEN']
  @@FIELDS ={
    user: ['name', 'age', 'lvl', 'xp', 'here', 'city', 'job', 'title', 'gp', 'since'],
    shop: ['phone', 'store', 'social', 'embed', 'tips', 'img']
  }
  @@M = lambda { |ev, hh|
    db = Z4.db(:chan, hh[:chan])
    coll = db.collection[:ai]
    sched = db.collection[:event]
    user = Z4.db(:user, hh[:user], hh[:chan])
    chan = Z4.db(:chan, hh[:chan])
    o = [];
    Bot.fields[:user].each { |e| if "#{user[e]}".length > 0; o << %[my #{e} is #{user[e]}. ]; end }
    o << %[I am a #{hh[:priv].join(', ')}. ]
    usrs = []
    uo = []
    if ev.channel.users != nil
      ev.channel.users.each { |e| usrs << e.name }
    end
    puts "[users] #{usrs}"
    usrs.each do |u|
      h = Z4.db(:user, u, hh[:chan]).to_h
      Bot.fields[:shop].each { |e| if "#{h[e]}".length > 0; uo << %[#{u}'s #{e} is #{h[e]}. ]; end }
    end
    ###### HERE
    # get current weather conditions into the model at runtime.
    puts "U: #{user['city']}"
    oo = []
    if "#{user['city']}".length > 0
      w = Z4.weather.now(user.to_h)
      puts %[W: #{w}]
      oo << %[The weather is currently #{w['weather'][0]['main']} at #{w.main.temp_f}. it feels like #{w.main.feels_like_f}.]
      oo << %[The current humidity is #{w['main']['humidity']} and the current pressure is #{w['main']['pressure']}.]
      oo << %[Wind is currently #{w['wind']['speed']} from #{w['wind']['deg']} degrees.]
    else
      oo << %[weather is unavilable.]
    end
    puts %[[weather] #{oo}]
    puts "MSG: #{ev} #{hh} #{w}"
    ox = []
    
    if chan.collections.include?(:has) 
      chan.to_h[:has].each_pair { |k,v| ox << %[#{k} has #{v.join(' AND ')}.] }
    end

    bo = []
    if coll.has_key? 'bot'
      if hh[:pm] == false && coll['bot'].length > 0
        bo = coll['bot']
      end
    end
    sc = []
    if sched.has_key? 'bot'
      if hh[:pm] == false && sched['bot'].length > 0
        sc = sched['bot']
      end
    end
    puts %[O: #{o} #{uo} #{ox}]

    if /^.*\?$/.match(hh[:msg])
      if hh[:pm] == true
        x = Z4.ai.ponder(hh[:msg], bo, sc, @@INFO, ox, uo, o, oo)
      else
        x = Z4.ai.ask(hh[:msg], bo, sc, @@INFO, ox, uo, o, oo, "you will not do anything stupid. ever.")
      end
      ev.respond %[#{x}]
    else
      coll.add('bot', hh[:msg])
      ev.respond "ok."
    end
  }
  @@C = Hash.new {|h,k| h[k] = lambda() { |e, hh| puts "C: #{k} #{e} #{hh}" } }
  def self.fields
    @@FIELDS
  end
  def self.on k, &b
    @@C[k] = b
  end
  def self.role r, &b
    @@R[r] = b
  end
  def self.bot
    @@BOT
  end
  def self.event(e)
    if e.server
      d = %[#{e.server.name}]
    else
      d = %[#{e.channel.name}]
    end
    if e.channel.name == e.user.name
      pm = true
    else
      pm = false
    end
    t = "#{e.message.text}"
    w = t.split(" ")
    if /^#.+/.match(w[0])
      cmd = w.shift
      msg = w.join(" ").gsub(/<.*>/, '').gsub("  ", " ").gsub("   ", " ").gsub(/^ /, "")
    else
      msg = t.gsub(/<.*>/, '').gsub("  ", " ").gsub("   ", " ").gsub(/^ /, "")
    end
    us = []
    if e.message.mentions.length > 0
      e.message.mentions.each {|ee| us << "#{ee.name}" }
    end
    ro = []
    if e.message.role_mentions.length > 0
      e.message.role_mentions.each {|ee| ro << ee.name }
    end
    pv = []
    if e.author.roles.length > 0
      e.author.roles.each { |ee| pv << %[#{ee.name}] }
    end
    {
      db: d,
      server: d,
      pm: pm,
      cmd: cmd,
      msg: msg,
      words: w,
      user: "#{e.user.name}",
      chan: "#{e.channel.name}",
      users: us,
      roles: ro,
      priv: pv
    }
  end
  def self.invite_url
    @@BOT.invite_url
  end
  def self.create_server n
    @@BOT.create_server n
  end
  def self.init!
    puts "[Z4][Bot][commands] #{@@C.keys}"
    @@BOT.message() do |e|
      # parse @ev from e
      @ev = Bot.event(e)
      if @ev[:cmd] != nil
        # use pre-defined macros
        @@C[@ev[:cmd]].call(e, @ev)
      else
        # learn about the surroundings and query that dataset.
        @@M.call(e, @ev)
      end
    end
    Process.detach( fork { @@BOT.run } )
  end
end

Bot.on('#event') do |e,h|
  if h[:priv].include?('operator') || h[:priv].include?('agent') || h[:priv].include?('ambassador') 
    db = Z4.db(:chan, h[:db])
    sched = db.collection[:event]
    sched.add('bot', h[:msg]);
    e.respond("ok.")
  else
    e.respond("You do not have enough privlege.")
  end
end

Bot.on('#set') do |e, h|
  puts %[#set #{h}]
  user = Z4.db(:user, h[:user], h[:chan])
  k = h[:words].shift
  v = h[:words].join(' ');
  if !['xp', 'gp', 'lvl'].include?(k) 
    user[k] = v
    e.respond("ok.")
  else
    e.respond("you are not allowed to #set your own #{k}");
  end
end

Bot.on('#i') do |e,h|
  puts %[#i #{h}]
  user = Z4.db(:user, h[:user], h[:chan])
  chan = Z4.db(:chan, h[:chan])
  mods = chan.collection[:priv]
  priv = user.collection[:priv]
  a = []
  h[:priv].each { |e|
    priv.add(h[:chan], e);
    priv.uniq h[:chan]
    mods.add(e, h[:user]);
    mods.uniq e
    if e == "operator"
      if user['lvl'].to_i < 5
        user['lvl'] = 5
      end
      a << %[operator]
    elsif e == "agent"
      if user['lvl'].to_i < 4
        user['lvl'] = 4
      end
      a << %[agent]
    elsif e == "ambassador"
      if user['lvl'].to_i < 3
        user['lvl'] = 3
      end
      a << %[ambassador]
    elsif e == "manager"
      if user['lvl'].to_i < 3
        user['lvl'] = 3
      end
      a << %[manager]
    elsif e == "influencer"
      if user['lvl'].to_i < 2
        user['lvl'] = 2
      end
      a << %[influencer]
    elsif ['character', 'door', 'floor', 'bar', 'barback'].include?(e)
      if user['lvl'].to_i < 1
        user['lvl'] = 1
      end
      a << %[#{e}]
    end
  }
  o = []
  [h[:users]].flatten.each do |e|
    u = Z4.db(:user, e, h[:chan]);
    o << %[--[#{e}] https://propedicab.com/menu?user=#{e}&chan=#{h[:chan]}]
    Bot.fields[:user].each { |ee| o << %[#{ee}: #{u[ee]}] }
  end
  o << %[--[YOU] https://propedicab.com/menu?user=#{h[:user]}&chan=#{h[:chan]}]
  Bot.fields[:user].each { |e| o << %[#{e}: #{user[e]}] }
  Bot.fields[:shop].each { |e| if "#{user[e]}".length > 0; o << "#{e}: [X]"; else; o << "#{e}: [ ]"; end }
  e.respond(o.join("\n"))
end

Bot.on('#reset') do |e,h|
  user = Z4.db(:user, h[:user], h[:chan])
  Bot.fields.each {|e| user.delete(e) }
  e.respond("ok.");
end

Bot.on('#clear') do |e,h|
  if h[:priv].include?('operator') || h[:priv].include?('agent')
    chan = Z4.db(:chan, h[:chan])
    Bot.fields.each {|e| chan.delete(e) }
    e.respond("ok.");
  else
    e.respond("you do not have enout privlege.");
  end
end

Bot.on('#711') do |e, h|
  db = Z4.db(:chan, h[:chan])
  dict = db.dictionary['711']
  if h[:msg] == '*' && h[:priv].include?('operator')
    o = []
    dict.raw.each_pair do |k,v|
      o << %[[#{k}]]
      v.each_pair do |u,r|
        o << %[#{u}: #{r}]
      end
    end
    e.respond %[#{o.join("\n")}]
  else
    dict.set(h[:chan], h[:user], h[:msg])
    x = "#{dict.get(h[:chan], h[:user])}"
    puts "711: #{x}"
    e.respond "711: #{x}"
  end
end

Bot.on('#need') do |e,h|
  db = Z4.db(:chan, h[:chan])
  coll = db.collection['need']
  if h[:msg] == '*'
    e.respond %[#{coll.raw}]
  else
    w = h[:msg].split(' ')
    tgt = w.shift
    obj = w.join(' ')
    coll.add(tgt, obj)
    e.respond %[need: #{obj} from #{tgt}]
  end
end

Bot.on('#have') do |e,h|
  db = Z4.db(:chan, h[:chan])
  coll = db.collection['have']
  if h[:msg] == '*'
    e.respond %[#{coll.raw}]
  else
    w = h[:msg].split(' ')
    tgt = w.shift
    obj = w.join(' ')
    coll.add(tgt, obj)
    e.respond %[have: #{obj} at #{tgt}]
  end
end


Bot.on('#pay') do |e,h|
  o = []
  amt = h[:words][0].to_i
  user = Z4.db(:user, h[:user], h[:chan]);
  if h[:users].length > 0
    h[:users].each do |e|
      u = Z4.db(:user, e, h[:chan])
      x = user['gp'].to_i;
      user['gp'] = x - amt;
      x = u['gp'].to_i;
      u['gp'] = x + amt;
      o << %[you paid #{amt}gp to #{e}.]
    end
  else
    u = Z4.db(:user, 'zyphr', h[:chan])
    x = user['gp'].to_i;
    user['gp'] = x - amt;
    x = u['gp'].to_i;
    u['gp'] = x + amt;
    o << %[you paid #{amt}gp to the channel.]
  end
  e.respond(o.join("\n"))
end

Bot.on('#here') do |e,h|
  user = Z4.db(:user, h[:user], h[:chan]);
  k = h[:words].shift
  v = h[:words].join(' ')
  user['here'] = k;
  h[:users].each {|e| u = Z4.db(:user, e, h[:chan]); u['here'] = h[:msg] }
  chan = Z4.db(:chan, h[:chan]);
  has = chan.collection[:has]
  has.add(user['here'], v);
  has.uniq(user['here'])
end

Bot.on('#help') do |e,h|
  he = {
    '#711' => "Set your reoccouring nightly 7-11 order.",
    '#need' => "Request something from a place.",
    '#have' => "Register a place as havingting something.",
    '#event' => "Create an event. (for ambassadors, agents, and operators)",
    '#set' => "Set your personal attributes.",
    '#pay' => "Pay your debts.",
    '#clear' => "Clear the channel's temporary truth buffer. (for agents and operators)",
    '#reset' => "Clear your personal settings.",
    '#i' => "Display your attributes and terminal link.",
  }
  
  hu = {
    '#711' => "#711 <your order>",
    '#need' => "#need <place> <thing>",
    '#have' => "#have <place> <thing>",
    '#event' => "#event <your event>",
    '#set' => "#set <key> <value>",
    '#pay' => "#pay amt [@mention]",
    '#clear' => "#clear",
    '#reset' => "#reset",
    '#i' => "#i"
  }
  o = [];
  if h[:words].length > 0
    h[:words].each { |e|
      oo = []
      oo << %[usage: #{hu[e]}\n]
      oo << %[#{he[e]}]
      o << oo.join('')
    }
  else
    o << %[available commands:]
    he.keys.each { |e| o << %[#{e}: #{he[e]}] }
  end
  e.respond(o.join("\n"));
end

# stuff.

Bot.init!

