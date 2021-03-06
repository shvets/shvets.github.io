---
title: Configuring Code Coverage for Ruby/Rails project
date: 2013-10-19
tags: ruby, simplecov, CI
---

# Configuring Code Coverage for Ruby/Rails project

## Getting Started

[SimpleCov] [simplecov home] is a code coverage analytical tool for Ruby 1.9 built as ruby gem.

In order to use it in your project add this gems to your Gemfile:

```ruby
  group :coverage do
    gem 'simplecov', :require => false
  end
```

The formatter for SimpleCov is packaged as a separate gem called [simplecov-html] [simplecov-html].
You don't have to include it explicitly - SimpleCov already has it as a dependency.

You don't have to call coverage as separate command. Instead, you have to integrate it with your specs or tests.
How to do it?

You have to start SimpleCov before any of your specs/tests in order to be covered:

```ruby
# spec_helper.rb
if ENV['COVERAGE'] == 'true'
  require 'simplecov'

  SimpleCov.start
end
```

```ruby
# my_model_spec.rb
require 'spec_helper'

describe MyModel do
...
end
```
Now you can run your specs:

```bash
rspec spec/my_model_spec.rb
```

Coverage report will be saved in **coverage** folder. Open up **coverage/index.html** in your browser
and check out results:

```bash
open coverage/index.html
```

If you want to save results to another folder, change **coverage_path** property:

```ruby
SimpleCov.coverage_path = 'my_output'
```

In real project you have different groups of specs executed by separate commands. If you want to **merge**
coverage results generated by each of command into total report, you have to assign **unique command name**
for each group of specs:

```ruby
# model_spec_helper.rb
if ENV['COVERAGE'] == 'true'
  require 'simplecov'

  SimpleCov.command_name "rspec:models"

  SimpleCov.start unless SimpleCov.running
end
```

```ruby
# domains_spec_helper.rb
if ENV['COVERAGE'] == 'true'
  require 'simplecov'

  SimpleCov.command_name "rspec:domains"

  SimpleCov.start unless SimpleCov.running
end
```

## SimpleCov Adapters

SimpleCov understands notion of **adapter**. You can start SimpleCov with preconfigured **rails** adapter:

```ruby
SimpleCov.start 'rails'
```

Let's look closer at definition of **rails** adapter:

```ruby
SimpleCov.adapters.define 'rails' do
  ...
  add_filter '/config/'
  add_filter '/db/'
  add_filter '/vendor/bundle/'

  add_group 'Controllers', 'app/controllers'
  add_group 'Models', 'app/models'
  add_group 'Mailers', 'app/mailers'
  add_group 'Helpers', 'app/helpers'
  add_group 'Libraries', 'lib'
  add_group 'Plugins', 'vendor/plugins'
end
```

As you can see, adapter definition includes **filters** and **groups**. **Filters** specify which directories
and files will be includes into coverage. **Groups** define separate tabs of coverage report.

You can read more about groups and filters on [SimpleCov] [simplecov home] home page.

If you are not satisfied with **rails** adapter, you can create your own:

```ruby
  def register_adapter adapter_name
    SimpleCov.adapters.define adapter_name do
      add_filter '/spec/'
      add_filter '/db/'
      add_filter 'lib/tasks/'
      add_filter '/vendor/'
      add_filter '/config/'

      add_group "Domain", "app/domain"
      add_group "Models", "app/models"
      add_group "Services", "app/services"
    end
  end
```

## Full Example

Let's create compete example that can be used in any project:

```ruby
# spec_helper.rb
  def init_spec command_name
    ...
    SimplecovHelper.run_simplecov command_name,
      "your_adapter_name" if ENV['COVERAGE'] == 'true'
    ...
  end
```

And this is SimpleCov helper implemented as utility module:

```ruby
module SimplecovHelper
  extend self

  def run_simplecov command_name, adapter_name
    require 'simplecov'

    SimpleCov.command_name command_name

    start_simplecov(adapter_name) unless SimpleCov.running
  end

  private

  def start_simplecov adapter_name
    register_adapter adapter_name

    SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter

    SimpleCov.at_exit do
      SimpleCov.result.format!
    end

    SimpleCov.start adapter_name
  end

  def register_adapter adapter_name
    ...
    # see implementation in previous section
  end
end
```

## Alternatives

Another gem dedicated to code coverage is [coco gem] [coco home].

It provides simple code coverage report and it's much easier to configure, but resulting report is
much simpler and less convenient.

You can choose what tool to use in your project based on your preferences.

If you need to cover your javascript code, you can visit [my previous blog article]
(http://shvets.github.io/blog/2013/09/14/nodejs_and_karma.html).

[simplecov home]: https://github.com/colszowka/simplecov
[simplecov-html]: https://github.com/colszowka/simplecov-html
[coco home]: http://lkdjiin.github.io/coco/