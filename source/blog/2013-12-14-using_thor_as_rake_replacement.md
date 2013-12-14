---
title: Using thor as rake replacement
date: 2013-12-14
tags: ruby, rake, thor
---

#  Using thor as rake replacement

[Thor](thor) is a ruby library for building powerful command-line interfaces. It also can be
used for writing build scripts similar to [rake](rake) scripts. Because thor tasks are implemented
as classes, it is possible to **reuse** them in **more object-oriented way**.

We want to keep different thor tasks in separate files and even in separate **thor** folder. To do
it we need to put this code into **Thorfile** within your project:

```ruby
# Thorfile

# load thor files
Dir.glob("thor/**/*.thor") do |name|
  Thor::Util.load_thorfile(name)
end
```

If you want to debug thor script, add this code to the beginning of *Thorfile*:

```ruby
# Thorfile

unless defined? Thor::Runner
  require 'bundler'

  gems = Bundler::Definition.build(Bundler.default_gemfile, Bundler.default_lockfile, nil).requested_specs

  gem = gems.find { |gem| gem.name == 'thor'}

  load "#{ENV['GEM_HOME']}/gems/#{gem.name}-#{gem.version}/bin/thor"
end

# load thor files
...
```

This code will try to load thor command as if it was started from command line. This lets us
to run **Thorfile** as a regular ruby file:

```bash
ruby Thorfile
```

As a result, all debugging abilities are available:

```bash
rdebug-ide --host 0.0.0.0 --port 1234 -- Thorfile
```

Now let's build something useful for your current project. We want to automate some
routine day-to-day tasks, like restarting postgres, initialize database, check status
of jenkins CI server etc.:


```ruby
class Utils < Thor
  desc "pg_restart", "Restarts Postgres server"
  def pg_restart

    exec %Q(
        launchctl unload -w ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist
        launchctl load -w ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist
      )
    end
  end

  desc "create_tables",
       "Creates user and all required DB tables"
  def create_tables
    exec %Q(
      createuser -s -d -r rails_user

      createdb -U rails_user rails_test
      createdb -U rails_user rails_dev
    )
  end

  desc "drop_tables",
       "Removes all required DB tables and user"
  def drop_tables
    exec %Q(
      dropdb rails_test
      dropdb rails_dev

      dropuser rails_user
    )
  end

  desc "show_jenkins",
       "Displays projects on particular jenkins server"
  def show jenkins_url
    require 'json'

    request = get_request(jenkins_url)
    response = http.request(request)

    json = JSON.parse(response.body)

    jobs = json['jobs']

    jobs.each do |job|
      status = case job['color']
        when /blue/i then
          "success"
        when /red/i then
          "failure"
        else
          "failure"
      end

      puts "#{job['name']} -- #{status}."
    end

    puts "Total: #{jobs.size} jobs."
  end

  private

  def get_request url
    uri = URI.parse(URI.escape(url))
    http = Net::HTTP.new(uri.host, uri.port)

    Net::HTTP::Get.new(uri.request_uri)
  end
end
```
Now you can run these commands:

```bash
thor -T

thor utils:pg_restart
thor utils:create_tables
thor utils:drop_tables
thor utils:show_jenkins jenkins_server.your_domain.com
```

[thor]: https://github.com/erikhuda/thor
[rake]: https://github.com/jimweirich/rake