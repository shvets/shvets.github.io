---
title: Using Node.js and Karma Framework for Unit Tests and Code Coverage in Javascript
date: 2013-09-14
tags: nodejs, javascript, karma, code coverage
---

# Using Node.js and Karma Framework for Unit Tests and Code Coverage in Javascript

Your web project, whether it's written in Java, Python or Ruby, has Javascript files that
support front-end part of it. And unit tests and code coverage for them are two most
**uncovered** areas, **terra incognito** of Javascript world.

New technologies, such as **Node.js**, can help you to **cover** it. Node.js is server-side technology, but
we don't plan to change the way we use Javascript in today's projects, we just use Node.js as complimentary
tool for packages delivery and execution of code, that is located outside of your project,
such as unit-test runner or coverage runner.

Because this technology is orthogonal to your project, it can be used in virtually any project,
whether it's PHP, Java, Ruby or C#, as long as they have Javascript.

Writing unit tests and generating code coverage is superior to your project, because having unit tests
**increases quality** of code and code coverage report provides **awareness** and **better control**
of what is going on with the project.

## Node.js: what it is?

* It was created by **Ryan Dahl** in 2009.

* It is **scripting language** - no compilation required, convenient for writing automation scripts. It uses
Google Chrome v8 Javascript engine.

* It is Javascript that's **freed from the browser's chains** - it can be used from **command line** and as
part of **server-side** collection of technologies.

* It has a lot of **packages** (libraries) for easy extending existing functionality. You use **node package manager**
to deliver node packages to your computer same way as Ruby developers use RubyGems for downloading gems
(Ruby equivalent of library).

* It is **technology-in-demand**. Some companies that use it: **github.com**,  **linkedin.com**,
**vonage.com**, **ebay.com**, **microsoft.com**, **trello.com**.

* It is **new and promising technology**. See [Tessel] (http://www.dragoninnovation.com/projects/22-tessel‎) -
internet-connected microcontroller progammable in Node.js.

* A lot of hosting services already support Node.js: **Heroku**, **Joyent**, **CloudFoundry**, **OpenShift**, **Cloudnode**,
**WindowsAzure**.


## Installation

If you are on Apple computer, you can use **homebrew** tool to install it:

```bash
brew install node
```

It will install **node package manager** (npm) as well:


```bash
node -v
npm -v
```

On Windows you can download node and npm as one installation from [here] (http://nodejs.org/download).


## Using Node.js: Webserver example

Let's demonstrate "hello world" program for Node.js. This simple web server responds with "Hello World" string
for every request.

```js
// hello_world.js

var http = require('http');

var server = http.createServer(function (req, res) {
  res.writeHead(200, {'Content-Type': 'text/plain'});
  res.end('Hello World\n');
});

server.listen(1337, '127.0.0.1');

console.log('Server running at http://127.0.0.1:1337/');
```

To run this code, execute it from the command line:

```bash
% node example.js

Server running at http://127.0.0.1:1337/
```

## Installing node packages

You can install node packages in two ways:

- **globally**, for all projects: usually in **/usr/local//lib/node_modules**;

- **locally**, for current project only: in **your_project_root/node_modules**;

This is the example of global installation:

```bash
npm install -g grunt-cli
```

and local installation:

```bash
npm install grunt-cli
```
In examples above we are installing **grunt** build tool.

Saving packages locally is [good practice] (http://www.futurealoof.com/posts/nodemodules-in-git.html) -
this way you will have the ability to quickly reproduce your production environment -
[dev/prod parity] (http://www.12factor.net/dev-prod-parity).

You can execute grunt command now:

```bash
cd your_project_root

node_modules/grunt-cli/bin/grunt -version
```

## Keep track of node packages used by project

You can create **package.json** file used by **npm** to keep track of project dependencies. This is
sample file:

```json
{
  "name": "your_project",
  "version": "1.0.0",
  "description": "Npm package for your_project",
  "author": "John Smith <jsmith@site.com>",
  "engines": {
    "node": ">= 0.10.16"
  },
  "dependencies": {},
  "devDependencies": {
    "grunt": "~0.4.1",
    "grunt-cli": "~0.1.9"
  }
}
```

With this file in place you can install all required dependencies (grunt, grunt-cli) in one command:

```bash
npm install
```

You can also install single package with automatic insert of package name/description into **package.json**
as development dependency:

```bash
npm install grunt-cli --save-dev
```


## Look: identical tools for different languages

If we look at different languages as frameworks, we can see that most of them have similar tools for similar needs.

For example,

* build tool:
  * Java - Ant/Maven
  * Ruby - rake/thor
  * Node - grunt

* package manager:

  * Java - ??? (maybe Maven?)
  * Ruby - gem
  * Node - npm

* dependencies resolver:

  * Java - Maven
  * Ruby - bundler
  * Node - npm

* version manager:

  * Java - no
  * Ruby - rvm
  * Node - nvm

Looks like it's becoming **de-facto standard** for contemporary popular languages to have
at least some **package delivery engine**, **dependencies resolver** and **framework version manager**.

## Karma Framework: what is it?

We use Node.js primarily as **delivery mechanism** for easy installation of packages that will help
us to build **unit tests** and generate **code coverage**. This can be done by **Karma** framework.

* It was created by **AngularJS** team.

* It's **not** unit test or coverage library - it's universal **layer built on top** of existing testing/coverage
libraries **with common configuration**.

* It's **agnostic to testing framework**: you describe your tests with Jasmine, Mocha, QUnit, or write a simple
adapter for any framework you like.

* You can plug in coverage library seamlessly.

* You can test **same code in different browsers** simultaneously.

* You can **debug** with the help of RubyMine/WebStorm IDEs, Chrome or Firefox browsers.

* You can run your tests in **headless mode** with the help of **PhantomJS** library.


## Installation

You can install karma through **npm**:

```bash
npm install karma --save-dev
```

After **karma** installation you need to create **karma configuration file**.

You can keep it in javascript:

```bash
node_modules/karma/bin/karma init karma.conf.js
```

or coffeescript:

```bash
node_modules/karma/bin/karma init karma.conf.coffee
```

Script will ask few questions and at the end **karma.conf.js** or **karma.conf.coffee** file will be created.


Now, you need to install additional packages. First, install browser launchers and preprocessors:

```bash
npm install karma-chrome-launcher --save-dev
npm install karma-firefox-launcher --save-dev
npm install karma-safari-launcher --save-dev
npm install karma-phantomjs-launcher --save-dev

npm install karma-coffee-preprocessor --save-dev
npm install karma-html2js-preprocessor --save-dev
```

Then, install support for jasmine (it's one of supported testing libraries):

```bash
npm install karma-jasmine --save-dev
```

## Revisiting Content of Karma Configuration File

Below is the typical example of karma configuration file:

```coffee
# karma.conf.coffee

module.exports = (config) ->
  config.set
    basePath: '.'

    frameworks: ['jasmine']

    files: [
      # external libraries

      process.env.GEM_HOME +
        '/gems/jquery-rails-3.0.4/vendor/assets/javascripts/jquery.js'

      # project libraries

      'app/assets/javascripts/*.js',
      'app/assets/javascripts/*.coffee',

      # specs

      {pattern: 'spec/javascripts/*_spec.js', included: true}
      {pattern: 'spec/javascripts/*_spec.coffee', included: true}
    ]

    # list of files to exclude
    exclude: []

    preprocessors:
      '**/*.coffee': ['coffee']

    reporters: ['dots']

    port: 9876

    colors: true

    logLevel: config.LOG_INFO

    autoWatch: false

    browsers: ["PhantomJS"]

    captureTimeout: 60000

    singleRun: true

    reportSlowerThan: 500
```

Let's explain some of used properties.

* **basePath** points to the root of your project

* **frameworks** describes used frameworks (we use jasmine only)

* **files** should include
 * original javascript code to be tested
 * dependent external libraries
 * specs
 * fixtures (if yop plan to use them)

* **preprocessors** describe different actions/filters. Some of them:
  - how to process coffescript files (coffee);
  - how to build fixtures (html2js);
  - what files to include into code coverage (coverage);

* **reporters** define usage of "dots" reporter

* **browsers** describe in which browsers code should be tested. We use **PhantomJS** for headless tests

* **singleRun**: true is useful for running in CI server


## Using Karma

You can start karma with this command:

```bash
node_modules/karma/bin/karma start
```

This command will run all specs in **spec/javascripts** folder and output results to console.

```bash
INFO [karma]: Karma v0.10.2 server started at http://localhost:9876/
INFO [launcher]: Starting browser PhantomJS
INFO [PhantomJS 1.9.1 (Mac OS X)]: Connected on socket _juBSCUpZSBdU1wA-URx
...............................................
PhantomJS 1.9.1 (Mac OS X): Executed 47 of 47 SUCCESS (0.167 secs / 0.027 secs)
```

## Code Coverage with Karma

For generating code coverage report you have to install **karma-coverage** package:

```bash
npm install karma-coverage --save-dev
```

You also have to register your javascript or coffeescript files with **coverage** preprocessor,
add **coverage** reporter to the list of reporters and create **coverageReporter** section:

```coffee
# karma.conf.coffee
module.exports = (config) ->
  config.set
    ...

    preprocessors:
      'app/assets/javascripts/**/*.js': ['coverage']
      'app/assets/javascripts/**/*.coffee': ['coverage']

    reporters: ['dots', 'coverage']

    coverageReporter:
      type: 'html'
      dir: 'coverage'
    ...
```

**coverageReporter** section describes configuration of "coverage" reporter: type of report and location of it.

Now, when you run karma again

```bash
node_modules/karma/bin/karma start
```

it will create coverage report inside **coverage** directory. Open it:

```bash
open coverage/PhantomJS\ 1.9.1\ \(Mac\ OS\ X\)/
 ```

## Using fixture for your specs

If you plan to use fixtures inside your specs, you have to do these steps.

* Create fixture file in **fixtures** folder:

```html
<!-- spec/javascripts/fixtures/template.html -->
<div>something</div>
```

* Add fixtures location to **files** sections and specify **html2js** preprocessor for
html files inside **fixtures** directory:

```coffee
# karma.conf.coffee
module.exports = (config) ->
  config.set
    ...

    files: [
      ...
      'spec/javascripts/fixtures/**/*.html'
    ]

    preprocessors:
      'spec/javascripts/fixtures/**/*.html': ['html2js']

    ...
```

* Access **fixture** from the spec through global **window.\_\_html\_\_** variable:

```coffee
# spec/javascripts/some_coffee_spec.coffee
describe 'some_coffee_code', ->
  fixture = undefined

  beforeEach ->
    window.__html__ = window.__html__ || {};
    fixture = window.__html__['spec/javascripts/fixtures/template.html']

  it 'access div element', ->
    el = $(fixture).find('#div')
    expect(el).toBeDefined()
```
