---
title: Creating executable web applications with Ruby
date: 2013-09-28
tags: ruby, sinatra, vegas, launchy
---

# Creating executable web applications with Ruby

[Vegas gem] (http://code.quirkey.com/vegas)
[Launchy gem] (https://github.com/copiousfreetime/launchy)
[mvn-plugin-config gem] (https://github.com/shvets/mvn-plugin-config)


https://github.com/oguzbilgic/garaj/tree/master/lib/garaj


What

Vegas aims to solve the simple problem of creating executable versions of Sinatra/Rack apps.
Why

I have a vision of a future where all us developers release gems with simple local web interfaces powered by Sinatra.
I see Vegas as a little shove and an easy first step in making this vision come true.

I presented about “Sinatra: The Framework Within” at GoGaRuCo 2009: Check out the full video.

Usage

Currently, vegas contains a single class Vegas::Runner that provides a wrapper for a Sinatra app to easily make it into an executable bin.

Lets say you have a Sinatra app that looks like:

# /my_app.rb
require 'rubygems'
require 'sinatra/base'

class MyApp < Sinatra::Base

  get '/' do
    "This is my app"
  end

end

You can turn this into a simple binary:

  #!/usr/bin/env ruby
  # /myapp

  require File.expand_path(File.dirname(__FILE__) + 'myapp.rb')
  require 'vegas'

  Vegas::Runner.new(MyApp, 'my_app')

Now if you run ./my_app it should:

    find an appropriate rack handler (thin. mongrel)
    find an available port
    launch the app in a browser
    put itself in the background
    write a .pid and a .url file

Running it with -h or --help will print a list of available command line options. You can even add options specific to your app by using a block.

Vegas::Runner.new(AppClass, 'app_name') do |runner, opts, app|
  # runner is the instance of Vegas::Runner
  # opts is an option parser object
  # app is your app class
end

As of version 0.0.3, Vegas::Runner and its daemon-ization is fully compatible with Windows.
Rack Apps

Vegas (> v0.1.0) is not dependent on Sinatra. Vegas works almost exactly the same for general Rack Applications. For example, this will work as expected:

#!/usr/bin/env ruby

require 'vegas'

app = Proc.new {|env|
  [200, {'Content-Type' => 'text/plain'}, ["This is an app. #{env.inspect}"]]
}

Vegas::Runner.new(app, 'rack_app')


> bin/mvn-plugin-config -h
Usage: bin/mvn-plugin-config [options]

Vegas options:
  -K, --kill               kill the running process and exit
  -S, --status             display the current running PID and URL then quit
  -s, --server SERVER      serve using SERVER (thin/mongrel/webrick)
  -o, --host HOST          listen on HOST (default: 0.0.0.0)
  -p, --port PORT          use PORT (default: 5678)
  -x, --no-proxy           ignore env proxy settings (e.g. http_proxy)
  -e, --env ENVIRONMENT    use ENVIRONMENT for defaults (default: development)
  -F, --foreground         don't daemonize, run in the foreground
  -L, --no-launch          don't launch the browser
  -d, --debug              raise the log level to :debug (default: :info)
      --app-dir APP_DIR    set the app dir where files are stored (default: ~/.vegas/mvn_plugin_config)/)
  -P, --pid-file PID_FILE  set the path to the pid file (default: app_dir/mvn_plugin_config.pid)
      --log-file LOG_FILE  set the path to the log file (default: app_dir/mvn_plugin_config.log)
      --url-file URL_FILE  set the path to the URL file (default: app_dir/mvn_plugin_config.url)





DESCRIPTION

Launchy is helper class for launching cross-platform applications in a fire and forget manner.

There are application concepts (browser, email client, etc) that are common across all platforms, and they may be launched differently on each platform. Launchy is here to make a common approach to launching external application from within ruby programs.
FEATURES

Currently only launching a browser is supported.
SYNOPSIS

You can use launchy on the commandline, or via its API.
Commandline

% launchy http://www.ruby-lang.org/

There are additional commandline options, use launchy --help to see them.
Public API

In the vein of Semantic Versioning, this is the sole supported public API.

Launchy.open( uri, options = {} ) { |exception| }

At the moment, the only available options are:

:debug        Turn on debugging output
:application  Explicitly state what application class is going to be used
:host_os      Explicitly state what host operating system to pretend to be
:ruby_engine  Explicitly state what ruby engine to pretend to be under
:dry_run      Do nothing and print the command that would be executed on $stdout

If Launchy.open is invoked with a block, then no exception will be thrown, and the block will be called with the parameters passed to #open along with the exception that was raised.
An example of using the public API:

Launchy.open( "http://www.ruby-lang.org" )

An example of using the public API and using the error block:

uri = "http://www.ruby-lang.org"
Launchy.open( uri ) do |exception|
  puts "Attempted to open #{uri} and failed because #{exception}"
end


#require 'launchy'

#Launchy.open("http://localhost:9292")



require 'sinatra'
require "slim"

get "/" do
  slim :index
end

__END__

@@layout
doctype html
html
head
meta charset="utf8"
title Test
body
== yield

@@index
h1 index



