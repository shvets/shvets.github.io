---
title: How to use CoffeeScript with nanoc
date: 2012-01-01
tags: ruby, nanoc, coffeescript
---

## How to use CoffeeScript with nanoc

**Step 1**: Add **coffee-script** to **Gemflie**:

```ruby
  gem 'coffee-script'
```

**Step 2**: Add **coffee_filter.rb** file to **lib** folder:

```ruby
  require 'coffee-script'

  class CoffeeFilter < Nanoc3::Filter
    identifier :coffee

    def run(content, params = {})
      CoffeeScript.compile(content)
    end
  end
```

**Step 3**: Add new rules to **Rules** file for compiling **coffee-script** files into **javascript** files:

```ruby
  compile '/assets/coffee/*/' do
    filter :coffee
  end

  # so that the /assets/coffee/ item is copied to /javascripts/ item
  route '/assets/coffee/*/' do
    item.identifier.sub(%r{^/assets/coffee}, '/javascripts').chop + '.js'
  end
```

**Step 4**: Create your first coffescript file in **source/assets/coffee** directory:

```coffee
  # test.coffee

  notify -> alert "Hello, user!"

  notify()
```

**Step 5**: Compile your web site.

```ruby
  nanoc3 compile
```

Compiled javascript files should be located in **javascrips** folder.

If you want to use coffee-script inside your haml partials, include this gem into 'Gemfile':

```ruby
  gem 'coffee-filter'
```

And include this fragment into partial:

```coffee
:coffeescript
  window.notify = () -> alert 'Hello, user!'
```
