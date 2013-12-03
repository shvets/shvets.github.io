!SLIDE title-and-content transition=cover

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



!SLIDE title-and-content transition=cover

# Tip 2: Using RSpec Metadata for easy driver switch

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



!SLIDE title-and-content transition=cover

# Tip 2: Using RSpec Metadata for easy driver switch (continued)

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



!SLIDE title-and-content transition=cover

# Tip 3: Using remote selenium with rspec's metadata

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



!SLIDE title-and-content transition=cover

# Tip 3: Using remote selenium with rspec's metadata help (continued)

* Now you can specify new driver name per test suite or single test:

```ruby
describe SomeClass do
  include_context "CapybaraTest"

  it 'does something else', driver: :selenium_remote do
    ...
  end
end
```


!SLIDE title-and-content transition=cover

# Tip 4: Ignoring specs

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