require 'socket'
require 'json'

class Browser

  def initialize
    @host = "localhost"
    @port = 2000
    @path = "./index.html"
    @request_verb = ""
    @socket = TCPSocket.open(@host, @port)
    request_type
    send_request
    puts response = @socket.read
  end

  def request_type
    print "What kind of request are you making? GET or POST?  "
    @request_verb = gets.chomp.upcase
    puts ""
  end

  def send_request
    if @request_verb == "GET"
      @socket.print("GET #{@path} HTTP/1.0\r\n\r\n")
    elsif @request_verb == "POST"
      print "What is your name?  "
      name = gets.chomp.split(" ").map(&:capitalize)
      print "What is your email address?  "
      email = gets.chomp
      puts ""

      @path = "./thanks.html"
      data = { :viking => { :name => name, :email => email } }.to_json

      request = "POST #{@path} HTTP/1.0\r\n" +
                "From: #{email}\r\n" +
                "Content-Length: #{data.size}\r\n\r\n"+
                "#{data}"
      @socket.print(request)
    else
      puts "HTTP/1.0 501 Not Implemented"
    end
  end

end

x = Browser.new
