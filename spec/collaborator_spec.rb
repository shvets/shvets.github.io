class Collaborator

  def do_stuff # before: do_stuff

  end
end

class Collaborator

  undef_method :do_stuff

  def do_another_stuff

  end
end

class Unit
  def initialize(collaborator)
    @collaborator = collaborator
  end

  def call_collaborator
    @collaborator.do_stuff
  end
end

describe Unit do

  it "doesn't raise exception when it should: stub masks the fact that method does not exist" do
    collaborator = Collaborator.new

    # it does not fail here, but it should

    expect {
      expect(collaborator).to receive(:do_stuff)

      Unit.new(collaborator).call_collaborator
    }.not_to raise_error
  end

  it 'raises exception when it should: instance_double checks method for existence before stubbing' do
    collaborator = instance_double("Collaborator")

    # it fails here, as expected

    expect {
      expect(collaborator).to receive(:do_stuff)

      Unit.new(collaborator).call_collaborator
    }.to raise_error RSpec::Mocks::MockExpectationError
  end
end
