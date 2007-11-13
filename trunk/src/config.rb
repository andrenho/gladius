class GladiusConfig

	def initialize
		@data = YAML::load(File.open("#{HOME}/my.yaml"))
	end

	def [](section, variable=nil)
		if variable == nil
			begin
				return @data[section]
			rescue
				return nil
			end
		else
			begin
				return @data[section][variable]
			rescue
				return nil
			end
		end
	end

	def []=(section, variable, data=nil)
		if data == nil
			@data[section] = variable
		else
			@data[section] = {}
			@data[section][variable] = data
		end

		open("#{HOME}/my.yaml", 'w') do |file|
			file.puts @data.to_yaml
		end
	end

end
