---
title: Extending RubyMine with JRuby script
date: 2011-01-01
tags: ruby, jruby, rubymine
---

## Extending RubyMine with JRuby script - How to use HAML/SASS converter from inside IDE (JRuby script-plugin)

# How it works

RubyMine already has JRuby library as part of IDE (see **$\{RUBYMINE_INSTALLATION/lib/jruby-complete.jar\}** file).

It also has few scripts that extend standard functionality of IDE, you can see them under
**'File|Settings|Extension'** path or here: **$\{RUBYMINE_INSTALLATION/rb/*.rb\}**. It could be considered as convenient
platform with easy extensions as ruby-plugins.

Unfortunately, if your script depends on other gems and list of dependencies is big, it becomes very difficult to
install new plugins. You have to detect and install all dependent gems into RubyMine installation.

In this article I will introduce another way of how to extend RubyMine functionality. We'll have separate
installation of JRuby that will provide us with gems repository.

First of all, you have to install [rvm][rvm]. This is a tool for installing different ruby versions under Mac/Unix
platforms. Once you have **rvm** installed, install jruby and then use it:

```bash
rvm install jruby-1.5.6
rvm use jruby
```

Check, if you have correct ruby version:

```bash
ruby -v
```

It should be **jruby 1.5.6**.

Once we have **jruby** installed, we can develop new RubyMine plugin. We'll discuss step-by-step what needs to be done.

### Step 1: Defining dependencies

We need to document dependencies for our plugin in **Gemfile**:

```ruby
source "http://rubygems.org"

gem "haml", "3.0.24"
gem "hpricot", "0.8.3"
gem "abstract", "1.0.0"
gem "erubis", "2.6.6"
gem "sexp_processor", "3.0.5"
gem "ruby_parser", "2.0.5"
```

Now you can install dependencies with one command:

```ruby
bundle install
```

### Step 2: Loading dependencies

The following method loads all required gems into memory:

```ruby
include Java

def load_required_gems
  jruby_home = "#{ENV['HOME']}/.rvm/gems/jruby-1.5.6@haml-sass-converters"

  $: << "#{jruby_home}/gems"

  $: << "#{jruby_home}/gems/haml-3.0.24/lib"
  $: << "#{jruby_home}/gems/hpricot-0.8.3-java/lib"
  $: << "#{jruby_home}/gems/abstract-1.0.0/lib"
  $: << "#{jruby_home}/gems/erubis-2.6.6/lib"
  $: << "#{jruby_home}/gems/sexp_processor-3.0.5/lib"
  $: << "#{jruby_home}/gems/ruby_parser-2.0.5/lib"
end

load_required_gems
```

### Step 3: "Requiring" libraries

Now we need to **require** libraries for working with **HAML/SASS** and **RubyMine**:

```ruby
require "haml"
require "haml/html"
require "sass/css"

require 'default_scripts_groups'
require 'editor_action_helper'
require 'action_group_helper'
```

### Step 4: Building conversion logic

We encapsulate all conversion logic into **Converter** class. We need to integrate logic from HAML/SASS library
with RubyMine API. Because this class will be executed in RubyMine environment, we have access to **editor** object:

````ruby
class Converter
  def self.convert_selection editor
    if editor.has_selection?
      text = editor.selection
      s_start = editor.selection_start

      changed_text = yield(text)
      editor.replace_selection_text(changed_text)

      # restore selection
      editor.select(s_start, s_start + changed_text.length)
    end
  end

  def self.convert_to_haml(html)
    Haml::HTML.new(html, :erb => true, :xhtml => true).render
  end

  def self.convert_to_sass(css)
    Sass::CSS.new(css).render(:sass)
  end

  def self.convert_to_scss(css)
    Sass::CSS.new(css).render(:scss)
  end
end
```

### Step 5: Registering editor actions

Now we need to register conversion methods of **Converter** class as editor actions for HTML/HAML conversions:

```ruby
register_editor_action "html_to_haml",
                       :text => "Convert Html to Haml",
                       :description => "Converts Html content to Haml content.",
                       :group => "EditorPopupMenu",
                       :enable_in_modal_context => true do |editor, _|
  Converter.convert_selection editor do |text|
    Converter.convert_to_haml(text)
  end
end

register_editor_action "html_to_haml_erb",
                       :text => "Convert Html to Haml",
                       :description => "Converts Html content to Haml content.",
                       #:shortcut => "control shift PERIOD",
                       :group => "ScriptsErb",
                       :file_type => "RHTML" do |editor, _|
  Converter.convert_selection editor do |text|
    Converter.convert_to_haml(text)
  end
end
```

For executing CSS/SASS conversions we will create new "Css" group under 'Tools|Extensions' menu item.
We also need to register **Converter** class methods as editor actions for CSS/SASS conversions:

```ruby
register_action_group "ScriptsCss", :text => "Css"

register_editor_action "css_to_sass",
                       :text => "Convert CSS to SASS",
                       :description => "Converts CSS content to SASS content.",
                       :group => "EditorPopupMenu",
                       :enable_in_modal_context => true do |editor, _|
  Converter.convert_selection editor do |text|
    Converter.convert_to_sass(text)
  end
end

register_editor_action "css_to_sass_css",
                       :text => "Convert CSS to SASS",
                       :description => "Converts CSS content to SASS content.",
                       #:shortcut => "control shift PERIOD",
                       :group => "ScriptsCss",
                       :file_type => "CSS" do |editor, _|
  Converter.convert_selection editor do |text|
    Converter.convert_to_sass(text)
  end
end
```

# Install plugin

Above is th explanation of how plugin works. If you just want to use plugin, install
[haml-sass-converters][haml-sass-converters] gem into **haml-sass-converters** gemset:

```bash
rvm use jruby@haml-sass-converters --create
gem i haml-sass-converters
```
Run install script in your project's root (or some other location) in order to copy the script:

```bash
cd <your-project-root>
haml-sass-converters-install
```

New **"scripts"** folder will be created with **"converters.rb"** as a plugin.

Go to **"File|Setting|Extensions"** and add "scripts" folder as new **"Script Folder"**.

Restart **RubyMine**. After restarting IDE will have new **"Css"** group under **"Tools|Extensions"** and new actions:

* convert Html to Haml;
* convert CSS to SASS;

You can reach them from **"Tools|Extensions"** in main menu or from context popup menu inside the editor.

# How to use plugin

Select some content inside erb or css file. Right click inside the editor and select appropriate action.


[rvm]: https://rvm.io "RVM Home"
[haml-sass-converters]: http://github.com/shvets/haml-sass-converters "Haml/SASS Converters"
