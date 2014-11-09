---
title: Creating configuration files for Ruby programs
date: 2014-11-09
tags: ruby, config, json, yaml, nokogiri
---

# Creating configuration files for Ruby programs

## Introduction

There are different ways to keep configuration information outside of ruby program. You can use .ini, .xml, .properties, .json, .yml formats to achieve it. 

There are some issues with this approach though. In case when you need to evaluate one property based on value of another property, it could be very difficult or almost impossible.

Let's show some examples of external configuration. In **xml format** it could look this way:

```xml
<?xml version="1.0" encoding="UTF-8"?>

<properties>
  <property name="property1" value="value1"/>
  <property>
    <name>property2</name>
    <value>value2</value>
  </property>

  <property name="property3" value="#{property1}123"/>
</properties>
```

Question: how to implement reference to another property, e.g. **properties.property1** for **properties.property3**?

Another example in **json format**:

```json
{
  "property1": "value1",

  "property2": {
    "property21": "value21"
  },

  "property3": "#{property1}/123"
}
```

We can same question here.

Let's take a look at possible solutions.

## Using text interpolation

You can use some form of text interpolation to substitute such values based on the knowledge of the context. Look at [text_interpolator gem] [text_interpolator] and [article][text_interpolator_article] about how to use this gem  for further details. In short, it uses simple ruby trick:

```ruby
env = {var1: 'some value 1', var2: 'some value 2'}

template = "We have var1: %{var1} and var2: %{var2}."

result = template % env

puts result # We have var1: some value 1 and var2: some value 2.
```

With this technick you can use multi-level properties, e.g.:

```json
{
  "tomcat": {
    "home": "/usr/local/Cellar/tomcat7/7.0.56/libexec",
    "deploy_dir": "#{tomcat.home}/webapps"
  },

  "jboss": {
    "home": "/usr/local/Cellar/jboss-as5/5.1.0GA/libexec",
    "deploy_dir": "#{jboss.home}/server/default/deploy"
  }
```

## Using ruby language for describing configuration

Another idea is to use Ruby fragment (piece of code) to represent the configuration. In such a way you don't have to **a)** invent yet another language to represent configuration and **b)** you can use language's expressiveness to have text interpolation at the moment  when you really need it. For example:

```ruby
# .test_config

rails_env = "production"

ant_home = ENV['ANT_HOME'] || "#{ENV['HOME']}/apache-ant-1.8.3"
project_name = "web_app_builder_test"
gems_to_reject = %w(bundler)

groups_to_reject = %w(test)
groups_to_reject << 'development' unless %w(development staging).include? rails_env.to_sym

author = "Alexander Shvets"

templates_dir = "config/templates"
```

You can read this file and then convert it to hash with the help of ruby **eval** method. Complete
code is implemented as part of [meta_methods][meta_methods] gem:

```ruby
require 'meta_methods'

content = File.read(".test_config")

hash = MetaMethods::Core.instance.block_to_hash content
```

## Conclusion

All technics described above are implemented as separate [config-file] [config-file] gem. You can use it to read from 3 most popular formats.

- from yaml:

```ruby
require 'config_file'

config_file = ConfigFile.new

config = config_file.load "spec/config/test_config.yaml"
puts config
```

- from json:

```ruby
config = config_file.load "spec/config/test_config.json"

puts config
```

- from ruby:

```ruby
config = config_file.load "spec/config/.test_config", ".rb"

puts config
```
or register your own configuration format:

```ruby
require 'nokogiri'
require 'active_support/core_ext/hash'

require 'config_file/config_file'

class ConfigType
  class Xml
    ConfigFile.register(self)

    def self.extensions
      [".xml"]
    end

    def read file_name
      doc = Nokogiri::XML(File.read(file_name))
      
      HashWithIndifferentAccess.new Hash.from_xml(doc.to_s)
    end
  end
end
```
and then use it:

```ruby
config_file = ConfigFile.new

config = config_file.load "spec/config/test_config.xml"
puts config
```

[text_interpolator]: https://github.com/shvets/text-interpolator
[text_interpolator_article]: http://shvets.github.io/blog/2014/05/17/text_interpolator.html
[meta_methods]: https://github.com/shvets/meta_methods
[config-file]: https://github.com/shvets/config-file
