class BibleView < View

	attr_reader :bible

	# 
	# Create the Bible frame
	#
	def initialize(bible)
		super(bible.name)
		@bible = bible

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

		# Search menu
		create_search_frame

		@vbox.pack_start(@search_frame, false, false)

		# text buffer
		@buffer = Gtk::TextBuffer.new
		@textview = Gtk::TextView.new(@buffer)
		@textview.editable = false
		@textview.wrap_mode = Gtk::TextTag::WRAP_WORD
		@textview.pixels_below_lines = 10
		if $config[bible.abbr, 'font'] == nil
			@textview.modify_font(Pango::FontDescription.new('Serif 11'))
		else
			@textview.modify_font(Pango::FontDescription.new($config[bible.abbr, 'font']))
		end
		scroll = Gtk::ScrolledWindow.new
		scroll.add(@textview)
		@vbox.pack_start(scroll)

		@tags = []
		(1..176).each do |n|
			@tags[n] = @buffer.create_tag("verse#{n}", {})
		end
		@tag_header = @buffer.create_tag('', { :font => 'Serif 15', :weight => Pango::FontDescription::WEIGHT_HEAVY })

		@last_verse = 1

		@buffer.signal_connect('mark-set') do |w, iter, mark|
			# TODO this is repeating several times
			if iter.tags != []
				n = @tags.index(iter.tags[0])
				$main.select_verse(n) if n != nil
			end
		end

		show_all
		@search_frame.visible = false

		begin
			verse = $main.current_verse
			go_to($main.current_book, $main.current_chapter)
			select_verse(verse)
			$main.select_verse(verse)
		rescue
		end

	end

	#
	# Go to a given chapter in a given book
	#
	def go_to(book, chapter)
		@marks = []
		@buffer.delete(@buffer.start_iter, @buffer.end_iter)
		text = ''
		iter = @buffer.start_iter
		@buffer.insert(iter, "#{@bible.book_name(book)} #{chapter}\n", @tag_header)
		verse = 1
		while text != nil
			text = @bible.verse(book, chapter, verse)
			if text != nil
				@marks[verse] = @buffer.create_mark(nil, iter, true)
				@buffer.insert(iter, verse.to_s)
				@buffer.insert(iter, '. ')
				@buffer.insert(iter, text, @tags[verse])
				@buffer.insert(iter, "\n", @tags[verse])
				verse += 1
			end
		end
		begin
			$main.select_verse(1)
		rescue; end
	end

	# 
	# When the user clicks a verse
	#
	def select_verse(verse)
		if @last_verse > 0
			@tags[@last_verse].background_set = false
			@tags[@last_verse].paragraph_background_set = false
		end
		@tags[verse].background_set = true
		@tags[verse].background = '#D0FFFF'
#		@tags[verse].paragraph_background_set = true
#		@tags[verse].paragraph_background = '#D0FFFF'
		@last_verse = verse
		@textview.scroll_to_mark(@marks[verse], 0.1, false, 0, 0.3)
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

	def close
		if super 
			@menu_item.sensitive = true
		end
	end

	private

	# 
	# Print Preview Screen
	#
	def print_preview
	end

	#
	# Open Copy Verses Window
	#
	def copy_verses
	end

	#
	# Open option screen
	#
	def options
	end
end
