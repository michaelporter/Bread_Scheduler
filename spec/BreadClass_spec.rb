require 'lib/BreadClass.rb'


describe Bread do
	
	before :each do
			@bread = Bread.new("mybread", 120, 30, 2, pan_rise = 0, need_pan = false)
	end

	it "should return a new Bread object" do
		@bread.should be_instance_of(Bread)
	end


end