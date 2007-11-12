class Util

	FL_BR = Gdk::Pixbuf.new("#{IMG}/br.gif")
	FL_EN = Gdk::Pixbuf.new("#{IMG}/gb.gif")

	def Util.flag(language)
		case language
		when 'pt-Br'
			return FL_BR
		when 'en'
			return FL_EN
		else
			return nil
		end
	end

end
