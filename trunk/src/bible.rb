class Bible

	def initialize(bible)
		@db = SQLite3::Database.new("#{BIBLES}/#{bible}.bible")
	end

	def verse(book, chapter, verse)
		return @db.get_first_value("SELECT text FROM bible WHERE book=#{book} AND chapter=#{chapter} AND verse=#{verse}")
	end

	def name
		return @db.get_first_value("SELECT variable FROM info WHERE content='name'")
	end

end
