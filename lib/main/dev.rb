
def set k,v
  if v.class == String
    s = "#{k} = '#{v}'; io(1, '--[k] #{v}'); ";
  else
    s = "#{k} = #{v}; io(1, '--[#{k}] #{v}'); ";
  end
  input(s);
end

def cmd(r, m, *a)
  as = [a].flatten
  if as.length > 0
    aa = []; as.each do |e|
      case
      when e.class == String
        aa << %["#{e}"]
      else
        aa << e
      end
    end
    s = "#{r}(#{m},#{aa.join(',')}); "
  else
    s = "#{r}(#{m}); "
  end
  input(s)
  return nil
end

def input i
  @devs.each_pair {|k,v| v.write(i); }
end

def read(f)
  input(%[io(0,''); ev(0, '/#{f}'); io(16, '[event] #{f}'); ]);
end

def write(f, p)
  input(%[io(0, '#{p}'); ev(1, '/#{f}'); ])
end

def root *a
  if a[0]
    [a].flatten.each { |e| input("ls(#{e});"); }
  else
    input("ls();");
  end
end

def roll h={}
  hh = []; h.each_pair {|k,v| hh << %[{#{v},#{k}}] }
  return %[roll({#{hh.join(',')}})]
end

def dice n, s
  return %[dice(#{n},#{s})]
end

def die s
  return %[die(#{s})]
end

def meow e, *o
  if o[0]
    input(%[meow(#{e}, #{o[0]}); ]);
  else
    input(%[meow(#{e}); ]);
  end
end

def ok()
  input("ok();");
end

def z4 m, *a
  cmd "z4", m, a
end

def t h={}
  ms = h[:ms].to_i
  s = (h[:s].to_i * 1000)
  m = (h[:m].to_i * (60 * 1000))
  h = (h[:h].to_i * ((60 * 1000) * 60))
  return ms + s + m + h
end

def at h = {}
  a = []; h.each_pair {|k, v| a << %[at(#{k},'#{v}'); ] }
  input(a.join(""));
end

def nm m, *a
  cmd "nm", m, a
end

def io m, *a
  cmd "io", m, a
end

def event m, *a
  cmd "ev", m, a
end

def beacon n
  set "beacon", n
end

def network k
  set "net", k
end

def device k
  set "dev", k
end


@devs = Hash.new do |h,k|
  d = Serial.new(port: k, baud: 115200)
  Process.detach(fork {
                   while(o = d.gets) do
                     o.strip.split("\n").each do |e|
                       if "#{e}".length > 0
                       puts "#{e}"
                     end
                     end
                   end
                 });
  h[k] = d
end
Dir['/dev/ttyUSB*'].each { |e| @devs[e] }
