require 'socket'               # Get sockets from stdlib

server = TCPServer.open(2000)  # Socket to listen on port 2000
loop {                         # Servers run forever
  client = server.accept       # Wait for a client to connect
  verb,request,http_standard = client.gets.split(" ", 3)
  request.gsub!(/\//, "")

  response = File.open("#{request}", 'r').each { |line| puts line }

  client.puts   "HTTP/1.0 200 OK\r\n" +
                "Content-Type: text/html\r\n" +
                "Content-Length: #{response.size}\r\n\r\n" +

  IO.copy_stream(response, client)
  client.close                 # Disconnect from the client
}
