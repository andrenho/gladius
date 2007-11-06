class Bible

	def initialize(bible)
		@db = SQLite3::Database.new("bibles/#{bible}.bible")
	end

	def verse(book, chapter, verse)
		return @db.get_first_value("SELECT text FROM bible WHERE book=#{book} AND chapter=#{chapter} AND verse=#{verse}")
	end

end
