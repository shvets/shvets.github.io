!SLIDE title-and-content transition=cover blank

# Tip: RSpec for Java

* You can use RSpec with JRuby in order to provide unit Ruby tests/mocks/stubs for Java class.

* Say, you have this Java class:

```
package demo;

public class Demo {

  public String getMessage() {
    return "Hello World!";
  }
}
```

* How to make compiled Java class or Java library visible from JRuby? You can use this code chunk:


```
require 'java'

target_dir = "target/classes"
$CLASSPATH << target_dir

def add_classes_from_dir dir
  Dir[dir + "/**/*.class"].each do |clazz|
    import clazz[dir.length+1..clazz.length-'.class'.length-1].gsub('/', '.')
  end
end
```

* This code will import all classes from **target/classes** folder.


!SLIDE title-and-content transition=cover

* Now you can create corresponding test:

```
add_classes_from_dir target_dir

describe Demo do
  before :each do
    @demo = Demo.new
  end

  it "returns hello world string" do
    @demo.message.should == "Hello World!"
  end
end
```

* and run it:

```bash
  javac -c target/classes Demo.java
  rvm use jruby
  rspec spec/demo_spec.rb
```