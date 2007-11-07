class Main < Gtk::Window

	def initialize
		super
	
		create_menu
		@paned = Gtk::HPaned.new
		@books = Books.new
		@paned.pack1(@books, true, true)
		@paned.position = 150
		set_title("Gladius #{BB_VERSION}") # TODO get from file
		set_default_size(600, 400)
		set_icon("#{IMG}/stock_book_yellow-16.png")

		@vbox = Gtk::VBox.new
		@vbox.pack_start(@menubar, false, false, 0)
		@vbox.pack_start(@paned, true, true, 0)
		add(@vbox)
		@top = nil

		@bibleviews = []
		add_bibleview($default_bible)

		signal_connect('destroy') do 
			Gtk.main_quit
		end
	end

	def create_menu
		@menubar = Gtk::MenuBar.new

		file_menu = Gtk::Menu.new
		file = Gtk::MenuItem.new(_('File'))
		file.set_submenu(file_menu)

		file_exit = Gtk::MenuItem.new(_('Exit'))
		file_exit.signal_connect('activate') { Gtk.main_quit }
		file_menu.append(file_exit)

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
