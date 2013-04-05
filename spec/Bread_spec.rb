require 'spec_helper'

describe Bread do
	before :each do
    options = {
      :name => "Breadname",
      :rise => 120,
      :bake => 35,
      :loaves => 2
    }
	  @bread = Bread.new(options)
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
    options2 = {
      :name => "SecondBreadname",
      :rise => 140,
      :bake => 55,
      :loaves => 4
    }
    @bread2 = Bread.new(options2)
    (@bread <=> @bread2).should eq(-1)
  end
end
