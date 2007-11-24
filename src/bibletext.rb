class BibleText < Gtk::ScrolledWindow

	attr_reader :buffer

	#
	# Initialize the Bible Text
	#
	def initialize(bible, format, view=nil)
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
			view.refit_menus if view != nil
		end
		@textview.signal_connect('button_release_event') do |w, e| 
			view.refit_menus if view != nil
			false
		end
		@textview.signal_connect('key_release_event') do |w, e| 
			view.refit_menus if view != nil
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
			# TODO this is repeating several times
			if iter.tags != []
				ref = @tags.index(iter.tags[0])
				if ref != @last_ref
					$main.select_verse(ref[0], ref[1], ref[2]) if ref != nil
					@last_ref = ref
				end
			end
		end
	end


	#
	# Adjust format tag
	#
	def set_format
		@textview.modify_font(Pango::FontDescription.new(@format.text_font))
		@textview.modify_text(Gtk::STATE_NORMAL, Gdk::Color.parse(@format.text_color))

		@header_tag.font = @format.header_font
		@header_tag.foreground = @format.header_color

		@verses_tag.font = @format.verses_font
		@verses_tag.foreground = @format.verses_color
		# TODO superscript

		@tag_bank.each do |tag| 
			tag.background = '#D0FFFF'
			tag.background_set = false
		end
	end


	#
	# Clear the text box, and display the verses that are passed as an array
	#
	def show_verses(verses, header=nil)
		if @tags != nil
			@tags[@last_selected].background_set = false if @tags[@last_selected] != nil
		end
		@tags = {}
		@last_selected = []
		@marks = {}
		@verses = verses.clone
		@buffer.delete(@buffer.start_iter, @buffer.end_iter)
		iter = @buffer.start_iter
		@buffer.insert(iter, header + "\n", @header_tag)
		i = 0
		verses.each do |ref|
			@tags[ref] = @tag_bank[i]; i += 1
			@marks[[ref[0], ref[1], ref[2]]] = @buffer.create_mark(nil, iter, true)
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
						@buffer.insert(iter, @bible.verse(ref[0], ref[1], ref[2]), @tags[ref])
					when 'K'
						@buffer.insert(iter, @bible.verse(ref[0], ref[1], ref[2]), @tags[ref])
					when 'n'
						@buffer.insert(iter, "\n", @tags[ref])
					when 'p'
						@buffer.insert(iter, "\n", @tags[ref])
					else
						@buffer.insert(iter, @format.paragraph_code[pos-1..pos])
					end
				else
					# TODO optimize to get all chars at once
					@buffer.insert(iter, @format.paragraph_code[pos..pos])
				end
				pos += 1
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

end
