class VersePart
	VERSE = 1
	TEXT  = 2
	OTHER = 3

	attr_accessor :type
	attr_accessor :verse
	attr_accessor :text
	attr_accessor :first_letter_bold
	attr_accessor :begin, :end

	def initialize
		@first_letter_bold = false
	end
end


class BibleText < Gtk::ScrolledWindow

	attr_reader :buffer

	#
	# Initialize the Bible Text
	#
	def initialize(bible, format, view)
		super()
		set_shadow_type(Gtk::SHADOW_IN)

		@bible = bible
		@format = format
		@view = view

		# Create buffer and textview
		@buffer = Gtk::TextBuffer.new
		@textview = Gtk::TextView.new(@buffer)
		@textview.editable = false
		@textview.wrap_mode = Gtk::TextTag::WRAP_WORD
		@textview.pixels_below_lines = 10

		# Connect events - for menu refitting
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

		# Connect events - to change selected verses
		# TODO - try to be faster (?)
		@textview.signal_connect('button_release_event') do |w, e|
			iter = @buffer.get_iter_at_mark(@buffer.get_mark('insert'))
			cursor_changed(iter)
			false
		end
		@textview.signal_connect('key_release_event') do |w, e|
			iter = @buffer.get_iter_at_mark(@buffer.get_mark('insert'))
			cursor_changed(iter)
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
<<<<<<< .mine

=======
		@h = @buffer.signal_connect('mark-set') do |w, iter, mark|
			offset = iter.offset
			@parts.each { |part| p part.verse if offset.between? part.begin, part.end }
		end
>>>>>>> .r52
		@found_tag = @buffer.create_tag(nil, { :weight => Pango::FontDescription::WEIGHT_BOLD })
		@tag_paragraph = @buffer.create_tag(nil, { :weight => Pango::FontDescription::WEIGHT_BOLD })
		@selected_tag = @buffer.create_tag(nil, {})
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
			@verses_tag.rise = (4 * Pango::SCALE)
		else
			@verses_tag.rise = 0
		end

<<<<<<< .mine
		@selected_tag.background = @format.text_bg_color

		show_verses(@paragraphs, @header) if rewrite
=======
		show_verses(@paragraphs, @header) if rewrite
>>>>>>> .r52
	end


	#
	# Clear the text box, and display the verses that are passed as an array
	#
	def show_verses(paragraphs, header=nil, search_terms=nil)
		@paragraphs = paragraphs
		@header = header

<<<<<<< .mine
		p @view
		p "Create verses"

		# create verses
		@parts = []
		i = 0
		paragraphs.each do |paragraph|
			next_letter_bold = false
			paragraph.each do |verse|
				@format.parsed_paragraph_code.each do |ppc|
					add = false
					if ppc.bop 
						add = true if verse == paragraph.first
					elsif ppc.eop
						add = true if verse == paragraph.last
					else 
						add = true
					end
					if add
						if ppc.type == ParsedParagraphCode::ATTRIBUTE
							next_letter_bold = true if ppc.value == '%k'
						else
							vp = VersePart.new
							vp.verse = verse if not ppc.bop and not ppc.eop
							if ppc.type == ParsedParagraphCode::TEXT
								vp.type = VersePart::OTHER
								vp.text = ppc.value
							elsif ppc.type == ParsedParagraphCode::TOKEN
								vp.type = VersePart::VERSE
								case ppc.value
								when '\\n'
									vp.text = "\n"
								when '%B'
									vp.text = @bible.book_name(verse[0])
								when '%A'
									vp.text = @bible.book_abbr(verse[0])
								when '%C'
									vp.text = verse[1].to_s
								when '%V'
									vp.text = ''
									vp.text = "#{paragraph[0][2]}-" if ppc.eop
									vp.text += verse[2].to_s
								when '%T'
									vp.type = VersePart::TEXT
									if verse[3] != nil
										vp.text = verse[3]
									else
										vp.text = @bible.verse(verse[0], verse[1], verse[2])
									end
									if next_letter_bold
										vp.first_letter_bold = true
										next_letter_bold = false
									end
								end
							end
							i += vp.text.length if vp.text != nil
							@parts << vp
						end
					end
				end		
=======
		# create verses
		@parts = []
		i = 0
		paragraphs.each do |paragraph|
			next_letter_bold = false
			paragraph.each do |verse|
				@format.parsed_paragraph_code.each do |ppc|
					add = false
					if ppc.bop 
						add = true if verse == paragraph.first
					elsif ppc.eop
						add = true if verse == paragraph.last
					else 
						add = true
					end
					if add
						if ppc.type == ParsedParagraphCode::ATTRIBUTE
							next_letter_bold = true if ppc.value == '%k'
						else
							vp = VersePart.new
							vp.verse = verse if not ppc.bop and not ppc.eop
							vp.begin = i
							if ppc.type == ParsedParagraphCode::TEXT
								vp.type = VersePart::OTHER
								vp.text = ppc.value
							elsif ppc.type == ParsedParagraphCode::TOKEN
								vp.type = VersePart::VERSE
								case ppc.value
								when '\\n'
									vp.text = "\n"
								when '%B'
									vp.text = @bible.book_name(verse[0])
								when '%A'
									vp.text = @bible.book_abbr(verse[0])
								when '%C'
									vp.text = verse[1].to_s
								when '%V'
									vp.text = ''
									vp.text = "#{paragraph[0][2]}-" if ppc.eop
									vp.text += verse[2].to_s
								when '%T'
									vp.type = VersePart::TEXT
									if verse[3] != nil
										vp.text = verse[3]
									else
										vp.text = @bible.verse(verse[0], verse[1], verse[2])
									end
									if next_letter_bold
										vp.first_letter_bold = true
										next_letter_bold = false
									end
								end
							end
							i += vp.text.length
							vp.end = i - 1
							@parts << vp
						end
					end
				end		
>>>>>>> .r52
			end
		end

<<<<<<< .mine
		p @view
		p "Show verses"

		# Show verses
=======
		# Show verses
>>>>>>> .r52
		@buffer.delete(@buffer.start_iter, @buffer.end_iter)
		iter = @buffer.start_iter
<<<<<<< .mine
		@buffer.insert(iter, header + "\n", @header_tag) if @format.show_header and header != nil
		@parts.each do |vp|
			vp.begin = iter.offset
			if vp.type == VersePart::VERSE
				@buffer.insert(iter, vp.text, @verses_tag)
=======
		@parts.each do |vp|
			if vp.type == VersePart::VERSE
				@buffer.insert(iter, vp.text, @verses_tag)
>>>>>>> .r52
			else
				if vp.first_letter_bold
					@buffer.insert(iter, vp.text[0..0], @tag_paragraph)
					@buffer.insert(iter, vp.text[1..-1])
				else
					@buffer.insert(iter, vp.text)
				end
			end
			vp.end = iter.offset
		end

		p @view
		p "Search terms"

		# Search terms
		if search_terms != nil
			search_terms.each do |term|
				i = []
				i[1] = @buffer.start_iter
				while (i = i[1].forward_search(term, Gtk::TextIter::SEARCH_TEXT_ONLY, nil)) != nil
					@buffer.apply_tag(@found_tag, i[0], i[1])
				end
			end
		end
	end


	#
	# Select the given verse
	#
	def select_verse(book, chapter, verse)
<<<<<<< .mine
		@parts.each do |part|
			if part.verse
				if part.verse[0..2] == @last_selected
					@buffer.remove_tag(
						@selected_tag, 
						@buffer.get_iter_at_offset(part.begin),
						@buffer.get_iter_at_offset(part.end)
					)
				end
				if part.verse[0..2] == [book, chapter, verse]
					bgn = @buffer.get_iter_at_offset(part.begin)
					@buffer.apply_tag(
						@selected_tag, 
						bgn,
						@buffer.get_iter_at_offset(part.end)
					)
					@textview.scroll_to_iter(bgn, 0.1, false, 0, 0.3)
				end
=======
=begin
#		@buffer.signal_handler_block(@h) do
			if @last_selected != [book, chapter, verse] and @last_selected != []
				@tags[@last_selected].background_set = false if @tags[@last_selected] != nil
>>>>>>> .r52
			end
		end
		@last_selected = [book, chapter, verse]
=end
	end


	# 
	# Cursor has changed position
	#
	def cursor_changed(iter)
		verse = []
		@parts.each do |part| 
			verse = part.verse if iter.offset.between? part.begin, part.end
		end
		if @view.kind_of? View
			if verse != @last_ref
				$main.select_verse(verse[0], verse[1], verse[2]) if verse != [] and verse != nil
				@last_ref = verse
			end
		elsif @view.class == BibleviewOptions
			if verse != @last_ref
				@last_ref = verse
				select_verse(verse[0], verse[1], verse[2]) if verse
			end
		end
	end

end
