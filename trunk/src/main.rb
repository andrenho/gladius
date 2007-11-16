require 'ftools'

class Main < Gtk::Window

	attr_reader :current_book, :current_chapter, :current_verse, :books
	attr_reader :menubar

	# 
	# Initialize main screen
	#
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
		@toolbar = Gtk::Toolbar.new
		@toolbar.toolbar_style = Gtk::Toolbar::ICONS

		@views = []
		add_bibleview($default_bible)

		create_menu
		@vbox.pack_start(@menubar, false, false, 0)
		create_toolbar
		@toolbar.show_all
#		@vbox.pack_start(@toolbar, false, false, 0)

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


	#
	# Create menu for the main screen
	#
	def create_menu
		# File menu
		file_menu = Gtk::Menu.new
		file = Gtk::MenuItem.new(_('File'))
		file.set_submenu(file_menu)

		# File -> New
		file_new = Gtk::ImageMenuItem.new(Gtk::Stock::NEW)
		file_new_menu = Gtk::Menu.new
		file_new.set_submenu(file_new_menu)
		file_menu.append(file_new)

		# File -> New -> Topic Study (...)
		file_new_study = Gtk::MenuItem.new(_('Topic Study') + _('(Not Implemented)'))
		file_new_study.sensitive = false
		file_new_menu.append(file_new_study)

		# File -> Open
		file_open = Gtk::ImageMenuItem.new(Gtk::Stock::OPEN)
		file_open_menu = Gtk::Menu.new
		file_open.set_submenu(file_open_menu)
		file_menu.append(file_open)

		# File -> Open -> Bible (from disk)
		file_open_bible_d = Gtk::ImageMenuItem.new(_('Bible translation (from disk)...'))
		file_open_bible_d.image = Gtk::Image.new(Gtk::Stock::HARDDISK, Gtk::IconSize::MENU)
		file_open_bible_d.signal_connect('activate') { add_new_bible }
		file_open_menu.append(file_open_bible_d)

		# File -> Open -> Bible (from internet)
		file_open_bible_i = Gtk::ImageMenuItem.new(_('Bible translation (from internet)...'))
		file_open_bible_i.image = Gtk::Image.new(Gtk::Stock::NETWORK, Gtk::IconSize::MENU)
		file_open_bible_i.signal_connect('activate') { Download.new.show }
		file_open_menu.append(file_open_bible_i)

		# File -> -----------
		file_menu.append(Gtk::SeparatorMenuItem.new)

		# File -> Save
		file_save = Gtk::ImageMenuItem.new(Gtk::Stock::SAVE)
		file_save.sensitive = false
		file_save.signal_connect('activate') { current_view.save }
		file_menu.append(file_save)

		# File -> Save As
		file_save_as = Gtk::ImageMenuItem.new(Gtk::Stock::SAVE_AS)
		file_save_as.sensitive = false
		file_save_as.signal_connect('activate') { current_view.save_as }
		file_menu.append(file_save_as)

		# File -> Revert
		file_revert = Gtk::ImageMenuItem.new(Gtk::Stock::REVERT_TO_SAVED)
		file_revert.sensitive = false
		file_revert.signal_connect('activate') { current_view.revert }
		file_menu.append(file_revert)

		# File -> -----------
		file_menu.append(Gtk::SeparatorMenuItem.new)

		# File -> Page Setup
		file_ps = Gtk::MenuItem.new(_('Page Setup...'))
		file_ps.signal_connect('activate') { page_setup }
		file_menu.append(file_ps)

		# File -> Print Preview
		file_pp = Gtk::ImageMenuItem.new(Gtk::Stock::PRINT_PREVIEW)
		file_pp.signal_connect('activate') { current_view.print_preview }
		file_menu.append(file_pp)

		# File -> Print...
		# File -> -----------
		# File -> Properties
		# File -> -----------
		# File -> Close

		# File -> Quit
		file_exit = Gtk::ImageMenuItem.new(Gtk::Stock::QUIT)
		file_exit.signal_connect('activate') { Gtk.main_quit }
		file_menu.append(file_exit)

		# Edit
		# Edit -> Undo
		# Edit -> Redo
		# Edit -> -----------
		# Edit -> Cut
		# Edit -> Copy
		# Edit -> Copy Verses
		# Edit -> Paste
		# Edit -> Delete
		# Edit -> Select All
		# Edit -> -----------
		# Edit -> Find...
		# Edit -> Find Next
		# Edit -> Find Previous
		# Edit -> Replace...
		# Edit -> -----------
		# Edit -> Default Translation
		# Edit -> Preferences
		
		# View
		# View -> Previous Chapter
		# View -> Next Chapter
		# View -> -----------
		# View -> Toolbar
		# View -> -----------
		# View -> Bible Translations
		# View -> Topic Studies...
		
		# Insert (TODO)
		
		# Format
		# Format -> Font
		# Format -> Paragraph
		# Format -> -----------
		# Format -> Bold
		# Format -> Italic
		# Format -> Underline

		# Bookmarks
		# Bookmarks -> Add
		# Bookmarks -> ----------
		# Bookmarks list
		
		# Help
		# Help -> About

=begin
		# Bibles menu
		@bible_menu = Gtk::Menu.new
		bible = Gtk::MenuItem.new(_('Bibles'))
		bible.set_submenu(@bible_menu)
		
		# Bibles -> Install from file
		bible_add = Gtk::ImageMenuItem.new(_('Load bible...'))
		bible_add.image = Gtk::Image.new(Gtk::Stock::OPEN, Gtk::IconSize::MENU)
		bible_add.signal_connect('activate') do
			add_new_bible
		end
		@bible_menu.append(bible_add)

		# Bibles -> Download from the internet
		bible_download = Gtk::ImageMenuItem.new(_('Download from internet...'))
		bible_download.image = Gtk::Image.new(Gtk::Stock::NETWORK, Gtk::IconSize::MENU)
		bible_download.signal_connect('activate') do
			Download.new.show
		end
		@bible_menu.append(bible_download)

		# Bibles -> Bible translations
		@bible_menu.append(Gtk::SeparatorMenuItem.new)
		Dir["#{HOME}/*.bible"].each do |f|
			add_bible_to_menu(f) if not f.include? 'default.bible'
		end

		@menubar.prepend(bible)
=end
		@menubar.prepend(file)
	end
	private :create_menu


	# 
	# Create a toolbar for the main window
	# 
	def create_toolbar
		bibles = Gtk::Label.new(_('Bibles'))
		bibles.xpad = 6
		@toolbar.append(bibles)

		@toolbar.append(Gtk::Stock::OPEN, _('Load bible from file')) { add_new_bible }
		@toolbar.append(Gtk::Stock::NETWORK, _('Download bible from the internet')) { Download.new.show }
		# TODO implement
		@toolbar.append(Gtk::Stock::JUSTIFY_FILL, _('Open a new bible')) {  } 

		@toolbar.append_space
	end
	private :create_toolbar


	#
	# Add a new bible to the menu (when the program is started, or when a new
	# bible is found).
	#
	def add_bible_to_menu(f)
		bible_name = Bible.name(f)
		item = Gtk::ImageMenuItem.new(bible_name)
		item.image = Gtk::Image.new(Util.flag(Bible.language(f)))
		item.signal_connect('activate') do |widget|
			b = Bible.new(f.scan(/.*\/(.*)\.bible/)[0][0])
			bibleview = add_bibleview(b)
			bibleview.menu_item = widget
			bibleview.menu_item.sensitive = false
		end
		@bible_menu.append(item)
		if $default_bible.name == bible_name
			@views[0].menu_item = item
			@views[0].menu_item.sensitive = false
		end
		item.show
	end


	# 
	# Add a new Bibleview (translation).
	#
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


	# 
	# Search a text in the bible
	#
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


	#
	# The user closed a frame
	# 
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

	#
	# Go to a given chapter of the Bible
	#
	def go_to(book, chapter)
		@current_book = book
		@current_chapter = chapter
		@views.each { |bv| bv.go_to(book, chapter) }
	end

	#
	# User clicked on a given verse of the Bible
	#
	def select_verse(verse)
		@current_verse = verse
		@views.each { |bv| bv.select_verse(verse) }
	end

	# 
	# Install a new Bible from a file
	#
	def add_new_bible
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
				Util.infobox(_("This Bible has been installed. You can this Bible anytime by choosing View -> Bible translations -> %s", b.name))
			end
		end
		dialog.destroy
	end
	private :add_new_bible


	# 
	# The list of open bible frames
	#
	def bibleviews
		r = []
		@views.each { |v| r << v if v.class == BibleView }
		return r
	end
	private :bibleviews


	# 
	# Page setup
	#
	def page_setup
		raise 'Implement this method'
	end
	private :page_setup

end
