require 'socket'
require 'json'

CONTENT_TYPE_MAPPING = {
  'html' => 'text/html'
}

server = TCPServer.open(2000)

def requested_file(path)
  File.open("#{path}", 'r').each { |line| puts line }
end

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

  if verb == "GET"
    path = path[1..-1]
    if File.exist?("#{path}")
      File.open("#{path}") do |file|
        socket.print "HTTP/1.0 200 OK\r\n" +
                     "Date: #{Time.new.strftime("%B %-d, %Y at %H:%M:%S")}\r\n" +
                     "Content-Type: #{content_type(path)}\r\n" +
                     "Content-Length: #{path.size}\r\n" +
                     "Last-Modified: #{File.mtime(path).strftime("%B %-d, %Y")}\r\n\r\n"
        IO.copy_stream(path, socket)
      end
    else
      socket.print "HTTP/1.0 404 Not Found"
    end

  elsif verb == "POST"
    params = JSON.parse(body)
    data =  "<li>Name: #{params['viking']['name'].join(" ")}</li>\r\n" +
            "      <li>Email: #{params['viking']['email']}</li>"
    body = File.read("#{path}").gsub("<%= yield %>", data)

    socket.print "HTTP/1.0 200 OK\r\n" +
                 "Date: #{Time.new.strftime("%B %-d, %Y at %H:%M:%S")}\r\n" +
                 "Content-Type: #{content_type(path)}\r\n" +
                 "Content-Length: #{path.size}\r\n" +
                 "Last-Modified: #{File.mtime(path).strftime("%B %-d, %Y")}\r\n\r\n" +
                 "#{body}"

  else
    socket.print "HTTP/1.0 501 Not Implemented"
  end

  socket.close
}
