# Using Gemfile gems inside .gemspec file

## Introduction

If you have a (or plan to create new) gem, the chance is that you also have **Gemfile** inside your project.
Here we have old and new approaches to describe dependencies of your gem. They don't coexist well
with each other and you have to do additional steps in order to let them work together.

According to [bundler gem help](http://bundler.io/v1.3/rubygems.html), all you have to do is to create simple **Gemfile**
with only one instruction (gemspec):

```ruby
# Gemfile

gemspec
```

This instruction will look into corresponding **.gemspec** file (you should have it as part of your gem project).
It will create **default** and **development** groups and fill them out according to usage of **add\_runtime\_dependency**
and **add\_development\_dependency** calls.

So, if you have the following **my_gem.gemspec** file:

```ruby
# my_gem.gemspec

spec.add_runtime_dependency "haml", [">= 0"]
spec.add_runtime_dependency "sass", [">= 0"]

spec.add_development_dependency "gemcutter", [">= 0"]
```

it will dynamically build something like this:

```ruby
# Gemfile

group :default do
  gem "haml"
  gem "sass"
end

group :development do
  gem "gemcutter"
end
```

This approach has on drawback though - you have to think in terms of .gemspec file, which is counter-intuitive.

I propose to do it [other way around](https://github.com/shvets/gemspec_deps_gen). We keep all the dependencies in
Gemfile as we would do for **any other ruby project**. We also keep gemspec file as **ERB template**, so we can generate
resulting gemspec when we need it or as part of gem release process.


## Installation

Add this line to to your Gemfile:

```ruby
gem "gemspec_deps_gen"
```

And then execute it:

```bash
bundle
```

## Usage

Create **Gemfile** file:

```ruby
# Gemfile

group :default do
  gem "haml"
  gem "sass"
end

group :development do
  gem "gemcutter"
end
```

Create **my_gem.gemspec.erb** file:

```ruby
Gem::Specification.new do |spec|
  spec.name = "sample"
  spec.summary = %q{Summary.}
  spec.description = %q{Description.}
  spec.email = "alexander.shvets@gmail.com"
  spec.authors = ["Alexander Shvets"]
  spec.homepage = "http://github.com/shvets/sample"

  spec.files = `git ls-files`.split($\)
  spec.test_files =
    spec.files.grep(%r{^(test|spec|features)/})

  spec.version = "1.0.0"
  #<%= project_dependencies %>
end
```

You can see ERB fragment (**project_dependencies**) included inside the body of the specification.

Now, run this command:


```bash
gemspec_deps_gen my_gem
```

It will generate **my_gem.gemspec** and replace ERB fragment with dependencies from Gemfile:

```ruby
Gem::Specification.new do |spec|
  ...

  spec.add_runtime_dependency "haml", [">= 0"]
  spec.add_runtime_dependency "sass", [">= 0"]
  spec.add_development_dependency "gemcutter", [">= 0"]

end
```

As alternative, you can call it as **rake command**:

```ruby
require "gemspec_deps_gen"

project_name = 'my_gem'

task :gen do
  generator = GemspecDepsGen.new project_name

  generator.generate_dependencies "spec",
    "#{project_name}.gemspec.erb",
    "#{project_name}.gemspec"
end
```

And run it:

```bash
rake gen
```

It will also generate **my_gem.gemspec** and replace ERB fragment with dependencies from Gemfile.
