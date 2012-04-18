require 'lib/BreadCalc.rb'

describe BreadCalc do 

	before(:each) do
		date = Time.local(2012, 2, 12)
		@breadcalc = BreadCalc.new(date, 12, 0, nil)
	end

	it "should make a new BreadCalc instance" do
		@breadcalc.should be_instance_of(BreadCalc)
	end


end