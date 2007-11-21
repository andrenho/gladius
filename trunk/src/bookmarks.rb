class Bookmarks < Gtk::Window

	def initialize
		super(_('Edit Bookmarks'))
		store = create_model
		create_structure(store)
	end

private
	
	def create_model
		store = Gtk::TreeStore.new(String)
		return store
	end

	def create_structure(store)
		set_border_width(12)
		vbox = Gtk::VBox.new(false, 12)
		hbox1 = Gtk::HBox.new(false, 6)
		hbox2 = Gtk::HBox.new(false, 6)
	
		treeview = Gtk::TreeView.new(store)
		delete = Gtk::Button.new(Gtk::Stock::DELETE)
		verse = Gtk::Entry.new
		add = Gtk::Button.new(Gtk::Stock::ADD)

		hbox1.pack_start(Gtk::ScrolledWindow.new.add(treeview), true, true)
		hbox1.pack_start(delete, false, false)
		hbox2.pack_start(verse, false, false)
		hbox2.pack_start(add, false, false)

		vbox.pack_start(hbox1, true, true)
		vbox.pack_start(Gtk::HSeparator.new)
		vbox.pack_start(hbox2, false, false)

		add(vbox)
		show_all
	end

end
