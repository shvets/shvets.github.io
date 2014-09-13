---
title: Configure Macbook for Ruby/Rails Development
date: 2014-09-13
tags: ruby, osx, mavericks, provisioning, macbook
---

# Configuring Macbook for Ruby/Rails Development with automated scripts

## Introduction

There are numerous instructions around the Internet about how to configure your MacBook to work
with Ruby and Rails. I have my own [blog entry](configure_macbook_article) on the same topic.
The problem with all of them is that they ought to be executed **manually**. But we want to do
it **automatically** with the help of scripts.

When you try to solve this type of task, you have **"the chicken and egg" problem** - in order to
do automatic provision, you have to have pre-installed languages/libraries. You don't want
to do everything in form of **low-level shell script**, but rather in **high-level language**, like ruby,
python or node. Unfortunately such high-level scripts use external libraries that need to be downloaded
and installed first before you can run scripts.

To make it simple and straightforward, we are going to do it **remotely**, e.g. you have one computer
**with pre-installed language and libraries** and we will install all required programs over **ssh**
on clean computer. It means that you have to enable ssh access on this computer. This idea is somewhat
similar to what [capistrano](capistrano) or [chef](chef) does. Why don't we use them here? Look at
this [article](script_executor_article) for the explanation.

I have built new ruby gem called [osx_provision](osx_provision), that provides automated scripts
for configuring Macbook. This article is about how to install, configure and use it with your project.

## Install

Add this line to your application's Gemfile:

```bash
gem 'osx_provision'
```

And then execute it:

```bash
bundle
```

Or install it yourself as:

```bash
gem install osx_provision
```

## Configure

Before you can start using **osx_provision** gem within your project, you need to do the following:

1. Create configuration file (e.g. .osx\_provision.json) in json format at the root of your project.
It will define your environment:

```json
{
  "node": {
    "domain": "127.0.0.1",
    "user": "ENV['USER']",
    "home": "ENV['HOME']",
    "port": "",
    "remote": false
  },

  "project": {
    "home": "#{node.home}/work/my_project",
    "ruby_version": "1.9.3",
    "gemset": "new_gem"
  },

  "postgres": {
    "hostname": "localhost", "user": "postgres", "password": "postgres",
    "app_user": "pg_user", "app_password": "pg_password",
    "app_schemas": [ "my_project_test", "my_project_dev", "my_project_prod"]
  }
}
```

Variables defined in this file are used by underlying shell scripts provided by this gem.
You can also add your own shell script (see details later) - in this case .osx\_provision.json
will have your variables as well.

Next **node** section describes your destination computer where you want to install this provision.
In this example we do provisioning locally, but it's possible to do it on remote machine, e.g.:

```json
  ...
  "node": {
    "domain": "192.168.1.2",
    "user": "some_remote_user",
    "home": "some_remote_password",
    "port": "22",
    "remote": true
  },
  ...
```

In **project** section you keep project-related info, like project **home**, project **gemset name**
and **ruby version**.

If you need to refer variable form another section, use "dot" notation, like **#{node.home}**. It is
possible thanks to another gem called [text-interpolator](text-interpolator).

Last **postgres** section contains information about your postgres server and what database user and
schemas need to be created. In our example we describe that we want to create **pg_user** with **password**
and 3 schemas: **my\_project\_test**, **my\_project\_dev**, **my\_project\_prod**. Postgres server
itself is located at **localhost** address.

You can also add **mysql** section - it's also supported.


2. Provide execution script

Library itself if written in ruby, but for launching its code you have to use **rake** or **thor** tool.
Here I provide thor script as an example:

```ruby
# thor/osx_install.thor

$: << File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'osx_provision'

class OsxInstall < Thor
  @installer = OsxProvision.new self, ".osx_provision.json"

  class << self
    attr_reader :installer
  end

  desc "all", "Installs all required packages"
  def all
    invoke :brew # execute command defined in shell script
    invoke :rvm
    invoke :qt

    invoke :init_launch_agent

    invoke :postgres
    invoke :postgres_restart

    invoke :jenkins
    invoke :jenkins_restart

    invoke :selenium

    invoke :ruby

    invoke :postgres_create_user
    invoke :postgres_create_schemas
  end

  desc "postgres_create_schemas", "Initializes postgres schemas"
  def postgres_create_schemas
    # execute method from  OsxProvision class - we need to read
    # schema names from configuration file and create them in the loop
    OsxInstall.installer.postgres_create_schemas
  end

  desc "postgres_drop_schemas", "Drops postgres schemas"
  def postgres_drop_schemas
    OsxInstall.installer.postgres_drop_schemas
  end
end
```

You can execute separate commands from script directly with **invoke** thor command. Below is fragment
of such script:

```bash
#!/bin/sh

[prepare]

mkdir #{home}/Library/LaunchAgents/

[brew]

ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"

brew update
brew doctor

brew tap homebrew/dupes
brew tap homebrew/versions

[rvm]

PATH=$PATH:/usr/local/bin
USER_HOME="#{node.home}"

curl -L https://get.rvm.io | bash

source $USER_HOME/.rvm/scripts/rvm

```

All available scripts are located [here](osx_provision_scripts). If you need more scripts, you can
create them locally (e.g. in (thor/osx\_provision\_scripts\_my\_project.sh)) and then initialize
thor script accordingly:


```ruby
# thor/my_project_osx_provision_scripts.thor
...

class OsxInstall < Thor
  @installer = OsxProvision.new self, ".osx_provision.json",
                 [File.expand_path("my_project_osx_provision_scripts.sh", File.dirname(__FILE__))]
  ...
end
```

Below is the example of such script for running rails server in standard and debug mode:

```bash
#!/bin/sh

##############################
[rails]

USER_HOME="#{node.home}"
APP_HOME="#{project.home}"

cd $APP_HOME

source $USER_HOME/.rvm/scripts/rvm

rvm use #{project.ruby_version}@#{project.gemset} --create

bundle exec rails s

##############################
[rails_debug]

USER_HOME="#{node.home}"
APP_HOME="#{project.home}"

cd $APP_HOME

source $USER_HOME/.rvm/scripts/rvm

rvm use #{project.ruby_version}@#{project.gemset} --create

RAILS=`which rails`

bundle exec rdebug-ide --port 1234 --dispatcher-port 26162 -- $RAILS s
```

## Executing automated scripts

First, take a look at the list of available thor command:

```bash
thor -T
```

You can see something like this:

```bash
osx_install
-----------
thor osx_install:all                      # Installs all required packages
thor osx_install:app                      # Installs app
thor osx_install:brew                     # brew
thor osx_install:general                  # Installs general packages
thor osx_install:git                      # git
thor osx_install:jenkins                  # jenkins
thor osx_install:jenkins_restart          # jenkins_restart
thor osx_install:mysql                    # mysql
thor osx_install:mysql_create_schema      # mysql_create_schema
thor osx_install:mysql_create_schemas     # Initializes mysql schemas
thor osx_install:mysql_create_user        # mysql_create_user
thor osx_install:mysql_drop_schema        # mysql_drop_schema
thor osx_install:mysql_drop_schemas       # Drops mysql schemas
thor osx_install:mysql_drop_user          # mysql_drop_user
thor osx_install:mysql_restart            # mysql_restart
thor osx_install:npm                      # npm
thor osx_install:package_installed        # package_installed
thor osx_install:postgres                 # postgres
thor osx_install:postgres_create_schema   # postgres_create_schema
thor osx_install:postgres_create_schemas  # Initializes postgres schemas
thor osx_install:postgres_create_user     # postgres_create_user
thor osx_install:postgres_drop_schema     # postgres_drop_schema
thor osx_install:postgres_drop_schemas    # Drops postgres schemas
thor osx_install:postgres_drop_user       # postgres_drop_user
thor osx_install:postgres_restart         # postgres_restart
thor osx_install:postgres_start           # postgres_start
thor osx_install:postgres_stop            # postgres_stop
thor osx_install:prepare                  # prepare
thor osx_install:qt                       # qt
thor osx_install:ruby                     # ruby
thor osx_install:rvm                      # rvm
thor osx_install:selenium                 # selenium
thor osx_install:selenium_restart         # selenium_restart
thor osx_install:service_started          # service_started
thor osx_install:svn                      # svn
```

With this scripts you can execute them separately and all together:

```bash
thor osx_install:brew
thor osx_install:rvm
thor osx_install:postgres
thor osx_install:brew

thor osx_install:all
```

To configure postgres only run this sequence:

```bash
thor osx_install:postgres
thor osx_install:postgres_create_user
thor osx_install:postgres_create_schemas
thor osx_install:postgres_start
```

Enjoy the gem and let me know if other useful command can be added to it.

[configure_macbook_article]: http://shvets.github.io/blog/2014/04/19/configure_macbook.html
[capistrano]: http://capistranorb.com
[chef]: https://github.com/opscode/chef
[script_executor_article]: http://shvets.github.io/blog/2013/12/21/script_executor.html
[osx_provision]: https://github.com/shvets/osx_provision
[text-interpolator]: https://github.com/shvets/text-interpolator
[osx_provision_scripts]: https://github.com/shvets/osx_provision/blob/master/lib/osx_provision/osx_provision_scripts.sh
