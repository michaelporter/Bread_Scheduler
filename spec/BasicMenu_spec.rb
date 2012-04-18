require 'BasicMenu.rb'

describe BreadMenus do
	before (:each) do
		@menu = BreadMenus.new
	end

	it "should make a new Bread Menu" do
		@menu.should be_instance_of(BreadMenus)
	end
end