def nz(value, nil_value)
	return nil_value if(value == nil)
	return value
end

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

	def Util.infobox(message, parent=$main)
		d = Gtk::MessageDialog.new(parent, 
			Gtk::Dialog::DESTROY_WITH_PARENT | Gtk::Dialog::MODAL,
			Gtk::MessageDialog::INFO,
			Gtk::MessageDialog::BUTTONS_OK,
			message)
		d.title = _('Gladius %s', BB_VERSION)
		d.modal = true
		d.transient_for = parent
		d.run
		d.destroy
	end

	def Util.warning(message, parent=$main)
		d = Gtk::MessageDialog.new(parent, 
			Gtk::Dialog::DESTROY_WITH_PARENT | Gtk::Dialog::MODAL,
			Gtk::MessageDialog::WARNING,
			Gtk::MessageDialog::BUTTONS_OK,
			message)
		d.title = _('Gladius %s', BB_VERSION)
		d.modal = true
		d.transient_for = parent
		d.run
		d.destroy
	end

end
