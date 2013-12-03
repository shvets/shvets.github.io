
http://phantomjs.org/

PhantomJS is a headless WebKit scriptable with JavaScript or CoffeeScript



* Headless Website Testing - run functional tests with frameworks such as Jasmine, QUnit, Mocha, Capybara, WebDriver, and many others.

* Screen Capture - orogrammatically capture web contents, including SVG and Canvas. Create web site screenshots with thumbnail preview.

Page Automation - access and manipulate webpages with the standard DOM API, or with usual libraries like jQuery.

Network Monitoring - monitor page loading and export as standard HAR files. Automate performance analysis using YSlow and Jenkins.


Mac:

brew install phantomjs

Linux:
cd
wget http://phantomjs.googlecode.com/files/phantomjs-1.9.0-linux-x86_64.tar.bz2
tar jxf phantomjs-1.9.0-linux-x86_64.tar.bz2
cp phantomjs-1.9.0-linux-x86_64/bin/phantomjs /usr/bin/


# Installation

* Add poltergeist to your Gemfile, and in your test setup add:

```ruby
require 'capybara/poltergeist'

Capybara.javascript_driver = :poltergeist
```

* Register new driver:

```ruby
options = {}
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, options)
end
```

We write the acceptance test using only terminology from the application’s
domain, not from the underlying technologies (such as databases or web servers).
This helps us understand what the system should do, without tying us to any of
our initial assumptions about the implementation or complicating the test with
technological details.






