---
title: Modularity in Javascript
date: 2013-09-21
tags: nodejs, javascript, commonjs, requirejs
---

# Modularity in Javascript

Modularity in code **increases maintainability** of the project, letting us to to break code into
**manageable parts**, **easy to read** and **easy to fix** forthcoming issues.


## Options

* Use **home-grown library** for implementing modularity

* Use **CommonJS** specification

* Use **RequireJS** framework as implementation of  CommonJS specification

* Wait for upcoming **ECMA script 6** implementation for javascript

* Use **other language** that support modules, e.g. **Dart**


## Using Anonymous Closure

You can simulate modularity in Javascript with the help of anonymous closure:

```js
(function () {
  // - all vars and functions are in this scope only
  // - still maintains access to all globals
}());
```
It creates an anonymous function and execute it immediately. All of the code inside the function lives in a closure.

Notice the **()** around the anonymous function. Including () creates a function expression instead of
function declaration. For example:

```js
var MyModule = (function() {
  var exports = {};

  //Export foo to the outside world
  exports.foo = function() {
     return "foo";
  }

  //Keep bar private
  var bar = "bar";

  //Expose interface to outside world
  return exports;
})();

MyModule.foo(); // OK
MyModule.bar(); // error
```

## Using JQuery.extend

You can use jquery's **extend** API in order to implement module:

```js
function ModularityLibrary() {}

ModularityLibrary.prototype.createClass = function(definitions, extra_definitions) {
  var klass = function() {
    this.initialize.apply(this, arguments);
  };

  jQuery.extend(klass.prototype, definitions);

  if(extra_definitions) {
    jQuery.extend(klass.prototype, extra_definitions);
  }

  return klass;
};

ModularityLibrary.prototype.extendClass = function(baseClass, methods) {
  var klass = function() {
    this.initialize.apply(this, arguments);
  };

  jQuery.extend(klass.prototype, baseClass.prototype);
  jQuery.extend(klass.prototype, methods);

  return klass;
};

var Modularity = new ModularityLibrary();
```

Now, you can use it in your code:

```js
// Create new class

var DisplayModule = Modularity.createClass({
  initialize: function () {},

  display: function(connector) {
    console.log("display");
  }
});

// Create instance of class
var displayObject = new DisplayModule();

// Call instance function
custoModule.display();
```

## Working with CommonJS

CommonJS is the **set of specifications** that define how to do modules in Javascript.

Instead of running your Javascript code from a global scope, CommonJS starts out each of your Javascript files
in their own **unique module context**.

CommonJS adds two new variables which you can use to import and export other modules:

* **module.exports** **exposes** variables to other libraries;

* **require** function helps to **import** your module into another module.

For example, javascript class and jasmine spec for it could look like this:

```js
// app/assets/javascripts/commonjs/example.js

module.exports.hello = function() {
  return 'Hello World'
};
```

```js
// spec/javascripts/commonjs/example_spec.js
var example = require('../../../app/assets/javascripts/commonjs/example');

describe('example', function() {
  it("tests CommonJS", function() {
    example.hello();
  });
});
```

You need to modify **karma.conf.coffee** file in order to **recognize** commonjs:

```coffee
# karma.conf.coffee
 module.exports = (config) ->
   config.set
     ...

     frameworks: ['jasmine', 'commonjs]

     files: [
       'app/assets/javascripts/commonjs/*.js',
       {pattern: 'spec/javascripts/commonjs/*_spec.js', included: true}
       {pattern: 'spec/javascripts/commonjs/*_spec.coffee', included: true}
     ]

     preprocessors:
       'app/assets/javascripts/commonjs/*.js': ['commonjs'],
       'spec/javascripts/commonjs/*_spec.js': ['commonjs']
       'spec/javascripts/commonjs/*_spec.coffee': ['commonjs']
     ...
```

You have toadd **commonjs** as framework and mark files that use CommonJS with **commonjs** preprocessor.

## CommonJS implementations

Because CommonJS is just specification, you cannot use it directly in the browser. Node.js has it's
own implementation and we use it withing spec, but we cannot use it on client side inside the browser.

Developers have different options to have it in browser. Some of them:

* browserify, webmake - command line tools that wraps up your CommonJS-compatible code with simple implementation
of **require** and **module.exports**.

* NodeJS - asynchronous implementation of CommonJS specification.

* [List of other solutions] (http://wiki.commonjs.org/wiki/Implementations)


## Working with RequireJS

RequireJS uses another module format: Asynchronous Module Definition (AMD), originally created as part of
the Dojo web framework.

Compared to CommonJS, the main differences of AMD are:

* Special syntax for specifying module imports - **define** - must be done at the top of each script.

* No tooling required to use, works within browsers out of the box.

First, create RequireJS-compatible js code:

```js
// app/assets/javascripts/requirejs/example.js

define('example', function() {
  var message = "Hello!";

  return {
    message: message
  };
});
```

Then, create jasmine spec for it:

```js
// spec/javascripts/requirejs/example.js

require(['example'], function(example) {
  describe("Example", function() {
    it("should have a message equal to 'Hello!'", function() {
      console.log(example.message);
      expect(example.message).toBe('Hello!');
    });
  });
});
```

Configure **karma.conf.coffee** to recognize RequireJS framework:

```coffee
# karma.conf.coffee
 module.exports = (config) ->
   config.set
     ...
     frameworks: ['jasmine', 'requirejs]

     files: [
       'app/assets/javascripts/requirejs/*.js',
       {pattern: 'spec/javascripts/requirejs/*_spec.js', included: true}
       {pattern: 'spec/javascripts/requirejs/*_spec.coffee', included: true}
       'spec/javascripts/requirejs/spec-main.js'
     ]
     ...
```

You don't have to preprocess requirejs files - it's already part of karma framework.

Create **main** RequireJS file for tests only:

```js
// spec/javascripts/requirejs/spec-main.js

// Grabs specs
var specs = [];

for (var file in window.__karma__.files) {
  if (window.__karma__.files.hasOwnProperty(file)) {
    if (/spec\.js$/.test(file)) {
      specs.push(file);
    }
  }
}

console.log(specs);

// Configures RequireJS for tests
requirejs.config({
  // Karma serves files from '/base'
  baseUrl: '/base/app/assets/javascripts/requirejs',

  paths: {
    'jquery': process.env.GEM_HOME + '//gems/jquery-rails-3.0.4/vendor/assets/javascripts/jquery'
  },

  // ask Require.js to load these files (all our tests)
  deps: specs,

  // start test run, once Require.js is done
  callback: window.__karma__.start
});
```

## Using RequireJS in browser

For using RequireJS in browser you have to [download] (http://requirejs.org/docs/download.html)
it and include into your html file.

Your sample  **html template file**:

```haml
-#index.haml
%html{:lang => "en"}
  %head
    = javascript_include_tag "requirejs-2.1.8.min"
    = javascript_include_tag  "helper"
    = javascript_include_tag  "application"

  %body
    = "Hello, Web!"
```

and **main** RequireJS file:

```js
// application.js
require.config({
  baseUrl: 'assets/javascripts',

  paths: {
    app: '.'
  }
});

// Start the main app logic.
require(['jquery-1.10.2.min', 'helper'], function($, helper) {

  helper.do_something();
});
```

Now you can open it in browser:

```bash
open index.html
```