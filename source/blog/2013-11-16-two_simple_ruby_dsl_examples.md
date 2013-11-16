---
title: Two simple ruby DSL examples
date: 2013-11-16
tags: ruby, dsl, zip
---

# Two simple ruby DSL examples

# Introduction

Domain Specific Languages (DSL) become quite popular in last decade. DSL could be **external**
(as a separate language) or **internal** (as a specific way to write a program within existing
programming language). In this article we are interested more in **internal DSL** because of
some advantages:

* it is a way to expose functionality in a simple, readable format.

* it is like a miniature specialized programming language within parent language.

* being written in host language, it still could use full power of parent language.

* it introduces notions that are close to the lexicon of target domain, allowing us easily express
logic specific to a particular problem.

Programming languages provide different levels of convenience/abstraction in writing DSLs. Ruby
is one of recognizable languages that lets writing DSL quite easy, because of built-in abilities
for writing DSLs based on **metaprogramming** and **first-class functions**.

**Metaprogramming** (and especially class body evaluation) let us to create **directives** that look
like they are part of the language itself. **First class functions** lets us treat methods
as parameters.

You can see other articles about DSL [here] [how to build DSL 1] and [here] [how to build DSL 2].

# Example

Let's have some simple class for building arrays:

```ruby
class Collector

  def initialize
    @array = []
  end

  def add element
    @array << element
  end

  def remove element
    @array.delete(element)
  end

  def to_a
    @array
  end
end
```

We can use this class now:

```ruby
collector = Collector.new

collector.add "1"
collector.add "2"
collector.add "3"
```

This is regular program and as any other program it's verbose. We can remove noise by applying some
metaprogramming tricks. We'll try to remove method receiver: **"collector."** from the code by making it implicit.

# Implementation

One way of doing DSL in Ruby is based on **instance_eval** method. It takes **block of code** as input parameter
and evaluates it in the **context of the calling object**:

```ruby
class DSL
  def build object, &code
    object.instance_eval &code
  end
end

dsl = DSL.new
```

Now, let's test our code with this example:

```ruby
collector = Collector.new

# one way of doing DSL with direct code block

dsl.build(collector) do
  add "1"
  add "2"
  add "3"
end

# another way of doing DSL with lambda

code = lambda do |_|
  add "4"
  add "5"
  add "6"
end

dsl.build(collector, &code)

puts collector.to_a.join(' ') # $ 1 2 3 4 5 6
```

You have to keep in mind two thing though:

* **instance_eval** changes evaluation context, so code passed for evaluation is treated as original
code of the object. As a result, all private methods and fields are available:

```ruby
dsl.build(collector) do
  puts @array # this field is accessible,
              # self is pointing to 'collector' object
  puts self   # "collector" instance
end
```
* Because of context switch, you loose access to the calling context:

```ruby
class DSL
  def dsl_method
    "dsl_method"
  end
end

dsl = DSL.new

collector = Collector.new

dsl.build(collector) do
  begin
    puts dsl_method # raises exception
  rescue
    puts "'dsl_method' not available"
  end
end
```
We cannot do anything with accessing private methods/fields, but we can make methods from calling context available.
if you provide parent context as an additional parameter, you can redirect  calls to missing object directly to
the parent (proxy object):

```ruby
module Proxy
  def subject= subject
    @subject = subject
  end

  def method_missing(name, *args, &block)
    @subject.send(name, *args, &block)
  end

  def respond_to?(method)
    @subject.respond_to?(method)
    super
  end
end
```

Here is our modified DSL class:

```ruby
class DSL
  def build object, parent, &code
    object.extend Proxy
    object.subject = parent

    object.instance_eval &code
  end
end
```

If you know that code block is coming from the parent scope, you can calculate parent
dynamically, this way you may reduce amount of input parameters:

```ruby
class DSL
  def build object, &code
    parent = code.binding.eval 'self'

    object.extend Proxy
    object.subject = parent

    object.instance_eval &code
  end
end
```

# Building something useful

Now, let's apply our knowledge to build something useful. We will try to build DSL for
building zip archive and regular directory in same fashion. The idea is to build API identical,
so you can use similar code for building zip files and for copying files.

As a result, we have 2 gems: ZipDSL and DirDSL.

# ZipDSL gem

[ZipDSL] [zip_dsl home] is library for working with zip files in DSL way.

Install new gem:

    $ gem i zip_dsl

Now you can create new archive:

```ruby
require 'zip_dsl'

zip_file = "test.zip"
from_dir = "."

zip_builder = ZipDSL.new zip_file, from_dir

zip_builder.build do
  # files from 'from_dir'
  file :name => "Gemfile"
  file :name => "Rakefile", :to_dir => "my_config"
  file :name => "spec/spec_helper.rb",
       :to_dir => "my_config"

  # create empty directory
  directory :to_dir => "my_config"

  # copy from one directory to another
  directory :from_dir => "spec", :to_dir => "my_spec"

  # create zip entry from arbitrary source:
  # string or StringIO
  content :name => "README",
          :source => "My README file content"
end
```

or update existing archive:

```ruby
zip_builder.update do
  file :name => "README.md"
  directory :from_dir => "lib"
end
```

You can also display all entries from archive's folder:

```ruby
zip_builder.list("lib/zip_dsl")
```

or display entries:

```ruby
zip_builder.each_entry("lib/zip_dsl") do |entry
  puts entry.name

  content = entry.get_input_stream.read

  puts content
end
```

When you work with zip file, you have to decide how to allocate/release resources (zip files) in order to
avoid memory leaks. One possibe solution could be using modified DSL class implementation:

```ruby
class DSL
  def build create_code, destroy_code=nil, &code
    parent_binding = code.binding
    parent = parent_binding.eval 'self'

    object = create_code.kind_of?(Proc) ? create_code.call : create_code

    object.extend Proxy
    object.subject = parent

    object.instance_eval &code
  ensure
    destroy_code.call(object) if destroy_code && object
  end
end
```

For example, we can wrap ZipInputStream in this way:

```ruby
class Reader
  include DSL

   def each_entry name, &code
    create_code = lambda {
      Zip::ZipInputStream.new("#{name}")
    }
    destroy_code = lambda {|zis| zis.close }
    execute_code = lambda do |zis|
      zis.rewind

      while (entry = zis.get_next_entry)
        next if entry.name =~ %r{\.\.}
        code.call(entry)
      end
    end

    build(create_code, destroy_code, execute_code)
   end
end
```

# DirDSL gem

[DirDSL] (dir_dsl home) is library for working with files and directories (create, copy) in DSL way.

Install it with this command:

    $ gem install dir_dsl

You can create new directory now:

```ruby
require 'dir_dsl'

from_dir = "."
to_dir = "build"

dir_builder = DirDSL.new from_dir, to_dir

dir_builder.build do
  # files from 'from_dir'
  file :name => "Gemfile"
  file :name => "Rakefile", :to_dir => "my_config"
  file :name => "spec/spec_helper.rb",
       :to_dir => "my_config"

  # create empty directory
  directory :to_dir => "my_config"

  # copy from one directory to another
  directory :from_dir => "spec",
            :to_dir => "my_spec"

  # create zip entry from arbitrary source:
  # string or StringIO
  content :name => "README",
          :source => "My README file content"
end
```

And display all entries from the folder:

```ruby
dir_builder.list("lib/zip_dsl")
```

Some other examples of DSL can be found [here] [dsl example 1], [here] [dsl example 2], [here] [dsl example 3],
[here] [dsl example 4] and [here] [dsl example 5].

[how to build DSL 1]: http://rubylearning.com/blog/2010/11/30/how-do-i-build-dsls-with-yield-and-instance_eval
[how to build DSL 2]: http://softwarebyjosh.com/2012/01/08/How-To-Write-Your-Own-DSL.html

[zip_dsl home]: https://github.com/shvets/zip_dsl
[dir_dsl home]: https://github.com/shvets/dir_dsl

[dsl example 1]: https://github.com/shvets/design_patterns_in_ruby/blob/master/meta_tricks/simple_dsl.rb
[dsl example 2]: https://github.com/shvets/design_patterns_in_ruby/blob/master/enterprise/dsl11.rb
[dsl example 3]: https://github.com/shvets/design_patterns_in_ruby/blob/master/enterprise/dsl12.rb
[dsl example 4]: https://github.com/shvets/design_patterns_in_ruby/blob/master/enterprise/dsl13.rb
[dsl example 5]: https://github.com/shvets/design_patterns_in_ruby/blob/master/enterprise/dsl2.rb

[zipit home]: https://github.com/shvets/zipit/blob/master/lib/zipit/zipit.rb


