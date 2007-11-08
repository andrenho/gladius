class BibleView < Gtk::HPaned

	attr_reader :bible
	attr_accessor :menu_item

	def initialize(bible)
		super()

		framebase = Gtk::Frame.new
		pack1(framebase, true, true)
		framebase.shadow_type = Gtk::SHADOW_IN

		@bible = bible

		vbox = Gtk::VBox.new

		# title
		frame = Gtk::Frame.new
		frame.shadow_type = Gtk::SHADOW_OUT
		label = Gtk::Label.new(@bible.name)
		label.set_alignment(0, 0.5)
		label.ypad = 2
		hbox = Gtk::HBox.new
		hbox.pack_start(label, true, true, 5)

		# Search button
		@search_button = Gtk::ToggleButton.new
		@search_button.add(Gtk::Image.new(Gtk::Stock::FIND, Gtk::IconSize::MENU))
		@search_button.relief = Gtk::RELIEF_NONE
		hbox.pack_start(@search_button, false, false)

		# Close button
		close_button = Gtk::Button.new
		close_button.add(Gtk::Image.new(Gtk::Stock::CLOSE, Gtk::IconSize::MENU))
		close_button.relief = Gtk::RELIEF_NONE
		close_button.signal_connect('clicked') { close }
		hbox.pack_start(close_button, false, false)
		frame.add(hbox)

		# Search menu
		create_search_frame

		vbox.pack_start(frame, false, false)
		vbox.pack_start(@search_frame, false, false)

		# text buffer
		@buffer = Gtk::TextBuffer.new
		@textview = Gtk::TextView.new(@buffer)
		@textview.editable = false
		@textview.wrap_mode = Gtk::TextTag::WRAP_WORD
		@textview.pixels_below_lines = 10
		@textview.modify_font(Pango::FontDescription.new('Serif 12'))
		scroll = Gtk::ScrolledWindow.new
		scroll.add(@textview)
		vbox.pack_start(scroll)

		@tags = []
		(1..176).each do |n|
			@tags[n] = @buffer.create_tag("verse#{n}", {
			    :background_full_height => true,
			})
		end
		@last_verse = 1

		@buffer.signal_connect('mark-set') do |w, iter, mark|
			if iter.tags != []
				n = @tags.index(iter.tags[0])
				$main.select_verse(n)
			end
		end

		framebase.add(vbox)
		
		show_all
		@search_frame.visible = false

		begin
			verse = $main.current_verse
			go_to($main.current_book, $main.current_chapter)
			select_verse(verse)
			$main.select_verse(verse)
		rescue
		end
	end

	def go_to(book, chapter)
		@marks = []
		@buffer.delete(@buffer.start_iter, @buffer.end_iter)
		text = ''
		iter = @buffer.start_iter
		verse = 1
		while text != nil
			text = @bible.verse(book, chapter, verse)
			if text != nil
				@marks[verse] = @buffer.create_mark(nil, iter, true)
				@buffer.insert(iter, verse.to_s)
				@buffer.insert(iter, '. ')
				@buffer.insert(iter, text, @tags[verse])
				@buffer.insert(iter, "\n", @tags[verse])
				verse += 1
			end
		end
		begin
			$main.select_verse(1)
		rescue; end
	end

	def select_verse(verse)
		if @last_verse > 0
			@tags[@last_verse].background_set = false
			@tags[@last_verse].paragraph_background_set = false
		end
		@tags[verse].background_set = true
		@tags[verse].background = '#D0FFFF'
		@tags[verse].paragraph_background = '#D0FFFF'
		@tags[verse].paragraph_background_set = true
		@last_verse = verse
		@textview.scroll_to_mark(@marks[verse], 0.1, false, 0, 0.3)
	end

	def close
		$main.delete_view(self)
		@menu_item.sensitive = true
	end

	def create_search_frame
		@search_frame = Gtk::Frame.new
		@search_button.signal_connect('toggled') { @search_frame.visible = @search_button.active? }
		@search_frame.shadow_type = Gtk::SHADOW_OUT
		search_hbox = Gtk::HBox.new

		# label
		search_label = Gtk::Label.new(_('Search'))
		search_label.set_alignment(0, 0.5)
		search_label.ypad = 2
		search_hbox.pack_start(search_label, false, false, 5)

		# search entry
		search_entry = Gtk::Entry.new
		search_entry.width_chars = 10
		search_hbox.pack_start(search_entry, false, false, 5)

		# all words/any words/exact phrase

		# partial match

		# range

		@search_frame.add(search_hbox)
		search_hbox.show_all
		@search_frame.visible = false
	end

end
