!SLIDE title-slide

# Boosting QA productivity:
# <span style="color:green">Automating acceptance tests</span>

* Author: **Alexander Shvets**
* Role: **Developer**
* Date: **October, 2014**


!SLIDE title-and-content transition=cover incremental

# Goals for presentation

* Explain the value of acceptance scripts for setting up common language between all party members:
**Developers**, **Testers**, **Business Analysts** and **Business Owners**.
* Build acceptance framework for **reducing cost** of manual acceptance testing and eventually
**eliminate manual testing** completely.
* Explain **architectural and technological** decisions for proposed acceptance framework.


!SLIDE title-and-image transition=cover

# Brown rice salad with pickled turnip, baby cucumber and smoked labneh

![turnip_salad](images/turnip_salad.jpg)


!SLIDE title-and-content incremental transition=cover

# Why do we need tests?

* to have an automated way to check if code is doing what it supposed to do (verify it's correctness).
* to have an example of how to use code.

* Note: You have to follow formatting rules
[best practices](http://blog.plataformatec.com.br/2014/04/improve-your-test-readability-using-the-xunit-structure) for tests.


!SLIDE title-and-content incremental transition=cover

# Acceptance Tests

* They try to answer the question: <span style="color:red">Does the whole system work?</span>

* They created to **mirror the user stories**.

* They utilize **user behavior simulation** approach by imitating human interactions with web applications.

* They easily understood by **stakeholders**, **business analysts**, **testers**, and **developers**.

* Writing **acceptance tests** tells us something about **how well we understand the domain**,
but they **don’t tell us how well we’ve written the code**.

* Running **acceptance tests** tells us about the **External Quality** of our system.


!SLIDE title-and-content incremental transition=cover

# Automated Acceptance Tests: Why it matters?

* It's **not possible or extremely expensive** to manually test each feature of your application.

* Making testing automated will **save a lot of time/money** for the company.

* In case of **adding new functionality** you want to know whether it breaks existing flow or not.
Unit or integration tests do not know about new functionality and cannot fail on it yet.

!SLIDE title-and-content transition=cover incremental

# Given-When-Then triad: BDD Concept

* With BDD we are trying to understand what **an object does**, not **what an object is** (TDD).

* Why is that important? To verify that behavior **did not change**.

* If you change **internals only** (implementation) without changing **interface** (behavior):
  * test that depends on internals will fail;
  * test that depends on behavior - will not fail.

* BDD introduces the language we use to describe testing scenarios based on **Given**, **When**, **Then** words.

* <span style="color:magenta">Given some context,<span> <span style="color:blue">When some event occurs,</span> <span style="color:green">Then I expect some outcome.</span>

* <span style="color:magenta">Given I have potato,<span> <span style="color:blue">When I cook it,</span> <span style="color:green">Then I can eat it.</span>


!SLIDE title-and-content transition=cover incremental

# Consequences of using TDD/BDD

* You think about **problem first**, before you write any line of code.

* Testing is **no longer** just about keeping defects from the users; instead, it’s about helping
the team **to understand the features** that the users need and to deliver those features reliably
and predictably.

* Tests require **fair amount of efforts** to maintain/upgrade them.

* After applying TDD/BDD technics iteratively, your system will have more **modular architecture**,
well-defined components with **published interfaces**.

* Instead of running **full-fledged application server with web application** you can run isolated test only.
Thus, you can concentrate on one aspect of your code - reducing time spend for implementation or bug fix.


!SLIDE title-and-content transition=cover incremental

# Testing Framework: Main components

* [RSpec](rspec) - testing framework.
* [Capybara](capybara) - DSL for writing acceptance tests.
* [Gherkin](gherkin) - parser of simplified plain English.
* [Cucumber](cucumber) - tool for running Gherkin scripts.
* [Turnip](turnip) - tool for running Gherkin scripts within RSpec.
* [TurnipFormatter](turnip_formatter) - a pretty custom formatter for Turnip.
* [Gnawrnip](gnawrnip) - TurnipFormatter add-on that can build animated screen shots in case of problem with script.

All of them are ruby gems.

!SLIDE title-and-content transition=cover incremental

# RSpec

* **Domain Specific Language** for describing tests.

* It uses such language words as:

  * **describe**
  * **it (example)**
  * **expect**
  * **mock**

* it also could be used as a launcher for another types of scripts.


!SLIDE title-and-content transition=cover incremental

# Capybara

* Domain Specific Language for describing **acceptance tests**.

* **Simulates real user interactions** with web application.

* Provides **higher level API** to user interaction. You can have or write drivers that fit into this API.
Examples: **selenium**, **webkit** or **poltergeist** driver.

* Provides **auto-waiting** feature - powerful synchronization for asynchronous processes, like AJAX.

* It could be used inside both **rspec** and **cucumber**.


!SLIDE title-and-content transition=cover incremental

# Cucumber

* **Domain Specific Language** for describing acceptance tests.

* it uses **Gherkin** language (simplified plain English) for test description.

* Tests are written in terms of **features**.

* Each feature consists of one or more **scenarios**.

* Each scenario consists of one or more **steps**.

* Each step uses **Given**, **When**, **Then**, **And** and **But** words for describing what needs to be done.

* Can be used for **all types of tests**, not only for acceptance tests.

* Can be used for **other languages** like Java, C# or Python. You use ruby directly or search for Cucumber
adapted for a given language.


!SLIDE title-and-content transition=cover incremental

# Turnip

* Gherkin extension for RSpec.

* All features from Cucumber are available in Turnip.

* Tries to solve the following Cucumber problems:
  * Having a separate test framework and separate launcher is annoying.
  * Mapping steps to regexps is hard.
  * Cucumber has a huge, messy codebase.
  * Steps are always global.


!SLIDE title-and-content transition=cover incremental

# Turnip features

* Integrates directly into your RSpec test suite.
* Features and Step definitions live in the **spec** directory.
* No need to maintain two configuration files (for rspec and cucumber).
* Uses Ruby style symbols instead of regular expressions in step definitions.
* No need to write Given/When/Then in the step definitions file (steps only).
* Speed boost when running unit tests and integration tests together.


!SLIDE title-and-content transition=cover

# Example: Acceptance script for Neptune Desktop Subscribe

    ``` cucumber
    Feature: Subscribe to Vonage phone service through Neptune Desktop Application
    In order to subscribe to Vonage phone service
    As a user
    I want to fill in an order and submit

    Background: within Selected Environment context
      Given I am within Selected Environment

    @selenium
    Scenario: Typical Direct Flow
      When I visit "Neptune Desktop Application"
      Then I should be on "Account" page
      And I should see summary popup page

      When I enter Contact Info
      And I enter Service Address
      And I click "Proceed to Next Step" button
      Then I should be on "Payment" page

      When I enter Credit Card Info
      And I click "Proceed to Next Step" button
      Then I should be on "Summary" page
    ```


!SLIDE title-and-content transition=cover

# Example: Acceptance script for Neptune Desktop Subscribe (continued)

    ``` cucumber
    When I accept Terms of Service
    And I click "Proceed to Next Step" button
    Then I should be on "Confirmation" page

    When I setup account
    And I want to save intermediate results
    And I click "Submit" button
    Then I should be on Online Account page

    When I visit "Neptune Desktop Application" on "Confirmation" page
    Then I should be on "Confirmation" page
    And "Confirmation" page is hiding account form
    ```

!SLIDE title-and-content transition=cover

# Steps example

    ``` ruby
    steps_for :neptune_desktop_direct do
        include CommonSteps

        attr_reader :flow

        step "I am within Selected Environment" do
          @flow = Neptune::Desktop::DirectFlow.new(page)
        end

        step "I visit :name" do |name|
          flow.visit_page "/gulp-index-desktop.html"
          FlowHelper.instance.wait_for_spinner page
        end

        step "I visit :name on :suffix page" do |_, suffix|
          flow.visit_page "/gulp-index-desktop.html#/#{suffix.downcase}"
          FlowHelper.instance.wait_for_spinner page
        end

        step "I should be on :name page" do |name|
          expect(page.current_url).to match %r{/#{name.downcase}}
        end

        step "I should see summary popup page" do
          expect(page).to have_content
           'An Order Confirmation email will be sent to your email address'
        end

        step "I enter Contact Info" do
          flow.enter_contact_info
        end
    ```

!SLIDE title-and-content transition=cover

# Steps example (continued)

    ``` ruby
        step "I enter Service Address" do
          flow.enter_emergency_address
        end

        step "I click :name button" do |name|
          if name == 'Submit'
            flow.submit_ola_form
            FlowHelper.instance.wait_for_spinner page
          else
            flow.click_button '.next'
          end
        end

        step "I enter Credit Card Info" do
          flow.enter_credit_card_info
        end

        step "I accept Terms of Service" do
          flow.accept_terms_of_service
        end

        step "I setup account" do
          flow.setup_account
        end

        step "I should be on Online Account page" do
          expect(page).to have_content 'Sign in to your Vonage Account'
        end

        step ":page page is hiding account form" do |_|
          expect(page).to have_content 'You will receive an order confirmation email within 2 days'
        end
      end
    ```

!SLIDE title-and-content transition=cover

# How to run

You can run existing test with command:

    ``` sh
    rspec -r turnip/rspec spec/features/direct_flow.feature

    ```

!SLIDE title-and-content transition=cover incremental

# Testing Framework Design

* **Page** - represents whole web page or part of it (contact page, account page or order page). It has all
related to this page calls to core acceptance framework like selenium, webkit or capybara.

* **PageSet** - group of pages. All calls to pageset will be delegated to pages that are included into this pageset.

* **Flow** - concrete instance of pageset to represent actual collections of web interactions to be done
(direct, retail flow etc.).

* Each flow has **steps** (implemented as turnip steps).

* Each flow is represented with **feature** file that is aware of corresponding steps.


!SLIDE title-and-content transition=cover

# Implementation Requirements and Details (1)

Framework should be able to run against different **environments** and **drivers**.

It can read external configuration file (e.g. acceptance_config/neptune-development.yml):

    ``` ruby
    webapp_url: 'http://www.wikipedia.org'
    selenium_url: 'http://localhost:4444'
    screenshot_dir: 'tmp'
    browser: 'chrome'
    timeout_in_seconds: 40
    ```

Name of configuration file consists of 2 parts: application name and then environment name. For example:
**neptune-ci.yml** for Neptune application running in CI environment.

We can override environment, wait time and driver with **ACCEPTANCE_ENV**, **WAIT_TIME** and **DRIVER**
env variables.

We run selenium server in standalone mode - that lets us build infrastructure when we have remote selenium
server under different OS: MacOS, Windows, Unix.



!SLIDE title-and-content transition=cover

# Implementation Requirements and Details (2)

Tester should be able to do screen shots at any time:

    ``` cucumber
    And I generate screenshot
    ```

File will be saved into **screenshot_dir** folder.

Framework should maintain saving intermediate results, like user name, passwords etc:

    ``` cucumber
    And then I want to save intermediate results
    ```

Result is saved inside **acceptance_results** folder.


!SLIDE title-and-content transition=cover

# Implementation Requirements and Details (3)

Framework should be able to read input data from external file (xls or csv).

Say, we have data in acceptance_data/neptune.yml

  ```ruby
  test1:
    name1: "value11"
    name2: "value12"
    name3: "value13"
  test2:
    name1: "value21"
    name2: "value22"
    name3: "value23"
    ```

Now we can read data for **test1** in acceptance test:

    ``` cucumber
    And I pick a "test1" test
    ````

and use it inside step implementations:

    ```ruby
    step "I pick a :arg test" do |arg|
        result = flow.data[arg]

        puts result
    end
    ```

!SLIDE title-and-content transition=cover

# Implementation Requirements and Details (4)

Framework should be able to run scripts for different input parameters. For example, retail flow in Subscribe could
be initiated with different mac address.

Unfortunately, Cucumber as language does not support loops.

You can only use Scenario Outline with embedded data.

    ``` cucumber

    Scenario Outline: Typical Retail Flow
      When I visit Triton retail landing page

      When I select Mac Address <mac_address>
      Then I should see "Congratulations, your MAC address has been verified!"
      And I should see "Select one of our most popular plans"

      When I select Retail Plan
      And I pick a new phone number
      And I click "Continue"
      Then I should see "Enter your contact information"

      When I enter Contact Info
      Then I should see "Set up your 911 address"

    Examples:
      | mac_address  |
      | AAAAAAAAAAAA |
      | BBBBBBBBBBBB |

    ````

!SLIDE title-and-content transition=cover

# Implementation Requirements and Details (4)

Framework handles this problem with programming trick, letting us to define data in the following way:

    ``` cucumber

    Scenario Outline: Typical Retail Flow
      When I visit Triton retail landing page

    ...

    Examples:
      | mac_address  |
      | file:spec/support/acceptance_data/proteus.xlsx |

    ```

!SLIDE title-and-content transition=cover

# Example: Acceptance Report

Visit [Proteus Jenkins CI](http://10.111.74.178:8080/job/trunk-proteus-acceptance-specs) to see results.


!SLIDE title-and-content transition=cover

# Links

* [Formatting Tests - http://blog.plataformatec.com.br/2014/04/improve-your-test-readability-using-the-xunit-structure]
(http://blog.plataformatec.com.br/2014/04/improve-your-test-readability-using-the-xunit-structure)
* [RSpec Home - http://rspec.info](http://rspec.info)
* [Capybara Home - https://github.com/jnicklas/capybara](https://github.com/jnicklas/capybara)
* [Gherkin Home - https://github.com/cucumber/gherkin](https://github.com/cucumber/gherkin)
* [Cucumber Home - https://github.com/cucumber/cucumber](https://github.com/cucumber/cucumber)
* [Turnip Home - https://github.com/jnicklas/turnip](https://github.com/jnicklas/turnip)
* [Tasty Turnip Article - http://robots.thoughtbot.com/turnip-a-tasty-cucumber-alternative](http://robots.thoughtbot.com/turnip-a-tasty-cucumber-alternative)
* [Turnip Formatter - https://github.com/gongo/turnip_formatter](https://github.com/gongo/turnip_formatter)
* [Gnawrnip (Turnip Formatter extension) - https://github.com/gongo/gnawrnip](https://github.com/gongo/gnawrnip)


!SLIDE title-and-content transition=cover

# Thank You!
# Hola!
# Спасибо!
# 谢谢!
# Toda!

# Questions?
# Suggestions?


[formatting_tests]: http://blog.plataformatec.com.br/2014/04/improve-your-test-readability-using-the-xunit-structure
[rspec]: http://rspec.info
[capybara]: https://github.com/jnicklas/capybara
[gherkin]: https://github.com/cucumber/gherkin
[cucumber]: https://github.com/cucumber/cucumber
[turnip]: https://github.com/jnicklas/turnip
[tasty_turnip]: http://robots.thoughtbot.com/turnip-a-tasty-cucumber-alternative
[turnip_formatter]: https://github.com/gongo/turnip_formatter
[gnawrnip]: https://github.com/gongo/gnawrnip
