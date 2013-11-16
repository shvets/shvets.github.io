---
title: Configuring Acceptance Tests with Capybara, Webkit and Selenium
date: 2013-10-12
tags: ruby, capybara, selenium, webkit, phantomjs, qt, acceptance tests
---

# Configuring Acceptance Tests with Capybara, Webkit and Selenium


## Introduction

We all know about importance of being armed with tests for your project. Usually project could have **unit**,
**integration** and **acceptance** tests.

Unit tests help us to test **small piece of functionality in isolation** (within single class) and try
to answer this question:

<span style="color:green">Do our objects do the right thing, are they convenient to work with?</span>

Unit tests don't necessary work as expected when you **combine units together**, even if units
work perfectly in isolation. In this case we use integration tests that try to answer another question:

<span style="color:green">Does our code work against code we can't change?</span>

Integration tests don't prove that a **complete feature works** as intended. In this case we introduce
higher test level with acceptance tests. They help us with the next question:

<span style="color:green">Does the whole system work as expected?</span>

Acceptance tests simulate human interactions with **interactive applications**. Acceptance tests written
in ruby can be used for **supporting projects in other languages**, such as Java, Python, PHP or C#.

## Automated Acceptance Tests: Why?

We can do acceptance tests manually by hiring human being to click on buttons, select combo-boxes etc.
in our web application or create separate program that will do the same for us in automated way.

What benefits can we expect here?

* It's **not possible or extremely expensive** to manually test each feature of your application.

* Making testing automated will **save a lot of time/money** for the company.

* In case of **adding new functionality** you want to know whether it breaks existing flow or not.
Unit or integration tests do not know about new functionality and cannot fail on it yet.

## Capybara: What is it?

[Capybara] [Capybara Home] is the ruby gem that:

> "helps you test web applications by simulating how a real user would interact with your app."

In other words, capybara represents domain specific language (DSL) for describing **acceptance tests**
written in Ruby.

It **simulates real user interactions** with web application, provides **higher level API**
to user interaction. You can use existing or write your own drivers that fit into this API.

**selenium**, **webkit** and **poltergeist** are examples of such drivers.

Because of neutral capybara API, it could be used with both **rspec** and **cucumber**.

In order to start using capybara, add it to your Gemfile:

```bash
  gem "capybara"
```

and require it inside your code:

```ruby
require 'capybara'
```

If you plan to use selenium driver, install it:

```ruby
  gem "selenium-webdriver"
```

Below is the typical example of capybara script:

```ruby
require "capybara/dsl"

Capybara.app_host = 'http://www.google.com'
Capybara.default_wait_time = 15

Capybara.current_driver = :selenium

include Capybara::DSL

visit "/"

fill_in "q", :with => "Capybara"
find("#gbqfbw button").click

page.should have_content 'Capybara'
```

## Capybara: auto-waiting

Capybara provides **auto-waiting** feature - powerful synchronization for asynchronous processes, like AJAX calls.

Capybara 1 uses **wait_until** API for waiting on asynchronous events. This way you can build scripts of arbitrary
complexity. For example:

```ruby
visit "/"
click_button "Submit"

wait_until { page.find("some_element_id").visible? }

wait_until do
  execute_script('return jQuery(".response .success").is(":visible")')
end
```

This approach has one drawback though: **wait_until** makes scripts bulky, hard to read and maintain.

In Capybara 2 wait_until [was removed completely] [why wait until was removed]. Why?

- wait_until is simply not necessary for most cases.

- it was added in older versions of Capybara when auto-waiting feature was much more primitive.

Capybara 2 provides smarter implementation of **auto-waiting** feature. Now you have to remember these rules:

* Methods like **find("#foo")** have blocking code that perform waiting for requested element
to become available.

* Instead of calling regular methods like **contain**, you should use **have_content** or **have_selector**,
**has_selector?**.

Below is an example of incorrect usage of new API:

```ruby
  page.find("foo").text.should contain("login failed")
```

This is correct usage:

```ruby
  page.find("#foo").should have_content("login failed")

  page.should have_selector("#foo", :text => "login failed")
```

What's wrong in first example?

- Method **text**, being just a regular method that returns a regular string, isn’t going to do auto-waiting.
It will immediately return the text.

- When you use **have_content** or **have_selector**, they will do **auto-waiting** for you.

Code becomes simple and much easier to read/maintain. As long as you stick with Capybara API, you should
never have to use wait_until explicitly.

## Selenium server

When you run selenium test, it communicates to selenium server, which in turn connects to
web site to be tested.

Don't forget to install it. On OSX you can do it with one homebrew command:

```bash
brew install selenium-server-standalone
```

Standalone selenium server is implemented as launchd agent.

To have launchd start selenium-server-standalone at login, create soft link:

```bash
ln -sfv /usr/local/opt/selenium-server-standalone/*.plist ~/Library/LaunchAgents
```

Then load selenium-server-standalone agent:

```bash
launchctl load ~/Library/LaunchAgents/homebrew.mxcl.selenium-server-standalone.plist
```

It will run selenium server on port 4444.

If you don't want to use agent, use java directly:

```bash
java -jar /usr/local/opt/selenium-server-standalone/selenium-server-standalone-2.35.0.jar -p 4444
```

## Tips

You can get plenty of information about how to configure capybara on [capybara home page] [Capybara Home].

All details related to Selenium you can find on [selenium home page] [Selenium Home].

Below I cover some of my tricks that I have discovered while tailoring capybara for my needs.

## Tip 1: Executing Selenium server on remote machine

In order to run Selenium on another machine you have to register **selenium remote driver**:

```ruby

  def register_remote_selenium_driver
      selenium_host, selenium_port
    selenium_url =
      "http://#{selenium_host}:#{selenium_port}/wd/hub"

    Capybara.register_driver :selenium_remote do |app|
      Capybara::Selenium::Driver.new(app,
        {:url => selenium_url, :browser => :remote})
    end
  end

  selenium_host = "some-selenium-host"
  selenium_port = "some-selenium-port"

  register_remote_selenium_driver selenium_host, selenium_port

  # Use registered driver
  Capybara.current_driver = :selenium_remote
```

## Tip 2: Using RSpec metadata for easy switching between drivers

You can use **rspec metadata** if you need to  use or change driver whether for single test
or for the whole test suite.

First, create [shared context] [shared context] named **CapybaraTest**:

```ruby
shared_context "CapybaraTest" do

  before do
    if example.metadata[:driver]
      new_driver = example.metadata[:driver]

      if [:javascript, :webkit, :selenium].include? new_driver
        Capybara.current_driver = new_driver
      else
        Capybara.current_driver = Capybara.default_driver
      end
    end
  end

  after do
    Capybara.current_driver = Capybara.default_driver
  end
end
```

Now, you can specify driver for single test:

```ruby
describe SomeClass do
  include_context "CapybaraTest"

  it 'does something', driver: :webkit do
    ...
  end

  it 'does something else', driver: :selenium do
    ...
  end
end
```

or for the whole test suite:


```ruby
describe SomeClass, driver: :webkit do
  include_context "CapybaraTest"
  ...
end
```

## Tip 3: Using remote selenium with RSpec metadata

If you want to integrate remote selenium with rspec metadata, you need to register new driver type
for it, e.g. **selenium_remote**:

```ruby
shared_context "CapybaraTest" do

  before do
    if example.metadata[:driver]
      new_driver = example.metadata[:driver]

      if [:javascript, :webkit, :selenium].include? new_driver
        Capybara.current_driver = new_driver
      elsif [:selenium_remote].include? new_driver
        setup_remote_selenium SELENIUM_CONFIG_FILE_NAME, config_name()
        Capybara.current_driver = new_driver
      else
        Capybara.current_driver = Capybara.default_driver
      end
    end
  end

  def setup_remote_selenium config_file_name, config_name
    config = ... # load selenium configuration from file

    # see implementation in Tip 1
    register_remote_selenium_driver config[:selenium_host],
      config[:selenium_port]
  end
end
```

Now you can specify new driver name per single test or test suite:

```ruby
describe SomeClass do
  include_context "CapybaraTest"

  it 'does something else', driver: :selenium_remote do
    ...
  end
end
```

## Tip 4: Ignoring specs

First, configure your rspec:

```ruby
RSpec.configure do |config|
  config.filter_run_excluding :exclude => true
end
```

Now, if you want to exclude particular test from the execution, use **exclude** meta-attribute:

```ruby
describe SomeClass do
  include_context "CapybaraTest"

  it 'does something else', driver: :selenium, exclude: true do
    ...
  end
end
```

## Tip 5: Headless mode

You can run capybara in headless mode with the help of  **webkit** driver.

Add gem for webkit driver to your Gemfile:

```ruby
  gem "capybara-webkit", "1.0.0"
```

If you are on OSX, you also need to install **QT library** with homebrew help. It's used for rendering:

```bash
brew install qt
```

Even though it's headless driver, it still can execute javascript code and it's faster than selenium driver.

Also, comparing to selenium driver, you don't have to run separate selenium server and you don't have to open
browser window for executing tests.

In order to use it, change current capybara driver:

```ruby
Capybara.current_driver = :webkit
```

Another example of headless driver is **phantomjs driver**. First, install phantomjs:

```bash
brew install phantomjs
```

And then, include poltergeist gem into your Gemfile:

```ruby
  gem "poltergeist"
```

In order to use it, change current capybara driver:

```ruby
Capybara.current_driver = :poltergeist
```

In my experience, webkit and poltergeist work in 95% of cases. If you have some problems, you can switch to selenium
driver - it's the most reliable one.

## Tip 6: Chrome Driver

If you want to use chrome driver, you need to follow these steps:

Register chrome driver:

```ruby
Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, :browser => :selenium_chrome)
end

Capybara.javascript_driver = :chrome
end

On OSX install chromedriver utility with homebrew help:

```bash
brew install chromedriver
```

Now you can run your acceptance test with Chrome browser.

## Acceptance Test gem

All ideas, described in mentioned above tips, were implemented and now available as one ruby gem:
[acceptance test gem] [acceptance test gem].

All you have to do is to include it into yor Gemfile:

```ruby
  gem "acceptance_test"
```

It's implemented as rspec's shared context, so you need to do the following in your acceptance test:

```ruby
require 'acceptance_test'

describe 'Google Search' do
  include_context "AcceptanceTest"

  before :all do
    acceptance_test.app_host = "http://www.google.com"
  end

  before do
    puts "Using driver: #{Capybara.current_driver}."
  end

  it "uses selenium driver", driver: :selenium, exclude: false do
    visit('/')

    fill_in "q", :with => "Capybara"

    find("#gbqfbw button").click

    all(:xpath, "//li[@class='g']/h3/a").each { |a| puts a[:href] }
  end
end
```

You can specify which tests to exclude and which drivers to use.

As you can see, withing your test you have access to **acceptance_test** variable.

If you want to use external configuration for selenium, use **load\_selenium\_config** method:

```ruby
require 'acceptance_test'

describe 'Google Search' do
  include_context "AcceptanceTest"

  before :all do
    acceptance_test.app_host = "http://www.google.com"

    selenium_config_file = "spec/features/selenium.yml"
    selenium_config_name = "test"

    acceptance_test.load_selenium_config
      selenium_config_file, selenium_config_name
  end

  it "do something" do
    # ...
  end
end
```

**acceptance_test** gem understand few external variables.

**DRIVER** - if you want to overrides drivers for all tests and use only one driver type:

```bash
DRIVER=selenium rspec your_acceptance_spec.rb
```

**APP_HOST** - overrides host to be tested;

**WAIT_TIME** - overrides used wait time for long operations;

**RUN_SERVER** - default is false; use it if you want to run internal server with capybara:

```bash
RUN_SERVER=true rspec your_acceptance_spec.rb
```

[Capybara Home]: https://github.com/jnicklas/capybara
[why wait until was removed]: http://www.elabs.se/blog/53-why-wait_until-was-removed-from-capybara
[Selenium Home]: http://docs.seleniumhq.org/
[shared context]: https://www.relishapp.com/rspec/rspec-core/v/2-11/docs/example-groups/shared-context
[acceptance test gem]: https://github.com/shvets/acceptance_test
[selenium help]: http://makandracards.com/makandra/8381-run-chrome-in-a-specific-resolution-or-user-agent-with-selenium
[Introducing Capybara 2.1]: http://www.elabs.se/blog/60-introducing-capybara-2-1
