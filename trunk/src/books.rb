class Books < Gtk::Frame

	def initialize
		super

		@books = [
			_('Genesis'), _('Exodus'), _('Leviticus'), _('Numbers'), _('Deuteronomy'),
			_('Joshua'), _('Judges'), _('Ruth'), _('1 Samuel'), _('2 Samuel'),
			_('1 Kings'), _('2 Kings'), _('1 Chronicles'), _('2 Chronicles'),
			_('Ezra'), _('Nehemiah'), _('Esther'), _('Job'), _('Psalms'), _('Proverbs'),
			_('Ecclesiastes'), _('Song of Solomon'), _('Isaiah'), _('Jeremiah'),
			_('Lamentations'), _('Ezekiel'), _('Daniel'), _('Hosea'), _('Joel'),
			_('Amos'), _('Obadiah'), _('Jonah'), _('Micah'), _('Nahum'), _('Habakkuk'),
			_('Zephenaiah'), _('Haggai'), _('Zechariah'), _('Malachi'), 
			_('Matthew'), _('Mark'), _('Luke'), _('John'), _('Acts'),
			_('Romans'), _('1 Corinthians'), _('2 Corinthians'), _('Galatians'),
			_('Ephesians'), _('Philippians'), _('Colossians'), _('1 Thessalonians'),
			_('2 Thessalonians'), _('1 Timothy'), _('2 Timothy'), _('Titus'),
			_('Philemon'), _('Hebrews'), _('James'), _('1 Peter'), _('2 Peter'),
			_('1 John'), _('2 John'), _('3 John'), _('Jude'), _('Revelation')
		]
		@n_chapters = [50, 50, 27, 36, 34, 24, 21, 4, 31, 24, 22, 25, 29,
			36, 10, 13, 10, 42, 150, 31, 12, 8, 66, 52, 5, 48, 12, 14, 3,
			9, 1, 4, 7, 3, 3, 3, 2, 14, 4, 28, 16, 24, 21, 28, 16, 16, 13,
			6, 6, 4, 4, 5, 3, 6, 4, 3, 1, 13, 5, 5, 3, 5, 1, 1, 1, 22 ]

		treestore = Gtk::TreeStore.new(String)
		i = 0
		@books.each do |book|
			parent = treestore.append(nil)
			parent[0] = book
			(1..@n_chapters[i]).each do |n|
				child = treestore.append(parent)
				child[0] = n.to_s
			end
			i += 1
		end

		@view = Gtk::TreeView.new(treestore)
		
		renderer = Gtk::CellRendererText.new

		@col = Gtk::TreeViewColumn.new(_('Book'), renderer, :text => 0)
		@view.append_column(@col)

		@view.signal_connect("row-activated") do |view, path, column|
			book, chapter = path.to_str.split(':')
			book = book.to_i + 1
			chapter = chapter.to_i + 1
			$main.go_to(book, chapter)
		end

		scroll = Gtk::ScrolledWindow.new
		scroll.add(@view)
		add(scroll)
	end

	def go_to(book, chapter)
		@view.expand_row(Gtk::TreePath.new("#{book-1}"), false)
		path = Gtk::TreePath.new("#{book-1}:#{chapter-1}")
		@view.set_cursor(path, @col, false)
		@view.scroll_to_cell(path, nil, false, 0.5, 0)
	end
	
end
