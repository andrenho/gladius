#!/bin/sh

mkdir gladius-`cat version.txt`
cp gladius.rb gladius-`cat version.txt`/
cp install.rb gladius-`cat version.txt`/
cp license.txt gladius-`cat version.txt`/
cp version.txt gladius-`cat version.txt`/
cp Changelog gladius-`cat version.txt`/
cp Install gladius-`cat version.txt`/
mkdir -p gladius-`cat version.txt`/home
cp home/* gladius-`cat version.txt`/home/
mkdir -p gladius-`cat version.txt`/i18n
cp i18n/* gladius-`cat version.txt`/i18n/
mkdir -p gladius-`cat version.txt`/img
cp img/* gladius-`cat version.txt`/img/
mkdir -p gladius-`cat version.txt`/src
cp src/* gladius-`cat version.txt`/src/
#mkdir -p gladius-`cat version.txt`/man/man1
#cp man/man1/gladius.1 gladius-`cat version.txt`/man/man1/
tar -zcf gladius-`cat version.txt`.tar.gz gladius-`cat version.txt`/
rm -rf gladius-`cat version.txt`/
