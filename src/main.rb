require 'ftools'

class Main < Gtk::Window

	attr_reader :current_book, :current_chapter, :current_verse, :books
	attr_reader :menubar

	def initialize
		super

		@current_book = @current_chapter = @current_verse = 1
		$main = self

		$tip = Gtk::Tooltips.new
	
		@paned = Gtk::HPaned.new
		@books = Books.new
		@paned.pack1(@books, true, true)
		@paned.position = 150
		set_title(_('Gladius %s', BB_VERSION))
		set_default_size(600, 400)
		set_icon("#{IMG}/stock_book_yellow-16.png")

		@vbox = Gtk::VBox.new
		@vbox.pack_end(@paned, true, true, 0)
		add(@vbox)

		@menubar = Gtk::MenuBar.new

		@views = []
		add_bibleview($default_bible)

		create_menu
		@vbox.pack_start(@menubar, false, false, 0)

		signal_connect('destroy') do 
			Gtk.main_quit
		end

		@paned.show
		@books.show_all
		@vbox.show
		@menubar.show_all

		go_to(1, 1)
		select_verse(1)
	end

	def create_menu
		# @menubar.each { |menu_item| @menubar.remove(menu_item) }
		file_menu = Gtk::Menu.new
		file = Gtk::MenuItem.new(_('File'))
		file.set_submenu(file_menu)

		file_exit = Gtk::MenuItem.new(_('Exit'))
		file_exit.signal_connect('activate') { Gtk.main_quit }
		file_menu.append(file_exit)

		view_menu = Gtk::Menu.new
		view = Gtk::MenuItem.new(_('View'))
		view.set_submenu(view_menu)

		@bible_menu = Gtk::Menu.new
		bible = Gtk::MenuItem.new(_('Bible translations'))
		bible.set_submenu(@bible_menu)
		view_menu.append(bible)

		# Add bible translations
		@bible_menu.append(Gtk::SeparatorMenuItem.new)
		bible_add = Gtk::MenuItem.new(_('Install from file...'))
		bible_add.signal_connect('activate') do
			add_new_bible(file)
		end
		@bible_menu.append(bible_add)
		bible_download = Gtk::MenuItem.new(_('Download from internet...'))
		bible_download.signal_connect('activate') do
			d = Download.new
			d.show
		end
		@bible_menu.append(bible_download)
		Dir["#{HOME}/*.bible"].each do |f|
			add_bible_to_menu(f) if not f.include? 'default.bible'
		end

		@menubar.prepend(view)
		@menubar.prepend(file)
	end
	private :create_menu

	def add_bible_to_menu(f)
		bible_name = Bible.name(f)
		item = Gtk::ImageMenuItem.new(bible_name)
		case Bible.language(f)
		when 'en'
			item.image = Gtk::Image.new("#{IMG}/gb.gif")
		when 'pt-Br'
			item.image = Gtk::Image.new("#{IMG}/br.gif")
		end
		item.signal_connect('activate') do |widget|
			b = Bible.new(f.scan(/.*\/(.*)\.bible/)[0][0])
			bibleview = add_bibleview(b)
			bibleview.menu_item = widget
			bibleview.menu_item.sensitive = false
		end
		@bible_menu.insert(item, @bible_menu.children.length - 3)
		if $default_bible.name == bible_name
			@views[0].menu_item = item
			@views[0].menu_item.sensitive = false
		end
		item.show
	end

	def add_bibleview(bible)
		bibleview = BibleView.new(bible)
		if @views == []
			@paned.pack2(bibleview, true, true)
		else
			@views.last.pack2(bibleview, true, true)
			@views.last.position = @views.last.allocation.width / 2
			bibleview.show
		end
		@views << bibleview
		return bibleview
	end

	def search(bible, text, match, partial, range)
		search_view = Search.new(bible, text, match, partial, range)
		if @views == []
			@paned.pack2(search_view, true, true)
		else
			@views.last.pack2(search_view, true, true)
			@views.last.position = @views.last.allocation.width / 2
			search_view.show
		end
		@views << search_view
		return search_view
	end

	def delete_view(view)
		return false if bibleviews.length == 1 and view.class == BibleView
		current = @views.index(view)
		view.remove(@views[current+1])
		if view == @views.first
			@paned.remove(view)
			@paned.pack2(@views[current+1], true, true)
		else
			@views[current-1].remove(view)
			@views[current-1].pack2(@views[current+1], true, true)
		end
		@views.delete(view)
		view.destroy
		return true
	end

	def go_to(book, chapter)
		@current_book = book
		@current_chapter = chapter
		@views.each { |bv| bv.go_to(book, chapter) }

	end

	def select_verse(verse)
		@current_verse = verse
		@views.each { |bv| bv.select_verse(verse) }
	end

	def add_new_bible(file)
		dialog = Gtk::FileChooserDialog.new('Choose Bible file',
			$main,
			Gtk::FileChooser::ACTION_OPEN,
			nil,
			[Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL],
			[Gtk::Stock::OPEN, Gtk::Dialog::RESPONSE_ACCEPT])
		if dialog.run == Gtk::Dialog::RESPONSE_ACCEPT
			# check if it's a valid bible file
			file = dialog.filename
			if Bible.name(file) == nil
				dialog.destroy
				Util.infobox(_("File %s is not a valid Bible file.", file))
				return
			else
				File.copy file, "#{HOME}/"
				b = Bible.new(file.scan(/.*[\/\\](.*)\.bible/)[0][0])
				add_bibleview(b)
				add_bible_to_menu(file)
			end
		end
		dialog.destroy
	end
	private :add_new_bible

	def bibleviews
		r = []
		@views.each { |v| r << v if v.class == BibleView }
		return r
	end
	private :bibleviews

end
