class CopyVerses < Gtk::Window

	def initialize(bible, verses='')
		super()
		@bible = bible
		@format = Format.new
		add_controls(verses)
	end

private

	def add_controls(verses)
		set_title(_('Copy Verses'))
		set_border_width(6)
		set_default_height(560)
		
		vbox = Gtk::VBox.new(false, 6)
		hbox = Gtk::HBox.new(false, 6)

		@options = FormatOptions.new(@format, self, @bible)

		frame = Gtk::Frame.new(_('Verses to copy'))
		buffer = Gtk::TextBuffer.new
		buffer.text = verses
		@text = Gtk::TextView.new(buffer)
		@text.width_request = 120
		scroll = Gtk::ScrolledWindow.new
		scroll.shadow_type = Gtk::SHADOW_IN
		scroll.border_width = 6
		scroll.add(@text)
		frame.add(scroll)

		@text.signal_connect('focus-out-event') do
			update_sample
			false
		end
		@text.signal_connect('key-press-event') do |w, e|
			update_sample if e.keyval == 65293 # Enter
			false
		end

		button_box = Gtk::HButtonBox.new
		button_box.layout_style = Gtk::ButtonBox::END
		button_box.spacing = 6
		copy = Gtk::Button.new(Gtk::Stock::COPY)
		copy.signal_connect('clicked') { copy_verses }
		cancel = Gtk::Button.new(Gtk::Stock::CANCEL)
		cancel.signal_connect('clicked') { self.destroy }
		button_box.pack_start(cancel)
		button_box.pack_start(copy)

		hbox.pack_start(frame, true, true)
		hbox.pack_start(@options, false, false)

		vbox.pack_start(hbox, true, true)
		vbox.pack_start(button_box, false, false)
		add(vbox)

		show_all
	end

	def update_sample
		verses = @bible.parse(@text.buffer.text)
		@options.text.show_verses(verses)
	end

	def copy_verses
	end

end
