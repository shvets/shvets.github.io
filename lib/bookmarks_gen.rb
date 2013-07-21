require 'json'

class BookmarksGen
  def generate_data input_file_name, output_file_name
    document = build_document(input_file_name)

    new_document = cut_unrelated_info(document)

    File.open(output_file_name, "w") do |f|
      f.write new_document
    end
  end

  def generate_haml file_name, dir
    FileUtils.mkdir_p dir

    document = build_document(file_name)

    bookmarks = find_my_bookmarks(document.to_hash)

    generate_folder dir, bookmarks

    #bookmarks.each do |raw|
    #  section = raw['title']
    #  Dir.mkdir "#{dir}/#{section}" unless File.exists?("#{dir}/#{section}")

#      File.open("#{dir}/#{section}/index.haml", "w") do |file|
#        file.write <<-CONTENT
#%h1="#{section}"
#%ul{:class => "#{section}"}
#        CONTENT
#
#        raw['children'].each do |link|
#          file.write <<-CONTENT
#%li
#  %a{:href => "#{link['uri']}"}="#{process_title(link['title'])}"
#          CONTENT
#        end
#      end
#    end
  end

  def generate_folder dir, items
    Dir.mkdir "#{dir}" unless File.exists?("#{dir}")

    File.open("#{dir}/index.haml", "w") do |file|
      items.each do |item|
        title = item['title']

        if item['children'].nil?
          file.write <<-CONTENT
%li
%a{:href => "#{item['uri']}"}="#{process_title(item['title'])}"
          CONTENT

        else
          file.write <<-CONTENT
%ul{:class => "#{title}"}
  %li
    %a{:href => "#{title}/index.html"}="#{title}"
          CONTENT
        end


      end
    end

    items.each do |item|
      title = item['title']

      if item['children'].nil?
        # generate_file name
      else
        generate_folder "#{dir}/#{title}", item['children']
      end
    end
  end

#  def generate_file name
#    File.open(name, "w") do |file|
#      file.write <<-CONTENT
#%h1="#{section}"
#%ul{:class => "#{section}"}
#      CONTENT
#
#      raw['children'].each do |link|
#        file.write <<-CONTENT
#%li
#%a{:href => "#{link['uri']}"}="#{process_title(link['title'])}"
#        CONTENT
#      end
#    end
#  end

  def read_data file_name
    build_document(file_name)
  end

  private

  def build_document bookmarks_file
    content = nil

    open(bookmarks_file) do |file|
      content = file.read
    end

    if content[content.length-3..content.length-3] == ","
      content = content[0..content.length-4] + content[content.length-2..-1]
    end

    JSON.parse(content)
  end

  private

  def cut_unrelated_info document
    my_bookmarks = find_my_bookmarks(document.to_hash) # part of the document

    convert(my_bookmarks).to_json
  end

  def find_my_bookmarks document
    bookmarks = nil

    document['children'].each do |item1|
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