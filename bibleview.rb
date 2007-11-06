class BibleView < Gtk::Frame

	def initialize(bible)
		super(nil)
		shadow_type = Gtk::SHADOW_IN

		@bible = bible

		vbox = Gtk::VBox.new

		@buffer = Gtk::TextBuffer.new

		@textview = Gtk::TextView.new(@buffer)
		@textview.editable = false
		@textview.wrap_mode = Gtk::TextTag::WRAP_WORD
		@textview.pixels_below_lines = 10
		@textview.modify_font(Pango::FontDescription.new('Serif 12'))

		scroll = Gtk::ScrolledWindow.new
		scroll.add(@textview)
		add(scroll)

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
