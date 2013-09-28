---
title: Webmock extension
date: 2014-01-01
tags: ruby, webmock
---


# Webmock extension

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

        #$responses ||= []
        #
        #$responses << response

        stub_request(:any, StubWebMethod.stubbed_url(ignore_get_params, self.url)).to_return(:body => response)

        send("#{method_name}_without_stub_web_method", *args)
      ensure
        WebMock.reset!

        #$responses.pop
        #
        #previous_response = $responses.last
        #
        #stub_request(:any, StubWebMethod.stubbed_url(ignore_get_params, self.url)).to_return(:body => response) if previous_response
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

  ResourceManager::ResourceManagerGateway.class_eval do
    extend StubWebMethod

    stub_web_method :check_number_portability, "#{Rails.root}/spec/services/stubs/check_number_portability_response.xml", false,
                    :port_in_number, :partner_id
    stub_web_method :get_available_resources, "#{Rails.root}/spec/services/stubs/get_available_resources_response.haml", false,
                    :resource_request do |gtw, resource_request|
      "for test"
    end
    stub_web_method :get_region_list, "#{Rails.root}/spec/services/stubs/get_region_list_response.haml", false,
                    :iso_country_code, :category do |gtw|
      "for test"
    end
    stub_web_method :get_town_list, "#{Rails.root}/spec/services/stubs/get_town_list_response.haml", false,
                    :iso_country_code, :region, :area_code, :type do |gtw|
      "for test"
    end
    stub_web_method :release_resources, "#{Rails.root}/spec/services/stubs/release_resources_response.haml", false,
                    :resources do |gtw|
      "for test"
    end
    stub_web_method :reserve_and_release_resources, "#{Rails.root}/spec/services/stubs/reserve_and_release_resources_response.haml", false,
                    :resource_to_reserve, :resources_to_release do |gtw|
      "for test"
    end

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
end
