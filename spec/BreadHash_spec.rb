require 'lib/BreadHash.rb'

describe DayCollector do 

	before :each do
			@breadhash = DayCollector.new
	end

	it "should return a new DayCollector object" do
		@breadhash.should be_instance_of(DayCollector)
	end

end