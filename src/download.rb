require 'net/http'

class Download < Gtk::Window

	def initialize
		super()

		set_title(_('Download from the internet'))
		set_border_width(6)
		set_default_size(450, 280)

		# Downloading... label
		@vbox = Gtk::VBox.new
		@vbox.spacing = 6
		@downloading_frame = Gtk::Frame.new
		@downloading_frame.shadow_type = Gtk::SHADOW_IN
		downloading = Gtk::Label.new(_('Downloading data from the internet...'))
		@downloading_frame.add(downloading)
		@vbox.pack_start(@downloading_frame, true, true)
		@vbox.show_all

		# Download options
		@scroll_options = Gtk::ScrolledWindow.new
		@scroll_options.shadow_type = Gtk::SHADOW_IN
		build_download_tree
		@scroll_options.add(@download_options)
		@vbox.pack_start(@scroll_options, true, true)

		# Download button
		download_button = Gtk::Button.new(_('Download'))
		@af = Gtk::AspectFrame.new('', 1, 0.5, 1, true)
		@af.shadow_type = Gtk::SHADOW_NONE
		@af.add(download_button)
		download_button.show
		@vbox.pack_start(@af, false, false)

		# TODO download bar
		
		add(@vbox)

		Thread.new { download }
	end

	def build_download_tree
		@treestore = Gtk::TreeStore.new(String, TrueClass, Gdk::Pixbuf, String, TrueClass, Integer)
		@download_options = Gtk::TreeView.new(@treestore)
		@download_options.selection.mode = Gtk::SELECTION_NONE
		
		renderer = Gtk::CellRendererToggle.new
		col = Gtk::TreeViewColumn.new('', renderer, :active => 1, :visible => 4)
		@download_options.append_column(col)

		renderer = Gtk::CellRendererPixbuf.new
		col = Gtk::TreeViewColumn.new(_('Lang'), renderer, :pixbuf => 2, :visible => 4)
		@download_options.append_column(col)

		renderer = Gtk::CellRendererText.new
		col = Gtk::TreeViewColumn.new(_('Bible Translation'), renderer, :text => 0, :weight => 5)
		@download_options.append_column(col)

		@download_options.show_all
	end
	private :build_download_tree

	def download
		yaml = ''
		begin
			Net::HTTP.start('gladius.googlecode.com') do |http|
				resp = http.get('/svn/trunk/data/modules.yaml')
				yaml = resp.body
				# open("#{HOME}/modules.yaml", 'w') do |file|
				#	file.write(resp.body)
				# end
			end
		rescue
			puts 'No connection'
		else
			records = YAML::load(yaml)
			@downloading_frame.hide
			@scroll_options.show
			@af.show
			
			# Bibles
			parent = @treestore.append(nil)
			parent[0] = _('Bibles')
			parent[4] = false
			parent[5] = Pango::WEIGHT_BOLD
			records.each do |rec|
				if rec['type'] == 'bible'
					child = @treestore.append(parent)
					child[0] = rec['name']
					child[2] = Util.flag(rec['language'])
					child[3] = rec['url']
					child[4] = true
				end
			end
		end
	end

end
