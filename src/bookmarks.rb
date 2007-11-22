class Bookmarks < Gtk::Window

	def initialize
		super
		store = Gtk::ListStore.new(String, Integer, Integer, Integer)
		create_model(store)
		create_structure(store)
	end

	def Bookmarks.add(book, chapter, verse)
		bk = $config['bookmarks']
		bk = [] if bk == nil
		if bk.length > 10 
			Util.warning(_('There can only be up to 10 bookmarks. If you want to add this bookmark, please delete some to make room.'))
		else
			bk << [book, chapter, verse]
			$config['bookmarks'] = bk
		end
	end

	def Bookmarks.list
		bk = $config['bookmarks']
		return [] if bk == nil
		return bk
	end

private
	
	def create_model(store)
		store.clear
		
		Bookmarks.list.each do |bk|
			item = store.append
			item[0] = "#{Books.books[bk[0]-1]} #{bk[1]}:#{bk[2]}"
			item[1] = bk[0]
			item[2] = bk[1]
			item[3] = bk[2]
		end

		return store
	end

	def create_structure(store)
		set_title(_('Edit bookmarks'))
		set_border_width(6)
		set_modal(true)
		set_transient_for($main)
		vbox = Gtk::VBox.new(false, 12)
	
		frame = Gtk::Frame.new
		frame.shadow_type = Gtk::SHADOW_IN
		vbox.pack_start(frame, true, true)

		treeview = Gtk::TreeView.new(store)
		treeview.selection.mode = Gtk::SELECTION_MULTIPLE
		treeview.append_column(Gtk::TreeViewColumn.new(_('Verse list'), Gtk::CellRendererText.new, :text => 0))
		
		frame.add(treeview)

		delete = Gtk::Button.new(Gtk::Stock::DELETE)
		delete.signal_connect('clicked') do 
			iters = []
			treeview.selection.selected_each do |model, path, iter|
				bk = [iter[1], iter[2], iter[3]]
				bkmks = Bookmarks.list
				bkmks.delete(bk)
				$config['bookmarks'] = bkmks
			end
			create_model(store)
		end
		vbox.pack_start(delete, false, false)

		add(vbox)
		show_all

		signal_connect('destroy') { $main.populate_bookmark_menu }
	end

end
