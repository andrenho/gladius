class Download < Gtk::Window

	def initialize(main_window)
		super()

		set_modal(true)
		set_transient_for(main_window)
		set_title(_('Download from the internet'))

		
	end

end
