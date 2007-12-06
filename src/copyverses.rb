class CopyVerses < Gtk::Window

	def initialize(bible, verses='')
		super()
		@bible = bible
		@format = Format.new

		if OS == :win32
			@format.text_font = 'Lucida Console 9'
		else
			@format.text_font = 'monospace 9'
		end
		@format.verses_font = @format.text_font
		@format.paragraph_code = FormatOptions::INDIVIDUAL_VERSES
		@format.show_header = false

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
		@options.tabs.remove_page(0)

		instruction = Gtk::Label.new(_('Type below the references of the verses you want to copy, and then click on \'Apply\'.'))
		instruction.wrap = true
		instruction.width_request = 120
		frame = Gtk::Frame.new(_('Verses to copy'))
		buffer = Gtk::TextBuffer.new
		buffer.text = verses
		@text = Gtk::TextView.new(buffer)
		@text.width_request = 120
		@text.signal_connect('key-press-event') do |w, e|
			update_sample if e.keyval == 65293 # Enter
			false
		end
		scroll = Gtk::ScrolledWindow.new
		scroll.shadow_type = Gtk::SHADOW_IN
		scroll.add(@text)
		@error = Gtk::Label.new
		@error.markup = '<span foreground="red" weight="bold">' + _('There was a error parsing one of the verses supplied.') + '</span>'
		@error.wrap = true
		@error.width_request = 120
		apply = Gtk::Button.new(Gtk::Stock::APPLY)
		apply.signal_connect('clicked') do
			update_sample
		end

		vbox_frame = Gtk::VBox.new(false, 6)
		vbox_frame.border_width = 6
		vbox_frame.pack_start(instruction, false, false)
		vbox_frame.pack_start(scroll, true, true)
		vbox_frame.pack_start(@error, false, false)
		vbox_frame.pack_start(apply, false, false)
		frame.add(vbox_frame)

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

		update_sample

		show_all
		@error.hide
	end

	def update_sample
		$main.window.cursor = Gdk::Cursor.new(Gdk::Cursor::WATCH)
		window.cursor = Gdk::Cursor.new(Gdk::Cursor::WATCH) if window != nil
		Gtk.main_iteration
		verses, ok = @bible.parse(@text.buffer.text)
		$main.window.cursor = nil 
		window.cursor = nil if window != nil
		Gtk.main_iteration

		if verses.length > 200
			# TODO progress bar
		end

		@options.text.show_verses(verses)
		if ok
			@error.hide
		else
			@error.show
		end
	end

	def copy_verses
		clipboard = Gtk::Clipboard.get(Gdk::Selection::CLIPBOARD)
		clipboard.text = @options.text.buffer.text
		Util.infobox(_("The text was copied to the clipboard."))
	end

end
