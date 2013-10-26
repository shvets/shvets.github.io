---
title: Configure Macbook
date: 2014-01-01
tags: ruby, osx, mavericks
---

# Install UI applications:

* Iterm2
* Firefox
* Sublime2
* DropBox
* Skype
* RubyMine
* Moroshka File Manager
* MU Commander
* ForkLift
* VLC

# Install appropriate XCode and Command Line Tools for XCode

Read and agree to Xcode license:

```bash
xcodebuild -license
```
# Install Homebrew

See this [article] (http://dhruba.name/2012/07/29/installing-g-and-gcc-on-mac-os-x-10-8-command-line) for details.

```bash
ruby -e "$(curl -fsSkL raw.github.com/mxcl/homebrew/go)"

brew update
brew tap homebrew/dupes
brew tap --repair homebrew/dupes
brew tap homebrew/versions

brew install autoconf automake apple-gcc42

brew doctor
```

# Install command line tools

```bash
brew install wget
brew install mc
brew install git
brew install qt
```

Qt is required by capybara acceptance tests.

# Install RVM:

```bash
\curl -L https://get.rvm.io | bash -s
\curl -L https://get.rvm.io | bash -s -- --autolibs=enable
```

Then run this command:

```bash
source ~/.rvm/scripts/rvm
```

or reopen another Terminal.

Enable autolibs option. It will automatically install missing packages, like libyaml, libxml2, libxslt, openssl, sqlite:

```bash
rvm autolibs enable
rvm autolibs homebrew
```

Install required packages:

```bash
rvm requirements
```

# Install various rubies:

* Install Ruby 1.9.3:

```bash
rvm install 1.9.3

```

Add to ~/.bash_profile:

```bash
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
[[ -r $rvm_path/scripts/completion ]] && . $rvm_path/scripts/completion

rvm use 1.8.7
ruby -v
```

Install jruby:

```bash
rvm install jruby
```

Install Ruby 1.8.7 (32 bit):

```bash
rvm install ruby-1.8.7-p371 -n i386 --with-arch=i386 --enable-shared --without-tk --without-tcl
``

Note: i386 arch is important if you plan to use Oracle Instant Client on Mountain Lion.

Install Ruby 1.8.7 (64 bit):

```bash
rvm install ruby-1.8.7-p371 --enable-shared --without-tk --without-tcl
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

Open 'subl /usr/local/var/postgres/postgresql.conf' in a text editor, and uncomment + edit the unix_socket_directory key to:

```
unix_socket_directory = '/var/pgsql_socket'
``

```bash
export PGHOST=/var/pgsql_socket

mkdir -p ~/Library/LaunchAgents
sudo chown $USER ~/Library/LaunchAgents
cp /usr/local/Cellar/postgresql/9.2.4/homebrew.mxcl.postgresql.plist ~/Library/LaunchAgents/

launchctl unload -w ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist
launchctl load -w ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist
```

You can now start the database server   manually using:

```bash
    postgres -D /usr/local/var/postgres
```
or

```bash
    pg_ctl -D /usr/local/var/postgres -l logfile start
```
And stop with:

```bash
    pg_ctl -D /usr/local/var/postgres stop -s -m fast
```

Create users and databases, e.g.:

```bash
    createuser -s -d -r rails_app_tmpl

    createdb -U rails_app_tmpl rails_app_tmpl_dev
    createdb -U rails_app_tmpl rails_app_tmpl_prod

rake db:migrate
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

Or you can start the MySQL daemon manually with:

```bash
cd /usr/local/Cellar/mysql/$MYSQL_VERSION ; /usr/local/Cellar/mysql/$MYSQL_VERSION/bin/mysqld_safe &
```

Configure Mysql (32 bit):

Download installation from here: http://dev.mysql.com/downloads/mysql.

Look for something like mysql-5.6.10-osx10.6-x86.dmg.

Install it. In System Preferences | MySQL start the server. Check the flag to start MySQL on restart.


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

or

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

# Install oracle server (out of scope)

Note: The JDBC driver jar file is expected to be placed in %JBOSS_HOME%/server/< serverName>/lib folder. It won't be
used from the WEB-INF/lib folder


# Install app on heroku:

```bash
> heroku create rails-app-tmpl -s cedar
# --buildpack https://github.com/carlhoerberg/heroku-buildpack-jruby.git
> git push heroku master
> heroku run rake db:migrate
> heroku open
> heroku destroy rails-app-tmpl --confirm rails-app-tmpl
```




git clone https://github.com/cldwalker/debugger-ruby_core_source.git
cp -R debugger-ruby_core_source ~/.rvm/gems/ruby-1.9.3-p448@n1/gems/debugger-ruby_core_source-1.2.3

cp -R ~/Dropbox/Alex/work/projects/debugger-ruby_core_source ~/.rvm/gems/ruby-1.9.3-p448@n1/gems/debugger-ruby_core_source-1.2.3


brew link libpng
brew install libxml2 libxslt
brew unlink libxml2
brew unlink libxslt


rvm install ruby-1.9.3-p392 -n i386 --with-arch=i386 --with-gcc=clang

rvm reinstall 1.9.3 --with-gcc=clang

The provided compiler '/usr/bin/gcc' is LLVM based, it is not yet fully supported by ruby and gems,
please read `rvm requirements`.

[Install Ruby on Rails · Mac OS X Mavericks]: http://railsapps.github.io/installrubyonrails-mac.html
[Setting up a Ruby on Rails development environment on Mavericks]: http://dean.io/setting-up-a-ruby-on-rails-development-environment-on-mavericks/
