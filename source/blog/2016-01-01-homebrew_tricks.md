---
title: Homebrew Tricks
date: 2016-01-01
tags: ruby, OSX, homebrew, tools
---

# Homebrew Tricks

# Install correct version of library

brew tap homebrew/versions

$ brew versions postgresql
9.0.4    git checkout 2accac4 /usr/local/Library/Formula/postgresql.rb
9.0.3    git checkout b782d9d /usr/local/Library/Formula/postgresql.rb

$ git checkout -b postgresql-9.0.3 b782d9d
$ brew install postgresql
$ git checkout master
$ git branch -d postgresql-9.0.3 # to remove

# Search/install for major versions

$ brew search postgres

postgresql
homebrew/versions/postgresql8    homebrew/versions/postgresql9

$ brew install postgresql8


# Switch between versions

There is new command to switch berteen versions:

brew switch [formula] [version]

For instance, I alternate regularly between Node.js 0.4.12 and 0.6.5:

brew switch node 0.4.12
brew switch node 0.6.5

# Install specific formula version

$ brewv postgresql 8.4.4

Script is located here: https://gist.github.com/MattiSG/3076772



# Install html2pdf tool

brew install wkhtmltopdf

wkhtmltopdf -l -O Landscape http://0.0.0.0:9090/print vagrant-chef-presentation.pdf
wkhtmltopdf -l -O Landscape http://0.0.0.0:9090/print better-code-quality-with-tests-presentation.pdf

wkhtmltopdf --outline --orientation Landscape vagrant-and-chef.pdf.html vagrant-chef-presentation.pdf

# Identifying and deleting duplicates in photos

$ brew install fdupes

$ fdupes -rd <path to exported photos>


# Play mp3 files from console or mc


brew install mpg123

mpg123 <filename.mp3>

or press enter on <filename.mp3> inside mc.


# Convert or play audio files: SoX

SoX is a cross-platform command line utility that can convert various formats of computer
audio files in to other formats. It can also apply various effects to these sound files and also
play and record audio files.

brew install sox

sox track.au track.wav



