---
title: Acceptance tricks
date: 2013-10-12
tags: ruby, capybara, selenium, webkit
---

# Configuring Acceptance Tests with Capybara, Webkit and Selenium


## Introduction

We all know about importance of being equipped with tests in your project. Usually project has unit,
integration and acceptance tests.

Unit tests help us to test small piece of functionality (within single class) in isolation.
They try to answer this question:

"Do our objects do the right thing, are they convenient to work with?"

Unit tests don't necessary work as expected when you combine 2 units together, even if units work perfectly
in isolation. In this case we use integration tests that try to answer another question:

"Does our code work against code we can't change?"

Integration tests don't prove that a **complete feature works** as intended. In this case we introduce
higher level with acceptance tests. They help us with this question:

"Does the whole system work?"

Acceptance tests simulate human interactions with interactive applications. Acceptance tests in ruby can be used
for supporting projects in other languages, such as Java, Python, PHP, C#.

## Automated Acceptance Tests: Why?

* It's **not possible or extremely expensive** to manually test each feature of your application.

* Making testing automated will **save a lot of time/money** for the company.

* In case of **adding new functionality** you want to know whether it breaks existing flow or not.
Unit or integration tests do not know about new functionality and cannot fail on it yet.

## Initial Setup

## Capybara: What is it?

* Domain Specific Language for describing **acceptance tests** written in Ruby.

* **Simulates real user interactions** with web application.

* Provides **higher level API** to user interaction. You can have or write drivers that fit into this API.
Example: **selenium** or **webkit** driver.

* Provides **auto-waiting** feature - powerful synchronization for asynchronous processes, like AJAX.

* It could be used inside both **rspec** and **cucumber**.

# Tip 1: Executing Selenium server on remote machine

* In order to run Selenium on another machine you have to register selenium remote driver:

```ruby

  def register_remote_selenium_driver selenium_host, selenium_port
    selenium_url = "http://#{selenium_host}:#{selenium_port}/wd/hub"

    Capybara.register_driver :selenium_remote do |app|
      Capybara::Selenium::Driver.new(app, {:url => selenium_url, :browser => :remote})
    end
  end


  selenium_host = "some-selenium-host"
  selenium_port = "some-selenium-port"

  register_remote_selenium_driver selenium_host, selenium_port

  Capybara.current_driver = :selenium_remote
```

## Tip 2: Using RSpec Metadata for easy driver switch

* You can use rspec's metadata for implementing switching drivers on **all tests for class** or **single test** level.

* First, create shared context named **CapybaraTest**:

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

* Now, you can specify driver for the whole test suite:

```ruby
describe SomeClass, driver: :webkit do
  include_context "CapybaraTest"
  ...
end
```

* Or, for a single test:

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

## Tip 3: Using remote selenium with rspec's metadata

* You need to register new driver type: **:selenium_remote**.

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
    # load selenium configuration from file
    config = ...

    register_remote_selenium_driver config[:selenium_host], config[:selenium_port]
  end
end
```

* Now you can specify new driver name per test suite or single test:

```ruby
describe SomeClass do
  include_context "CapybaraTest"

  it 'does something else', driver: :selenium_remote do
    ...
  end
end
```

## Tip 4: Ignoring specs

* You can ignore particular test. First, configure rspec:

```ruby
RSpec.configure do |config|
  config.filter_run_excluding :exclude => true
end
```

* In your test:

```ruby
describe SomeClass do
  include_context "CapybaraTest"

  it 'does something else', driver: :selenium, exclude: true do
    ...
  end
end
```

# CI

brew install selenium-server-standalone
brew upgrade selenium-server-standalone

To reload selenium-server-standalone after an upgrade:
    launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.selenium-server-standalone.plist
    launchctl load ~/Library/LaunchAgents/homebrew.mxcl.selenium-server-standalone.plist

## Acceptance Test gem

[Capybara Home]: https://github.com/jnicklas/capybara
[Selenium Home]: http://docs.seleniumhq.org/
[Ruby Bindings for Selenium]: http://code.google.com/p/selenium/wiki/RubyBindings
[acceptance test gem]: https://github.com/shvets/acceptance_test

* [Why wait_until was removed from Capybara - *http://www.elabs.se/blog/53-why-wait_until-was-removed-from-capybara*]


