class BibleView < Gtk::Frame

	def initialize(bible)
		super(nil)
		shadow_type = Gtk::SHADOW_IN

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
		frame.add(hbox)
		vbox.pack_start(frame, false, false)

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

		add(vbox)

		go_to(1, 1)
	end

	def go_to(book, chapter, verse=1)
		@buffer.text = ''
		text = ''
		while text != nil
			text = @bible.verse(book, chapter, verse)
			if text != nil
				@buffer.insert_at_cursor(verse.to_s)
				@buffer.insert_at_cursor('. ')
				@buffer.insert_at_cursor(text)
				@buffer.insert_at_cursor("\n")
				verse += 1
			end
		end
	end

end
