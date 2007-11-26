class Format

	attr_accessor :text_font
	attr_accessor :text_color
	attr_accessor :text_bg_color

	attr_accessor :header_font
	attr_accessor :header_color
	attr_accessor :show_header

	attr_accessor :verses_font
	attr_accessor :verses_color
	attr_accessor :verses_ss

	attr_accessor :strongs_font
	attr_accessor :strongs_color
	attr_accessor :strongs_ss
	attr_accessor :show_strongs

	attr_accessor :paragraph_code

	def Format.load(abbr)
		f = Format.new
		
		f.text_font = $config[abbr, 'text_font']
		f.text_font = 'Serif 11' if f.text_font == nil
		f.text_color = $config[abbr, 'text_color']
		f.text_color = '#000000' if f.text_color == nil
		f.text_bg_color = $config[abbr, 'text_bg_color']
		f.text_bg_color = '#EEEEFF' if f.text_bg_color == nil

		f.header_font = $config[abbr, 'header_font']
		f.header_font = 'Serif Bold 14' if f.header_font == nil
		f.header_color = $config[abbr, 'header_color']
		f.header_color = '#000000' if f.header_color == nil
		f.show_header = $config[abbr, 'show_header']
		f.show_header = true if f.show_header == nil

		f.verses_font = $config[abbr, 'verses_font']
		f.verses_font = 'Serif 11' if f.verses_font == nil
		f.verses_color = $config[abbr, 'verses_color']
		f.verses_color = '#000000' if f.verses_color == nil
		f.verses_ss = $config[abbr, 'verses_ss']
		f.verses_ss = false if f.verses_ss == nil

		f.strongs_font = $config[abbr, 'strongs_font']
		f.strongs_font = 'Serif 8' if f.strongs_font == nil
		f.strongs_color = $config[abbr, 'strongs_color']
		f.strongs_color = '#000000' if f.strongs_color == nil
		f.strongs_ss = $config[abbr, 'strongs_ss']
		f.strongs_ss = true if f.strongs_ss == nil
		f.show_strongs = $config[abbr, 'show_strongs']
		f.show_strongs = true if f.show_strongs == nil

		f.paragraph_code = $config[abbr, 'paragraph_code']
		f.paragraph_code = FormatOptions::OLD_BIBLE

		return f
	end

	def save(abbr)
		$config[abbr, 'text_font'] = @text_font
		$config[abbr, 'text_color'] = @text_color
		$config[abbr, 'text_bg_color'] = @text_bg_color

		$config[abbr, 'header_font'] = @header_font
		$config[abbr, 'header_color'] = @header_color
		$config[abbr, 'show_header'] = @show_header

		$config[abbr, 'verses_font'] = @verses_font
		$config[abbr, 'verses_color'] = @verses_color 
		$config[abbr, 'verses_ss'] = @verses_ss

		$config[abbr, 'strongs_font'] = @strongs_font
		$config[abbr, 'strongs_color'] = @strongs_color
		$config[abbr, 'strongs_ss'] = @strongs_ss
		$config[abbr, 'show_strongs'] = @show_strongs
		
		$config[abbr, 'paragraph_code'] = @paragraph_code
		p "saved #{abbr}"
	end

end
