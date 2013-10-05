---
title: How to maintain ruby project that works with Ruby and JRuby
date: 2013-10-05
tags: ruby, jruby, rvm
---

## How to maintain ruby project that works with Ruby and JRuby

If your Ruby/Rails project has to work with Ruby and JRuby at the same time,
sooner or later you'll end up with **Gemfile** that has a lot of **if logic**:

```ruby
# Gemfile

if RUBY_PLATFORM == "java" # jruby
  gem "jdbc-postgres"
  gem "activerecord-jdbcpostgresql-adapter"
else
  gem "pg", '0.13.2'
end
```

If you have a lot of dependencies this **if logic** complicates and pollutes your code.

How can we simplify this code? Easy - keep two separate **Gemfile** - one for
Ruby (Gemfile) and another for JRuby (Gemfile-jruby).

You need to tell your bundler though which **Gemfile** needs to be used.

If you want to run bundler with different Gemfile, run it this way:

```bash
BUNDLE_GEMFILE=Gemfile-jruby bundle
```

This is fine, but you have to remember to provide additional environment variable every time you run the command.

If you want to select Gemfile automatically when you change ruby or gemset,
you can use **rvm hook**. All hooks for rvm are located in **~/.rvm/hooks**  folder.

Create or edit this file:

```bash
vi ~/.rvm/hooks/after_use_jruby
```

Locate line with **if [[ "${rvm_ruby_string}" =~ "jruby" ]]** and add your code:

```bash
#!/usr/bin/env bash
\. "${rvm_path}/scripts/functions/hooks/jruby"

if [[ "${rvm_ruby_string}" =~ "jruby" ]]
then
  export BUNDLE_GEMFILE="Gemfile-jruby"
else
  export BUNDLE_GEMFILE="Gemfile"
fi
```

Change rights for this file to make it executable:

```bash
chmod +x ~/.rvm/hooks/after_use_jruby
```

Now, every time you change directory to your project, rvm will setup all environment
variables as before plus your **BUNDLE_GEMFILE** variable.

If your current ruby (.ruby-version) is jruby, it will use **Gemfile-jruby**, otherwise - **Gemfile**.
