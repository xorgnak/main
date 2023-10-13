
class Dev
  def initialize d
    @rt = false
    @pipe = false
    @buf = "";
    @d = d
    @prog = []
    Process.detach( fork { loop { puts @d.readline } })
  end
  # interactive?
  def rt= s
    @rt = s
  end

  # store?
  def pipe= s
    @pipe = s
  end

  # prog builder
  def repl!
    if @rt == true
      self.<< @buf
    end
    if @pipe == true
      @prog << @buf
    end
    b = @buf;
    @buf = "";
    return b
  end

  # dump prog into buffer
  def run!
    self.<< @prog
  end

  # prog object
  def prog
    @prog
  end

  # buffer pipe to output
  def raw i
    o = []
    [i].flatten.each { |e| o << %[#{e}] }
    return o.join("")
  end
  
  # buffer pipe
  def << i
    [i].flatten.each { |e| @d.write(%[#{e}\n\r]); }
  end
  
  # time offset generator
  def t h={}
    tt = 0
    tt += h[:ms].to_i
    tt += h[:s].to_i * 1000
    tt += h[:m].to_i * (60 * 1000)
    tt += h[:h].to_i * (60 * (60 * 1000))
    return tt
  end

  # system tool
  def me *n
    if n[0]
      @buf = %[me(#{n[0]});]
    else
      @buf = %[me(0);] 
    end
    repl!
  end

  # fork event; pool by timer
  def spawn e, *t
    if t[0]
      tt = t[0]
    else
      tt = 0
    end      
    if e.class == Symbol
      ee = "'/#{e}'"
    else
      ee = "'#{e}'"
    end
    @buf = %[spawn(#{ee},#{tt});]
    repl!
  end
  
  # event reader
  def cat e, *t
    if t[0]
      tt = ", '#{t[0]}'"
    else
      tt = ''
    end
    if e.class == Symbol
      @buf = %[cat('/#{e}'#{tt});]
    else
      @buf = %[cat('#{e}'#{tt});]
    end
    repl!
  end

  # print wrapper
  def meow i, *n
    if n[0]
      nn = n[0];
    else
      nn = 0;
    end
    if i.class == Symbol
      @buf = %[meow(#{i},#{nn});];
    else
      @buf = %[meow('#{i}',#{nn});];
    end
    repl!
  end
  
  # setTimeout
  def at t, c
    @buf = %[at(#{t},"#{c}");]
    repl!
  end

  # set and trigger events
  def on ev, *b
    if ev.class == Symbol
      evv = %['/#{ev}']
    else
      evv = %['#{ev}']
    end
    if b[0]
      @buf = %[on(#{evv},"#{b[0]}");]
    else
      @buf = %[on(#{evv});]
    end
    repl!
  end
  
  # list events and collections
  def ls *c
    if c[0]
      if c[0].class == Symbol
        evv = %['/#{c[0]}']
      else
        evv = %['#{c[0]}']
      end
      @buf = %[ls(#{evv});];
    else
      @buf = %[ls();];
    end
    repl!
  end
  
  # network manager
  def nm m, *a
    if a[0]
      ssid = %[,'#{a[0]}']
    else
      ssid = %[]
    end
    if a[1]
      pwd = %[,'#{a[1]}']
    else
      pwd = %[]
    end
    @buf = %[nm(#{m}#{ssid}#{pwd});]
    repl!
  end
  
  # ok state
  def ok!
    @buf = %[ok();\n\r];
    repl!
  end
  
  # hi event
  def hi!
    @buf = %[hi();\n\r];
    repl!
  end
end


class DevProg
  def initialize d
    @dev = d
    # cmd; cmd; cmd;
    @buf = []
    # event => cmd; cmd; cmd;
    @es = Hash.new { |h,k| h[k] = [] }
  end

  def buffer
    @buf
  end
  def events
    @es
  end
  
  # raw event getter and setter
  def [] k
    @es[k].join(" ")
  end
  def []= k,v
    @es[k] = v
  end

  # dump buffer to event
  def event e
    @es[e] = @buf
    @buf = []
  end

  # access to underlying device object
  def cmd
    @dev
  end

  # append cmd to buffer
  def << i
    @buf << i 
  end

  # write program to device
  def write!
    @dev.rt = true
    @es.each_pair { |k,v| @dev.on(k,v.join(" ")) }
    @dev << %[ok();]
    @dev.rt = false
  end
end

Dir['/dev/ttyUSB*'].each { |e|
  if d = SerialPort.new(e, 115200, 8, 1, SerialPort::NONE);
    puts "[DEV] #{e}"
    @dev = DevProg.new(Dev.new(d))
  end
}

if @dev

@dev[:info] = [ @dev.cmd.me(1), @dev.cmd.me(2), @dev.cmd.me(3), @dev.cmd.raw(%[meow('net: ' .. net);]), @dev.cmd.raw(%[meow('dev: ' .. dev, 2);]) ]
@dev[:hi] = [ @dev.cmd.raw(%[spawn('/info',0);]) ]
@dev[:welcome] = [ %[play(4,4,2); play(4,4,2); play(5,7,3); play(5,1,2); play(5,1,2); play(4,1,1);] ]
@dev[:beep] = [ %[play(4,4,4); play(4,4,4); play(4,4,4);] ]
@dev[:on] = [ %[pin(led,1);] ]
@dev[:off] = [ %[pin(led,0);] ]
@dev[:blink] = [ %[pin(led,1);], %[at(t(500,0,0,0), 'pin(led,0)');], @dev.cmd.spawn(:blink, @dev.cmd.t(s: 2)) ]
@dev[:power] = [ %[flash(3);] ]
@dev[:cue] = [ %[flash(0);] ]
@dev[:eq] = [ %[flash(10)] ]
@dev[:mute] = [ %[dark(1);] ]
@dev[:mode] = [ %[dark(0);] ]
@dev[:left] = [ %[pattern(1,0,0,1,0);] ]
@dev[:right] = [ %[pattern(0,1,0,1,0);] ]
@dev[:up] = [ %[pattern(1,1,0,1,1);] ]
@dev[:down] = [ %[pattern(1,1,0,1,0);] ]
@dev[:rpt] = [ %[rainbow(12);] ]
@dev[:scn] = [ %[rainbow(1);] ]
@dev[:zero] = [ %[theme(red,red,red);] ]
@dev[:one] = [ %[theme(blue,violet,red);] ]
@dev[:two] = [ %[theme(green,green,purple);] ]
@dev[:three] = [ %[theme(orange,gold,blue);] ]
@dev[:four] = [ %[theme(blue,gold,orange);] ]
@dev[:five] = [ %[theme(green,green,green);] ]
@dev[:six] = [ %[theme(blue,blue,blue);] ]
@dev[:seven] = [ %[leds(120,200,5,0);] ]
@dev[:eight] = [ %[leds(60,90,5,0);] ]
@dev[:nine] = [ %[leds(15,60,5,0);] ]
end
