---
title: Replacing nanoc with middleman for static web site generation
date: 2013-08-31
tag: ruby, bundler, nanoc, middleman
---

# Replacing nanoc with middleman for static web site generation

[Nanoc] [nanoc] and [middleman] [middleman] are comparable tools. Both provide static web site generation from ruby
templates, such as erb, haml etc. I discover that middleman is easier to configure and has better/simpler
extension support. So, I decided to convert my existing web site to work with middleman.

Here are the steps that you need to do in order to use middleman or migrate your web site from other static site generator.

**1.** If you have old **.rvmrc** file, remove it and create 2 new files:

* **.ruby-version**:

```txt
1.9.3
```

* **.ruby-gemset**:

```txt
your_gemset_name
```

This is the [new way] [new_rvm_way] of handling **ruby version** and **gemset name** introduced in latest
versions of bundler.


**2.** Include into your **Gemfile** at least these gems:

```ruby
gem "middleman"
gem "middleman-livereload"
gem "haml"
gem "redcarpet"
```

In this minimal configuration we have support for dynamic reloading of web pages when they get changed
and support for haml and markdown engines.

**3.** Move all files from your **content** folder into new **sources** folder.:

```bash
mv content source
```

**4.** Remove **compass_config.rb** and create new **config.rb** file. This is configuration file for
middleman:

```ruby
set :build_dir, "public"

set :css_dir, "assets/stylesheets"
set :js_dir, "assets/javascripts"
set :images_dir, "assets/images"

set :markdown_engine, :redcarpet

set :markdown, fenced_code_blocks: true, autolink: true, smartypants: true,
    gh_blockcode: true, lax_spacing: true

set :haml, { ugly: true }
```

Make sure that your styles, javascripts and images are located in:
* source/assets/stylesheets
* source/assets/javascripts
* source/assets/images

**5.** Adding language highlight support

If you want support for language highlight in markdown files, include this gem into **Gemfile**:

```ruby
gem "middleman-syntax"
```

and these lines to **config.rb** file:

```ruby
configure :development do
  activate :syntax, :line_numbers => true
end

configure :build do
  activate :syntax, :line_numbers => true
end
```

Make sure that you activated syntax highlight in development configuration too.

**6.** Adding partials support

If you need partials in your project, use **partial** command:

```haml
  #main-column
    #logo
      = partial "common/header"
```

**7.** Other miscellaneous changes

* Remove all related to **nanoc** files from **lib** folder.

* Move **common** folder (if you have) from **layout/common** into **common** folder.

* Rename **layouts/default.haml** into **layouts/layout.haml**.

**8.** Generate static web site:

```bash
rm -rf public
middleman build
```

**9.** Start middleman and then access your web site from the browser:

```bash
middleman &

open http://localhost:4567
```

[nanoc]: http://nanoc.ws/
[middleman]: http://middlemanapp.com/
[new_rvm_way]: http://blog.railsapps.org/post/47051459677/project-gemsets-with-rvm
