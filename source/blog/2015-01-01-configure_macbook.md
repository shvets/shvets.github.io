---
title: Configure Macbook for Ruby/Rails Development
date: 2015-01-01
tags: ruby, osx, mavericks
---

# Install UI applications:

* Iterm2
* Firefox
* DropBox
* Skype
* RubyMine
* Moroshka File Manager
* MU Commander
* VLC

# Install appropriate XCode and Command Line Tools for XCode

Install XCode from AppStore. Install Command Line Tools.

Read and agree to Xcode license:

```bash
sudo xcodebuild -license
```
# Install Homebrew

```bash
ruby -e "$(curl -fsSkL raw.github.com/mxcl/homebrew/go)"

brew update
brew tap homebrew/dupes
brew tap --repair homebrew/dupes
brew tap homebrew/versions

brew doctor
```

# Install command line tools

Install base tools:

```bash
brew install wget
brew install mc
brew install git
```

'Qt' package is required by Capybara acceptance tests.

```bash
brew install qt
```

'Node' is used for jasmine javascript unit test and other javascript management.
It will install **node package manager** (npm) as well:

```bash
brew install node
```

Test it:

```bash
node -v
npm -v
```

# Install Sublime 3 Text Editor

Download it from http://www.sublimetext.com.

Create convenient link:

```bash
ln -s /Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl $HOME/Dropbox/bin/subl
```

# Install RVM:

```bash
\curl -sSL https://get.rvm.io | bash
```

Then run this command:

```bash
source ~/.rvm/scripts/rvm
```

or reopen another Terminal.


Install required packages:

```bash
rvm requirements
```

# Install various rubies:

* Install Ruby 1.9.3:

```bash
rvm install 1.9.3

```

Install jruby:

```bash
rvm install jruby
```

# Update .bash_profile

Add to ~/.bash_profile the following lines:


```bash
export PATH=/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/opt/local/bin:$PATH

export EDITOR='subl -w'
export PS1='${LOGNAME}@$(hostname): [$(~/.rvm/bin/rvm-prompt)] (\w):\n> '

[[ -r $rvm_path/scripts/completion ]] && . $rvm_path/scripts/completion

rvm use 1.9.3
ruby -v
```

# Install postgres server:

```bash
brew install postgres

sudo sysctl -w kern.sysv.shmall=65536
sudo sysctl -w kern.sysv.shmmax=16777216
```

Initialize database:

```bash
initdb /usr/local/var/postgres -E utf8
```

Fix Mountain Lion related issue:

```bash
sudo mkdir /var/pgsql_socket
sudo chown $USER /var/pgsql_socket
```bash

Open 'subl /usr/local/var/postgres/postgresql.conf' in a text editor, and uncomment + edit the unix_socket_directories key to:

```
unix_socket_directories = '/var/pgsql_socket'
``

```bash
export PGHOST=/var/pgsql_socket

mkdir -p ~/Library/LaunchAgents
sudo chown $USER ~/Library/LaunchAgents
cp /usr/local/Cellar/postgresql/9.3.3/homebrew.mxcl.postgresql.plist ~/Library/LaunchAgents/

launchctl unload -w ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist
launchctl load -w ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist
```

Create users and databases, e.g.:

```bash
    createuser -s -d -r rails_app_tmpl

    createdb -U rails_app_tmpl rails_app_tmpl_dev
    createdb -U rails_app_tmpl rails_app_tmpl_prod

rake db:migrate
```

or with psql

```bash
psql -c 'create user rails_app_tmp;' -s -d -r

psql -c 'create database rails_app_tmpl_dev;' -U rails_app_tmpl -h 127.0.0.1
psql -c 'create database rails_app_tmpl_test;' -U rails_app_tmpl -h 127.0.0.1
```

# Install mysql server:

```bash
brew install mysql

mkdir -p ~/Library/LaunchAgents
sudo chown $USER ~/Library/LaunchAgents

ln -sfv /usr/local/opt/mysql/*.plist ~/Library/LaunchAgents

launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist
launchctl load ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist
```

or

```bash
    lunchy start mysql
```

Set up mysql root password:

```bash
mysqladmin -u root password 'root'
```

Run mysql script:

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

or with mysql:

```bash
mysql -h localhost -u root -p"root" -e "flush  priveleges;"
mysql -h localhost -u root -p"root" -e "drop user 'rails_app_tmpl'@'localhost';"
mysql -h localhost -u root -p"root" -e "CREATE USER 'rails_app_tmpl'@'localhost' IDENTIFIED BY 'rails_app_tmpl';"
mysql -h localhost -u root -p"root" -e "grant all privileges on *.* to 'rails_app_tmpl'@'localhost' identified by 'rails_app_tmpl' with grant option;"
mysql -h localhost -u root -p"root" -e "grant all privileges on *.* to 'rails_app_tmpl'@'%' identified by 'rails_app_tmpl' with grant option;"
mysql -h localhost -u root -p"root" -e "create database rails_app_tmpl_dev;"
mysql -h localhost -u root -p"root" -e "create database rails_app_tmpl_test;"
mysql -h localhost -u root -p"root" -e "create database rails_app_tmpl_prod;"
```


# Install selenium standalone server

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


# Create or load your project

```bash
npm install
```

[Install Ruby on Rails · Mac OS X Mavericks]: http://railsapps.github.io/installrubyonrails-mac.html
[Setting up a Ruby on Rails development environment on Mavericks]: http://dean.io/setting-up-a-ruby-on-rails-development-environment-on-mavericks/
