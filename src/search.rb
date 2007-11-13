class Search < View

	EXACT     = 0
	ALL_WORDS = 1
	ANY_WORDS = 2
	
	ALL         = 0
	PENTATEUCH  = 1
	HISTORICALS = 2
	WISDOM      = 3
	PROPHETS    = 4
	GOSPELS     = 5
	ACTS        = 6
	EPISTOLS    = 7
	REVELATION  = 8

	def initialize(bibleview, text, match, partial, range)
		super(_('Search Results') + ': ' + text)
		@search_vbox = Gtk::VBox.new(false, 12)
		search_label = Gtk::Label.new(_('Searching...'))
		search_image = Gtk::Image.new("#{IMG}/book.gif")
		search_cancel = Gtk::Button.new(Gtk::Stock::CANCEL)
		af = Gtk::AspectFrame.new('', 0.5, 0.5, 1, true)
		af.shadow_type = Gtk::SHADOW_NONE
		af.add(search_cancel)
		@search_vbox.pack_start(search_label, false, false)
		@search_vbox.pack_start(search_image, false, false)
		@search_vbox.pack_start(af, false, false)
		@vbox.pack_start(@search_vbox, true, false)
		show_all
		Thread.abort_on_exception = true
		@tags = {}
		thread = Thread.new do
			rs = bibleview.bible.search(text, match, partial, range)
			show_results(rs)
		end
		search_cancel.signal_connect('clicked') do
			thread.kill
			close
		end
		@previous = nil
		@last_mark_set = nil
		@search_term = text
		@bible = bibleview.bible
	end

	def show_results(rs)
		# text buffer
		@buffer = Gtk::TextBuffer.new
		@found_tag = @buffer.create_tag(nil, { :weight => Pango::FontDescription::WEIGHT_BOLD })
		@found_tag.priority = 0

		found_iters = []
		iter = @buffer.start_iter
		rs.each do |row|
			@tags[[row['book'].to_i, row['chapter'].to_i, row['verse'].to_i]] = @buffer.create_tag(nil, {})
			reference = "#{row['abbr']} #{row['chapter']}:#{row['verse']} "
			@buffer.insert(iter, reference)
			@buffer.insert(iter, row['text'], @tags[[row['book'].to_i, row['chapter'].to_i, row['verse'].to_i]])
			get_ranges(row['text'], @search_term).each do |rg|
				it_start = @buffer.get_iter_at_line_offset(iter.line, rg.first + reference.length)
				it_end = @buffer.get_iter_at_line_offset(iter.line, rg.last + reference.length)
				@buffer.apply_tag(@found_tag, it_start, it_end)
			end
			@buffer.insert(iter, "\n", @tags[[row['book'].to_i, row['chapter'].to_i, row['verse'].to_i]])
		end

		# click event
		@buffer.signal_connect('mark-set') do |w, iter, mark|
			# TODO this is repeating several times
			tag = nil
			iter.tags.each { |t| tag = t if t != @found_tag }
			if tag != nil
				tx = @tags.index(tag)
				$main.go_to(tx[0], tx[1])
				$main.select_verse(tx[2])
				$main.books.go_to(tx[0], tx[1])
				if @previous != nil
					@previous.background_set = false
				end
				tag.background = '#D0FFFF'
				tag.background_set = true
				@previous = tag
			end
		end

		# text view
		@textview = Gtk::TextView.new(@buffer)
		@textview.editable = false
		@textview.wrap_mode = Gtk::TextTag::WRAP_WORD
		@textview.pixels_below_lines = 15
		if $config[@bible.abbr, 'font'] == nil
			@textview.modify_font(Pango::FontDescription.new('Serif 11'))
		else
			@textview.modify_font(Pango::FontDescription.new($config[@bible.abbr, 'font']))
		end
		scroll = Gtk::ScrolledWindow.new
		scroll.add(@textview)
		scroll.show_all
		@vbox.remove(@search_vbox)
		@vbox.pack_start(scroll)
	end
	private :show_results

	def go_to(x, y); end

	def select_verse(v)
		tx = @tags[[$main.current_book, $main.current_chapter, v]]
		if @previous != nil
			@previous.background_set = false
		end
		if tx != nil
			tx.background = '#D0FFFF'
			tx.background_set = true
			@previous = tx
		else
			@previous = nil
		end
	end

	def get_ranges(text, search)
		r = []
		search.split.each do |word|
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
