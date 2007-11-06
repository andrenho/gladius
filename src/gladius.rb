#!/usr/bin/env ruby

require 'gtk2'
require 'sqlite3'

require 'main'
require 'bible'
require 'bibleview'
require 'books'

Gtk.init
$default_bible = Bible.new('ptbr-jfa')
$main = Main.new
$main.show_all
Gtk.main
