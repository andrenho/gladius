class BibleText < Gtk::ScrolledWindow

	attr_reader :buffer

	#
	# Initialize the Bible Text
	#
	def initialize(bible, format, view)
		super()
		@bible = bible
		@format = format
		@view = view

		# Create buffer and textview
		@buffer = Gtk::TextBuffer.new
		@textview = Gtk::TextView.new(@buffer)
		@textview.editable = false
		@textview.wrap_mode = Gtk::TextTag::WRAP_WORD
		@textview.pixels_below_lines = 10

		# Connect events
		@textview.signal_connect('focus_in_event') do 
			view.refit_menus if view.kind_of? View
		end
		@textview.signal_connect('button_release_event') do |w, e| 
			view.refit_menus if view.kind_of? View
			false
		end
		@textview.signal_connect('key_release_event') do |w, e| 
			view.refit_menus if view.kind_of? View
			false
		end

		@last_ref = -1
		@last_selected = []

		initialize_tags
		set_format

		self.add(@textview)
	end


	#
	# Initialize format tags (but do not adjust them)
	#
	def initialize_tags
		@header_tag = @buffer.create_tag(nil, {})
		@verses_tag = @buffer.create_tag(nil, {})
		@tag_bank = []
		(0..200).each do |n|
			@tag_bank[n] = @buffer.create_tag(nil, {})
		end
		@buffer.signal_connect('mark-set') do |w, iter, mark|
			if iter.tags != []
				ref = @tags.index(iter.tags[0])
				if @view.kind_of? View
					if ref != @last_ref
						$main.select_verse(ref[0], ref[1], ref[2]) if ref != nil
						@last_ref = ref
					end
				elsif @view.class == BibleviewOptions
					if ref != @last_ref
						@last_ref = ref
						select_verse(ref[0], ref[1], ref[2]) if ref
					end
				end
			end
		end
		@found_tag = @buffer.create_tag(nil, { :weight => Pango::FontDescription::WEIGHT_BOLD })
		@tag_paragraph = @buffer.create_tag(nil, { :weight => Pango::FontDescription::WEIGHT_BOLD })
	end


	#
	# Adjust format tag
	#
	def set_format(format=nil, rewrite=false)
		@format = format if format != nil
		@textview.modify_font(Pango::FontDescription.new(@format.text_font))
		@textview.modify_text(Gtk::STATE_NORMAL, Gdk::Color.parse(@format.text_color))

		@header_tag.font = @format.header_font
		@header_tag.foreground = @format.header_color

		@verses_tag.font = @format.verses_font
		@verses_tag.foreground = @format.verses_color
		if @format.verses_ss
			@verses_tag.size = (@verses_tag.size.to_f * 0.67).to_i
			@verses_tag.rise = (6 * Pango::SCALE)
		else
			#@verses_tag.size = @format.verses_font.split.last.to_i
			@verses_tag.rise = 0
		end
		# TODO superscript

		@tag_bank.each do |tag|
			tag.background = @format.text_bg_color
			tag.background_set = false
		end

		show_verses(@verses, @header) if rewrite
	end


	#
	# Clear the text box, and display the verses that are passed as an array
	#
	def show_verses(verses, header=nil, search_terms=nil)
		if @tags != nil
			@tags[@last_selected].background_set = false if @tags[@last_selected] != nil
		end

		# create tags for more than 200 verses
		if verses.length > 200
			(201..verses.length + 2).each do |n|
				@tag_bank[n] = @buffer.create_tag(nil, {})
				@tag_bank[n].background = @format.text_bg_color
				@tag_bank[n].background_set = false
			end
		end

		@tags = {}
		@last_selected = []
		@marks = {}
		@verses = verses.clone
		@header = header
		@buffer.delete(@buffer.start_iter, @buffer.end_iter)
		iter = @buffer.start_iter
		@buffer.insert(iter, header + "\n", @header_tag) if @format.show_header and header != nil
		i = 0
		verses.each do |ref|
			@tags[ref] = @tag_bank[i]; i += 1
			@marks[[ref[0], ref[1], ref[2]]] = @buffer.create_mark(nil, iter, true)
			pos = 0
			verse, paragraph = @bible.verse(ref[0], ref[1], ref[2])
			if search_terms == nil
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
							@buffer.insert(iter, @bible.book_abbr(ref[0]), @verses_tag)
						when 'V'
							@buffer.insert(iter, ref[2].to_s, @verses_tag)
						when 'T'
							@buffer.insert(iter, verse, @tags[ref])
						when 'K'
							if bop == 1
								@buffer.insert(iter, verse[0..0], @tags[ref], @tag_paragraph)
								@buffer.insert(iter, verse[1..-1], @tags[ref])
							else
								@buffer.insert(iter, verse, @tags[ref])
							end
						when 'n'
							@buffer.insert(iter, "\n", @tags[ref])
						when 'p'
							@buffer.insert(iter, "\n", @tags[ref]) if eop == 1
						else
							@buffer.insert(iter, @format.paragraph_code[pos-1..pos])
						end
					else
						# TODO optimize to get all chars at once
						@buffer.insert(iter, @format.paragraph_code[pos..pos])
					end
					pos += 1
				end
			else
				text, tmp = @bible.verse(ref[0], ref[1], ref[2])
				reference = "#{@bible.book_abbr(ref[0])} #{ref[1].to_s}:#{ref[2].to_s}  "
				@buffer.insert(iter, reference, @verses_tag)
				@buffer.insert(iter, text, @tags[ref])
				get_ranges(text, search_terms).each do |rg|
					it_start = @buffer.get_iter_at_line_index(iter.line, rg.first + reference.length)
					it_end = @buffer.get_iter_at_line_index(iter.line, rg.last + reference.length)
					@buffer.apply_tag(@found_tag, it_start, it_end)
				end
				@buffer.insert(iter, "\n", @tags[ref])
			end
		end
	end


	#
	# Select the given verse
	#
	def select_verse(book, chapter, verse)
		if @last_selected != [book, chapter, verse] and @last_selected != []
			@tags[@last_selected].background_set = false if @tags[@last_selected] != nil
		end
		if @tags[[book, chapter, verse]] != nil
			@last_selected = [book, chapter, verse]
			@tags[[book, chapter, verse]].background_set = true
			@textview.scroll_to_mark(@marks[[book, chapter, verse]], 0.1, false, 0, 0.3)
		end
	end


	#
	# Get ranges (to bold searches)
	#
	def get_ranges(text, search_terms)
		r = []
		search_terms.split.each do |word|
			offset = text.index(word)
			while offset != nil
				r << [offset, offset + word.length]
				offset = text.index(word, offset + word.length)
			end
		end
		return r
	end
	private :get_ranges

end
