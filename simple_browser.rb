require 'socket'
require 'pry'

host = 'localhost'     # The web server
port = 2000                           # Default HTTP port
path = "/index.html"                 # The file we want

# This is the HTTP request we send to fetch a file
request = "GET #{path} HTTP/1.0\r\n\r\n"

socket = TCPSocket.open(host,port)  # Connect to server
socket.print(request)               # Send request
response = socket.read              # Read complete response

# Split response at first blank line into headers and body
puts response                       # And display it
