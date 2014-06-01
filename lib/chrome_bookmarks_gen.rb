require 'json'

require 'bookmarks_gen'

class ChromeBookmarksGen < BookmarksGen
  def build_hash content
    JSON.parse(content).to_hash
  end

  private

  def find_my_bookmarks hash
    list = hash['roots']['bookmark_bar']

    bookmarks = nil

    list['children'].each do |item1|
      if item1['name'] == 'Imported (1)'
        item1['children'].each do |item2|
          if item2['name'] == 'Alex Bookmarks'
            item2['children'].each do |item3|
              if item3['name'] == 'Alex'

                bookmarks = item3['children']
                break
              end
            end
          end
        end
      end
    end

    bookmarks
  end

  def convert bookmarks
    hash = {}

    unless bookmarks.nil?
      bookmarks.each do |section|
        name = section['name']

        hash[name] = []

        section['children'].each_with_index do |link, index|
          hash[name][index] = {:name => process_name(link['name']), :url => link['url']}
        end
      end
    end

    hash
  end

  def process_name name
    name.gsub("\"", "'") unless name.nil?
  end
end