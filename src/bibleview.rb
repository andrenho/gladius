class BibleView < Gtk::HPaned

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
		close_button = Gtk::Button.new
		close_button.add(Gtk::Image.new(Gtk::Stock::CLOSE, Gtk::IconSize::MENU))
		close_button.relief = Gtk::RELIEF_NONE
		close_button.signal_connect('clicked') { close }
		hbox.pack_start(close_button, false, false)
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

		framebase.add(vbox)

		go_to(1, 1)
	end

	def go_to(book, chapter, verse=1)
		tag = @buffer.create_tag('selected', { :background => "Blue" })

		@textview.buffer = nil
		@buffer.text = ''
		text = ''
		while text != nil
			text = @bible.verse(book, chapter, verse)
			if text != nil
				@buffer.insert_at_cursor(verse.to_s)
				@buffer.insert_at_cursor('. ')
				if verse == 1
					@buffer.insert(@buffer.end_iter, text, 'selected')
				else
					@buffer.insert_at_cursor(text)
				end
				@buffer.insert_at_cursor("\n")
				verse += 1
			end
		end
		@textview.buffer = @buffer
	end

	def close
		$main.delete_view(self)
	end

end
