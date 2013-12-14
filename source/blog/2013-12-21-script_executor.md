---
title: "ScriptExecutor: Ruby library for executing shell scripts locally or on remote server"
date: 2013-12-21
tags: ruby, capistrano, chef
---

# ScriptExecutor: Ruby library for executing shell scripts locally or on remote server

## Introduction

There are few libraries for automating deployment tasks:

* [Capistrano](capistrano)
* [Chef](chef)
* [Mina](mina)
* [Vlad](vlad)

All of them tend to be too complicated, especially for relatively simple tasks. For example:

* capistrano is tailored for same set of commands for group of servers. If you want
to create small script for executing code on unique server, you have to "respect"
capistrano restrictions, e.g. create "Capfile", "config/deploy.rb" etc.

* Chef is implemented as huge framework with servers and clients and only "chef-solo" is
relevant for our goal.

* Most of them are rake-centric, so it's difficult to reuse developed code in other
applications.

In most cases deployment task can be done over ssh protocol. You can use 'net-ssh' gem
for it - it's pure Ruby implementation of an SSH (protocol 2) client.

When you execute shell script locally, you have plenty of ways to do it in ruby:

1. %x{ }

2. `` - backticks

3. system ""

4. exec ""

5. spawn ""

6. IO.popen

7. Open3


"Open3 grants you access to stdin, stdout, stderr and a thread to wait the child process when running another program. You can specify various attributes, redirections, current directory, etc., of the program as Process.spawn." Quoted from the docs
Use open3 when you have to explicitly manage all input, output, and errors.


With this gem we want to build common interface for executing whether local or remote code.


## Installation

Add this line to your application's Gemfile:

```bash
gem 'script_executor'
```
And then execute:

```bash
bundle
```

Or install it yourself as:

```bash
gem install script_executor
```

## Usage

```ruby
# Create executor
executor = ScriptExecutor.new
```

* Execute local command:

```ruby
executor.execute "ls"
```

* Execute remote command:

```ruby
server_info = {
  :remote => true,
  :domain => "some_host",
  :user => "some_user",
  :password => "some_password"
}

executor.execute server_info.merge(:script => "ls -al")
```

* Execute remote command as 'sudo':

```ruby
executor.execute server_info.merge({:sudo => true, :script => "/etc/init.d/tomcat stop"})
```

* Execute remote command with code block:

```ruby
executor.execute server_info.merge(:sudo => true) do
  %Q(
    /etc/init.d/tomcat stop
    /etc/init.d/tomcat start
  )
end
```

* Execute remote command while capturing and suppressing output (default is 'false'):

```ruby
server_info.merge(:capture_output => true, :suppress_output => true)

result = executor.execute server_info.merge(:script => "whoami")

puts result # ENV['USER']
```

* Simulate remote execution:

```ruby
server_info.merge(:simulate => true)

executor.execute server_info.merge(:script => "whoami") # generate commands without actual execution
```

## Using ScriptLocator

You can keep scripts that needs to be executed embedded into your code (as in examples above),
move them into separate file or keep them in same file behind "__END__" Ruby directive.
The latter gives you the ability to keep command and code together thus simplifying
access to code.

For example, if you want to create script with 2 commands (command1, command2), you can use
"scripts" and "evaluate_script_body" methods:

```ruby
require 'script_locator'

include ScriptLocator

puts scripts(__FILE__) # [command1, command2]

name = "john"

result = evaluate_script_body(result['command1'], binding)

puts result # john
__END__

[command1]

echo "<%= name %>"

[command2]

echo "test2"
```

Example:

```ruby
require "highline/import"
require 'script_executor/executable'
require 'script_executor/script_locator'
require 'file_utils/file_utils'

class Ssh < Thor
  include Executable, ScriptLocator, FileUtils

  desc "gen_key", "gen_key"
  def gen_key
    scripts = scripts(__FILE__)

    execute { evaluate_script_body(scripts['gen_key'], binding) }
  end

  desc "cp_key", "cp_key"
  def cp_key(host)
    ENV['USER'] = "ashvets"

    scripts = scripts(__FILE__)

    execute { evaluate_script_body(scripts['cp_key1'], binding) }

    execute(:remote => true, :domain => host, :user => ENV['USER']) do
      evaluate_script_body(scripts['cp_key2'], binding)
    end
  end
end

__END__

[gen_key]

echo "Generating ssh key..."

cd ~/.ssh
ssh-keygen

[cp_key1]

echo "Copying public key to remote server..."

scp ~/.ssh/id_rsa.pub <%= ENV['USER'] %>@<%= host %>:~/pubkey.txt

[cp_key2]

mkdir -p ~/.ssh
chmod 700 .ssh
cat pubkey.txt >> ~/.ssh/authorized_keys
rm ~/pubkey.txt
chmod 600 ~/.ssh/*

```

[capistrano]: https://github.com/capistrano/capistrano
[chef]: https://github.com/opscode/chef
[mina]: https://github.com/nadarei/mina
[vlad]: https://github.com/seattlerb/vlad