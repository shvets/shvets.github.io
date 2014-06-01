class BookmarksGen
  # def generate_data input_name, output_name
  #   content = load_file input_name
  #
  #   document = build_document(content)
  #
  #   new_document = cut_unrelated_info(document)
  #
  #   save_file new_document, output_name
  # end

  def build_hash content
    {}
  end

  def generate_haml file_name, dir
    FileUtils.mkdir_p dir

    content = load_file file_name

    hash = build_hash(content)

    bookmarks = find_my_bookmarks(hash)

    generate_folder dir, bookmarks
  end

  def load_file file_name
    content = nil

    File.open(file_name, "r") do |file|
      content = file.read
    end

    content
  end

  def cut_unrelated_info document
    document
  end

  def save_file document, file_name
    File.open(file_name, "w") do |file|
      file.write document
    end
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

end