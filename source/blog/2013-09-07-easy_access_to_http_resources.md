---
title: Easy access to http resources
date: 2013-09-07
tag: ruby
---

# Easy access to http resources

When you want to access some http resource, you have plenty of solutions, such as:

* [OpenURI] (OpenURI)
* [HTTP Client] (HTTP Client)
* [rest client] (rest client)
* [HTTParty] (HTTParty)
* [Typhoeus] (Typhoeus)

But they tend to be too big to use for simple cases. All you need is probably simple wrapper
around **http/https** ruby standard classes. You can get such implementation as
[resource_accessor] (resource_accessor) gem.

## Installation

Add this line to to your Gemfile:

    gem "resource_accessor"

And then execute:

    $ bundle

## Usage

Create accessor object:

```ruby
require 'resource_accessor'

accessor = ResourceAccessor.new
```

If you want to access unprotected resource located at **some_url**, execute this line:

```ruby
response = accessor.get_response :url => some_url
```

If you want to get protected resource, first get the cookie and then access protected resource:

```ruby
# 1. Get cookie

cookie = accessor.get_cookie login_url, user_name, password

# 2.a. Get protected resource through POST and post body as hash

some_hash = {...}

response = accessor.get_response :url => some_url,
                                 :method => :post,
                                 :cookie => cookie,
                                 :body => some_hash

# 2.b. Get protected resource through POST and post body as string

some_string = "..."

response = accessor.get_response :url => some_url,
                                 :method => :post,
                                 :cookie => cookie,
                                 :body => some_string
```
You have to specify HTTP method explicitly here (post).

If you want to get AJAX resource, add special header to the request or
use dedicated method:

```ruby
response1 = accessor.get_response {:url => some_url},
  {'X-Requested-With' => 'XMLHttpRequest'}

response2 = accessor.get_ajax_response :url => some_url
```

If you want to get SOAP resource, same as before, add special header to the request
or use dedicated method:

```ruby
response1 = accessor.get_response {:url => some_url},
  {'SOAPAction' => 'someSoapOperation',
  'Content-Type' => 'text/xml;charset=UTF-8'}

response2 = accessor.get_soap_response :url => some_url
```

If you want to get JSON resource, same as before, add special header to the request
or use dedicated method:

```ruby
response = accessor.get_response {:url => some_url},
  {'Content-Type" => "application/json;charset=UTF-8'}

response2 = accessor.get_json_response :url => some_url
```

If you want to provide additional parameters in GET call, use **query** parameter:

```ruby
response = accessor.get_response :url => some_url, :query => {:param1 => 'p1', :param2 => 'p2'}
```

or

```ruby
response = accessor.get_response :url => "#{some_url?param1=p1&param2=p2}"
```

You can setup timeout for your accessor object in milliseconds:

```ruby
accessor.timeout = 10000
```

If you need to work over ssl, enable certificate validation and certificate file location
 before the call:

```ruby
accessor.validate_ssl_cert = true
accessor.ca_file = 'your cert file location'
```

[OpenURI]: http://www.ruby-doc.org/stdlib-1.9.3/libdoc/open-uri/rdoc/OpenURI.html
[HTTP Client]: https://github.com/nahi/httpclient
[rest client]: https://github.com/adamwiggins/rest-client
[HTTParty]: https://github.com/jnunemaker/httparty
[Typhoeus]: https://github.com/typhoeus/typhoeus
[resource_accessor]: https://github.com/shvets/resource_accessor