class BookmarksGen
  def generate_bookmarks input_name, output_name
    content = load_file input_name

    document = build_document(content)

    new_document = cut_unrelated_info(document)

    save_file new_document, output_name
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
end