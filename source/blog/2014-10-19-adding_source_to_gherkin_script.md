---
title: Reading from external source in gherkin scripts
date: 2014-10-19
tags: ruby, acceptance tests, cucumber, gherkin, turnip
---

# Reading from external source in gherkin (cucumber) scripts

## Introduction

Gherkin is simple English-like language for representing **Given-When-Then** sequences to
support Behavior Driven Development (BDD). It is also a parser for the language itself.

Based on this simple language you can build convenient tools that make communications
between Developers, Testers, Business Analysts, Product Owners and other stakeholders **easy**.

For example, these tools use gherkin as a language for representing behavior:

* [Cucumber][Cucumber Home] is a tool for running automated tests written in plain language.

* [Turnip][Turnip: a tasty Cucumber alternative?] is a Gherkin extension for RSpec.
It allows you to write tests in Gherkin and run them through your RSpec environment so
you can write cucumber features in RSpec.

* [Spinach][Spinach Home] is a high-level BDD framework that leverages the expressive
Gherkin language to help you define executable specifications of your application or
library's acceptance criteria.

## Problem

Gherkin language lets you build simple Given-When-Then sequences and when you need
to repeat same set of sequences, you can use [Scenario Outline][Scenario Outline].
Unfortunately, Scenario Outline lets you use data defined only inside script only. It does
not have the ability to get data from external source like file or database connection.

## Solution

Below is an example of Gherkin (Cucumber) feature script with Scenario Outline:

```cucumber
Feature: Using Wikipedia

  Background: within wikipedia.com context
    Given I am within wikipedia.com

  @selenium
  Scenario Outline: Searching with selenium for a term with submit

    Given I am on wikipedia.com
    When I enter word <keyword>
    And I click submit button
    Then I should see keyword results: <keyword>

    Examples:
      | keyword  |
      | Capybara |
      | Wombat   |
      | Echidna  |
```

It reads from **Examples** section and execute script 3 times for different **\<keyword\>**.

We want to be able to externalize keywords, say in **data.csv** file:

```csv
Capybara
Wombat
Echidna
```

and then replace section with data with the path to external file.

```cucumber
Feature: Using Wikipedia

  Background: within wikipedia.com context
    Given I am within wikipedia.com

  @selenium
  Scenario Outline: Searching with selenium for a term with submit

    Given I am on wikipedia.com
    When I enter word <keyword>
    And I click submit button
    Then I should see keyword results: <keyword>

    Examples:
      | keyword |
      | file:spec/features/data.csv |
```

It is possible to do with a little ruby metaprogramming and code is available [here][gherkin ext].

The idea is to locate the code where gherkin reads that data and replace it with your code
dynamically in memory.

The code introduces hook on gherkin level, so it will work for all tools.

Below it an example how to use it:

```ruby
require 'acceptance_test/gherkin_ext'

data_reader = lambda do |source_path|
  CSV.read(File.expand_path(source_path))
end

GherkinExt.enable_external_source data_reader
```


[Cucumber Home]: https://github.com/cucumber/cucumber/tree/master
[Turnip Home]: https://github.com/jnicklas/turnip
[Spinach Home]: https://github.com/codegram/spinach
[Scenario Outline]: https://github.com/cucumber/cucumber/wiki/Scenario-Outlines
[gherkin ext]: https://github.com/shvets/acceptance_test/blob/master/lib/acceptance_test/gherkin_ext.rb
[Turnip: a tasty Cucumber alternative?]: http://robots.thoughtbot.com/turnip-a-tasty-cucumber-alternative