require 'json'
require 'bookmarks_gen'

class ChromeBookmarksGen < BookmarksGen
  # def generate_data input_name, output_name
  #   content = load_file input_name
  #
  #   document = build_document(content)
  #
  #   new_document = cut_unrelated_info(document)
  #
  #   save_file new_document, output_name
  # end

  # def generate_haml file_name, dir
  #   FileUtils.mkdir_p dir
  #
  #   content = load_file file_name
  #
  #   document = build_document(content)
  #
  #   bookmarks = find_my_bookmarks(document.to_hash)
  #
  #   generate_folder dir, bookmarks
  # end

  # def read_data file_name
  #   build_document(file_name)
  # end

  def build_hash content
    if content[content.length-3..content.length-3] == ","
      content = content[0..content.length-4] + content[content.length-2..-1]
    end

    JSON.parse(content).to_hash
  end

  private

  # def cut_unrelated_info document
  #   my_bookmarks = find_my_bookmarks(document.to_hash) # part of the document
  #
  #   convert(my_bookmarks).to_json
  # end

  def find_my_bookmarks hash
    bookmarks = nil

    hash['children'].each do |item1|
      if item1['title'] == 'Bookmarks Menu'
        item1['children'].each do |item2|
          if item2['title'] == 'Bookmarks Bar'
            item2['children'].each do |item3|
              if item3['title'] == 'Alex'
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
        name = section['title']

        hash[name] = []

        section['children'].each_with_index do |link, index|
          hash[name][index] = {:name => process_title(link['title']), :url => link['uri']}
        end
      end
    end

    hash
  end

  def process_title title
    title.gsub("\"", "'") unless title.nil?
  end
end