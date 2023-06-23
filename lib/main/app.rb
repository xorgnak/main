
if File.exist? "z4/app.rb"
  load "z4/app.rb"
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
    return ERB.new(f).result(binding)
  end
end


class App < WEBrick::HTTPServlet::AbstractServlet
  def get_env(r)
    if File.exist? "views/#{r.path}.erb"
      @view = r.path
    else
      @view = :index
    end
    @path = r.path
    @query = r.query_string
    @host = r.host
    @params = r.query
    @type = r.content_type
  end
  
  def do_GET request, response
    get_env(request)
    response.status = 200
    response['Content-Type'] = @type
    response.body = HTML.view(@view)
  end
  
  def do_POST(request, response)
    get_env(request)
    response.status = 200
    response['Content-Type'] = @type
    response.body = HTML.view(@view)
  end
end

SERVER = WEBrick::HTTPServer.new :Port => 4567, :DocumentRoot => File.expand_path('public/')
SERVER.mount '/', App

Process.detach( fork { SERVER.start })
