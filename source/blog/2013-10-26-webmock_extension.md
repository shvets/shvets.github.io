---
title: Using WebMock gem for tests and web application
date: 2013-10-26
tags: ruby, webmock
---

# Using WebMock gem for tests and web application


[WebMock] [webmock home] is library-gem for stubbing HTTP requests. You can use
it in your tests if you don't want to hit actual service while testing other functionality.

Add it to your Gemfile and then install it:

```ruby
gem "webmock"
```

It's pretty easy to use it in your spec:

```ruby
# spec_helper.rb

require 'webmock/rspec'

describe YourWebService do
  it "should" do
    stub_request(:post, "www.example.com").
      with(:body => /^.*world$/, :headers => {"Content-Type" => /image\/.+/}).
         to_return(:body => "abc")

    subject.call_gateway

  end
end
```

You can use WebMock for building stubbed versions of your services. This approach is especially
useful when your services are not ready yet (maybe it's done by another team) and you still
want to finish your part.

Your actual service:

```ruby
class ResourceManagerGateway
  def check_number_portability port_in_number, partner_id

  end

  def get_region_list iso_country_code, category

  end

  def get_town_list iso_country_code, :region, :area_code, :type

  end
end
```

Your stubbed service:

```ruby
ResourceManagerGateway.class_eval do
  extend StubWebMethod

  stub_web_method :check_number_portability, "#{Rails.root}/spec/services/stubs/check_number_portability_response.xml", false,
                    :port_in_number, :partner_id
  stub_web_method :get_region_list, "#{Rails.root}/spec/services/stubs/get_region_list_response.haml", false,
                    :iso_country_code, :category
  stub_web_method :get_town_list, "#{Rails.root}/spec/services/stubs/get_town_list_response.haml", false,
                    :iso_country_code, :region, :area_code, :type

  stub_web_method :get_resources_by_location, "#{Rails.root}/spec/services/stubs/get_resources_by_location_response.xml", false,
                    :cart do |parent, cart|
      contact_number = cart.account.phone_number

      define_attribute(parent, :contact_number,  contact_number)

      if contact_number == "00000000000"
        reserved_phone_number = ""
        num_reserved = 0
      else
        reserved_phone_number = cart.plan_package.premium? ? "441618702349" : "441618702340"
        num_reserved = 1
      end

      define_attribute(parent, :reserved_phone_number,  reserved_phone_number)
      define_attribute(parent, :num_reserved,  num_reserved)
  end
end
```

# Webmock extension

```ruby
require 'erb'
require 'haml'

#require 'meta_methods'

module StubWebMethod
  #include MetaMethods
  include Services::MetaHelper

  def self.extended(base)
    base.send :include, WebMock::API
  end

  def stub_web_method(method_name, stubbed_response, ignore_get_params, *param_names)
    current_class = self

    define_method("#{method_name}_with_stub_web_method") do |*args|
      param_names.each_with_index do |param_name, index|
        current_class.define_attribute(self, param_name, args[index])
      end

      yield(self, *args) if block_given?

      begin
        response = StubWebMethod.render stubbed_response, binding

        stub_request(:any, StubWebMethod.stubbed_url(ignore_get_params, self.url)).to_return(:body => response)

        send("#{method_name}_without_stub_web_method", *args)
      ensure
        WebMock.reset!
      end
    end

    alias_method_chain method_name, :stub_web_method
  end

  private

  def self.render template, binding

    if template =~ /haml/
      template = Haml::Engine.new(File.read(template))
      template.render binding
    else
      template = ERB.new(File.read(template))
      template.result binding
    end
  end

  def self.stub_it response, url
    stub_request(:any, url).to_return(:body => response) if response
  end

  def self.stubbed_url ignore_get_params, url
    ignore_get_params ? /#{url}/ : url
  end

end
```


[webmock home]: https://github.com/bblimke/webmock