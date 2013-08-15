###
# Settings
###

set :site_title, "GitHub --- Alexander Shvets's Web Page"
set :site_url, "http://shvets.github.io"
set :site_description, "Meta description."
set :site_keywords, "keyword-one, keyword-two"

set :relative_links, true

# Remove .html extension from pages
#activate :directory_indexes

# Set slim-lang output style
#Slim::Engine.set_default_options :pretty => true

# Set template languages
#set :slim, :layout_engine => :slim

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
  activate :syntax,
           #:linenos => 'inline',
           :line_numbers => true
           #:anchorlinenos => true,
           #:linenostart => 2
end

# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  # activate :minify_css

  # Minify Javascript on build
  # activate :minify_javascript

  # Enable cache buster
  # activate :asset_hash

  # Use relative URLs
  activate :relative_assets

  # Or use a different image path
  # set :http_path, "/Content/images/"
end
