require 'sqlite3'
require 'ftools'

class ImportUnbound

	def ImportUnbound.import(file, new_file, language, abbr, name, charset)
		File.copy("#{BIBLES}/default.bible", "#{BIBLES}/#{new_file}.bible")
		db = SQLite3::Database.new("#{BIBLES}/#{new_file}.bible")
		db.execute "INSERT INTO info ( content, variable ) VALUES ( 'language', '#{language}' )"
		db.execute "INSERT INTO info ( content, variable ) VALUES ( 'abbr', '#{abbr}' )"
		db.execute "INSERT INTO info ( content, variable ) VALUES ( 'name', '#{name}' )"
		db.execute "INSERT INTO info ( content, variable ) VALUES ( 'charset', '#{charset}' )"

		file = File.new(file)
		db.prepare("INSERT INTO bible ( book, chapter, verse, text ) VALUES ( ?, ?, ?, ? )") do |stmt|
			file.each_line do |line|
				x = line.scan(/([0-9]+)(.)\t([0-9]+)\t([0-9]+)\t\t([0-9]+)\t(.*)/)
				book, testament, chapter, verse, order, text = x[0]
			
				if testament == 'O' or testament == 'N'
					stmt.execute book.to_i, chapter.to_i, verse.to_i, text
				end
			end
		end
		db.execute "vacuum"
	end

end

BIBLES = 'bibles'
ImportUnbound.import('bibles/kjv_apocrypha_utf8.txt', 'kjv', 'en', 'KJV', 'King James Version', 'iso-8859-1')
