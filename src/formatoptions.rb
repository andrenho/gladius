class FormatOptions < Gtk::VBox

	OLD_BIBLE = '%V. %K%n'
	INDIVIDUAL_VERSES = '%A %C:%V %K%n'
	PARAGRAPHS = '%V%T %p'
	PARAGRAPHS_NO_VERSES = '%T %p'

	def initialize(format, parent, bible, book=43, chapter=3, page=1)
		super(false, 6)
		@bible = bible
		@format = format.clone
		@parent = parent
		add_controls(book, chapter, page)
	end

	def format
		@format
	end

private

	def add_controls(book, chapter, page)
		@book = book; @chapter = chapter

		tabs = Gtk::Notebook.new

		frame_font = Gtk::Frame.new(_('Fonts'))
		frame_paragraph = Gtk::VBox.new
		add_font_controls(frame_font)
		add_paragraph_controls(frame_paragraph)

		textframe = Gtk::Frame.new(_('Sample'))
		textframe.shadow_type = Gtk::SHADOW_IN
		@text = BibleText.new(@bible, @format, @parent)
		@text.border_width = 6
		@verses = []
		(1..@bible.n_verses(book, chapter)).each { |n| @verses << [book, chapter, n] }
		@text.show_verses(@verses, "#{@bible.book_name(book)} #{chapter}")
		textframe.add(@text)

		tabs.append_page(frame_font, Gtk::Label.new(_('Font')))
		tabs.append_page(frame_paragraph, Gtk::Label.new(_('Paragraph')))

		self.pack_start(tabs, false, false)
		self.pack_start(textframe, true, true)

		update_sample

		show_all
		tabs.page = page - 1
	end

	def add_font_controls(frame)
		table = Gtk::Table.new(4, 4, false)
		table.row_spacings = 6
		table.column_spacings = 6
		table.set_border_width(6)

		abbr = @bible.abbr

		# create controls
		text_chk = Gtk::Label.new(_('Biblical Text Font'))
		@header_chk = Gtk::CheckButton.new(_('Chapter Header'))
		verses_chk = Gtk::Label.new(_('Biblical References Font'))
		@strongs_chk = Gtk::CheckButton.new(_('Strongs Numbers'))
		[text_chk, @header_chk, verses_chk, @strongs_chk].each do |w|
			w.xalign = 0
		end

		@text_font = Gtk::FontButton.new(@format.text_font)
		@header_font = Gtk::FontButton.new(@format.header_font)
		@verses_font = Gtk::FontButton.new(@format.verses_font)
		@strongs_font = Gtk::FontButton.new(@format.strongs_font)
		[@text_font, @header_font, @verses_font, @strongs_font].each do |ft_button|
			ft_button.use_font = true
			ft_button.use_size = true
			ft_button.signal_connect('font-set') { update_sample }
		end

		@text_color = Gtk::ColorButton.new(Gdk::Color.parse(@format.text_color))
		@text_bg_color = Gtk::ColorButton.new(Gdk::Color.parse(@format.text_bg_color))
		@header_color = Gtk::ColorButton.new(Gdk::Color.parse(@format.header_color))
		@verses_color = Gtk::ColorButton.new(Gdk::Color.parse(@format.verses_color))
		@strongs_color = Gtk::ColorButton.new(Gdk::Color.parse(@format.strongs_color))
		[@text_color, @text_bg_color, @header_color, @verses_color, @strongs_color].each do |c|
			c.signal_connect('color-set') { update_sample }
		end

		@verses_ss = Gtk::ToggleButton.new
		@strongs_ss = Gtk::ToggleButton.new
		[@verses_ss, @strongs_ss].each do |b|
			b.add(Gtk::Image.new("#{IMG}/stock_superscript-16.png"))
		end

		# control values
		@header_chk.active = @format.show_header
		@strongs_chk.active = @format.show_strongs
		@verses_ss.active = @format.verses_ss
		@strongs_ss.active = @format.strongs_ss

		# connect signals
		@header_chk.signal_connect('toggled') { update_sample }
		@strongs_chk.signal_connect('toggled') { update_sample }
		[@verses_ss, @strongs_ss].each do |b|
			b.signal_connect('toggled') { update_sample }
		end

		# attach controls
		table.attach(text_chk, 0, 1, 0, 1, Gtk::FILL, 0)
		table.attach(@text_font, 1, 2, 0, 1, Gtk::EXPAND|Gtk::FILL, 0)
		table.attach(@text_color, 2, 3, 0, 1, 0, 0)
		table.attach(@text_bg_color, 3, 4, 0, 1, 0, 0)

		table.attach(@header_chk, 0, 1, 1, 2, Gtk::FILL, 0)
		table.attach(@header_font, 1, 2, 1, 2, Gtk::EXPAND|Gtk::FILL, 0)
		table.attach(@header_color, 2, 3, 1, 2, 0, 0)

		table.attach(verses_chk, 0, 1, 2, 3, Gtk::FILL, 0)
		table.attach(@verses_font, 1, 2, 2, 3, Gtk::EXPAND|Gtk::FILL, 0)
		table.attach(@verses_color, 2, 3, 2, 3, 0, 0)
		table.attach(@verses_ss, 3, 4, 2, 3, 0, 0)

		table.attach(@strongs_chk, 0, 1, 3, 4, Gtk::FILL, 0)
		table.attach(@strongs_font, 1, 2, 3, 4, Gtk::EXPAND|Gtk::FILL, 0)
		table.attach(@strongs_color, 2, 3, 3, 4, 0, 0)
		table.attach(@strongs_ss, 3, 4, 3, 4, 0, 0)

		frame.set_border_width(6)
		frame.add(table)
	end

	def add_paragraph_controls(frame)
		tabs = Gtk::Notebook.new
		@paragraph_code = Gtk::Entry.new
		@paragraph_code.text = @format.paragraph_code
		
		box_simple = Gtk::VBox.new(false, 6)
		box_simple.set_border_width(6)
		group_1 = Gtk::RadioButton.new(_('Old Bible'))
		group_2 = Gtk::RadioButton.new(group_1, _('Individual verses'))
		group_3 = Gtk::RadioButton.new(group_1, _('Paragraphs'))
		group_4 = Gtk::RadioButton.new(group_1, _('Paragraphs (no verses)'))
		group_advanced = Gtk::RadioButton.new(group_1, _('Advanced'))
		
		case @format.paragraph_code
		when OLD_BIBLE
			group_1.active = true
		when INDIVIDUAL_VERSES
			group_2.active = true
		when PARAGRAPHS
			group_3.active = true
		when PARAGRAPHS_NO_VERSES
			group_4.active = true
		else
			group_advanced.active = true
		end

		group_1.signal_connect('clicked') do 
			@paragraph_code.text = OLD_BIBLE
			@verses_ss.active = false
			tabs.page = 0
			update_sample
		end
		group_2.signal_connect('clicked') do
			@paragraph_code.text = INDIVIDUAL_VERSES
			@verses_ss.active = false
			tabs.page = 0
			update_sample
		end
		group_3.signal_connect('clicked') do 
			@paragraph_code.text = PARAGRAPHS
			@verses_ss.active = true
			tabs.page = 0
			update_sample
		end
		group_4.signal_connect('clicked') do
			@paragraph_code.text = PARAGRAPHS_NO_VERSES
			tabs.page = 0
			update_sample
		end
		group_advanced.signal_connect('clicked') do
			tabs.page = 1
		end
		box_simple.pack_start(group_1, false, false)
		box_simple.pack_start(group_2, false, false)
		box_simple.pack_start(group_3, false, false)
		box_simple.pack_start(group_4, false, false)
		box_simple.pack_start(group_advanced, false, false)
		
		tabs.append_page(box_simple, Gtk::Label.new(_('Simple')))

		box_advanced = Gtk::VBox.new(false, 6)
		box_advanced.set_border_width(6)
		box_advanced.pack_start(Gtk::Label.new('%B - ' + _('Name of the book (e.g. "Genesis")')), false, false)
		box_advanced.pack_start(Gtk::Label.new('%A - ' + _('Abbreviation of the book (e.g. "Gen")')), false, false)
		box_advanced.pack_start(Gtk::Label.new('%C - ' + _('Number of the chapter')), false, false)
		box_advanced.pack_start(Gtk::Label.new('%V - ' + _('Number of the verse')), false, false)
		box_advanced.pack_start(Gtk::Label.new('%T - ' + _('Text of the verse')), false, false)
		box_advanced.pack_start(Gtk::Label.new('%K - ' + _('Text with the first letter bold when paragraph')), false, false)
		box_advanced.pack_start(Gtk::Label.new('%n - ' + _('New line')), false, false)
		box_advanced.pack_start(Gtk::Label.new('%p - ' + _('New line only if new paragraph')), false, false)
		box_advanced.each do |label|
			label.xalign = 0
			label.modify_font(Pango::FontDescription.new('Monospaced 8'))
		end
		hbox = Gtk::HBox.new(false, 6)
		hbox.pack_start(Gtk::Label.new(_('Text code')), false, false)
		hbox.pack_start(@paragraph_code, true, true)
		apply = Gtk::Button.new(Gtk::Stock::APPLY)
		apply.signal_connect('clicked') { update_sample }
		hbox.pack_start(apply, false, false)
		box_advanced.pack_start(hbox, false, false)

		tabs.append_page(box_advanced, Gtk::Label.new(_('Advanced')))
	
		frame.set_border_width(6)
		frame.add(tabs)
	end

	def update_sample
		rewrite = false
		if @format.show_header != @header_chk.active? or @format.show_strongs != @strongs_chk.active? or @format.paragraph_code != @paragraph_code.text
			rewrite = true
		end

		@format.show_header = @header_chk.active?
		@format.show_strongs = @strongs_chk.active?
		@format.verses_ss = @verses_ss.active?
		@format.strongs_ss = @strongs_ss.active?

		@format.text_color = color_s(@text_color.color)
		@format.text_bg_color = color_s(@text_bg_color.color)
		@format.header_color = color_s(@header_color.color)
		@format.verses_color = color_s(@verses_color.color)
		@format.strongs_color = color_s(@strongs_color.color)

		@format.text_font = @text_font.font_name
		@format.header_font = @header_font.font_name
		@format.verses_font = @verses_font.font_name
		@format.strongs_font = @strongs_font.font_name

		@format.paragraph_code = @paragraph_code.text

		@text.set_format(@format, rewrite)
	end

	def color_s(c)
		r = (c.red / 256).to_s(16)
		r = "0#{r}" if r.length == 1
		g = (c.green / 256).to_s(16)
		g = "0#{g}" if g.length == 1
		b = (c.blue / 256).to_s(16)
		b = "0#{b}" if b.length == 1
		return "##{r}#{g}#{b}"
	end

end
