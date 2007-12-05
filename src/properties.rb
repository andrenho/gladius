class Properties < Gtk::Window

	def initialize(*pairs)
		super()
		set_title(_('Properties'))
		set_border_width(6)
		set_modal(true)
		set_transient_for($main)
		set_resizable(false)
		set_size_request(300, 400)

		table = Gtk::Table.new(pairs.length, 2)
		table.row_spacings = table.column_spacings = 6
		table.border_width = 6
		i = 0
		pairs.each do |pair|
			label = Gtk::Label.new(pair[0])
			table.attach(label, 0, 1, i, i+1, Gtk::SHRINK, Gtk::SHRINK)
			if pair[0] == _('Comment')
				scroll = Gtk::ScrolledWindow.new
				scroll.shadow_type = Gtk::SHADOW_IN
				buffer = Gtk::TextBuffer.new
				entry = Gtk::TextView.new(buffer)
				entry.wrap_mode = Gtk::TextTag::WRAP_WORD
				scroll.add(entry)
				buffer.text = pair[1]
				table.attach(scroll, 1, 2, i, i+1)
			else
				entry = Gtk::Entry.new
				entry.text = pair[1]
				table.attach(entry, 1, 2, i, i+1, Gtk::EXPAND|Gtk::FILL, Gtk::SHRINK)
			end
			i += 1
		end

		tab = Gtk::Notebook.new
		tab.append_page(table, Gtk::Label.new(_('Properties')))

		ok = Gtk::Button.new(Gtk::Stock::OK)
		ok.flags = Gtk::Widget::CAN_DEFAULT
		ok.signal_connect('clicked') { self.destroy }
		button_box = Gtk::HButtonBox.new
		button_box.layout_style = Gtk::ButtonBox::END
		button_box.spacing = 6
		button_box.pack_start(ok)

		vbox = Gtk::VBox.new(false, 6)
		vbox.pack_start(tab, true, true)
		vbox.pack_start(button_box, false, false)

		add(vbox)
		set_default(ok)
		self.show_all
	end

end
