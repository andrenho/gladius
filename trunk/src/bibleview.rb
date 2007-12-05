class BibleView < View

	attr_reader :bible
	attr_reader :format

	# 
	# Create the Bible frame
	#
	def initialize(bible)
		super(bible.name)
		@bible = bible
		@find_slot = ""
		@format = Format.load(bible.abbr)

		@displaying_book = 0
		@displaying_chapter = 0

		#
		# MENU BUTTONS
		# 
		
		# Previous
		previous_button = Gtk::Button.new
		previous_button.add(Gtk::Image.new(Gtk::Stock::GO_BACK, Gtk::IconSize::MENU))
		previous_button.relief = Gtk::RELIEF_NONE
		$tip.set_tip(previous_button, _('Previous chapter'), '')
		@hbox.pack_start(previous_button, false, false)
		previous_button.signal_connect('clicked') { $main.previous_chapter }

		# Next
		next_button = Gtk::Button.new
		next_button.add(Gtk::Image.new(Gtk::Stock::GO_FORWARD, Gtk::IconSize::MENU))
		next_button.relief = Gtk::RELIEF_NONE
		$tip.set_tip(next_button, _('Next chapter'), '')
		@hbox.pack_start(next_button, false, false)
		next_button.signal_connect('clicked') { $main.next_chapter }

		# ----------------
		@hbox.pack_start(Gtk::VSeparator.new, false, false)

		# Copy verses
		cv_button = Gtk::Button.new
		cv_button.add(Gtk::Image.new(Gtk::Stock::COPY, Gtk::IconSize::MENU))
		cv_button.relief = Gtk::RELIEF_NONE
		$tip.set_tip(cv_button, _('Copy verses'), '')
		@hbox.pack_start(cv_button, false, false)
		cv_button.signal_connect('clicked') { copy_verses }

		# Search button
		@search_button = Gtk::ToggleButton.new
		@search_button.add(Gtk::Image.new(Gtk::Stock::FIND, Gtk::IconSize::MENU))
		@search_button.relief = Gtk::RELIEF_NONE
		$tip.set_tip(@search_button, _('Search'), nil)
		@hbox.pack_start(@search_button, false, false)

		# ----------------
		@hbox.pack_start(Gtk::VSeparator.new, false, false)

		# Search menu
		create_search_frame

		@vbox.pack_start(@search_frame, false, false)

		# text buffer
		@bible_text = BibleText.new(@bible, @format, self)
		@vbox.pack_start(@bible_text)

		@last_verse = 1

		show_all
		@search_frame.visible = false

		#begin
			verse = $main.current_verse
			select_verse($main.current_book, $main.current_chapter, verse)
			$main.select_verse($main.current_book, $main.current_chapter, verse)
		#rescue
		#end
	end


	#
	# Set a new format to the bible
	#
	def format=(new_format)
		@format = new_format
		@bible_text.set_format(new_format, true)
	end


	# 
	# When the user clicks a verse
	#
	def select_verse(book, chapter, verse)
		if book != @displaying_book or chapter != @displaying_chapter
			#verses = []
			#(1..@bible.n_verses(book, chapter)).each { |n| verses << [book, chapter, n] }
			verses = @bible.chapter(book, chapter)
			@displaying_book = book
			@displaying_chapter = chapter
			@bible_text.show_verses(verses, "#{@bible.book_name(book)} #{chapter}")
		end

		@bible_text.select_verse($main.current_book, $main.current_chapter, verse)
	end


	#
	# Create the search toolbar
	#
	def create_search_frame
		@search_frame = Gtk::Frame.new
		@search_frame.shadow_type = Gtk::SHADOW_OUT
		search_hbox = Gtk::HBox.new

		# label
		search_label = Gtk::Label.new(_('Search'))
		search_label.set_alignment(0, 0.5)
		search_label.ypad = 2
		search_hbox.pack_start(search_label, false, false, 5)

		# search entry
		search_entry = Gtk::Entry.new
		search_entry.width_chars = 18
		search_hbox.pack_start(search_entry, false, false, 5)
		$tip.set_tip(search_entry, _('Type the search term here'), nil)

		# match menu
		match_menu = Gtk::Menu.new
		match_menu.append(exact = Gtk::RadioMenuItem.new(_('Exact phrase')))
		match_menu.append(all_words = Gtk::RadioMenuItem.new(exact, _('All words')))
		match_menu.append(any_words = Gtk::RadioMenuItem.new(exact, _('Any words')))
		match_menu.show_all
		exact.active = true

		# match
		match_button = Gtk::Button.new
		match_button.add(Gtk::Image.new(Gtk::Stock::FIND_AND_REPLACE, Gtk::IconSize::MENU))
		match_button.relief = Gtk::RELIEF_NONE
		match_button.signal_connect('clicked') do 
			match_menu.popup(nil, nil, 0, 0)
		end
		search_hbox.pack_start(match_button, false, false, 0)
		$tip.set_tip(match_button, _('How the search matches the string typed by the user'), nil)

		# partial match
		partial_button = Gtk::ToggleButton.new
		partial_button.add(Gtk::Image.new("#{IMG}/partial.png"))
		partial_button.relief = Gtk::RELIEF_NONE
		partial_button.active = true
		search_hbox.pack_start(partial_button, false, false, 0)
		$tip.set_tip(partial_button, _('Partial match'), nil)

		# range menu
		range_button = Gtk::Button.new(_('All'))
		range_menu = Gtk::Menu.new
		range_menu.append(all = Gtk::RadioMenuItem.new(_('All')))
		range_menu.append(pentateuch = Gtk::RadioMenuItem.new(all, _('Pentateuch')))
		range_menu.append(ot_historicals = Gtk::RadioMenuItem.new(all, _('OT Historicals')))
		range_menu.append(ot_wisdom = Gtk::RadioMenuItem.new(all, _('OT Wisdom')))
		range_menu.append(prophets = Gtk::RadioMenuItem.new(all, _('Prophets')))
		range_menu.append(gospels = Gtk::RadioMenuItem.new(all, _('Gospels')))
		range_menu.append(acts = Gtk::RadioMenuItem.new(all, _('Acts')))
		range_menu.append(epistols = Gtk::RadioMenuItem.new(all, _('Epistols')))
		range_menu.append(revelation = Gtk::RadioMenuItem.new(all, _('Revelation')))
		range_menu.show_all
		all.active = true
		[all, pentateuch, ot_historicals, ot_wisdom, prophets,
		gospels, acts, epistols, revelation].each do |item|
			item.signal_connect('toggled') do |w|
				range_button.label = w.child.text
			end
		end

		# range
		range_button.relief = Gtk::RELIEF_NONE
		range_button.signal_connect('clicked') do 
			range_menu.popup(nil, nil, 0, 0)
		end
		search_hbox.pack_start(range_button, false, false, 0)
		$tip.set_tip(range_button, _('Range of the search'), nil)

		# separator
		search_hbox.pack_start(Gtk::VSeparator.new, false, false)

		# in new window
		new_window = Gtk::ToggleButton.new
		new_window.add(Gtk::Image.new("#{IMG}/new_window.png"))
		new_window.relief = Gtk::RELIEF_NONE
		$tip.set_tip(new_window, _('Open search in a new window'), '')
		search_hbox.pack_start(new_window, false, false)

		# search click event
		@search_button.signal_connect('toggled') do 
			@search_frame.visible = @search_button.active?
			search_entry.has_focus = true if @search_button.active?
		end

		# entry event
		search_entry.signal_connect('activate') do 
			text = search_entry.text
			if text != ''
				m = Search::EXACT     if exact.active?
				m = Search::ALL_WORDS if all_words.active?
				m = Search::ANY_WORDS if any_words.active?
				r = Search::ALL         if all.active?
				r = Search::PENTATEUCH  if pentateuch.active?
				r = Search::HISTORICALS if ot_historicals.active?
				r = Search::WISDOM      if ot_wisdom.active?
				r = Search::PROPHETS    if prophets.active?
				r = Search::GOSPELS     if gospels.active?
				r = Search::ACTS        if acts.active?
				r = Search::EPISTOLS    if epistols.active?
				r = Search::REVELATION  if revelation.active?
				$main.search(self, text, m, partial_button.active?, r)
			end
		end

		@search_frame.add(search_hbox)
		search_hbox.show_all
		@search_frame.visible = false
	end


	#
	# Close the form
	#
	def close
		if super 
			@menu_item.sensitive = true
		end
	end


	# 
	# Print Preview Screen
	#
	def print_preview
	end


	#
	# Open Copy Verses Window
	#
	def copy_verses
		verses = @bible_text.selected_verses
		if verses.length == 0
			CopyVerses.new(@bible, '').show
		elsif verses[0].length == 1
			CopyVerses.new(@bible, "#{@bible.book_abbr(@displaying_book)} #{@displaying_chapter}\n").show
		else
			CopyVerses.new(@bible, @bible.unparse(verses)).show
		end
	end


	# 
	# Jump to
	#
	def jump_to
		w = Gtk::Window.new
		w.set_title(_('Jump to verse'))
		w.border_width = 6
		
		vbox = Gtk::VBox.new(false, 6)
		hbox = Gtk::HBox.new(false, 6)
		entry = Gtk::Entry.new
		entry.activates_default = true
		jump = Gtk::Button.new(Gtk::Stock::JUMP_TO)
		jump.flags = Gtk::Widget::CAN_DEFAULT
		jump.signal_connect('clicked') do
			paragraphs, ok = @bible.parse(entry.text)
			if ok
				verses = paragraphs[0]
				$main.select_verse(verses[0][0], verses[0][1], verses[0][2])
			else
				Util.warning(_('Invalid reference.'))
			end
			w.destroy
		end

		vbox.pack_start(Gtk::Label.new(_('Type a bible reference below.')), false, false)
		hbox.pack_start(entry, false, false)
		hbox.pack_start(jump, false, false)
		vbox.pack_start(hbox, false, false)
		w.add(vbox)

		w.modal = true
		w.transient_for = self
		w.resizable = false
		w.default = jump
		w.show_all
	end


	#
	# Set this as my default translation
	#
	def default_translation
		$config['default_bible'] = @bible.abbr
		Util.infobox(_('%s is now your default bible.', @bible.name), $main)
		refit_menus
	end


	#
	# Change font and paragraph
	#
	def font(page=1)
		BibleviewOptions.new(self, page, @displaying_book, @displaying_chapter).show
	end
	def paragraph; font(2); end


	# 
	# View properties
	#
	def properties
		Properties.new([_('Name'), @bible.name], [_('Year'), @bible.year], [_('Comment'), @bible.comment])
	end


	# 
	# Check if any menu options need to be set sensible or not
	#
	def refit_menus
		return if $main.file_save == nil

		$main.file_save.sensitive = false
		$main.file_save_as.sensitive = false
		$main.file_revert.sensitive = false
		$main.file_properties.sensitive = true
		if $main.views.length > 1
			$main.file_close.sensitive = true
			$main.views.each { |bv| bv.close_button.sensitive = true }
		else
			$main.file_close.sensitive = false
			@close_button.sensitive = false
		end

		$main.view_jump.sensitive = true

		$main.edit_undo.sensitive = false
		$main.edit_redo.sensitive = false

		$main.edit_cut.sensitive = false
		if @bible_text.buffer.selection_bounds != nil
			$main.edit_copy.sensitive = true
		else
			$main.edit_copy.sensitive = false
		end
		$main.edit_cv.sensitive = true
		$main.edit_paste.sensitive = false

		$main.edit_find.sensitive = true
		$main.edit_fn.sensitive = (@find_slot != "")
		$main.edit_replace.sensitive = false

		$main.edit_dt.signal_handler_block($main.edit_dt_signal) do 
			$main.edit_dt.active = ($config['default_bible'].downcase == @bible.abbr.downcase)
		end
		$main.edit_dt.sensitive = !$main.edit_dt.active?

		$main.format_font.sensitive = true
		$main.format_paragraph.sensitive = true

		$main.format_bold.sensitive = false
		$main.format_italic.sensitive = false
		$main.format_underline.sensitive = false

		$main.current_view = self
	end

	def current_buffer; @bible_text.buffer; end
end
