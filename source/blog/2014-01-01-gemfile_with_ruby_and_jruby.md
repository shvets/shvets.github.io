---
title: Configuring separate gemsets for ruby and jruby
date: 2014-01-01
tags: ruby, jruby, gemset, rvm
---

## Configuring separate gemsets for ruby and jruby

1a. If you want to run bundle with different Gemfile, run it this way:

> BUNDLE_GEMFILE=Gemfile_jruby bundle

1b. If you want to select Gemfile automatically when you change ruby or gemset,
use rvm hook.

All hooks for rvm are located in **~/.rvm/hooks**  folder. You have to assign "x"
(executable) right to it in order to be used by rvm.

Create or edit this file:

> subl ~/.rvm/hooks/after_use_jruby

Content:

#!/usr/bin/env bash
\. "${rvm_path}/scripts/functions/hooks/jruby"


if [[ "${rvm_ruby_string}" =~ "jruby" ]]
then
  export BUNDLE_GEMFILE="Gemfile-jruby"
  #jruby_options_append "--ng" "${PROJECT_JRUBY_OPTS[@]}"
else
  export BUNDLE_GEMFILE="Gemfile"
  #jruby_options_remove "--ng" "${PROJECT_JRUBY_OPTS[@]}"
  #jruby_clean_project_options
fi

> chmod +x ~/.rvm/hooks/after_use_jruby
