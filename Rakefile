# http://12devs.co.uk/articles/204/
# http://blog.rlmflores.me/blog/2013/07/16/ruby-patterns-webservice-object/

#require 'middleman-gh-pages'

$:.unshift(File::join(File::dirname(__FILE__), "lib"))

#require "bookmarks_gen2"
require "bookmarks_gen"
require 'projects_gen'

#desc "generates web site"
#namespace :assets do
#  task :precompile do
#    sh "rake gen"
#    sh "middleman build"
#  end
#end

desc "generates web site"
task "setup" do
  sh "rake gen"
  sh "middleman build"
  sh "cp -r build/** ."
  sh "cp -r build/assets/images images"
  sh "cp -r build/assets/javascripts javascripts"
  sh "cp -r build/assets/stylesheets stylesheets"
  sh "rm -rf assets"
end

desc "generates bookmarks layout from bookmark.json"
task "gen-bm" do
  #bookmarks = "#{ENV['HOME']}/Library/Application Support/Google/Chrome/Default/Bookmarks"
  #generator = BookmarksGen2.new

  bookmarks = "#{ENV['HOME']}/Dropbox/Alex/bookmarks-2013-07-19.json"
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



