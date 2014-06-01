require 'nokogiri'
require 'nokogiri_utils'
# require 'active_support/core_ext/hash/conversions'
require 'bookmarks_gen'

class SafariBookmarksGen < BookmarksGen
  include NokogiriUtils

  def build_hash content
    #Nokogiri.HTML(content).to_hash
    #hash_from_node(Nokogiri.HTML(content))
    Nokogiri.HTML(content)
  end

  def find_my_bookmarks document
    bookmarks = nil
    node = nil

    detected = false
      document.css('dt').each {|link|
        if detected
          node = link
          break
        end

        if link.content =~ /Alex Bookmarks/
          detected = true
        end
      }

    p node[0].parent

    bookmarks = xml_node_to_hash(node[0].parent)


    # document['children'].each do |item1|
    #   if item1['title'] == 'Bookmarks Menu'
    #     item1['children'].each do |item2|
    #       if item2['title'] == 'Bookmarks Bar'
    #         item2['children'].each do |item3|
    #           if item3['title'] == 'Alex'
    #             bookmarks = item3['children']
    #             break
    #           end
    #         end
    #       end
    #     end
    #   end
    # end

    bookmarks
  end

  # def search object, text
  #   if object.kind_of? String
  #     if object == text
  #       return object
  #     end
  #   elsif object.kind_of? Hash
  #     object.each do |el|
  #       result = search el, text
  #
  #       return result if result
  #     end
  #   elsif object.kind_of? Array
  #     object.each do |el|
  #       result = search el, text
  #
  #       return result if result
  #     end
  #   else
  #     p value
  #   end
  # end

end