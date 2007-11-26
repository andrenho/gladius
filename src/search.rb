class Search < View

	EXACT     = 0
	ALL_WORDS = 1
	ANY_WORDS = 2
	
	ALL         = 0
	PENTATEUCH  = 1
	HISTORICALS = 2
	WISDOM      = 3
	PROPHETS    = 4
	GOSPELS     = 5
	ACTS        = 6
	EPISTOLS    = 7
	REVELATION  = 8

	def initialize(bibleview, text, match, partial, range)
		super(_('Search Results') + ": #{text}")

		# Copy verses
		cv_button = Gtk::Button.new
		cv_button.add(Gtk::Image.new(Gtk::Stock::COPY, Gtk::IconSize::MENU))
		cv_button.relief = Gtk::RELIEF_NONE
		$tip.set_tip(cv_button, _('Copy verses'), '')
		@hbox.pack_start(cv_button, false, false)
		cv_button.signal_connect('clicked') { copy_verses }

		# ----------------
		@hbox.pack_start(Gtk::VSeparator.new, false, false)

		@search_vbox = Gtk::VBox.new(false, 12)
		search_label = Gtk::Label.new(_('Searching...'))
		search_image = Gtk::Image.new("#{IMG}/book.gif")
		search_cancel = Gtk::Button.new(Gtk::Stock::CANCEL)
		af = Gtk::AspectFrame.new('', 0.5, 0.5, 1, true)
		af.shadow_type = Gtk::SHADOW_NONE
		af.add(search_cancel)
		@search_vbox.pack_start(search_label, false, false)
		@search_vbox.pack_start(search_image, false, false)
		@search_vbox.pack_start(af, false, false)
		@vbox.pack_start(@search_vbox, true, false)
		show_all
		Thread.abort_on_exception = true
		@tags = {}
		thread = Thread.new do
			rs = bibleview.bible.search(text, match, partial, range)
			show_results(rs)
		end
		search_cancel.signal_connect('clicked') do
			thread.kill
			close
		end
		@previous = nil
		@last_mark_set = nil
		@search_term = text
		@bible = bibleview.bible
		@format = bibleview.format
	end

	def show_results(rs)
		@text = BibleText.new(@bible, @format, self)

		verses = []
		rs.each do |row|
			verses << [row['book'].to_i, row['chapter'].to_i, row['verse'].to_i]
		end
		@text.show_verses(verses, nil, @search_term)

		@text.show_all
		@vbox.remove(@search_vbox)
		@vbox.pack_start(@text)
	end
	private :show_results

	def select_verse(book, chapter, verse)
		@text.select_verse(book, chapter, verse)
	end

	def refit_menus
		$main.file_save.sensitive = false
		$main.file_save_as.sensitive = false
		$main.file_revert.sensitive = false
		$main.file_close.sensitive = true

		$main.edit_undo.sensitive = false
		$main.edit_redo.sensitive = false

		$main.edit_cut.sensitive = false
		if @text.buffer.selection_bounds != nil
			$main.edit_copy.sensitive = @text.buffer.selection_bounds[2]
		else
			$main.edit_copy.sensitive = false
		end
		$main.edit_cv.sensitive = true
		$main.edit_paste.sensitive = false

		$main.edit_find.sensitive = true
		$main.edit_fn.sensitive = (@find_slot != "")
		$main.edit_replace.sensitive = false

		$main.edit_dt.sensitive = false

		$main.format_font.sensitive = false
		$main.format_paragraph.sensitive = false

		$main.format_bold.sensitive = false
		$main.format_italic.sensitive = false
		$main.format_underline.sensitive = false

		$main.current_view = self
	end

	#
	# Copy verses screen
	def copy_verses
		# TODO
	end

	# 
	# Print Preview Screen
	#
	def print_preview
	end


end
