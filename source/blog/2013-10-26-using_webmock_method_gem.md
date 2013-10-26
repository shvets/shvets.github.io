---
title: Using WebMock gem in tests and web application services
date: 2013-10-26
tags: ruby, webmock
---

# Using WebMock gem in tests and web application services


[WebMock] [webmock gem home] is gem for stubbing HTTP requests. You can use
it in your tests if you don't want to hit actual service while testing other functionality of your service
(testing in isolation). For example:

```ruby
require 'webmock'

WebMock.stub_request(:any, "www.example.com").
  to_return(:body => "some body")

expect(Net::HTTP.get("www.example.com", "/")).to eq "some body"
```

It will stub all http verbs (GET, POST, PUT etc.) thanks to **:any** parameter.

You can also use webmock library for building **stubbed versions** of your services. This approach is especially
useful when services to be called **are not implemented yet** (maybe by another team) and you still
want to start working on your part and finish it on time.

In order to facilitate the creation of **mocked service methods**, you can use
[webmock_method] [webmock_method gem home] gem.

How to use it?

First, create **actual service wrapper** that works with future API of "not yet developed service". As an example,
we can use publicly available [OpenWeatherMap](http://api.openweathermap.org) web service.

We will implement call to **quote weather** for a given city. You have to provide **location** and **units** parameters:

```ruby
# services/open_weather_map_service.rb

require 'net/http'

class OpenWeatherMapService
  attr_reader :url

  def initialize
    @url = 'http://api.openweathermap.org/data/2.5/weather'
  end

  def quote location, units
    quote_url = "#{url}?q=#{location}%20nj&units=#{units}"

    uri = URI.parse(URI.escape(quote_url))

    Net::HTTP.get(uri) # At this moment, service is not developed yet...
  end
end
```

Then, create stub/mock for your service:

```ruby
# stubs/open_weather_map_service.rb

require 'webmock_method'
require 'json'

require 'services/open_weather_map_service.rb'

class OpenWeatherMapService
  extend WebmockMethod

  webmock_method :quote, [:location, :units], lambda { |_|
      File.open "#{File.dirname(__FILE__)}/stubs/templates/quote_response.json.erb"
    }, /#{WebmockMethod.url}/
end
```

**webmock_method** requires you to provide the following information:

- **method name** to be mocked;
- **parameters names** for the method (same as in original service);
- **proc/lambda** expression for building the response;
- **url** to remote service (optional).

You can build responses of arbitrary complexity with your own code or you can use **RenderHelper**, that comes with this
gem. Currently it supports **erb** renderer only. Here is example of how to build xml response:

```ruby
  webmock_method :purchase, [:amount, :credit_card], lambda { |binding|
      RenderHelper.render :erb, "#{File.dirname(__FILE__)}/templates/purchase_response.xml.erb", binding
    }
```

It's possible to tweak your response on the fly:

```ruby
  webmock_method :purchase, [:amount, :credit_card], lambda { |binding|
    RenderHelper.render :xml, "#{File.dirname(__FILE__)}/templates/purchase_response.xml.erb", binding
    } do |parent, _, credit_card|
    if credit_card.card_type == "VISA"
      define_attribute(parent, :success,  true)
    else
      define_attribute(parent, :success,  false)
      define_attribute(parent, :error_message, "Unsupported Credit Card Type")
    end
  end
```

and then, use newly defined attributes, such as **success** and **error_message** inside your template:

```xml
<!-- stubs/templates/purchase_response.xml.erb -->
<PurchaseResponse>
  <Success><%= success %></Success>

  <% unless success %>
    <ErrorMessage><%= error_message %></ErrorMessage>
  <% end %>
</PurchaseResponse>
```

**url** parameter is optional. If you don't specify it, gem will try to use **url** attribute defined
on your service or you can define **url** parameter for WebmockMethod:

```ruby
WebmockMethod.url = "http://api.openweathermap.org/data/2.5/weather"
```

And finally, create spec for testing your mocked service:

```ruby
require "stubs/open_weather_map_service"

describe OpenWeatherMapService do
  describe "#quote" do
    it "gets the quote" do
      result = JSON.parse(subject.quote("plainsboro, nj", "imperial"))

      expect(result['sys']['country']).to eq("United States of America")
    end
  end
end
```

There is another article on same topic from [thoughtbot] [thoughtbot blog] blog. It's written
by Harlow Ward and describes how to [create stubbed external services] [How To Stub External Services In Tests]
by using fakeweb, vcr and sinatra.


[webmock gem home]: https://github.com/bblimke/webmock
[webmock_method gem home]: https://github.com/shvets/webmock_method
[How To Stub External Services In Tests]: http://robots.thoughtbot.com/post/64474832169/how-to-stub-external-services-in-tests
[thoughtbot blog]: http://robots.thoughtbot.com