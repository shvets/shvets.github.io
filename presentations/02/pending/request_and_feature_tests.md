!SLIDE title-and-content transition=cover incremental

# Request and Feature Tests : for Ruby Developers Only

* Originally, rails team introduced **requests tests** that could use internally **Integration Test** or **Capybara**.

* That was misleading: in your code you use 2 types of API and it's not clear whether you have to
use **get** (Integration Test) or **visit** (Capybara) method.

* With new versions of Rails, Capybara and RSpec you keep requests tests in **requests** folder and acceptance/feature tests in
**features** folder.



!SLIDE title-and-content transition=cover

# Request Tests

* Request tests provide a thin wrapper around **Rails Integration Tests**.

* You can use familiar API with the help of **get**, **post**, **put**, **delete**, **response**, just like
in HTTP protocol.

* For example:

```ruby
# spec/requests/widget_api_spec.rb
describe "widget API" do
  it "allows API clients to create widgets" do
    post widgets_url, widget: { name: "Awesome Widget" },
         format: "json"

    expect(response.status).to eq(201) # "Created"
  end
end
```



!SLIDE title-and-content transition=cover

# Feature Tests

* Feature specs are **high-level tests** meant to exercise slices of functionality through an application.
They should drive the application only via its **external interface**, usually web pages.

* The conceptual difference is that you are usually testing a **user story**, and all interaction should be
driven via the **user interface**.

* You use something like **visit**, **click_button**, **click_link** API.

* For example:

```ruby
# spec/features/widget_management_spec.rb
feature "widget management" do
  scenario "creating a new widget" do
    visit root_url
    click_link "New Widget"

    fill_in "Name", with: "Awesome Widget"
    click_button "Create Widget"

    expect(page).to have_text("Widget was successfully created.")
  end
end
```

