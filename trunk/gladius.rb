#!/usr/bin/env ruby

SHARE = "."

#
# Get platform (code from Matt Mower <self@mattmower.com>)
#
if RUBY_PLATFORM =~ /darwin/i
	OS = :unix
	IMPL = :macosx
elsif RUBY_PLATFORM =~ /linux/i
	OS = :unix
	IMPL = :linux
elsif RUBY_PLATFORM =~ /freebsd/i
	OS = :unix
	IMPL = :freebsd
elsif RUBY_PLATFORM =~ /netbsd/i
	OS = :unix
	IMPL = :netbsd
elsif RUBY_PLATFORM =~ /mswin/i
	OS = :win32
	IMPL = :mswin
elsif RUBY_PLATFORM =~ /cygwin/i
	OS = :unix
	IMPL = :cygwin
elsif RUBY_PLATFORM =~ /mingw/i
	OS = :win32
	IMPL = :mingw
elsif RUBY_PLATFORM =~ /bccwin/i
	OS = :win32
	IMPL = :bccwin
elsif RUBY_PLATFORM =~ /wince/i
	OS = :win32
	IMPL = :wince
elsif RUBY_PLATFORM =~ /vms/i
	OS = :vms
	IMPL = :vms
elsif RUBY_PLATFORM =~ /os2/i
	OS = :os2
	IMPL = :os2 # maybe there is some better choice here?
elsif RUBY_PLATFORM =~ /solaris/i # tnx to Hugh Sasse
	OS = :unix
	IMPL = :solaris
elsif RUBY_PLATFORM =~ /irix/i # i.e. mips-irix6.5
	OS = :unix
	IMPL = :irix
else
	OS = :unknown
	IMPL = :unknown
end

#
# Load libraries
#
libraries_ok = true
begin
	require 'gtk2'
rescue LoadError
	$stderr.puts "You need the Ruby-GNOME2 libraries to run this application.\n" +
				 "You can get them in <http://ruby-gnome2.sourceforge.jp/>."
	libraries_ok = false
end

$swig_runtime_data_type_pointer2 = nil # Satisfy SQLite3
begin
	require 'sqlite3'
rescue LoadError
	$stderr.puts "You need SQLite3-Ruby library to run this application.\n" +
				 "You can get it in <http://sqlite-ruby.rubyforge.org/>."
	libraries_ok = false
end

begin
	require 'yaml'
rescue LoadError
	$stderr.puts "You need Ruby-Yaml to run this application.\n" +
		         "You can get it in <http://yaml4r.sourceforge.net/>."
	libraries_ok = false
end

exit if not libraries_ok

#
# Set global variables
#
if OS == :win32
	require 'win32'
	BIBLES = "#{INSTDIR}/bibles"
	SRC = "#{INSTDIR}/src"
	IMG = "#{INSTDIR}/img"
	I18N = "#{INSTDIR}/i18n"
	BB_VERSION = IO.readlines("#{INSTDIR}/version.txt")[0].chop
	HOME = "#{HOMEDIR}/gladius"
#	$db = SQLite3::Database.new("#{HOMEDIR}/bibliomori.db")
else
	BIBLES = "#{SHARE}/bibles"
	# BOOKIMGS = "#{ENV['HOME']}/.gladius/bibles"
	SRC = "#{SHARE}/src"
	IMG = "#{SHARE}/img"
	I18N = "#{SHARE}/i18n"
	HOME = "#{ENV['HOME']}/.gladius"

	# Check if installed
=begin
	if not File.readable?("#{SHARE}/bibliomori.db")
		$stderr.puts "This program seem not to be installed. Install it running " +
			         "'ruby install.rb'."
		exit
	end
=end

	BB_VERSION = IO.readlines("#{SHARE}/version.txt")[0].chop

	# Check for first run
=begin
	if not File.readable?("#{ENV['HOME']}/.bibliomori/bibliomori.db")
		`mkdir -p ~/.bibliomori/bookimgs`
		`cp #{SHARE}/bibliomori.db ~/.bibliomori/`
		`cp #{SHARE}/bookimgs/* ~/.bibliomori/bookimgs/`
	end
=end
end

#
# Load sources
#
require "#{SRC}/util"
require "#{SRC}/download"
require "#{SRC}/main"
require "#{SRC}/bible"
require "#{SRC}/view"
require "#{SRC}/search"
require "#{SRC}/bibleview"
require "#{SRC}/books"
require "#{I18N}/i18n"

begin
	Dir.mkdir(HOME)
rescue; end

#
# Initialize Gladius
#
load_language

Gtk.init
$default_bible = Bible.new('kjv') #('ptbr-jfa')
$main = Main.new
$main.show
Gtk.main
