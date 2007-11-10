require 'net/http'

class Download < Gtk::Window

	def initialize(main_window)
		super()

		set_modal(true)
		set_transient_for(main_window)
		set_title(_('Download from the internet'))
		set_border_width(6)
		set_default_size(450, 280)

		@vbox = Gtk::VBox.new
		@vbox.spacing = 6
		@downloading_frame = Gtk::Frame.new
		@downloading_frame.shadow_type = Gtk::SHADOW_IN
		downloading = Gtk::Label.new(_('Downloading data from the internet...'))
		@downloading_frame.add(downloading)
		@vbox.pack_start(@downloading_frame, true, true)
		@vbox.show_all

		download_button = Gtk::Button.new(_('Download'))
		@af = Gtk::AspectFrame.new('', 1, 0.5, 1, true)
		@af.shadow_type = Gtk::SHADOW_NONE
		@af.add(download_button)
		download_button.show
		@vbox.pack_start(@af, false, false)

		# TODO download bar
		
		add(@vbox)

		@download_ok = true
		Thread.new { download }
		# TODO timeout
	end

	def download
		Net::HTTP.start('gladius.googlecode.com') do |http|
			resp = http.get('/svn/trunk/data/modules.yaml')
			open("#{HOME}/modules.yaml", 'w') do |file|
				file.write(resp.body)
			end
		end
		@download_ok = true
		@af.show
		# TODO feed treeview
	end

end
