require 'open-uri'
require 'json'

class ProjectsGen
  REPOS_URL = "https://api.github.com/users/shvets/repos"

  def generate_data file_name
    r = FileUtils.mkdir_p File.dirname file_name

    items = JSON.parse(open(REPOS_URL).read).sort_by { |attr| attr['created_at'] }

    projects = []

    items.each do |item|
      projects << {:url => item['url'].gsub('api.github.com/repos/', 'github.com/'),
                   :name => item['name'],
                   :created_at => item['created_at'][0..9],
                   :description => item['description']}
    end


    File.open(file_name, "w") do |file|
      projects.each do |project|
        file.write <<-CONTENT
"#{project[:url]}", "#{project[:name]}", "#{project[:created_at]}", "#{project[:description]}"
        CONTENT
      end
    end
  end

  def read_data file_name
    File.open(file_name, "r").readlines().inject([]) do |result, line|
      url, name, created_at, description = line.split(',')

      result << [url.gsub('"', ''), name.gsub('"', ''), created_at.gsub('"', ''), description.gsub('"', '')]

      result
    end
  end
end


