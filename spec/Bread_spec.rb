require 'lib/bread.rb'

describe Bread do
	before :each do
	   @bread = Bread.new("mybread", 120, 30, 2, 0, false)
	end

	it "should return a new Bread object" do
    @bread.should be_instance_of(Bread)
  end

	it "should calculate a total time" do
    @bread.total.should_not be_nil
  end

  it "should have a comparison method" do
    @bread.should respond_to :<=>
  end

  it "should compare based on total time" do
    @bread2 = Bread.new("secondbread", 150, 30, 2, 0, false)
    (@bread <=> @bread2).should eq(-1)
  end
end
