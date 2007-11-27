class Bible

	def initialize(bible)
		@db = SQLite3::Database.new("#{HOME}/#{bible.downcase}.bible")
		@db.execute("ATTACH DATABASE [#{HOME}/data.db] AS data")
		@db.execute("
			CREATE TEMPORARY VIEW bible_p AS 
						   SELECT b.*
			                    , p.bop AS bop
			                    , p.eop AS eop
			                 FROM bible b
			                    , data.paragraphs p 
			                WHERE b.book = p.book 
			                  AND b.chapter = p.chapter 
			                  AND b.verse = p.verse")
		@db.results_as_hash = true
	end

	def n_verses(book, chapter)
		return @db.get_first_value("SELECT max(verse) FROM bible WHERE book=#{book} AND chapter = #{chapter} GROUP BY book, chapter").to_i
	end

	def verse(book, chapter, verse)
		# TODO optimize to cache verses
		rs = @db.get_first_row("SELECT text, bop, eop FROM bible_p WHERE book=#{book} AND chapter = #{chapter} AND verse = #{verse}")
		return rs['text'], rs['bop'].to_i, rs['eop'].to_i
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

	def abbr
		return @db.get_first_value("SELECT variable FROM info WHERE content='abbr'")
	end

	def book_name(book)
		return @db.get_first_value("SELECT name FROM books WHERE id=#{book}")
	end

	def book_abbr(book)
		return @db.get_first_value("SELECT abbr FROM books WHERE id=#{book}")
	end

	def last_chapter(book)
		return @db.get_first_value("SELECT max(chapter) FROM bible WHERE book=#{book}").to_i
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
