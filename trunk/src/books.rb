class Books < Gtk::Frame

	def initialize
		super

		@books = [
			'Genesis', 'Exodus', 'Leviticus', 'Numbers', 'Deuteronomy',
			'Joshua', 'Judges', 'Ruth', '1 Samuel', '2 Samuel',
			'1 Kings', '2 Kings', '1 Chronicles', '2 Chronicles',
			'Ezra', 'Nehemiah', 'Esther', 'Job', 'Psalms', 'Proverbs',
			'Ecclesiastes', 'Song of Solomon', 'Isaiah', 'Jeremiah',
			'Lamentations', 'Ezekiel', 'Daniel', 'Hosea', 'Joel',
			'Amos', 'Obadiah', 'Jonah', 'Micah', 'Nahum', 'Habakkuk',
			'Zephenaiah', 'Haggai', 'Zechariah', 'Malachi', 
			'Matthew', 'Mark', 'Luke', 'John', 'Acts',
			'Romans', '1 Corinthians', '2 Corinthians', 'Galatians',
			'Ephesians', 'Philippians', 'Colossians', '1 Thessalonians',
			'2 Thessalonians', '1 Timothy', '2 Timothy', 'Titus',
			'Philemon', 'Hebrews', 'James', '1 Peter', '2 Peter',
			'1 John', '2 John', '3 John', 'Jude', 'Revelation'
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
		end

		view = Gtk::TreeView.new(treestore)
		
		renderer = Gtk::CellRendererText.new

		col = Gtk::TreeViewColumn.new("Book", renderer, :text => 0)
		view.append_column(col)

		view.signal_connect("row-activated") do |view, path, column|
			book, chapter = path.to_str.split(':')
			book = book.to_i + 1
			chapter = chapter.to_i + 1
			$main.go_to(book, chapter)
		end

		scroll = Gtk::ScrolledWindow.new
		scroll.add_with_viewport(view)
		add(scroll)
	end
	
end
