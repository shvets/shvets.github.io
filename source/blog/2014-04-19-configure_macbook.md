---
title: Configure Macbook for Ruby/Rails Development
date: 2014-04-19
tags: ruby, osx, mavericks
---

# Configure Macbook for Ruby/Rails Development

## Install UI applications:

* Iterm2
* Firefox
* DropBox
* Skype
* RubyMine
* Moroshka File Manager
* MU Commander
* VLC

## Install XCode and XCode Tools

* Install XCode from AppStore.

* Install XCode Command Line Tools from inside XCode.

* Read and agree to Xcode license from command line:

```bash
sudo xcodebuild -license
```

## Install Homebrew

It is package manager for MacOS written in ruby:

```bash
ruby -e "$(curl -fsSkL raw.github.com/mxcl/homebrew/go)"

brew update
brew tap homebrew/dupes
brew tap homebrew/versions

brew doctor
```

## Install command line tools

Install base tools:

```bash
brew install wget
brew install mc
brew install git
```

**Qt** package is required by Capybara acceptance tests.

```bash
brew install qt
```

**Node** is used for jasmine javascript unit test and for various javascript tasks.
It will install **node package manager** (**npm**) as well:

```bash
brew install node
```

Test it:

```bash
node -v
npm -v
```

## Install Sublime 3 Text Editor

Download it from http://www.sublimetext.com.

Create convenient link:

```bash
ln -s /Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl $HOME/bin/subl
```

## Install RVM:

```bash
\curl -sSL https://get.rvm.io | bash
```

Then run this command:

```bash
source ~/.rvm/scripts/rvm
```

or reopen in another terminal window.

Install required packages:

```bash
rvm requirements
```

## Install various ruby versions:

```bash
rvm install 1.9.3

rvm install 2.1.1

rvm install jruby
```

## Update .bash_profile

Add to **~/.bash_profile** the following lines:


```bash
export PATH=/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/opt/local/bin:$PATH

export EDITOR='subl -w'
export PS1='${LOGNAME}@$(hostname): [$(~/.rvm/bin/rvm-prompt)] (\w):\n> '

[[ -r $rvm_path/scripts/completion ]] && . $rvm_path/scripts/completion

rvm use 1.9.3
ruby -v
```

## Install postgres server:

Install it:

```bash
brew install postgres
```

Start it:

```bash
mkdir -p ~/Library/LaunchAgents
sudo chown $USER ~/Library/LaunchAgents

cp /usr/local/Cellar/postgresql/9.3.3/homebrew.mxcl.postgresql.plist ~/Library/LaunchAgents/

launchctl unload -w ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist
launchctl load -w ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist
```

Initialize database:

```bash
initdb /usr/local/var/postgres -E utf8
```

Create users and databases from command line:

```bash
createuser -s -d -r rails_app_tmpl

createdb -U rails_app_tmpl rails_app_tmpl_dev
createdb -U rails_app_tmpl rails_app_tmpl_test
createdb -U rails_app_tmpl rails_app_tmpl_prod

rake db:migrate
```

or with psql tool:

```bash
psql -c 'create user rails_app_tmp;' -s -d -r

psql -c 'create database rails_app_tmpl_dev;' -U rails_app_tmpl -h 127.0.0.1
psql -c 'create database rails_app_tmpl_test;' -U rails_app_tmpl -h 127.0.0.1
psql -c 'create database rails_app_tmpl_prod;' -U rails_app_tmpl -h 127.0.0.1
```

## Install mysql server:

Install it:

```bash
brew install mysql
```

Start it:

```bash
mkdir -p ~/Library/LaunchAgents
sudo chown $USER ~/Library/LaunchAgents

ln -sfv /usr/local/opt/mysql/*.plist ~/Library/LaunchAgents

launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist
launchctl load ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist
```

Set up mysql root password:

```bash
mysqladmin -u root password 'root'
```

Create users and databases from command line:

```bash
--mysql -h localhost -u root -p"root" -e "flush  priveleges;"
--mysql -h localhost -u root -p"root" -e "drop user 'rails_app_tmpl'@'localhost';"

mysql -h localhost -u root -p"root" -e "CREATE USER 'rails_app_tmpl'@'localhost' IDENTIFIED BY 'rails_app_tmpl';"

mysql -h localhost -u root -p"root" -e "grant all privileges on *.* to 'rails_app_tmpl'@'localhost' identified by 'rails_app_tmpl' with grant option;"
mysql -h localhost -u root -p"root" -e "grant all privileges on *.* to 'rails_app_tmpl'@'%' identified by 'rails_app_tmpl' with grant option;"

mysql -h localhost -u root -p"root" -e "create database rails_app_tmpl_dev;"
mysql -h localhost -u root -p"root" -e "create database rails_app_tmpl_test;"
mysql -h localhost -u root -p"root" -e "create database rails_app_tmpl_prod;"
```

or with mysql tool interactively:

```bash
mysql -u root -p'root'

  CREATE USER 'rails_app_tmpl'@'localhost' IDENTIFIED BY 'rails_app_tmpl';

  grant all privileges on *.* to 'rails_app_tmpl'@'localhost' identified by 'rails_app_tmpl' with grant option;
  grant all privileges on *.* to 'rails_app_tmpl'@'%' identified by 'rails_app_tmpl' with grant option;

  create database rails_app_tmpl_dev;
  create database rails_app_tmpl_test;
  create database rails_app_tmpl_prod;

  exit;
```bash

## Install selenium standalone server

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

## Create or load your project

* Create folder with ruby and/or rails.

* Create **Gemfile** with all dependent ruby gems.

* Create **package.json** with all dependent javascript nodes.

*Install ruby gems and js nodes:

```bash
bundle install

npm install
```

Other instructions on Mac configuration are available here [here](link1) and [here](lik2).

[link1]: http://railsapps.github.io/installrubyonrails-mac.html
[link2]: http://dean.io/setting-up-a-ruby-on-rails-development-environment-on-mavericks/
