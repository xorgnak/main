
if File.exist? "z4/app.rb"
  load "z4/app.rb"
end

class Menu
  def initialize m
    @m = m
    return {}
  end
end

class Embed
  include Z4
  def initialize str
    @body = []
    self.instance_eval str
  end
  def opts h={}
    o = []
    h.each_pair { |k,v|
      if v.class == Array
        o << %[#{k}='#{v.join(" ")}']
      elsif v.class == Hash
        vvv = []; v.each_pair {|kk, vv| vvv << %[#{kk}: #{vv}] }
        o << %[#{k}='#{vvv.join("; ")};']
      else
        o << %[#{k}='#{v}']
      end
    }
    return o.join(' ')
  end
  
  def box t, h={}
    @body << %[<div #{opts(h)}>#{t}</div>]
  end
  def text t, h={}
    @body << %[<p #{opts(h)}>#{t}</p>]
  end
  def input h={}
    @body << %[<input #{opts(h)}>]
  end
  def textarea t, h={}
    @body << %[<textarea #{opts(h)}>#{t}</textarea>]
  end
  def checkbox i, l
    @body << %[<input type="checkbox" id="#{i}" name="#{i}" value="#{i}"><label for="#{i}">#{l}</label>]
  end
  def radio c, i, l
    @body << %[<input type="radio" id="#{i}" name="#{c}" value="#{i}"><label for="#{i}">#{l}</label>]
  end
  def submit t, h={}
    @body << %[<button type='submit' #{opts(h)}>#{t}</button>]
  end
  def body
    return @body.join("")
  end
end

class Run
  include Z4
  def initialize u
    @id = u
    @home = "usr/#{@id}"

    if !Dir.exist? @home
      Dir.mkdir @home
    end
    
    @json  = { id: u, type: 'post' }
  end

  def interest i, u, g
    Z4.group(g)[u][i]
  end
  
  def type t
    @json[:type] = t
  end
  
  def file *f
    if f[1]
      File.open("#{@home}/#{f[0]}", 'w') { |ff| ff.write(f[1]) }
    else
      File.read("#{@home}/#{f[0]}")
    end
  end

  def exist? f
    if File.exist? "#{@home}/#{f}"
      return true
    else
      return false
    end
  end
  
  def mkdir d
    Dir.mkdir "#{@home}/#{d}"
  end
  
  def pwd
    Dir.pwd.gsub(@home,'');
  end
  
  def ls *p, &b
    if p[0]
      pa = "#{@home}/#{p[0]}"
    else
      pa = "#{@home}/*"
    end
    a = []
    Dir[pa].each {|e| a << e.gsub(@home,'') }
    if block_given?
      a.each {|e| b.call(e) }
    else
      return a
    end
  end

  def link k, v
    return %[<a class='menu link' href='#{v}'>#{k}</a>]
  end
  
  def icon k, v
    return %[<a class='menu material-icons button' href='#{v}'>#{k}</a>]
  end
  
  
  def menu *m
    if m[1]
      mn = Menu.new(m[1])
    else
      if m[0] == :icon
        mn = { terminal: "/?net=#{@id}&id=#{@id}", flag: "/bingo?user=#{@id}" }
      else
        mn = { term: "/?net=#{@id}&id=#{@id}", bingo: "/bingo?user=#{@id}" }
      end
    end
    o = []
    mn.each_pair {|k,v|
      if m[0] == :icon
        o << icon(k,v)
      else
        o << link(k,v)
      end
    }
    return o.join("");
  end
  
  def id
    @id
  end
  
  def dev
    Z4::DEV
  end
  
  def erb k
    return ERB.new(k).result(binding)
  end
  
  def run i
    if m = /(.+): (.*)/.match(i)
      ii = [ m[1], m[2] ]
    else
      ii = [ '/', i ]
    end
    t = Time.now
    @json[:time] = t
    @json[:epoch] = t.to_i
    @json[:input] = i
    @json[:target] = ii[0]
    @json[:output] = %[#{self.instance_eval(ii[1])}]
    @json[:took] = Time.now.to_i - @json[:epoch]
    return @json
  end
end

module HTML
  def self.view f

    if File.exist? "views/head.erb"
      head = File.read "views/head.erb"
    else
      head = %[]
    end

    ff = "views/#{f}.erb"
    if File.exist? ff
      body = File.read ff
    else
      if BODY != nil
        body = BODY
      else
        body = %[]
      end
    end
    
    top = %[<!DOCTYPE html><html><head>]
    mid = %[</head><body><form id='form' action='/' method='post'>]
    tail = %[</form></body></html>]
    
    f = [top, head, mid, body, tail].join('')
    return f
  end
end


class App < WEBrick::HTTPServlet::AbstractServlet

  def frame(i)
    o = []
    i.split("\n").each {|e| o << %[<p>#{e}</p>]}
    return %[<div>#{o.join("")}</div>]
  end
  
  def get_env(r)
    @path = r.path
    @query = r.query_string
    @host = r.host
    @params = r.query
    @type = r.content_type
    @method = r.request_method
    if File.exist? "views/#{r.path}.erb"
      @view = r.path
    else
      @view = :index
    end
    Z4.db('/')[@params['net']] = @params['client']
    puts %[[#{@method}] #{@path} #{@query} #{@host} #{@params} #{@type}]
  end

  def erb k, h={}
    ERB.new(File.read("views/#{k}.erb")).result(h[:binding] ||binding)
  end
  
  def do_GET request, response
    get_env(request)
    response.status = 200
    @db = Z4.db(:host, @host)
    if @path == '/json'
      response['Content-Type'] = 'application/json'
      if @params.has_key? 'token'
        @h = Z4.db(:token, @params['token']).to_h
      elsif @params.has_key?('net')
        if @params.has_key?('net')
          @h = Z4.db(:dev, @params['dev'], @params['net']).to_h
        else
          @h = Z4.db(:net, @params['net']).to_h
        end
      elsif @params.has_key?('chan')
        if @params.has_key?('user')
          @h = Z4.db(:user, @params['user'], @params['chan']).to_h
        else
          @h = Z4.db(:chan, @params['chan']).to_h
        end
      else
        @h = @db.to_h
      end
      response.body = JSON.generate(@h)
    else
      response['Content-Type'] = @type
      response.body = ERB.new(HTML.view(@view)).result(binding)
    end
  end
  
  def do_POST(request, response)
    get_env(request)
    response.status = 200
    response['Content-Type'] = 'application/json'
    if @params.has_key? 'id'
      u = @params['id']
      if @params.has_key? 'input'
        i = @params['input']
        @h  = { id: u, fg: 'white', bg: 'black', bd: 'black', icon: 'send' }
        
        if /^--/.match(i)
          @h[:output] = ERB.new(i.gsub('--', '')).result(binding);
        elsif /^#/.match(i)
          @h[:output] = ERB.new(i.gsub(/^#/, '')).result(binding);
        else
          @u = Run.new(u);
          @h = @u.run(i);
        end
      else
        # user id, but no input
      end
    else
      # no user id
    end
    response.body = JSON.generate(@h)
  end
end

SERVER = WEBrick::HTTPServer.new :Port => 4567, :DocumentRoot => File.expand_path('public/')
SERVER.mount '/', App

Process.detach( fork { SERVER.start })
