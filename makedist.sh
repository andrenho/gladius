#!/bin/sh

mkdir bibliomori-`cat version.txt`
cp bibliomori.rb bibliomori-`cat version.txt`/
cp install.rb bibliomori-`cat version.txt`/
cp license.txt bibliomori-`cat version.txt`/
cp version.txt bibliomori-`cat version.txt`/
cp Changelog bibliomori-`cat version.txt`/
cp Install bibliomori-`cat version.txt`/
mkdir -p bibliomori-`cat version.txt`/bookimgs
cp bookimgs/0s.jpg bibliomori-`cat version.txt`/bookimgs/
mkdir -p bibliomori-`cat version.txt`/db
cp db/* bibliomori-`cat version.txt`/db/
mkdir -p bibliomori-`cat version.txt`/glade
cp glade/* bibliomori-`cat version.txt`/glade/
mkdir -p bibliomori-`cat version.txt`/i18n
cp i18n/* bibliomori-`cat version.txt`/i18n/
mkdir -p bibliomori-`cat version.txt`/img
cp img/* bibliomori-`cat version.txt`/img/
mkdir -p bibliomori-`cat version.txt`/src
cp src/* bibliomori-`cat version.txt`/src/
mkdir -p bibliomori-`cat version.txt`/man/man1
cp man/man1/bibliomori.1 bibliomori-`cat version.txt`/man/man1/
tar -zcf bibliomori-`cat version.txt`.tar.gz bibliomori-`cat version.txt`/
rm -rf bibliomori-`cat version.txt`/
