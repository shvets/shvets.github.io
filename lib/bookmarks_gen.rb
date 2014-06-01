class BookmarksGen

  def generate_haml file_name, dir
    FileUtils.mkdir_p dir

    content = load_file file_name

    hash = build_hash(content)

    bookmarks = find_my_bookmarks(hash)

    generate_tree dir, bookmarks
  end

  def load_file file_name
    content = nil

    File.open(file_name, "r") do |file|
      content = file.read
    end

    content
  end

  def save_file document, file_name
    File.open(file_name, "w") do |file|
      file.write document
    end
  end

  def generate_tree dir, items
    Dir.mkdir "#{dir}" unless File.exists?("#{dir}")

    generate_index_file dir, items

    generate_dependent_trees dir, items
  end

  def generate_index_file dir, items
    File.open("#{dir}/index.haml", "w") do |file|
      items.each do |item|
        name = item['name']

        if item['children'].nil?
          file.write <<-CONTENT
%li
%a{:href => "#{item['url']}"}="#{process_name(item['name'])}"
          CONTENT

        else
          file.write <<-CONTENT
%ul{:class => "#{name}"}
  %li
    %a{:href => "#{name}/index.html"}="#{name}"
          CONTENT
        end
      end
    end
  end

  def generate_dependent_trees dir, items
    items.each do |item|
      name = item['name']

      unless item['children'].nil?
        generate_tree "#{dir}/#{name}", item['children']
      end
    end
  end
end