---
title: "ScriptExecutor: Ruby library for executing shell scripts, locally or on remote server"
date: 2013-12-21
tags: ruby, capistrano, chef
---

# ScriptExecutor: Ruby library for executing shell scripts, locally or on remote server

## Introduction

There are few libraries for automating deployment tasks in **remote** environment:

* [Capistrano](capistrano)
* [Chef](chef)
* [Mina](mina)
* [Vlad](vlad)

All of them tend to be too complicated, especially for relatively simple tasks. For example:

* capistrano is tailored for same set of commands executed over group of servers. If you want
to create small script for executing code on unique server, you have to "respect"
capistrano restrictions, e.g. create **Capfile**, **config/deploy.rb** etc.

* Chef is implemented as huge framework with servers and clients and only "chef-solo" is
relevant to our conversation.

* Most of these libraries are rake-centric, so it's difficult to reuse developed code in other
applications.

In most cases, deployment task can be done over **ssh protocol**. You can use [net-ssh](net-ssh) gem
as implementation - it's pure Ruby implementation of a SSH (protocol 2) client.

When you execute shell script **locally**, you have plenty of ways to do it with ruby:

1. **%x** expression:

```ruby
%x{ pwd }
```

2. backticks:

```ruby
`pwd`
```

3. **system** command:

```ruby
 system "pwd"
```

4. **exec** command:

```ruby
exec "pwd"
```

5. **spawn** command:

```ruby
spawn "pwd"
```

6. **popen** command:

```ruby
IO.popen "pwd"
```

7. using **open3** library:

```ruby
require "open3"

Open3.popen3('pwd') { |stdin, stdout, stderr| ... }

stdout, stderr, status = Open3.capture3('pwd',
  :stdin_data => stdin) # another example
```

With [script_executor](script_executor) gem we are trying to build common interface for executing
both local and remote code in unified way.


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

* Create executor

```ruby
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
executor.execute server_info.merge({:sudo => true,
  :script => "/etc/init.d/tomcat stop"})
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

* Execute remote command while capturing and suppressing output (default is 'false' for both):

```ruby
server_info.merge(:capture_output => true,
                  :suppress_output => true)

result = executor.execute server_info.merge(
  :script => "whoami")

puts result # ENV['USER']
```

* Simulate remote execution:

```ruby
server_info.merge(:simulate => true)

executor.execute server_info.merge(:script => "whoami") # generate commands without actual execution
```

## Using ScriptLocator

You can keep scripts that need to be executed, embedded into your code (as in examples above),
move them into separate file or keep them in same file behind **\_\_END\_\_** Ruby directive.
The latter gives you the ability to keep commands and code together thus simplifying
access to the code, making maintenance easier.

For example, if you want to create script with 2 commands (command1, command2), you can use
**scripts** and **evaluate\_script\_body** methods:

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

Let's build more sophisticated example. We want to automate generating public/private
keys for ssh access and copying public key to remote server for password-less access
to the server.

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
    scripts = scripts(__FILE__)

    execute { evaluate_script_body(scripts['scp_public_key'], binding) }

    execute(:remote => true, :domain => host, :user => ENV['USER']) do
      evaluate_script_body(scripts['install_key'], binding)
    end
  end
end

__END__

[gen_key]

echo "Generating ssh key..."

cd ~/.ssh
ssh-keygen

[scp_public_key]

echo "Copying public key to remote server..."

scp ~/.ssh/id_rsa.pub <%= ENV['USER'] %>@<%= host %>:~/pubkey.txt

[install_key]

mkdir -p ~/.ssh
chmod 700 .ssh
cat pubkey.txt >> ~/.ssh/authorized_keys
rm ~/pubkey.txt
chmod 600 ~/.ssh/*
```

This example has 3 scripts: **gen\_key**, **scp\_public\_key** and **install\_key**. They are self-explanatory.
Also, pay attention at using **Executable** module. It is used when we want to add ScriptExecutor functionality
as part of class.

In order to execute new commands you have to use **thor** tool:

```bash
thor ssh:gen_key
thor ssh:cp_key your.remote.server.com
```

[capistrano]: https://github.com/capistrano/capistrano
[chef]: https://github.com/opscode/chef
[mina]: https://github.com/nadarei/mina
[vlad]: https://github.com/seattlerb/vlad
[net-ssh]: https://github.com/net-ssh/net-ssh
[script_executor]: https://github.com/shvets/script_executor