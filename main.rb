class Main < Gtk::Window

	def initialize
		super
	
		create_menu
		@paned = Gtk::HPaned.new
		@books = Books.new
		@paned.pack1(@books, true, true)
		set_title("Gladius 0.1")

		@vbox = Gtk::VBox.new
		@vbox.pack_start(@menubar, false, false, 0)
		@vbox.pack_start(@paned, true, true, 0)
		add(@vbox)
		@top = nil

		@bibleviews = []
		add_bibleview($default_bible)
	end

	def create_menu
		@menubar = Gtk::MenuBar.new

		file_menu = Gtk::Menu.new
		file = Gtk::MenuItem.new("File")
		file_menu.append(file_exit = Gtk::MenuItem.new("Exit"))
		file.set_submenu(file_menu)

		@menubar.append(file)
	end
	private :create_menu

	def add_bibleview(bible)
		bibleview = BibleView.new(bible)
		@paned.pack2(bibleview, true, true)
		@bibleviews << bibleview
	end

	def go_to(book, chapter, verse=1)
		@bibleviews.each { |bv| bv.go_to(book, chapter, verse) }
	end

end
