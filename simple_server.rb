require 'socket'
require 'json'
require 'pry'

CONTENT_TYPE_MAPPING = {
  'html' => 'text/html'
}

server = TCPServer.open(2000)

def content_type(path)
  ext = path.split(".").last
  CONTENT_TYPE_MAPPING.fetch(ext)
end

loop {
  socket = server.accept
  request = socket.recv(1000).split("\r\n\r\n")

  initial_line = request.first.split("\r\n")
  verb,path,http_standard = initial_line[0].split(" ")
  body = request.last

  headers = "HTTP/1.0 200 OK\r\n" +
               "Date: #{Time.new.strftime("%B %-d, %Y at %H:%M:%S")}\r\n" +
               "Content-Type: #{content_type(path)}\r\n" +
               "Content-Length: #{body.length}\r\n" +
               "Last-Modified: #{File.mtime(path).strftime("%B %-d, %Y")}\r\n\r\n"

  if verb == "GET"
    if File.exist?(path)
      body = ""
      File.open(path).each { |line| body << line + "\r" }

      socket.print(headers, body)
    else
      socket.print "HTTP/1.0 404 Not Found"
    end

  elsif verb == "POST"
    params = JSON.parse(body)
    data =  "<li>Name: #{params['viking']['name'].join(" ")}</li>\r\n" +
            "      <li>Email: #{params['viking']['email']}</li>"
    body = File.read("#{path}").gsub("<%= yield %>", data)

    socket.print(headers, body)
  end

  socket.close
}
