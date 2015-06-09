---
title: Hitting real angular http service from jasmine test
date: 2015-06-09
tags: javascript, node, jasmine, angular
---

# Hitting real angular http service from jasmine test

Sometimes you want to use jasmine as a tool for playing with existing web services,
grab some responses and then convert them into the stubs. Unfortunately, from jasmine test
you have access only to mocked version of **$httpBackend** service.

You can use this helper code for accessing real **$httpBackend** service:

```javascript
angular.module('httpReal', ['ng'])
  .config(['$provide', function($provide) {
    $provide.decorator('$httpBackend', function() {
      return angular.injector(['ng']).get('$httpBackend');
    });
  }])
  .service('HttpReal', function($rootScope) {
    this.submit = function() {
      $rootScope.$digest();
    };
  }
);
```
 
This code creates **httpReal** service in which you restore access to original **$httpBackend**.
It also provides a function to flush the request. Otherwise promises from http service call will 
never be executed.
    
Let's create demo service:
```javascript

var namespace = angular.module('myModule', []);

namespace.service('MyService', function($http) {
  this.remoteCall = function() {
    return $http({method: 'GET', url: 
      'http://api.openweathermap.org/data/2.5/weather?q=Princeton'});
  };
});
```

and test it:

```javascript
describe('MyService', function() {
  var myService, httpReal;

  beforeEach(module('myModule', 'httpReal'));

  beforeEach(inject(function(MyService, HttpReal) {
    myService = MyService;
    httpReal = HttpReal;
  }));

  it('calls success callback and returns valid data', 
    function(done) {
      myService.remoteCall().then(function(response) {
        expect(response.data.sys.country).toEqual('US');
        done();
      });
  
      httpReal.submit();
    }
  );

  it('calls error callback', function(done) {
    var myServiceResults = createPromise({}, false);

    spyOn(myService, 'remoteCall').and.returnValue(myServiceResults);

    myService.remoteCall().then(angular.noop, function() {
      done();
    });

    httpReal.submit();
  });
});

function createPromise(value, success) {
  var q;

  inject(function($q) {
    q = $q;
  });

  var deferred = q.defer();

  if(success === undefined || success == true) {
    deferred.resolve(value);
  }
  else {
    deferred.reject();
  }

  return deferred.promise;
```

Take a look on how to properly use promises in tests. It uses [**done**] [done function] 
function. In jasmine 2.x they have dropped **runs/waitsFor** functions in favor of the Mocha **done** 
callback. You can use it in **beforeEach**, **afterEach** and **it** calls. 


[done function]: http://www.htmlgoodies.com/beyond/javascript/stips/using-jasmine-2.0s-new-done-function-to-test-asynchronous-processes.html