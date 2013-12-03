!SLIDE title-and-content transition=cover

# Capybara 1 - wait_until API

* Capybara ver. 1 - mostly uses wait_until API for waiting asynchronous events.

* This way you can build scripts of arbitrary complexity. Example:

```ruby
visit "/"
click_button "Submit"

wait_until { page.find("some_element_id").visible? }

wait_until do
  execute_script('return jQuery(".response .success").is(":visible")')
end


# do next step

```

* Drawback: **wait_until** makes scripts bulky, hard to read, maintain.



!SLIDE title-and-content transition=cover

# Capybara 2 - smart auto-waiting feature implementation.

* In Capybara ver. 2 **wait_until was removed completely**. Why?

  - wait_until API is simply not necessary for most cases.

  - it was added in older versions of Capybara when auto-waiting feature was much more primitive.

# What's instead?

* Smart auto-waiting.

* Methods like **find("#foo")** have blocking code that perform waiting for requested element
to become available.

* Instead of calling regular methods like **contain**, you should use **have_content** or **have_selector**, **has_selector?**.


!SLIDE title-and-content columns transition=cover

# How to use new API?

## Incorrect Usage

```ruby
  page.find("foo").text.should
    contain("login failed")




```

## Correct Usage

```ruby
  page.find("#foo").should
    have_content("login failed")

  page.should
    have_selector("#foo",
      :text => "login failed")
```



!SLIDE title-and-content transition=cover

# Explanation

* What's wrong in first example?

  - Method **text**, being just a regular method that returns a regular string, isn’t going to do auto-waiting.
It will immediately return the text.

  - When you use **have_content** or **have_selector**, they will do **auto-waiting** for you.

  - Code becomes simple and much easier to read/maintain.

  - As long as you stick with Capybara API, you should never have to use wait_until explicitly.

