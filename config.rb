###
# Settings
###

set :site_title, "GitHub --- Alexander Shvets's Web Page"
set :site_url, "http://shvets.github.io"
set :site_description, "Meta description."
set :site_keywords, "keyword-one, keyword-two"

set :relative_links, true

# Set slim-lang output style
#Slim::Engine.set_default_options :pretty => true

# Set template languages
#set :slim, :layout_engine => :slim

###
# Blog settings
###

# Time.zone = "UTC"

activate :blog do |blog|
  blog.prefix = "blog"
  blog.permalink = ":year/:month/:day/:title.html"
  #blog.permalink = ":year/:title.md"
  #blog.sources = ":year-:month-:day-:title.html"
  #blog.sources = ":year/title.html"
  blog.taglink = "tags/:tag.html"

  #blog.layout = "blog_layout"
  # blog.summary_separator = /(READMORE)/
  # blog.summary_length = 250
  # blog.year_link = ":year.html"
  # blog.month_link = ":year/:month.html"
  # blog.day_link = ":year/:month/:day.html"
  # blog.default_extension = ".markdown"

  blog.tag_template = "blog/tag.html"
  blog.calendar_template = "blog/calendar.html"

  # blog.paginate = true
  # blog.per_page = 10
  # blog.page_link = "page/:num"
end

page "/feed.xml", :layout => false

# Remove .html extension from pages
#activate :directory_indexes

###
# Assets
###

set :css_dir, "assets/stylesheets"
set :js_dir, "assets/javascripts"
set :images_dir, "assets/images"

set :markdown_engine, :redcarpet

set :markdown, fenced_code_blocks: true, autolink: true, smartypants: true,
    gh_blockcode: true, lax_spacing: true

###
# Compass
###

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

###
# Haml
###

set :haml, { ugly: true }

# CodeRay syntax highlighting in Haml
# First: gem install haml-coderay

# CoffeeScript filters in Haml
# First: gem install coffee-filter
#require 'coffee-filter'

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
# page "/path/to/file.html", :layout => false
#
# With alternative layout
# page "/path/to/file.html", :layout => :otherlayout
#
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

# Proxy pages (http://middlemanapp.com/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", :locals => {
#  :which_fake_page => "Rendering a fake page with a local variable" }

###
# Helpers
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Reload the browser automatically whenever files change
#activate :livereload

# Methods defined in the helpers block are available in templates

helpers do
  def menu_style value
    #{:class => @item[:menu] == value ? "current_page_item" : ""}
    {:class => "current_page_item" }
  end
end

configure :development do
  activate :syntax
  #, :line_numbers => true
end

# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  # activate :minify_css

  # Minify Javascript on build
  # activate :minify_javascript

  activate :syntax
  #, :line_numbers => true

  # Enable cache buster
  # activate :asset_hash

  # Use relative URLs
  #activate :relative_assets

  # Or use a different image path
  # set :http_path, "/Content/images/"
end
