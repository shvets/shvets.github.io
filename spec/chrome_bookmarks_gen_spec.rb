require 'chrome_bookmarks_gen'

describe ChromeBookmarksGen do

  it "should generate haml content" do
    bookmarks = "#{ENV['HOME']}/Dropbox/Alex/bookmarks/bookmarks-2013-07-19.json"

    generator = ChromeBookmarksGen.new

    generator.generate_haml(bookmarks, "source/bookmarks")
  end
end

