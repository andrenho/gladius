class BibleviewOptions < Gtk::Window

	def initialize(bibleview, page, book, chapter)
		super()
		@bibleview = bibleview
		add_controls(book, chapter, page)
	end

private

	def add_controls(book, chapter, page)
		set_title(_('Bible preferences'))
		set_border_width(6)
		set_default_height(560)
		
		vbox = Gtk::VBox.new(false, 6)
		@options = FormatOptions.new(@bibleview.format, self, @bibleview.bible, book, chapter, page)

		button_box = Gtk::HButtonBox.new
		button_box.layout_style = Gtk::ButtonBox::END
		button_box.spacing = 6
		ok = Gtk::Button.new(Gtk::Stock::OK)
		ok.signal_connect('clicked') { ok_clicked }
		cancel = Gtk::Button.new(Gtk::Stock::CANCEL)
		cancel.signal_connect('clicked') { self.destroy }
		button_box.pack_start(cancel)
		button_box.pack_start(ok)
		set_default(ok)

		vbox.pack_start(@options, true, true)
		vbox.pack_start(button_box, false, false)
		add(vbox)

		show_all
	end

	def ok_clicked
		@options.format.save(@bibleview.bible.abbr)
		@bibleview.format = @options.format
		self.destroy
	end

end
