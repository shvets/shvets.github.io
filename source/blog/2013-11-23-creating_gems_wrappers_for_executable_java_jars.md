---
title: Creating gems-wrappers for executable java jars
date: 2013-11-23
tags: ruby, java, jar
---

# Creating gems-wrappers for executable java jars

Today I want to share little trick that lets us to use ruby distribution system (**rubygems**)
as delivery mechanism for java libraries/executables. The idea was borrowed
from [redcar project] [redcar project] which in turn was borrowed/extracted from
[ruby-processing gem] [ruby-processing gem]. I am trying to extract important logic into separate
[jar_wrapper gem] [jar_wrapper gem home], so it can be easily used in any ruby project.

Install jar_wrapper with this command:

    $ gem install jar_wrapper

Now you can use it in your program directly or create gem for delivering java jar file(s).
For example, this code will upload remote file:

```ruby
require 'jar_wrapper'

wrapper = JarWrapper::Runner.new
wrapper.java_opts = ["-Xmx1024m", "-Xss1024k" ]

# install jar file from source URL into target file:

source = "http://selenium.googlecode.com/files/selenium-server-2.37.0.zip"
target = "selenium-server.zip"

wrapper.install source, target
```

You can aldo execute jar file (a.k.a. "java -jar jar_file.jar")

```ruby
wrapper.jar_file = "jar_file.jar"

wrapper.run
```

Or you can execute java jar file by specifying **main class** (a.k.a. "java -cp some_class_path main_class"):

```ruby
wrapper.classpath = "some_class_path"
wrapper.main_class = "main_class"

wrapper.run
```

If you need more details on how to use it for practical gem, visit [selenium gem] [selenium standalone server home].
This gem downloads and create launcher for standalone selenium server.


[redcar project]: https://github.com/redcar/redcar
[ruby-processing gem]: https://github.com/jashkenas/ruby-processing
[jar_wrapper gem home]: https://github.com/shvets/jar_wrapper
[selenium standalone server home]: https://github.com/shvets/selenium
