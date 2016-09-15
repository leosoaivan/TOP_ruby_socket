require 'socket'
require 'pry'

class Browser

  def initialize
    @host = "localhost"
    @port = 2000
    @path = "/index.html"
    @request_verb = ""
    @socket = TCPSocket.open(@host, @port)
    request_type
    send_request
    puts response = @socket.read
  end

  def request_type
    print "What kind of request are you making? GET or POST?  "
    @request_verb = gets.chomp.upcase
    puts "\r\n"
  end

  def send_request
    if @request_verb == "GET"
      @socket.print("#{@request_verb} #{@path} HTTP/1.0\r\n\r\n")
    elsif @request_verb == "POST"
      print "What is your name?  "
      name = gets.chomp.capitalize
      print "What is your email address?  "
      email = gets.chomp
    end
  end
end

x = Browser.new
