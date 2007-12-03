class Bible

	#
	# Initialize a bible
	#
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

		@cache_book_name = []
		@cache_book_abbr = []
		@db.execute("SELECT * FROM books ORDER BY id") do |row|
			@cache_book_name << row['name']
			@cache_book_abbr << row['abbr']
		end
	end


	#
	# Return a array with the verses on the chapter, for the main
	# bible visualization.
	# 
	def chapter(book, ch)
		verse_list = []
		verses = []
		# TODO use bible_p
		@db.execute("
			SELECT b.book
			     , b.chapter
				 , b.verse
				 , b.text
				 , p.bop
			  FROM bible b
			     , paragraphs p
			 WHERE b.book    = p.book
			   AND b.chapter = p.chapter
			   AND b.verse   = p.verse
			   AND b.book    = #{book}
			   AND b.chapter = #{ch}
		  ORDER BY b.verse").each do |rs|
			if rs['bop'].to_i == 1 and verses != []
				verse_list << verses
				verses = []
			end
			verses << [rs['book'].to_i, rs['chapter'].to_i, rs['verse'].to_i, rs['text']]
		end
		verse_list << verses
		return verse_list
	end

	# 
	# Return the number of verses in a given chapter
	#
	def n_verses(book, chapter)
		return @db.get_first_value("SELECT max(verse) FROM bible WHERE book=#{book} AND chapter = #{chapter} GROUP BY book, chapter").to_i
	end


	#
	# Returns a array with the verses and the paragraphs
	#
	def verse(book, chapter, verse)
		return @db.get_first_value("SELECT text FROM bible WHERE book=#{book} AND chapter = #{chapter} AND verse = #{verse}")
	end


	# 
	# Search a given term in the bible
	#
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


	#
	# Parse a set of bible links, return a array of arrays with the
	# references.
	#
	def parse(text)
		list = []
		text = text.split(/[\n;]/)
		text.each do |t|
			dec = t.scan(/(.+)\ +([0-9]+)[:|\.]([0-9\-,\ ]+)/)[0]
			dec = t.scan(/(.+)\ +([0-9]+)/)[0] if dec == nil
			book = @db.get_first_value("
				SELECT id
				  FROM books
				 WHERE abbr = '#{dec[0]}'
				    OR name = '#{dec[0]}'").to_i
			chapter = dec[1].to_i
			verse_list = []
			if dec[2] != nil
				dec[2].split(',').each do |v|
					verses = v.split('-')
					if verses.length == 1
						verse_list << verses[0].to_i
					else
						verses[0].to_i.upto(verses[1].to_i) { |i| verse_list << i }
					end
				end
			else
				1.upto(self.n_verses(book, chapter)) { |i| verse_list << i }
			end
			verses = []
			verse_list.each do |verse|
				verses << [book, chapter, verse]
			end
			list << verses
		end

		return list
	end


	# 
	# Return the name of the bible
	#
	def name
		return @db.get_first_value("SELECT variable FROM info WHERE content='name'")
	end


	# 
	# Return the abbreviation of the bible
	#
	def abbr
		return @db.get_first_value("SELECT variable FROM info WHERE content='abbr'")
	end


	#
	# Return the name of a given book
	#
	def book_name(book)
		return @cache_book_name[book-1]
	end


	# 
	# Return the abbreviation of a given book
	#
	def book_abbr(book)
		return @cache_book_abbr[book-1]
	end


	# 
	# Returns the last chapter of a given book
	#
	def last_chapter(book)
		return @db.get_first_value("SELECT max(chapter) FROM bible WHERE book=#{book}").to_i
	end


	#
	# CLASS METHODS
	#
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
