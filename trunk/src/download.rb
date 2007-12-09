require 'net/http'
require 'zip/zipfilesystem'

class Download < Gtk::Window

	NAME = 0
	CHECK = 1
	FLAG  = 2
	FILE  = 3
	HEADER_INVISIBLE = 4
	HEADER_BOLD = 5
	PROGRESS = 6
	PROGRESS_VISIBLE = 7
	PROGRESS_TEXT = 8
	SIZE = 9
	VERSION = 10

	def initialize
		super()

		set_title(_('Download from the internet'))
		set_border_width(6)
		set_default_size(500, 320)

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
		@download_button = Gtk::Button.new(_('Download'))
		@af = Gtk::AspectFrame.new('', 1, 0.5, 1, true)
		@af.shadow_type = Gtk::SHADOW_NONE
		@af.add(@download_button)
		@download_button.show
		@download_button.signal_connect('clicked') do |w|
			Thread.abort_on_exception = true
			@dl_thread = Thread.new { download }
		end
		@vbox.pack_start(@af, false, false)

		# TODO download bar
		
		add(@vbox)

		@downloading_frame.show_all
		self.show
		self.window.cursor = Gdk::Cursor.new(Gdk::Cursor::WATCH)

		Gtk.main_iteration while Gtk.events_pending?

		Thread.abort_on_exception = true
		Thread.new do 
			get_modules
			self.window.cursor = nil
		end
	end

	def build_download_tree

		@treestore = Gtk::TreeStore.new(String, TrueClass, Gdk::Pixbuf, String, TrueClass, Integer, Integer, TrueClass, String, Integer, String)
		@download_options = Gtk::TreeView.new(@treestore)
		@download_options.selection.mode = Gtk::SELECTION_NONE
		
		@renderer = Gtk::CellRendererToggle.new
		@handler = @renderer.signal_connect('toggled') do |w, path_str|
			path = Gtk::TreePath.new(path_str)
			iter = @treestore.get_iter(path)
			toggle_item = iter[CHECK]
			toggle_item ^= 1
			iter[CHECK] = toggle_item
		end
		col = Gtk::TreeViewColumn.new('', @renderer, :active => CHECK, :visible => HEADER_INVISIBLE)
		@download_options.append_column(col)

		renderer = Gtk::CellRendererPixbuf.new
		col = Gtk::TreeViewColumn.new(_('Lang'), renderer, :pixbuf => FLAG, :visible => HEADER_INVISIBLE)
		@download_options.append_column(col)

		renderer = Gtk::CellRendererText.new
		col = Gtk::TreeViewColumn.new(_('Module'), renderer, :text => NAME, :weight => HEADER_BOLD)
		@download_options.append_column(col)

		renderer = Gtk::CellRendererText.new
		col = Gtk::TreeViewColumn.new(_('Version'), renderer, :text => VERSION, :weight => HEADER_BOLD)
		@download_options.append_column(col)

		renderer = Gtk::CellRendererProgress.new
		col = Gtk::TreeViewColumn.new(_('Download'), renderer, :value => PROGRESS, :visible => PROGRESS_VISIBLE, :text => PROGRESS_TEXT)
		@download_options.append_column(col)

		@download_options.show_all
	end
	private :build_download_tree

	def get_modules
		yaml = ''
		begin
#			Timeout::timeout(5) do 
				http = Net::HTTP.new('gladius.googlecode.com')
				http.open_timeout = 5
				http.read_timeout = 5
				http.start
				resp = http.get('/svn/trunk/data/modules.yaml')
				yaml = resp.body
				records = YAML::load(yaml)
#			end
		rescue Timeout::Error
			Util.warning(_('Sorry! An internet connection could not be established.'))
			self.destroy
		else
			@downloading_frame.hide
			@scroll_options.show
			@af.show

			# Info
			records.each do |rec|
				if rec['type'] == 'info'
					@host = rec['host']
				end
			end
			
			# Bibles
			parent = @treestore.append(nil)
			parent[NAME] = _('Bible Translations')
			parent[HEADER_INVISIBLE] = false
			parent[HEADER_BOLD] = Pango::FontDescription::WEIGHT_BOLD
			records.each do |rec|
				if rec['type'] == 'bible'
					child = @treestore.append(parent)
					child[NAME] = rec['name']
					child[FLAG] = Util.flag(rec['language'])
					child[FILE] = rec['file']
					child[HEADER_INVISIBLE] = true
					child[SIZE] = rec['size']
					child[PROGRESS_TEXT] = nil
					child[VERSION] = rec['version']
				end
			end

			@download_options.expand_all

		end
	end

	def download
		# Before
		@treestore.each do |model, path, iter|
			if iter[CHECK]
				iter[PROGRESS_VISIBLE] = true
				iter[PROGRESS] = 0
				iter[PROGRESS_TEXT] = nil
			end
		end
		@renderer.signal_handler_block(@handler)

		cancel_button = Gtk::Button.new(Gtk::Stock::CANCEL)
		@af.remove(@download_button)
		@af.add(cancel_button)
		cancel_button.show
		cancel_button.signal_connect('clicked') do |w|
			@treestore.each do |model, path, iter|
				iter[PROGRESS_TEXT] = _('Cancelled') if iter[CHECK]
			end
			@af.remove(cancel_button)
			@af.add(@download_button)
			@dl_thread.kill
		end

		# Downloads
		@treestore.each do |model, path, iter|
			if iter[CHECK]
				sz = 0
				filename = iter[FILE].scan(/.*\/(.*)/)[0][0]
				open("#{ENV['TEMP']}#{filename}", 'wb') do |file|
					Net::HTTP.start('gladius.googlecode.com') do |http|
						resp = http.get(iter[FILE]) do |r|
							file.write(r)
							sz += r.length
							iter[PROGRESS] = (sz * 100 / iter[SIZE])
						 end
					end
				end

				# Install
				bible_filename = ''
				iter[PROGRESS_TEXT] = _('Unpacking')
				Zip::ZipFile.open("#{ENV['TEMP']}#{filename}") do |zip|
					zip.dir.foreach('/') do |file|
						open("#{HOME}/#{file}", 'wb') do |f|
							f.write(zip.file.read(file))
							bible_filename = "#{HOME}/#{file}"
						end
					end
				end
				File.delete("#{ENV['TEMP']}#{filename}")
				iter[PROGRESS_TEXT] = _('Done')
				iter[CHECK] = false

				$main.add_bible_to_menu(bible_filename) if $main != nil

			end
		end

		# After
		Util.infobox(_('All downloads completed successfully. You can now read any of these modules on the View menu.'))
		self.destroy
	end

end
