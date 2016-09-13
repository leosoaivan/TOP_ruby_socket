require 'socket'
require 'pry'

CONTENT_TYPE_MAPPING = {
  'html' => 'text/html'
}

server = TCPServer.open(2000)

def requested_file(request)
  File.open("#{request}", 'r').each { |line| puts line }
end

def content_type(request)
  ext = request.split(".").last
  CONTENT_TYPE_MAPPING.fetch(ext)
end

loop {
  socket = server.accept
  verb,request,http_standard = socket.gets.split(" ", 3)
  request = request.gsub!(/\//, "")

  if File.exist?("#{request}") && verb == "GET"
    File.open("#{request}") do |file|
      socket.print "HTTP/1.0 200 OK\r\n" +
                   "Date: #{Time.new.strftime("%B %-d, %Y at %H:%M:%S")}\r\n" +
                   "Content-Type: #{content_type(request)}\r\n" +
                   "Content-Length: #{request.size}\r\n" +
                   "Last-Modified: #{File.mtime(request).strftime("%B %-d, %Y")}\r\n\r\n"

      IO.copy_stream(request, socket)
    end
  elsif !File.exist?("#{request}") && verb == "GET"
    socket.print "HTTP/1.0 404 Not Found\r\n\r\n"
  else
    socket.print "HTTP/1.0 501 Not Implemented\r\n\r\n"
  end

  socket.close
}
