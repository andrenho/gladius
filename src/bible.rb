class Bible

	def initialize(bible)
		@db = SQLite3::Database.new("#{BIBLES}/#{bible}.bible")
		@db.results_as_hash = true
	end

	def verse(book, chapter, verse)
		return @db.get_first_value("SELECT text FROM bible WHERE book=#{book} AND chapter = #{chapter} AND verse = #{verse}")
	end

	def search(text, match, partial, range)
		sql = "SELECT b.*, k.abbr 
		         FROM bible b, books k 
		        WHERE b.book = k.id
		          AND text LIKE '%#{text}%'"
		rs = []
		@db.execute(sql).each do |row|
			rs << row
		end
	end

	def name
		return @db.get_first_value("SELECT variable FROM info WHERE content='name'")
	end

	def Bible.language(file)
		db = SQLite3::Database.new(file)
		x = db.get_first_value("SELECT variable FROM info WHERE content='language'")
		db.close
		return x
	end

	def Bible.abbr(file)
		db = SQLite3::Database.new(file)
		x = db.get_first_value("SELECT variable FROM info WHERE content='abbr'")
		db.close
		return x
	end

	def Bible.name(file)
		begin
			db = SQLite3::Database.new(file)
			x = db.get_first_value("SELECT variable FROM info WHERE content='name'")
			db.close
		rescue SQLite3::NotADatabaseException
			return nil
		end
		return x
	end

end
