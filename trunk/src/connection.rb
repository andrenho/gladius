require 'gtk2'
require 'net/http'

# $OpSys = :win32

if $OpSys != :win32
	require 'resolv-replace'
else
	def win32_resolve(address)
		return '127.0.0.1'
	end
end

puts win32_resolve('gladius.googlecode.com')

class Connection
	
	def Connection.read(host, path)
		if $OpSys != :win32
			ip = host
		else
			ip = host # TODO win32
		end
		http = Net::HTTP.new(ip)
		http.open_timeout = 20
		http.read_timeout = 40
		http.start
		resp = http.get(path, { 'Host' => host })
		return resp.body
	end

	def Connection.download(host, path, file, size=0.0, progress=nil, n_iter=nil)
		if $OpSys != :win32
			ip = host
		else
			ip = host # TODO win32
		end
		sz = 0.0
		open(file, 'wb') do |f|
			http = Net::HTTP.new(ip)
			http.open_timeout = 30
			http.read_timeout = 60
			http.start
			http.get(path, { 'Host' => host }) do |r|
				f.write(r)
				if progress.class == Gtk::ProgressBar
					progress.fraction = (sz * 100 / size)
				elsif progress.class == Gtk::TreeIter
					progress[n_iter] = (sz * 100 / size)
				end
				sz += r.length
			end
		end
	end

end

#puts Connection.read('gladius.googlecode.com', '/svn/trunk/data/modules.yaml')
# Connection.download('gladius.googlecode.com', '/files/en-kjv.zip', 'en-kjv.zip')
# c.download('www.yahoo.com.br', '/index.html')
