tests and refactoring: how they are related?

Our design communicate to us through resistance,
when our code is hard to understand, test, change or reuse;


  inside-out vs. outside-in approach


1. When you develop single components in isolation first, it's very likely that they don't fit together entirely;
it require additional work for adapting parts.

2. You implement exactly what you need vs. you implement most likely more than your application actually needs
or you may forget to implement things that the application actually requires.

3. To aviod aforementioned problems you need specification firs. It's not required with outside-in approach.

Outside-In Development


    Specify a scenario
    Run the scenario and watch it fail
        Specify the behavior of a component in an example to fix the failure
        Run the component specification and watch it fail
        Implement the minimum functionality necessary to make the example work
    Run the feature again. If it still fails, continue with A.
    The scenario works! Write another scenario until the feature is complete.


Why ruby:

emerging busineses require short time to release working prototype, gain clients and then improve system.

Exampe of bad architecture: callbacks and listeners in rails.
Why:  because it makes testing harder, you have to start stubbing certain methods; if you forget or miss the stub
it's difficult to identify why some error occured. Working with them require to understand complete architecture before even you can start working
on small piece of it.

If you refactor it into service as POJO, it will much easy to test and as result - to understand.

