require 'chrome_bookmarks_gen'

describe ChromeBookmarksGen do
  it "should generate haml content" do
    bookmarks = "#{ENV['HOME']}/Dropbox/Alex/bookmarks/bookmarks-2014-05-31.json"
    #bookmarks = "#{ENV['HOME']}/Dropbox/Alex/bookmarks/bookmarks-2013-07-19.json"

    subject.generate_haml(bookmarks, "source/bookmarks")
  end
end

