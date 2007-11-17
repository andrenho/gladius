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
		file = Gtk::MenuItem.new(_('_File'))
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
		file_print = Gtk::ImageMenuItem.new(Gtk::Stock::PRINT)
		file_print.signal_connect('activate') { current_view.print }
		file_menu.append(file_print)

		# File -> -----------
		file_menu.append(Gtk::SeparatorMenuItem.new)

		# File -> Properties
		file_properties = Gtk::ImageMenuItem.new(Gtk::Stock::PROPERTIES)
		file_properties.signal_connect('activate') { current_view.properties }
		file_menu.append(file_properties)

		# File -> -----------
		file_menu.append(Gtk::SeparatorMenuItem.new)

		# File -> Close
		file_close = Gtk::ImageMenuItem.new(Gtk::Stock::CLOSE)
		file_close.signal_connect('activate') { current_view.close }
		file_menu.append(file_close)

		# File -> Quit
		file_exit = Gtk::ImageMenuItem.new(Gtk::Stock::QUIT)
		file_exit.signal_connect('activate') { Gtk.main_quit }
		file_menu.append(file_exit)

		# Edit
		edit_menu = Gtk::Menu.new
		edit = Gtk::MenuItem.new(_('_Edit'))
		edit.set_submenu(edit_menu)

		# Edit -> Undo
		edit_undo = Gtk::ImageMenuItem.new(Gtk::Stock::UNDO)
		edit_undo.signal_connect('activate') { current_view.undo }
		edit_menu.append(edit_undo)

		# Edit -> Redo
		edit_redo = Gtk::ImageMenuItem.new(Gtk::Stock::REDO)
		edit_redo.signal_connect('activate') { current_view.redo }
		edit_menu.append(edit_redo)

		# Edit -> -----------
		edit_menu.append(Gtk::SeparatorMenuItem.new)

		# Edit -> Cut
		edit_cut = Gtk::ImageMenuItem.new(Gtk::Stock::CUT)
		edit_cut.signal_connect('activate') { current_view.cut }
		edit_menu.append(edit_cut)

		# Edit -> Copy
		edit_copy = Gtk::ImageMenuItem.new(Gtk::Stock::COPY)
		edit_copy.signal_connect('activate') { current_view.copy }
		edit_menu.append(edit_copy)

		# Edit -> Copy Verses
		edit_cv = Gtk::MenuItem.new(_('Copy verses...'))
		edit_cv.signal_connect('activate') { current_view.copy_verses }
		edit_menu.append(edit_cv)

		# Edit -> Paste
		edit_paste = Gtk::ImageMenuItem.new(Gtk::Stock::PASTE)
		edit_paste.signal_connect('activate') { current_view.paste }
		edit_menu.append(edit_paste)

		# Edit -> -----------
		edit_menu.append(Gtk::SeparatorMenuItem.new)

		# Edit -> Find...
		edit_find = Gtk::ImageMenuItem.new(Gtk::Stock::FIND)
		edit_find.signal_connect('activate') { current_view.find }
		edit_menu.append(edit_find)

		# Edit -> Find Next
		edit_fn = Gtk::MenuItem.new(_('Find next'))
		edit_fn.signal_connect('activate') { current_view.find_next }
		edit_menu.append(edit_fn)

		# Edit -> Replace...
		edit_replace = Gtk::MenuItem.new(_('Replace'))
		edit_replace.signal_connect('activate') { current_view.replace }
		edit_menu.append(edit_replace)

		# Edit -> -----------
		edit_menu.append(Gtk::SeparatorMenuItem.new)

		# Edit -> Default Translation
		edit_dt = Gtk::CheckMenuItem.new(_('Default Translation'))
		edit_dt.signal_connect('activate') { current_view.default_translation }
		edit_menu.append(edit_dt)

		# Edit -> Preferences
		edit_preferences = Gtk::ImageMenuItem.new(Gtk::Stock::PREFERENCES)
		edit_preferences.signal_connect('activate') { preferences }
		edit_menu.append(edit_preferences)
		
		# View
		view_menu = Gtk::Menu.new
		view = Gtk::MenuItem.new(_('_View'))
		view.set_submenu(view_menu)

		# View -> Previous Chapter
		view_pc = Gtk::ImageMenuItem.new(Gtk::Stock::GO_BACK)
		view_pc.signal_connect('activate') { previous_chapter }
		view_menu.append(view_pc)

		# View -> Next Chapter
		view_nc = Gtk::ImageMenuItem.new(Gtk::Stock::GO_FORWARD)
		view_nc.signal_connect('activate') { next_chapter }
		view_menu.append(view_nc)

		# TODO - view toolbar

		# View -> -----------
		view_menu.append(Gtk::SeparatorMenuItem.new)

		# View -> Bible Translations
		@view_bibles_menu = Gtk::Menu.new
		view_bibles = Gtk::MenuItem.new(_('_Bible Translations'))
		view_bibles.set_submenu(@view_bibles_menu)
		Dir["#{HOME}/*.bible"].each do |f|
			add_bible_to_menu(f) if not f.include? 'default.bible'
		end
		view_menu.append(view_bibles)

		# Insert (TODO)
		
		# Format
		format_menu = Gtk::Menu.new
		format = Gtk::MenuItem.new(_('_Format'))
		format.set_submenu(format_menu)

		# Format -> Font
		format_font = Gtk::MenuItem.new(_('_Font...'))
		format_font.signal_connect('activate') { current_view.font }
		format_menu.append(format_font)

		# Format -> Paragraph
		format_paragraph = Gtk::MenuItem.new(_('_Paragraph...'))
		format_paragraph.signal_connect('activate') { current_view.paragraph }
		format_menu.append(format_paragraph)

		# Format -> -----------
		format_menu.append(Gtk::SeparatorMenuItem.new)

		# Format -> Bold
		format_bold = Gtk::ImageMenuItem.new(Gtk::Stock::BOLD)
		format_bold.signal_connect('activate') { current_view.bold }
		format_menu.append(format_bold)

		# Format -> Italic
		format_italic = Gtk::ImageMenuItem.new(Gtk::Stock::ITALIC)
		format_italic.signal_connect('activate') { current_view.italic }
		format_menu.append(format_italic)

		# Format -> Underline
		format_underline = Gtk::ImageMenuItem.new(Gtk::Stock::UNDERLINE)
		format_underline.signal_connect('activate') { current_view.underline }
		format_menu.append(format_underline)

		# Bookmarks
		bookmark_menu = Gtk::Menu.new
		bookmark = Gtk::MenuItem.new(_('_Bookmarks'))
		bookmark.set_submenu(bookmark_menu)

		# Bookmarks -> Add
		bookmark_add = Gtk::ImageMenuItem.new(_('Add bookmark'))
		bookmark_add.image = Gtk::Image.new(Gtk::Stock::ADD, Gtk::IconSize::MENU)
		bookmark_add.signal_connect('activate') { current_view.add_bookmark }
		bookmark_menu.append(bookmark_add)

		# Bookmarks -> ----------
		bookmark_menu.append(Gtk::SeparatorMenuItem.new)

		# Bookmarks list (TODO)
		
		# Help
		help_menu = Gtk::Menu.new
		help = Gtk::MenuItem.new(_('_Help'))
		help.set_submenu(help_menu)

		# Help -> About
		help_about = Gtk::ImageMenuItem.new(Gtk::Stock::ABOUT)
		help_about.signal_connect('activate') { about }
		help_menu.append(help_about)

		@menubar.append(file)
		@menubar.append(edit)
		@menubar.append(view)
		@menubar.append(format)
		@menubar.append(bookmark)
		@menubar.append(help)
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
		@view_bibles_menu.append(item)
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
	# Go to the previous chapter
	# 
	def previous_chapter
		book = @current_book
		chapter = @current_chapter
		if chapter == 1
			if book == 1
				return
			else
				book -= 1
				chapter = bibleviews[0].bible.last_chapter(book)
			end
		else
			chapter -= 1
		end
		go_to(book, chapter)	
	end
	

	#
	# Go to the next chapter
	#
	def next_chapter
		book = @current_book
		chapter = @current_chapter
		if chapter == bibleviews[0].bible.last_chapter(book)
			if book == 66
				return
			else
				book += 1
				chapter = 1
			end
		else
			chapter += 1
		end
		go_to(book, chapter)	
	end


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
