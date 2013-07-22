require 'json'

class BookmarksGen2

  def generate_haml file_name, dir
    document = open(file_name) { |file| JSON.parse(file.read) }

    document['roots']['bookmark_bar']['children'].each do |group|
      if group['name'] == 'Imported'

        group['children'].each do |child1|
          if child1['name'] == "Bookmarks Bar"
            child1['children'].each do |child2|
              if child2['name'] == "Alex"
                #generate_main_index_file child2, "#{dir}/index.haml"
                #generate_section child2, "#{dir}/index.haml", "My Bookmarks", "bookmarks"
                generate_subtree child2, dir
              end
            end
          end
        end
      end
    end
  end

  private

#  def generate_main_index_file element, file_name
#    Dir.mkdir File.dirname(file_name) unless File.exists?(File.dirname(file_name))
#
#    File.open(file_name, "w") do |file|
#      file.write <<-CONTENT
#%h1="My Bookmarks"
#%ul{:class => "bookmarks"}
#      CONTENT
#
#      element['children'].each do |link|
#        name = link['name'].gsub('"', "&quot;")
#
#        file.write <<-CONTENT
#  %li
#    %a{:href => "#{name}/index.html"}="#{name}"
#        CONTENT
#      end
#    end
#  end

  def generate_subtree child, dir
    if child['type'] == 'folder'
      generate_section child, "#{dir}/index.haml"
    end

    if child['children']
      child['children'].each do |section|
        if section['type'] == 'folder'
          generate_subtree section, "#{dir}/#{section['name']}"
        end
      end
    end
  end

  def generate_section element, file_name, title = nil, style = nil
    name = element['name']

    Dir.mkdir File.dirname(file_name) unless File.exists?(File.dirname(file_name))

    title = title.nil? ? name : title
    style = style.nil? ? name : style

    File.open(file_name, "w") do |file|
      file.write <<-CONTENT
%h1="#{title}"
%ul{:class => "#{style}"}
      CONTENT

      element['children'].each do |link|
        name = link['name'].gsub('"', "&quot;")
        url = link['url'] ? link['url'] : name

        file.write <<-CONTENT
  %li
    %a{:href => "#{url}"}="#{name}"
        CONTENT
      end
    end
  end
end