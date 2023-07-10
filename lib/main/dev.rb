module Z4
  def dev
    DEV
  end
  module DEV
    def self.set k,v
      if v.class == String
        s = "#{k} = '#{v}'; io(1, '--[#{k}] #{v}'); ";
      else
        s = "#{k} = #{v}; io(1, '--[#{k}] #{v}'); ";
      end
      self.input(s);
    end

    def self.cmd(r, m, *a)
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
      self.input(s)
      return nil
    end
    
    def self.input i
      if /.+: .*/.match(i)
        ii = i.split(": ")
      else
        ii = ["/", i]
      end
      puts %[input: #{ii}]
      @@DEVS.each_pair {|k,v|
        if ENV['BROKER'] != 'localhost' && ENV['BROKER'] != nil
          v.write(ii[1]);
          puts %[v.write: #{ii[1]}]
        end
      }
      Z4.emit(topic: "Z4#{ii[0]}", payload: ii[1])
      puts %[publish: #{ii[0]} #{ii[1]}]
        
    end
    
    def self.read(f)
      self.input(%[io(0,''); ev(0, '/#{f}'); io(16, '[event] #{f}'); ]);
    end
    
    def self.write(f, p)
      self.input(%[io(0, '#{p}'); ev(1, '/#{f}'); ])
    end
    
    def self.ls *a
      if a[0]
        [a].flatten.each { |e| self.input("ls(#{e});"); }
      else
        self.input("ls();");
      end
    end
    
    def self.roll h={}
      hh = []; h.each_pair {|k,v| hh << %[{#{v},#{k}}] }
      return %[roll({#{hh.join(',')}})]
    end
    
    def self.dice n, s
      return %[dice(#{n},#{s})]
    end
    
    def self.die s
      return %[die(#{s})]
    end
    
    def self.meow e, *o
      if o[0]
        self.input(%[meow(#{e}, #{o[0]}); ]);
      else
        self.input(%[meow(#{e}); ]);
      end
    end
    
    def self.date()
      self.input("date();");
    end
    
    def self.ok()
      self.input("ok();");
    end

    def self.hi()
      self.input("hi();");
    end
    
    def self.z4 m, *a
      self.cmd "z4", m, a
    end
    
    def self.t h={}
      ms = h[:ms].to_i
      s = (h[:s].to_i * 1000)
      m = (h[:m].to_i * (60 * 1000))
      h = (h[:h].to_i * ((60 * 1000) * 60))
      return ms + s + m + h
    end
    
    def self.at h = {}
      a = []; h.each_pair {|k, v| a << %[at(#{k},'#{v}'); ] }
      self.input(a.join(""));
    end
    
    def self.nm m, *a
      self.cmd "nm", m, a
    end
    
    def self.io m, *a
      self.cmd "io", m, a
    end
    
    def self.event m, *a
      self.cmd "ev", m, a
    end
    
    def self.beacon n
      self.set "beacon", n
    end
    
    def self.network k
      self.set "net", k
    end
    
    def self.device k
      self.set "dev", k
    end

    def self.devices
      @@DEVS.keys.length
    end

    @@DEVS = Hash.new do |h,k|
      d = Serial.new(port: k, baud: 115200)
      Process.detach(fork {
                       while(o = d.gets) do
                         o.split("\n").each do |e|
#                           if "#{e}".length > 0
                             puts "#{e.strip}"
#                           end
                         end
                       end
                     });
      h[k] = d
    end
    Dir['/dev/ttyUSB*'].each { |e| @@DEVS[e] }
  end
  include DEV
  DEV.hi();
end

