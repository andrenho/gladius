class Search < View

	EXACT     = 0
	ALL_WORDS = 1
	ANY_WORDS = 2
	
	ALL = 0

	def initialize(bible, text, match, partial, range)
		super(_('Search Results'))
		@vbox.pack_start(Gtk::Label.new(_('Searching...')), true, true)
		show_all
	end

end
