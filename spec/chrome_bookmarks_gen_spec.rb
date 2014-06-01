require 'chrome_bookmarks_gen'

describe ChromeBookmarksGen do
  let(:bookmarks) { "~/Library/Application Support/Google/Chrome/Default/Bookmarks" }
  it "should generate haml content" do
    #bookmarks = "#{ENV['HOME']}/Dropbox/Alex/bookmarks/bookmarks-2013-07-19.json"

    subject.generate_haml(bookmarks, "source/bookmarks")
  end
end

