class View < Gtk::HPaned

	attr_accessor :menu_item
	attr_reader :close_button

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
		@close_button = Gtk::Button.new
		@close_button.add(Gtk::Image.new(Gtk::Stock::CLOSE, Gtk::IconSize::MENU))
		@close_button.relief = Gtk::RELIEF_NONE
		@close_button.signal_connect('clicked') { close }
		$tip.set_tip(@close_button, _('Close this frame'), nil)
		@hbox.pack_end(@close_button, false, false)

		@frame.add(@hbox)
		@vbox.pack_start(@frame, false, false)
		@framebase.add(@vbox)
	end

	def close
		return $main.delete_view(self)
	end

	def copy
		current_buffer.copy_clipboard(Gtk::Clipboard.get(Gdk::Selection::CLIPBOARD))
	end

	def find
		w = Gtk::Window.new
		w.set_title(_('Find'))
		w.border_width = 6
		# w.modal = true
		w.transient_for = self
		w.resizable = false

		find_label = Gtk::Label.new(_('Find'))
		
		entry = Gtk::Entry.new
		entry.activates_default = true
		check_below = Gtk::RadioButton.new(_('_Below'), true)
		check_above = Gtk::RadioButton.new(check_below, _('_Above'), true)
		find = Gtk::Button.new(Gtk::Stock::FIND)
		find.flags = Gtk::Widget::CAN_DEFAULT
		cancel = Gtk::Button.new(Gtk::Stock::CANCEL)
		cancel.signal_connect('clicked') { w.destroy }

		hbox_frame = Gtk::HBox.new(false, 6)
		hbox_frame.border_width = 6
		hbox_frame.pack_start(check_below, false, false)
		hbox_frame.pack_start(check_above, false, false)
		frame = Gtk::Frame.new(_('Direction'))
		frame.shadow_type = Gtk::SHADOW_ETCHED_IN
		frame.add(hbox_frame)

		button_box = Gtk::VButtonBox.new
		button_box.spacing = 6
		button_box.layout_style = Gtk::ButtonBox::START
		button_box.pack_start(find, false, false)
		button_box.pack_start(cancel, false, false)

		table = Gtk::Table.new(2, 3)
		table.row_spacings = table.column_spacings = 6
		table.attach(find_label, 0, 1, 0, 1, Gtk::SHRINK, Gtk::SHRINK)
		table.attach(entry, 1, 2, 0, 1)
		table.attach(frame, 1, 2, 1, 2, Gtk::SHRINK, Gtk::SHRINK)
		table.attach(button_box, 2, 3, 0, 2)

		w.signal_connect('key-press-event') do |w, e|
			w.destroy if e.keyval == Gdk::Keyval::GDK_Escape
		end

		w.add(table)
		w.default = find
		w.show_all

		find.signal_connect('clicked') do
			buffer = current_buffer
			return if entry.text == ''
			current = buffer.get_iter_at_offset(buffer.get_iter_at_mark(buffer.get_mark('insert')).offset + 1)
			if check_below.active?
				found = current.forward_search(entry.text, Gtk::TextIter::SEARCH_TEXT_ONLY, nil)
			else
				found = current.backward_search(entry.text, Gtk::TextIter::SEARCH_TEXT_ONLY, nil)
			end
			if found != nil
				buffer.move_mark('insert', found[0])
				buffer.move_mark('selection_bound', buffer.get_iter_at_offset(found[0].offset + entry.text.length))
				current_textview.scroll_to_iter(found[0], 0.1, false, 0, 0.3)
			else
				Util.infobox(_('No results were found.'))
			end
		end
	end

	def current_buffer; raise 'Implement this method'; end
	def current_textview; raise 'Implement this method'; end
	def save; raise 'Implement this method'; end
	def save_as; raise 'Implement this method'; end
	def revert; raise 'Implement this method'; end
	def print_preview; raise 'Implement this method'; end
	def print; raise 'Implement this method'; end
	def properties; raise 'Implement this method'; end
	def undo; raise 'Implement this method'; end
	def redo; raise 'Implement this method'; end
	def cut; raise 'Implement this method'; end
	def paste; raise 'Implement this method'; end
	def replace; raise 'Implement this method'; end
	def font; raise 'Implement this method'; end
	def bold; raise 'Implement this method'; end
	def italic; raise 'Implement this method'; end
	def underline; raise 'Implement this method'; end
	def refit_menus; raise 'Implement this method'; end

end
