#!/usr/bin/env ruby

$:.unshift(File::join(File::dirname(__FILE__), "lib"))

require 'thor'

require "chrome_bookmarks_gen"
require 'projects_gen'

class Cmd < Thor
  desc "clean", "Cleans the project"
  def clean
    `rm -rf build`
    `rm -rf data`
    `rm -rf source/bookmarks`
    `rm -rf images`
    `rm -rf javascripts`
    `rm -rf stylesheets`
    `rm -rf blog`
    `rm -rf bookmarks`
    `rm -rf common`
    `rm -f index.html`
    `rm -f 404.html`
  end

  desc "gen_bm", "generates bookmarks layout from bookmark.json"
  def gen_bm
    bookmarks = "#{ENV['HOME']}/Dropbox/Alex/bookmarks/bookmarks-2014-05-31.json"
    generator = ChromeBookmarksGen.new

    generator.generate_haml(bookmarks, "source/bookmarks")
  end

  desc "gen_projects", "Generates projects"
  def gen_projects
    projects_gen = ProjectsGen.new

    projects_gen.generate_data("data/github_projects.txt")
  end

  desc "gen", "Generates all"
  def gen
    invoke :gen_projects
    invoke :gen_bm
  end

  desc "site", "generates web site"
  def site
    invoke :clean
    invoke :gen

    system "middleman build"
    system "cp -r build/** ."
  end
end

Cmd.start(ARGV)