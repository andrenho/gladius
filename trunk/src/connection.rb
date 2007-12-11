require 'socket'

class Connection
	
	def initialize
	end
	
	def download(host, address)
		sock = TCPSocket.new(host, 80)
		sock.puts "GET #{address} HTTP/1.1"
		sock.puts "Host: #{host}:80"
		sock.puts "Connection: close"
		sock.puts ""

		# Get headers
		headers = ""
		while (t = sock.gets.chop)
			headers += t
			break if t == ""
		end
		
		# Get data
		data = ""
		i = 0
		while (t = sock.getc) != nil
			data += t.chr
			i += 1#t.length
			# p i
		end
		sock.close

		return data
	end

end

c = Connection.new
# puts c.download('gladius.googlecode.com', '/svn/trunk/data/modules.yaml')
$stderr.puts c.download('gladius.googlecode.com', '/files/en-kjv.zip')
# c.download('www.yahoo.com.br', '/index.html')
