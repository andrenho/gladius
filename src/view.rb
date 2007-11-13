class View < Gtk::HPaned

	attr_reader :menu

	def initialize(label_text, label_menu = nil)
		super()

		@menu_item = nil

		@framebase = Gtk::Frame.new
		pack1(@framebase, true, true)
		@framebase.shadow_type = Gtk::SHADOW_IN

		@vbox = Gtk::VBox.new

		# title
		@frame = Gtk::Frame.new
		@frame.shadow_type = Gtk::SHADOW_OUT
		label = Gtk::Label.new(label_text)
		label.ellipsize = Pango::Layout::ELLIPSIZE_END
		label.set_alignment(0, 0.5)
		label.ypad = 2
		@hbox = Gtk::HBox.new
		@hbox.pack_start(label, true, true, 5)

		# Close button
		close_button = Gtk::Button.new
		close_button.add(Gtk::Image.new(Gtk::Stock::CLOSE, Gtk::IconSize::MENU))
		close_button.relief = Gtk::RELIEF_NONE
		close_button.signal_connect('clicked') { close }
		$tip.set_tip(close_button, _('Close this frame'), nil)
		@hbox.pack_end(close_button, false, false)

		@frame.add(@hbox)
		@vbox.pack_start(@frame, false, false)
		@framebase.add(@vbox)

		# Menu
		if label_menu != nil
			menuitem = Gtk::MenuItem.new(label_menu)
			@menu = Gtk::Menu.new
			menuitem.set_submenu(@menu)
			$main.menubar.append(menuitem)
		end
	end

	def close
		$main.menubar.remove(@menu)
		return $main.delete_view(self)
	end

end
