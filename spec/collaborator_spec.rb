class Collaborator
  # def do_stuff
  #
  # end

  def do_the_important_stuff

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

    expect(collaborator).to receive(:do_stuff) # should fail here

    Unit.new(collaborator).call_collaborator
  end

  it 'raises exception when it should: instance_double checks method for existence before stubbing' do
    collaborator = instance_double("Collaborator")

    expect(collaborator).to receive(:do_stuff) # it fails here, as expected

    Unit.new(collaborator).call_collaborator
  end
end
