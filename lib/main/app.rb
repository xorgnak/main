
if File.exist? "z4/app.rb"
  load "z4/app.rb"
end

class Run
  include Z4
  def initialize u
    @id = u
    @json  = { id: u, fg: 'white', bg: 'black', bd: 'black', icon: 'send' }
  end
  def A *a
    self.send(a)
  end
  def B *a
    db.send(a)
  end
  def C *a
    z4.send(a)
  end
  def D *a
    dev.send(a)
  end
  def E *a
    puts %[E: #{a}]
  end
  def F *a
    puts %[F: #{a}]
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
    t = Time.now
    @json[:time] = t
    @json[:epoch] = t.to_i
    @json[:input] = i
    @json[:output] = %[#{self.instance_eval(i)}]
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
  def get_env(r)
    @path = r.path
    @query = r.query_string
    @host = r.host
    @params = r.query
    @type = r.content_type
    if File.exist? "views/#{r.path}.erb"
      @view = r.path
    else
      @view = :index
    end
    Z4.db('/')[@params['id']] = @params['client']
    puts %[[GET] #{@path} #{@query} #{@host} #{@params} #{@type}]
  end
  
  def do_GET request, response
    get_env(request)
    response.status = 200
    response['Content-Type'] = @type
    response.body = ERB.new(HTML.view(@view)).result(binding)
  end
  
  def do_POST(request, response)
    get_env(request)
    response.status = 200
    response['Content-Type'] = 'application/json'
    
    u = @params['id']
    i = @params['input']
    @h  = { id: u, fg: 'white', bg: 'black', bd: 'black', icon: 'send' }
    
    if /^--/.match(i)
      @h[:output] = i.gsub('--', '');
    else
      @u = Run.new(u)
      @h = @u.run(i);
    end
    
    response.body = JSON.generate(@h)
  end
end

SERVER = WEBrick::HTTPServer.new :Port => 4567, :DocumentRoot => File.expand_path('public/')
SERVER.mount '/', App

Process.detach( fork { SERVER.start })
