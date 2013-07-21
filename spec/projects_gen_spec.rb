require 'projects_gen'

require 'open-uri'
require 'json'

describe ProjectsGen do

  it "should return sections after parsing" do
    repos_url = "https://api.github.com/users/shvets/repos"

    items = JSON.parse(open(repos_url).read)

    projects = []

    items.each do |item|
      projects << {:name => item['name'], :description => item['description']}
    end

    projects.size.should > 0
  end

end

