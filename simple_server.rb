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

  if verb == "GET"
    if File.exist?("#{request}")
      File.open("#{request}") do |file|
        socket.print "HTTP/1.0 200 OK\r\n" +
                     "Date: #{Time.new.strftime("%B %-d, %Y at %H:%M:%S")}\r\n" +
                     "Content-Type: #{content_type(request)}\r\n" +
                     "Content-Length: #{request.size}\r\n" +
                     "Last-Modified: #{File.mtime(request).strftime("%B %-d, %Y")}\r\n\r\n"

        IO.copy_stream(request, socket)
      end
    else
      socket.print "HTTP/1.0 404 Not Found"
    end
    
  elsif verb == "POST"
    socket.print "What is your name?"
    # user_name = socket.gets.chomp
    # socket.print "UserEmail: \r\n"
    # user_email = gets.chomp
    # socket.print "#{user_name} + " " + #{user_email}\r\n\r\n"
  else
    socket.print "HTTP/1.0 501 Not Implemented"
  end

  socket.close
}
