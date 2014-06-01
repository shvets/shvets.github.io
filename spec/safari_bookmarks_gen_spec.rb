require 'safari_bookmarks_gen'

describe SafariBookmarksGen do

  it "should generate haml content" do
    bookmarks = "#{ENV['HOME']}/Dropbox/Alex/bookmarks/safari-bookmarks-2014-05-31.html"

    subject.generate_haml(bookmarks, "source/bookmarks")
  end
end