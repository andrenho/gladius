class View < Gtk::HPaned

	attr_accessor :menu_item

	def initialize(label_text)
		super()

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
	end

	def close
		return $main.delete_view(self)
	end

	def save; raise 'Implement this method'; end
	def save_as; raise 'Implement this method'; end
	def revert; raise 'Implement this method'; end
	def print_preview; raise 'Implement this method'; end
	def print; raise 'Implement this method'; end
	def properties; raise 'Implement this method'; end
	def undo; raise 'Implement this method'; end
	def redo; raise 'Implement this method'; end
	def cut; raise 'Implement this method'; end
	def copy; raise 'Implement this method'; end
	def paste; raise 'Implement this method'; end
	def find; raise 'Implement this method'; end
	def find_next; raise 'Implement this method'; end
	def replace; raise 'Implement this method'; end


end
