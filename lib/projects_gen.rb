require 'open-uri'
require 'json'

class ProjectsGen
  REPOS_URL = "https://api.github.com/users/shvets/repos"

  def generate_data file_name
    r = FileUtils.mkdir_p File.dirname file_name

    items = JSON.parse(open(REPOS_URL).read)

    projects = []

    items.each do |item|
      projects << {:name => item['name'], :url => item['url'], :description => item['description']}
    end

    File.open(file_name, "w") do |file|
      projects.each do |project|
        file.write <<-CONTENT
"#{project[:url]}", "#{project[:name]}", "#{project[:description]}"
        CONTENT
      end
    end
  end

  def read_data file_name
    File.open(file_name, "r").readlines().inject([]) do |result, line|
      url, name, description = line.split(',')

      result << [name.gsub('"', ''), url.gsub('"', ''), description.gsub('"', '')]

      result
    end
  end
end


