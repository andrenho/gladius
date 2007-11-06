# Since all internationalization options for ruby suck, I decided to roll my
# own.

require 'yaml'

class Object

	def _(str, *args)
		return str % args if $l == nil
		x = $l[str]
		if x == nil
			return str % args
		else
			return x % args
		end
	end

	def load_language(language=nil)
		$l = nil
		if OS == :win32
			begin
				require 'Win32API'
				get_language = Win32API.new("kernel32.dll", "GetLocaleInfoA", ['L', 'L', 'P', 'L'], 'L')
				x = " " * 255
				get_language.Call(1024, 4097, x, 255)
				x.strip!
				x.chop!
				case x
				when 'Portuguese'
					language = 'pt'
				else
					language = nil
				end
			rescue
				language = nil
			end
		else
			language = ENV["LC_ALL"] if language == nil
			language = ENV["LC_MESSAGES"] if language == nil
			language = ENV["LANG"] if language == nil
		end
		if language == nil
			# puts "Warning: #{@l[0]['language']} language file could not be loaded."
			return
		else
			language = language.downcase
		end
		begin
			if I18N == nil
				f = YAML::load(File.open("i18n/#{language}.yaml"))
			else
				f = YAML::load(File.open("#{I18N}/#{language}.yaml"))
			end
#			puts "#{language} language file loaded."
		rescue SystemCallError
#			$stderr.puts "Warning: #{language} language file could not be loaded."
			return
		end
		$l = {}
		f.delete(0)
		f.each { |reg| $l[reg[0]] = reg[1] }
	end

end

def create(language)

	body = []

	(Dir["*.rb"] + Dir["src/*.rb"]).each do |file|
		IO.foreach(file) do |line|
			line.scan(/_\(\"(.*?)\".*?\)/) do |match|
				match.each { |m| body << [ m, nil ] }
			end
		end
	end

	begin
		translated = YAML::load(File.open("i18n/#{language}.yaml"))
		header = translated.delete_at(0)
	rescue SystemCallError
		translated = []
		header = { 'code' => language,
			  	   'language' => nil,
		  		   'translator' => nil,
	    	       'email-translator' => nil}
	end

	translated.each do |reg|
		body.delete_if { |x| x[0] == reg[0] }
	end

	body += translated
	body.uniq!
#	body.sort! { |x, y| x[0] <=> y[0] }

	file = File.new("i18n/#{language}.yaml", 'w')
	content = ([header] + body).to_yaml
	file.puts content
	file.close

end

create(ARGV[0]) if ARGV[0] != nil
