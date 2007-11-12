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

	def initialize(bible, text, match, partial, range)
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
			rs = bible.search(text, match, partial, range)
			show_results(rs)
		end
		search_cancel.signal_connect('clicked') do
			thread.kill
			close
		end
		@previous = nil
		@last_mark_set = nil
	end

	def show_results(rs)
		# text buffer
		@buffer = Gtk::TextBuffer.new
		found_tag = @buffer.create_tag(nil, { :weight => Pango::FontDescription::WEIGHT_BOLD })
		found_tag.priority = 0

		found_iters = []
		iter = @buffer.start_iter
		rs.each do |row|
			@tags[[row['book'].to_i, row['chapter'].to_i, row['verse'].to_i]] = @buffer.create_tag(nil, {})
			reference = "#{row['abbr']} #{row['chapter']}:#{row['verse']} "
			@buffer.insert(iter, reference)
			@buffer.insert(iter, row['text']) #, @tags[[row['book'].to_i, row['chapter'].to_i, row['verse'].to_i]])
			get_ranges().each do |rg|
				it_start = @buffer.get_iter_at_line_offset(iter.line, rg.first + reference.length)
				it_end = @buffer.get_iter_at_line_offset(iter.line, rg.first + reference.length)
				found_iters << [it_start.offset, it_end.offset]
			end
			@buffer.insert(iter, "\n", @tags[[row['book'].to_i, row['chapter'].to_i, row['verse'].to_i]])
		end

		# click event
		@buffer.signal_connect('mark-set') do |w, iter, mark|
			# TODO this is repeating several times
			if iter.tags != []
				tx = @tags.index(iter.tags[0])
				$main.go_to(tx[0], tx[1])
				$main.select_verse(tx[2])
				$main.books.go_to(tx[0], tx[1])
				if @previous != nil
					@previous.background_set = false
				end
				iter.tags[0].background = '#D0FFFF'
				iter.tags[0].background_set = '#D0FFFF'
				@previous = iter.tags[0]
			end
		end

		# text view
		@textview = Gtk::TextView.new(@buffer)
		@textview.editable = false
		@textview.wrap_mode = Gtk::TextTag::WRAP_WORD
		@textview.pixels_below_lines = 15
		@textview.modify_font(Pango::FontDescription.new('Serif 11'))
		scroll = Gtk::ScrolledWindow.new
		scroll.add(@textview)
		scroll.show_all
		@vbox.remove(@search_vbox)
		@vbox.pack_start(scroll)

		while (Gtk.events_pending?)
		  Gtk.main_iteration
		end
		found_iters.each do |iters|
			p iters
			@buffer.apply_tag(found_tag, @buffer.get_iter_at_offset(iters[0]), @buffer.get_iter_at_offset(iters[1]))
		end
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

	def get_ranges()
		return [(10..15)]
	end
	private :get_ranges

end
