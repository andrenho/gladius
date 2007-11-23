class BibleText < Gtk::ScrolledWindow

	attr_reader :buffer

	def initialize(bible, format)
		super()
		@bible = bible
		@format = format

		@buffer = Gtk::TextBuffer.new
		@textview = Gtk::TextView.new(@buffer)
		@textview.editable = false
		@textview.wrap_mode = Gtk::TextTag::WRAP_WORD
		@textview.pixels_below_lines = 10

		@last_n = -1

		initialize_tags
		set_format

#		@textview.signal_connect('focus_in_event') { refit_menus }
#		@textview.signal_connect('button_release_event') do |w, e| 
#			refit_menus
#			false
#		end
#		@textview.signal_connect('key_release_event') do |w, e| 
#			refit_menus 
#			false
#		end
		self.add(@textview)

#		@tags = []
#		(1..176).each do |n|
#			@tags[n] = @buffer.create_tag("verse#{n}", {})
#		end
#		@tag_header = @buffer.create_tag('', { :font => 'Serif 15', :weight => Pango::FontDescription::WEIGHT_HEAVY })

#		@buffer.signal_connect('mark-set') do |w, iter, mark|
#			# TODO this is repeating several times
#			if iter.tags != []
#				n = @tags.index(iter.tags[0])
#				$main.select_verse(n) if n != nil
#			end
#		end
	end

	def initialize_tags
		@header_tag = @buffer.create_tag(nil, {})
		@verses_tag = @buffer.create_tag(nil, {})
		@tags = []
		(0..200).each do |n|
			@tags[n] = @buffer.create_tag(nil, {})
		end
		@buffer.signal_connect('mark-set') do |w, iter, mark|
			# TODO this is repeating several times
			if iter.tags != []
				n = @tags.index(iter.tags[0])
				if n != @last_n
					$main.select_verse(n) if n != nil
					@last_n = n
				end
			end
		end
	end

	def set_format
		@textview.modify_font(Pango::FontDescription.new(@format.text_font))
		@textview.modify_text(Gtk::STATE_NORMAL, Gdk::Color.parse(@format.text_color))

		@header_tag.font = @format.header_font
		@header_tag.foreground = @format.header_color

		@verses_tag.font = @format.verses_font
		@verses_tag.foreground = @format.verses_color
		# TODO superscript
	end

	def show_verses(verses, header=nil)
		@verses = verses.clone
		@buffer.delete(@buffer.start_iter, @buffer.end_iter)
		iter = @buffer.start_iter
		@buffer.insert(iter, header + "\n", @header_tag)
		i = 0
		verses.each do |ref|
			pos = 0
			while @format.paragraph_code[pos..pos] != '' and @format.paragraph_code[pos..pos] != nil
				case @format.paragraph_code[pos..pos]
				when '%'
					pos += 1
					case @format.paragraph_code[pos..pos]
					when 'B'
						@buffer.insert(iter, @bible.book_name(ref[0]), @verses_tag)
					when 'C'
						@buffer.insert(iter, ref[1].to_s, @verses_tag)
					when 'A'
						@buffer.insert(iter, @bible.abbr(ref[0]), @verses_tag)
					when 'V'
						@buffer.insert(iter, ref[2].to_s, @verses_tag)
					when 'T'
						@buffer.insert(iter, @bible.verse(ref[0], ref[1], ref[2]), @tags[i])
					when 'K'
						@buffer.insert(iter, @bible.verse(ref[0], ref[1], ref[2]), @tags[i])
					when 'n'
						@buffer.insert(iter, "\n", @tags[i])
					when 'p'
						@buffer.insert(iter, "\n", @tags[i])
					else
						@buffer.insert(iter, @format.paragraph_code[pos-1..pos])
					end
				else
					# TODO optimize to get all chars at once
					@buffer.insert(iter, @format.paragraph_code[pos..pos])
				end
				pos += 1
			end
			i += 1
		end
	end

	def select_verse(book, chapter, verse)
		a = @verses.index([book, chapter, verse])
		return if a == nil
		@tags[a].background_set = true
		@tags[a].background = '#D0FFFF'
	end

end
