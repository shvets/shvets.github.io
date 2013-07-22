require 'bookmarks_gen'

describe BookmarksGen do

#  it "should return sections after parsing" do
#    bookmarks = Bookmarks.new "#{ENV['HOME']}/Desktop/bookmarks.json"
#    bookmarks.cut_unrelated_info!
#
#    bookmarks.sections.size.should > 0
#  end
#
#  it "should return links for the section" do
#    bookmarks = BookmarksGen.new "../bookmarks.json"
#
#    section = bookmarks.sections.first
#
#    bookmarks.links(section).size.should > 0
#
#    p bookmarks.links(section)
#  end

  it "should generate haml content" do
    bookmarks = "#{ENV['HOME']}/Dropbox/Alex/bookmarks-2013-07-19.json"

    generator = BookmarksGen.new

    generator.generate_haml(bookmarks, "source/bookmarks")
  end
end

