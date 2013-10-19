$:.unshift(File::join(File::dirname(__FILE__), "lib"))

require "bookmarks_gen"
require 'projects_gen'

desc "generates web site"
task "site" do
  sh "rake clean"
  sh "rake gen"
  sh "middleman build"
  sh "cp -r build/** ."
end

desc "generates bookmarks layout from bookmark.json"
task "gen-bm" do
  bookmarks = "#{ENV['HOME']}/Dropbox/Alex/bookmarks/bookmarks-2013-10-19.json"
  generator = BookmarksGen.new

  generator.generate_haml(bookmarks, "source/bookmarks")
end

desc "generates projects"
task "gen-projects" do
  projects_gen = ProjectsGen.new

  projects_gen.generate_data("data/github_projects.txt")
end

task "gen" => ["gen-projects", "gen-bm"]

task :clean do
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



