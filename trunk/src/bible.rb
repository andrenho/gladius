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
		        WHERE b.book = k.id "

		# Range
		case range
		when Search::PENTATEUCH
			sql += 'AND b.book <= 5 '
		when Search::HISTORICALS
			sql += 'AND b.book BETWEEN 6 AND 17 '
		when Search::WISDOM
			sql += 'AND b.book BETWEEN 18 AND 22 '
		when Search::PROPHETS
			sql += 'AND b.book BETWEEN 23 AND 39 '
		when Search::GOSPELS
			sql += 'AND b.book BETWEEN 40 AND 43 '
		when Search::ACTS
			sql += 'AND b.book = 44 '
		when Search::EPISTOLS
			sql += 'AND b.book BETWEEN 45 AND 65 '
		when Search::REVELATION
			sql += 'AND b.book = 66 '
		end

		# Match
		case match
		when Search::EXACT
			sql += "AND text LIKE '%#{text}%' "
		when Search::ALL_WORDS
			text.split.each do |word|
				sql += "AND text LIKE '%#{word}%' "
			end
		when Search::ANY_WORDS
			sql += "AND ("
			text.split.each do |word|
				sql += "text LIKE '%#{word}%' OR "
			end
			sql = sql.chop.chop.chop
			sql += ")"
		end

		p partial

		if partial
			return @db.execute(sql)
		else
			rs = []
			@db.execute(sql).each do |row|
				case match
				when Search::EXACT
					rs << row if (row['text'] =~ /\b#{text}\b/) != nil
				when Search::ALL_WORDS
					ok = true
					text.split.each do |word|
						ok = false if (row['text'] =~ /\b#{word}\b/) == nil
					end
					rs << row if ok
				when Search::ANY_WORDS
					ok = false
					text.split.each do |word|
						ok = true if (row['text'] =~ /\b#{word}\b/) != nil
					end
					rs << row if ok
				end
			end
			return rs
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
