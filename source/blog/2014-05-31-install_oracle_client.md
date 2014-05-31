---
title: Oracle Instant Client Installer
date: 2014-05-31
tags: ruby, thor, oracle, script_executor
---
 
# Oracle Instant Client Installer - thor-based tasks for facilitating oracle client installation
 
## Introduction

Installing database driver for Oracle (activerecord-oracle_enhanced-adapter) is not a simple process.
First, you need to install Oracle Instant Client. Second, you have to install ruby wrapper around Instant Client
(ruby-oci8 gem). On some platforms second step requires compiling source code. Only after that
you can install oracle database driver. Here we discuss how to do it for OSX 10 operating system.

## Create new gem group

Create separate group (e.g. "oracle") in Gemfile for oracle ruby-oci8 client wrapper. You have to keep
this gem in separate group because it requires special steps to be done before database driver
can be installed.

```ruby
# Gemfile

group :oracle do
  gem "ruby-oci8", "2.1.7"
end
```

## Install gems for the project (except ruby-oci8 gem)

Install ruby gems for your project with bundler tool. You have to bypass oracle client wrapper installation:

```bash
bundle install --without=oracle
```

**without** parameter will exclude **oracle** bundler group from the execution.

Check that you don't have ruby-oci8 installed yet:

```bash
gem list
```

## Download Oracle Instant Client

Download Oracle Instant Client packages and save them locally (e.g. in "downloads" folder). You can find
installation packages on **www.oracle.com** web site (you have to be registered user though).

## Configuration file

Create configuration file for the installation (.oracle\_client\_installer.json) in the root of your project.
It will define where you have downloaded files and some other parameters:

```json
{
  "user": "ENV['USER']",
  "home": "ENV['HOME']",
  "ruby_home": "ENV['MY_RUBY_HOME']",

  "oracle_base": "/usr/local/oracle",
  "oracle_version": "11.2.0.4.0",
  "ruby_oci_version": "2.1.7",
  "tns_admin_dir": "#{oracle_base}/network/admin",

  "src_dir": "downloads",
  "dest_dir": "#{oracle_base}/instantclient_11_2",

  "basic_zip": "#{src_dir}/instantclient-basic-macos.x64-#{oracle_version}.zip",
  "sdk_zip": "#{src_dir}/instantclient-sdk-macos.x64-#{oracle_version}.zip",
  "sqlplus_zip": "#{src_dir}/instantclient-sqlplus-macos.x64-#{oracle_version}.zip"
}
```

We are going to run ruby from **ruby_home** on behalf of the **user** and we will use specific versions
of **oracle** client and **ruby-oci8** gem. We also specify where to look for installation packages (src\_dir)
and where to install Instant Client (dest\_dir). Also, as you can see, we are using **macos** as a platform
and **x64** as an architecture.

## Provide execution script

Library itself if written in ruby, but for launching it's code you have to use **rake** or **thor**. I provide
thor script here as an example:

```ruby
require 'thor'
require 'oracle_client_installer'

class OracleClient < Thor
  def initialize *params
    @installer = OracleClientInstaller.new ".oracle_client_installer.json"

    super *params
  end

  desc "install", "Installs Oracle Instant Client"
  def install
    @installer.install
  end

  desc "uninstall", "Uninstalls Oracle Instant Client"
  def uninstall
    @installer.uninstall
  end

  desc "verify", "Verifies Oracle Instant Client connection"
  def verify
    username = "scott"
    password = "tiger"
    schema   = "ORCL"
    sql      = "SELECT * FROM emp where rownum <= 10"

    @installer.verify do
      "require 'oci8'; OCI8.new('#{username}','#{password}','#{schema}').exec('#{sql}') do |r| puts r.join(','); end"
    end
  end

end
```

## Install Oracle Instant Client

Run this **thor** command:

```bash
thor oracle_client:install
```

After execution all Instant Client packages (basic, sdk and sqlplus) will be installed at the right location
(dest\_dir) on your computer.

## Again: install gems for the project (now with ruby-oci8 gem)

Remove .bundle folder in order to include "oracle" group into bundle execution and
then run bundler with "oracle" group:

```bash
rm -rf .bundle

bundle
```

## Verify the installation

If you have Oracle installed locally with **scott/tiger/ORCL**, you can test it now:

```bash
thor oracle_client:verify
```

If you have oracle installed somewhere on the network, you can add TNS names inside your
**tnsnames.ora** file located inside **/usr/local/oracle/network/admin** folder. You can set up
this location via **tns\_admin\_dir** property inside your configuration file.

tnsnames.ora file will have this section:

```
MY_ORCL=
	(DESCRIPTION=
		(ADDRESS=
			(PROTOCOL=TCP)
			(HOST=db.your_host.com)
			(PORT=1521)
		)
		(CONNECT_DATA=
			(SID=MY_ORCL)
		)
	)
```

where you define **MY\_ORCL** schema on **db.your\_host.com** running on port **1521**.

In order to use oracle driver inside rails application, you have to include it into your Gemfile:

```ruby
# Gemfile

group :oracle do
  ...
  gem 'activerecord-oracle_enhanced-adapter', '1.5.3'
end
```

# Summary: all steps all together

```bash
bundle install --without=oracle

thor oracle_client:install

rm -rf .bundle

bundle

thor oracle_client:verify
```
