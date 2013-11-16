class Collector

  def initialize
    @array = []
    @private_info = 'private info'
  end

  def add element
    @array << element
  end

  def remove element
    @array.delete(element)
  end

  def to_a
    @array
  end
end

collector = Collector.new

collector.add "1"
collector.add "2"
collector.add "3"

module Proxy
  def subject= subject
    @subject = subject
  end

  def method_missing(name, *args, &block)
    @subject.send(name, *args, &block)
  end

  def respond_to?(method)
    @subject.respond_to?(method)
    super
  end
end

class DSL
  #def build object, parent, &code
  #  object.instance_eval &code
  #end

  def build object, parent, &code
    object.extend Proxy
    object.subject = parent

    object.instance_eval &code
  end

  #def build object, &code
  #  parent_binding = code.binding
  #
  #  parent = parent_binding.eval 'self'
  #
  #  object.instance_variable_set(:@parent, parent)
  #
  #  def object.method_missing(sym, *args, &block)
  #    @parent.send sym, *args, &block
  #  end
  #
  #  def object.respond_to?(sym, include_private = false)
  #    @parent.respond_to? sym, include_private
  #  end
  #
  #  object.instance_eval &code
  #end

  def dsl_method
    "dsl_method"
  end
end

dsl = DSL.new

collector = Collector.new

# one way of doing DSL with direct code block

dsl.build(collector, dsl) do
  puts self
  puts dsl_method
  #puts @array
  add "1"
  add "2"
  add "3"
end

# another way of doing DSL with lambda

code = lambda do |_|
  add "4"
  add "5"
  add "6"
end

dsl.build(collector, dsl, &code)

puts collector.to_a.join(' ')


class DSL2
  def build create_code, destroy_code=nil, &code
    parent_binding = code.binding

    parent = parent_binding.eval 'self'

    object = create_code.kind_of?(Proc) ? create_code.call : create_code

    object.extend Proxy
    object.subject = parent

    object.instance_eval &code
  ensure
    destroy_code.call(object) if destroy_code && object
  end
end


dsl2 = DSL2.new

create_code = lambda { Collector.new }
destroy_code = lambda {|_| }

dsl2.build(create_code, destroy_code) do
  puts self
  #puts @array
  add "1"
  add "2"
  add "3"
end

# another way of doing DSL with lambda

code = lambda do |_|
  add "4"
  add "5"
  add "6"
end

dsl2.build(create_code, destroy_code, &code)
