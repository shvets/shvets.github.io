---
title: Creating executable web applications with Ruby
date: 2013-09-28
tags: ruby, sinatra, vegas, launchy, lunchy
---

# Creating executable web applications with Ruby


## What is it?

Sometimes you have functionality that you want to **expose as the service** and **access it from the browser**.

One of such examples is [GemBox] [GemBox] - you run simple web server that's aware of your **gems repository**
and you can see all installed gems inside the browser.

Another example is **rubygems** running in server mode:

```bash
gem server
```

It starts server on port 8808 and lets you explore installed gems from inside the browser.

```bash
open http://localhost:8808
```

For creating executable web applications you can use at least these 2 gems:

* [Vegas gem] [Vegas gem] - let's you **daemonize** your code;
* [Launchy gem] [Launchy gem] - helps you to **open your application in the browser** when you start it.

## Using Vegas gem

[Vegas] [Vegas gem] helps to create executable version of Sinatra/Rack application.

You use **Vegas::Runner** class for wrapping such application. For example, this
is shell script for starting your favorite **sinatra** code:

```ruby
#!/usr/bin/env ruby
# bin/myapp

$:.unshift(File::join(File::dirname(
             File::dirname(__FILE__)), "lib"))

require 'vegas'
require 'myapp.rb'

Vegas::Runner.new(MyApp, 'my_app')
```

and this is your sinatra application:

```ruby
# my_app.rb

require 'sinatra/base'

class MyApp < Sinatra::Base
  get '/' do
    "Hello, world!"
  end
end
```

Now you can run it:

```bash
chmod +x bin/myapp
```

```bash
bin/myapp
```

When you wrap sinatra application with Vegas, it does the following steps:

* Starts rack application under appropriate rack handler (thin, mongrel, puma) in one of the following forms:
 - as daemon (default);
 - as standalone.
* Opens start page of your service in the  browser.

You can print a list of available command line options when running with -h or --help option:

```bash
> bin/myapp -h
Usage: bin/myapp [options]
...
```

If you don't want to create a daemon and don't want to open it in the browser, use:

```bash
bin/myapp -F -L
```

If you still use daemon and now want to stop it, use **-K** flag

```bash
bin/myapp -K
```

If you want to check status of your daemon, run this:

```bash
bin/myapp -S
```

## Using Launchy gem

[Launchy] [Launchy gem] is helper class for launching cross-platform applications in a "**fire and forget manner**".
This process is slightly different on different platforms and launchy is trying to hide this
difference.

You can use launchy on the command line, or via its API.

From command line:

```bash
launchy http://www.ruby-lang.org/
```

via API:

```ruby
require 'launchy'

Launchy.open("http://localhost:9292")
```

If you want to use launchy with your rack application, do it inside **config.ru**:

```ruby
# config.ru

$:.unshift(File::join(File::dirname(
             File::dirname(__FILE__)), "lib"))

require 'my_app'
require 'launchy'

run MyApp
Launchy.open("http://localhost:9292", :application => MyApp)

```

## Bonus: lunchy gem

If your development platform is OSX and you need to frequently start/stop **launchctl agents**, there is
a [lunchy] [lunchy gem] gem that let you to make this task extremely easy.

The burden here is that in order to start/stop/etc launchctl agents, you have to specify exact file name for that agent
as it's identifier.

When you use lunchy, you can use Ruby **regular expressions** for specifying agent's identifier and lunchy will
find correct entry.

For example, to restart postgres server you have to run this command:

```bash
launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist
```

With lunchy the tool you can shorten it:

```bash
gem install lunchy

lunchy start postgres
```

You can see the list of available agents:

```bash
lunchy ls
```

or manage particular agent:

```bash
lunchy start [agent]
lunchy stop [agent]
lunchy restart [agent]

lunchy status [agent]

lunchy show [agent]
lunchy edit [agent]
```

or install it:

```bash
lunchy install [file]
```

## Example: mvn-plugin-config gem

This [gem] [mvn-plugin-config gem] was created while I was working back on Java project. Generally speaking,
Ruby can be used as facilitator for any programming language. At that time I had to create maven project
and some of maven plugin options were undocumented.

All you have to do in this situation is to go inside jar file for given plugin and locate
**META-INF/maven/plugin.xml** file - inside you have all required information.

If you do it one time - it's OK, but if you need to do it frequently, it's good case for automation. So,
ruby gem was created to access this information in convenient way as local web server.

In order to use it first install it (keep in mind - it uses Vegas gem):

```bash
gem install mvn_plugin_config
```

and then run it as daemon:

```bash
mvn-plugin-config
```

All commands described in Vegas section are accessible here.

When you run the script, it starts server as daemon and opens start page in the browser.
On this page you can see **all discovered maven plugins**, something like this:

<img src="/assets/images/mvn_plugin_config1.png" style="width:600px; height:400px"/>

You can click on corresponding link for interested plugin and see all discovered information
on next page:

<img src="/assets/images/mvn_plugin_config2.png" style="width:600px; height:400px"/>

Look for implementation details [here] [mvn-plugin-config gem] if you are interested.

[GemBox]: https://github.com/quirkey/gembox
[Vegas gem]: http://code.quirkey.com/vegas
[Launchy gem]: https://github.com/copiousfreetime/launchy
[lunchy gem]: https://github.com/mperham/lunchy
[mvn-plugin-config gem]: https://github.com/shvets/mvn-plugin-config
