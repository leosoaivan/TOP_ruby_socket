require 'socket'
require 'json'
require 'pry'

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
  headers = request.first.split("\r\n")
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
    socket.print "#{initial_line}\r\n#{header}\r\n\r\n"
  else
    socket.print "HTTP/1.0 501 Not Implemented"
  end

  socket.close
}
