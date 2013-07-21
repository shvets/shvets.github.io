# All files in the 'lib' directory will be loaded
# before nanoc starts compiling.

require 'coderay'
require 'haml-coderay'

include Nanoc3::Helpers::Tagging
include Nanoc3::Helpers::Rendering

def menu_style value
  {:class => @item[:menu] == value ? "current_page_item" : ""}
end

def coderay(text)
  text.gsub(/<code( lang="(.+?)")?>(.+?)<\/code>/m) do
     CodeRay.scan($3, $2).div(:css => :class)
  end
end

module Nanoc3::DataSources

  # Provides functionality common across all filesystem data sources.
  module Filesystem
    def layouts
      load_objects('content/layouts', 'layout', Nanoc3::Layout)
    end
  end
end