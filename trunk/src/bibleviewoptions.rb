class BibleviewOptions < Gtk::Window

	def initialize(bibleview, page)
		super()
		@bibleview = bibleview
		add_controls
	end

private
	
	def add_controls
		set_title(_('Bible preferences'))
		set_border_width(6)
		
		vbox = Gtk::VBox.new(false, 6)
		tabs = Gtk::Notebook.new

		frame_font = Gtk::Frame.new(_('Fonts'))
		frame_paragraph = Gtk::VBox.new
		add_font_controls(frame_font)
		add_paragraph_controls(frame_paragraph)

		button_box = Gtk::HButtonBox.new
		button_box.layout_style = Gtk::ButtonBox::END
		button_box.spacing = 6
		ok = Gtk::Button.new(Gtk::Stock::OK)
		ok.signal_connect('clicked') { ok_clicked }
		cancel = Gtk::Button.new(Gtk::Stock::CANCEL)
		cancel.signal_connect('clicked') { self.destroy }
		button_box.pack_start(cancel)
		button_box.pack_start(ok)
		set_default(ok)

		textframe = Gtk::Frame.new
		textframe.shadow_type = Gtk::SHADOW_ETCHED_OUT
		@buffer = Gtk::TextBuffer.new
		@textview = Gtk::TextView.new(@buffer)
		@textview.editable = false
		@textview.wrap_mode = Gtk::TextTag::WRAP_WORD
		textframe.add(@textview)

		tabs.append_page(frame_font, Gtk::Label.new(_('Font')))
		tabs.append_page(frame_paragraph, Gtk::Label.new(_('Paragraph')))

		vbox.pack_start(tabs, false, false)
		vbox.pack_start(textframe, true, true)
		vbox.pack_start(button_box, false, false)
		add(vbox)

		update_sample

		show_all
	end

	def add_font_controls(frame)
		table = Gtk::Table.new(4, 4, false)
		table.row_spacings = 6
		table.column_spacings = 6
		table.set_border_width(6)

		abbr = @bibleview.bible.abbr

		# create controls
		text_chk = Gtk::Label.new(_('Biblical Text Font'))
		header_chk = Gtk::CheckButton.new(_('Chapter Header'))
		verses_chk = Gtk::CheckButton.new(_('Verse Numbers'))
		strongs_chk = Gtk::CheckButton.new(_('Strongs Numbers'))
		[text_chk, header_chk, verses_chk, strongs_chk].each do |w|
			w.xalign = 0
		end

		text_font = Gtk::FontButton.new(nz($config[abbr, 'text_font'], 'Serif 11'))
		header_font = Gtk::FontButton.new(nz($config[abbr, 'header_font'], 'Serif Bold 15'))
		verses_font = Gtk::FontButton.new(nz($config[abbr, 'verses_font'], 'Serif 11'))
		strongs_font = Gtk::FontButton.new(nz($config[abbr, 'strongs_font'], 'Serif 8'))
		[text_font, header_font, verses_font, strongs_font].each do |ft_button|
			ft_button.use_font = true
			ft_button.use_size = true
		end

		text_color = Gtk::ColorButton.new($config[abbr, 'text_color'])
		header_color = Gtk::ColorButton.new($config[abbr, 'header_color'])
		verses_color = Gtk::ColorButton.new($config[abbr, 'verses_color'])
		strongs_color = Gtk::ColorButton.new(nz($config[abbr, 'strongs_color'], Gdk::Color.parse('#FF0000')))

		verses_ss = Gtk::ToggleButton.new
		strongs_ss = Gtk::ToggleButton.new
		[verses_ss, strongs_ss].each { |b| b.add(Gtk::Image.new("#{IMG}/stock_superscript-16.png")) }

		# control values
		header_chk.active = nz($config[abbr, 'show_headers'], true)
		verses_chk.active = nz($config[abbr, 'show_verses'], true)
		strongs_chk.active = nz($config[abbr, 'show_strongs'], true)
		verses_ss.active = nz($config[abbr, 'verses_superscript'], false)
		strongs_ss.active = nz($config[abbr, 'strongs_superscript'], true)

		# attach controls
		table.attach(text_chk, 0, 1, 0, 1, Gtk::FILL, 0)
		table.attach(text_font, 1, 2, 0, 1, Gtk::EXPAND|Gtk::FILL, 0)
		table.attach(text_color, 2, 3, 0, 1, 0, 0)

		table.attach(header_chk, 0, 1, 1, 2, Gtk::FILL, 0)
		table.attach(header_font, 1, 2, 1, 2, Gtk::EXPAND|Gtk::FILL, 0)
		table.attach(header_color, 2, 3, 1, 2, 0, 0)

		table.attach(verses_chk, 0, 1, 2, 3, Gtk::FILL, 0)
		table.attach(verses_font, 1, 2, 2, 3, Gtk::EXPAND|Gtk::FILL, 0)
		table.attach(verses_color, 2, 3, 2, 3, 0, 0)
		table.attach(verses_ss, 3, 4, 2, 3, 0, 0)

		table.attach(strongs_chk, 0, 1, 3, 4, Gtk::FILL, 0)
		table.attach(strongs_font, 1, 2, 3, 4, Gtk::EXPAND|Gtk::FILL, 0)
		table.attach(strongs_color, 2, 3, 3, 4, 0, 0)
		table.attach(strongs_ss, 3, 4, 3, 4, 0, 0)

		frame.set_border_width(6)
		frame.add(table)
	end

	def add_paragraph_controls(frame)
		tabs = Gtk::Notebook.new
		code = Gtk::Entry.new
		
		box_simple = Gtk::VBox.new(false, 6)
		box_simple.set_border_width(6)
		group_1 = Gtk::RadioButton.new(_('Old Bible'))
		group_1.signal_connect('clicked') { code.text = '#{verse}. #{b_text}#{nl}' }
		group_2 = Gtk::RadioButton.new(group_1, _('Individual verses'))
		group_2.signal_connect('clicked') { code.text = '#{abbr} #{chapter}:#{verse} #{b_text}#{nl}' }
		group_3 = Gtk::RadioButton.new(group_1, _('Paragraphs'))
		group_3.signal_connect('clicked') { code.text = '#{verse}#{text} #{np}' }
		group_4 = Gtk::RadioButton.new(group_1, _('Paragraphs (no verses)'))
		group_4.signal_connect('clicked') { code.text = '#{text} #{np}' }
		box_simple.pack_start(group_1, false, false)
		box_simple.pack_start(group_2, false, false)
		box_simple.pack_start(group_3, false, false)
		box_simple.pack_start(group_4, false, false)
		
		tabs.append_page(box_simple, Gtk::Label.new(_('Simple')))

		box_advanced = Gtk::VBox.new(false, 6)
		box_advanced.set_border_width(6)
		box_advanced.pack_start(Gtk::Label.new('#{book} - ' + _('Name of the book (e.g. "Genesis")')), false, false)
		box_advanced.pack_start(Gtk::Label.new('#{abbr} - ' + _('Abbreviation of the book (e.g. "Gen")')), false, false)
		box_advanced.pack_start(Gtk::Label.new('#{chapter} - ' + _('Number of the chapter')), false, false)
		box_advanced.pack_start(Gtk::Label.new('#{verse} - ' + _('Number of the verse')), false, false)
		box_advanced.pack_start(Gtk::Label.new('#{text} - ' + _('Text of the verse')), false, false)
		box_advanced.pack_start(Gtk::Label.new('#{b_text} - ' + _('Text with the first letter bold when paragraph')), false, false)
		box_advanced.pack_start(Gtk::Label.new('#{nl} - ' + _('New line')), false, false)
		box_advanced.pack_start(Gtk::Label.new('#{np} - ' + _('New line only if new paragraph')), false, false)
		box_advanced.each do |label|
			label.xalign = 0
			label.modify_font(Pango::FontDescription.new('Monospaced 8'))
		end
		hbox = Gtk::HBox.new(false, 6)
		hbox.pack_start(Gtk::Label.new(_('Text code')), false, false)
		hbox.pack_start(code, true, true)
		apply = Gtk::Button.new(Gtk::Stock::APPLY)
		hbox.pack_start(apply, false, false)
		box_advanced.pack_start(hbox, false, false)

		tabs.append_page(box_advanced, Gtk::Label.new(_('Advanced')))
	
		frame.set_border_width(6)
		frame.add(tabs)
	end

	def update_sample
	end

	def ok_clicked
	end

end
