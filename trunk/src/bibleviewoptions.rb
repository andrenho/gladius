class BibleviewOptions < Gtk::Window

	def initialize(bibleview, page)
		super()
		@bibleview = bibleview
		add_controls
	end

private

	def add_controls
		set_title(_('Bible preferences'))
		set_border_width(6)
		
		vbox = Gtk::VBox.new(false, 6)
		options = FormatOptions.new(self, @bibleview.bible)

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

		vbox.pack_start(options, false, false)
		vbox.pack_start(button_box, false, false)
		add(vbox)

		show_all
	end

	def ok_clicked
	end

end
