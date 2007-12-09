class ParsedParagraphCode
	TOKEN     = 1
	TEXT      = 2
	ATTRIBUTE = 3

	attr_accessor :type
	attr_accessor :value
	attr_accessor :bop, :eop
end

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

	attr_reader :paragraph_code
	attr_reader :parsed_paragraph_code

	def initialize
		@text_font = 'Serif 11'
		@text_color = '#000000'
		@text_bg_color = '#EEEEFF'
		
		@header_font = 'Serif Bold 14'
		@header_color = '#000000'
		@show_header = true

		@verses_font = 'Serif 11'
		@verses_color = '#000000'
		@verses_ss = false

		@strongs_font = 'Serif 8'
		@strongs_color = '#000000'
		@strongs_ss = true
		@show_strongs = true

		self.paragraph_code = FormatOptions::OLD_BIBLE
	end


	def paragraph_code=(new)
		@paragraph_code = new
		@parsed_paragraph_code = parse(new) if new != nil
	end


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
		f.paragraph_code = FormatOptions::OLD_BIBLE if f.paragraph_code == nil

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
	end


private


	def parse(pc)
		i = 0
		parsed_paragraph_code = []
		bop = eop = false
		current_text = ''
		parsed = nil
		while pc[i] != nil
			if pc[i..i] == '{'
				if i == 0
					bop = true
				else
					eop = true
				end
				parsed = nil
			elsif pc[i..i] == '}'
				bop = eop = false
				parsed = nil
			elsif ['\\n', '%k', '%B', '%A', '%C', '%V', '%T'].include? pc[i..(i+1)]
				parsed = ParsedParagraphCode.new
				if pc[i..(i+1)] == '%k'
					parsed.type = ParsedParagraphCode::ATTRIBUTE
				else
					parsed.type = ParsedParagraphCode::TOKEN
				end
				parsed.value = pc[i..(i+1)]
				parsed.bop = bop
				parsed.eop = eop
				parsed_paragraph_code << parsed
				parsed = nil
				i += 1
			else
				if parsed == nil
					parsed = ParsedParagraphCode.new
					parsed.type = ParsedParagraphCode::TEXT
					parsed.value = pc[i..i]
					parsed.bop = bop
					parsed.eop = eop
					parsed_paragraph_code << parsed
				else
					parsed.value += pc[i..i]
				end
			end
			i += 1
		end
		return parsed_paragraph_code
	end

end
