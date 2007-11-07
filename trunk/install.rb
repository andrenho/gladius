#!/usr/bin/env ruby

require 'getoptlong'

share_dir = '/usr/local/share/gladius'
bin_dir = '/usr/local/bin'
man_dir = '/usr/local/share/man'
uninstall = false

opts = GetoptLong.new(
	[ '--help', '-h', GetoptLong::NO_ARGUMENT],
	[ '--uninstall', '-u', GetoptLong::NO_ARGUMENT],
	[ '--share-dir', GetoptLong::REQUIRED_ARGUMENT],
	[ '--man-dir', GetoptLong::REQUIRED_ARGUMENT],
	[ '--bin-dir', GetoptLong::REQUIRED_ARGUMENT])
opts.each do |opt, arg|
	case opt
	when '--help'
		`cat Install`
	when '--uninstall'
		uninstall = true
	when '--share-dir'
		share_dir = arg
	when '--bin-dir'
		bin_dir = arg
	when '--man-dir'
		man_dir = arg
	end
end

share_dir.chop! if share_dir[-1..-1] == '/'
bin_dir.chop! if bin_dir[-1..-1] == '/'

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
# Check OS
#
if OS == :win32
	$stderr.puts "This installer is not meant for Win32. To use this application in Win32, " +
				 "just execute 'ruby gladius.rb'."
	exit
end

#
# Check for root.
#
if ENV['USER'] != nil and ENV['USER'] != 'root'
	$stderr.puts "WARNING: This installer should be run as root!"
end

if uninstall
	`rm -rf #{share_dir}/gladius`
	`rm #{bin_dir}/gladius`
	#`rm #{man_dir}/man1/gladius.*`
	puts "Uninstall complete."
	exit
end

#
# Check for libraries
# 
#
# Load libraries
#

$swig_runtime_data_type_pointer2 = nil # Satisfy SQLite3
begin
	require 'sqlite3'
rescue LoadError
	$stderr.puts "WARNING: You need SQLite3-Ruby library to run this application.\n" +
				 "You can get it in <http://sqlite-ruby.rubyforge.org/>."
end

begin
	require 'yaml'
rescue LoadError
	$stderr.puts "WARNING: You need Ruby-Yaml to run this application.\n" +
		         "You can get it in <http://yaml4r.sourceforge.net/>."
end

#
# Install!!!
#
print 'Installing... '
['bibles', 'src', 'img', 'i18n'].each do |dir|
	`mkdir -p #{share_dir}/#{dir}`
	`cp #{dir}/* #{share_dir}/#{dir}/`
end
`cp version.txt #{share_dir}/`
#`cp man/man1/gladius.1 #{man_dir}/man1/`
`sed 's!SHARE = "."!SHARE = "#{share_dir}"!' gladius.rb > #{bin_dir}/gladius`
`echo "SHARE = '#{share_dir}'" > #{share_dir}/src/config.rb`
`chmod 755 #{bin_dir}/gladius`
puts 'ok.' # TODO - check if the installation was really sucessful.
