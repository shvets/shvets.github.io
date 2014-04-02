---
title: Provisioning for computers with OSX
date: 2015-02-15
tags: ruby, thor, script_executor
---

# Provisioning for computers with OSX


When you plan to do web development, you need to do few steps, like:

* installing installers (homebrew, rvm)
* installing support for various languages (ruby, java, nodejs, python, c, c++);
* installing databases (mysql, postgres, oracle etc);
* configuring databases (creating users, schemas, populating initial data);
* installing additional servers (apache, passenger, jenkins, selenium);
* starting/stopping services.


Usually all those steps are made manually. If it needs to be done only once, it's OK.
But next time when you try to reproduce all steps on new computer or explain
new developer in the team, you can forget some details of it or forget completely
what needs to be done.

As a common rule, it's nice to have this information documented, or even better -
automated in form of scripts.



[script_executor]: https://github.com/shvets/script_executor
[provisio]: https://github.com/shvets/provisio