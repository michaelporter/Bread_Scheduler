require 'BasicMenu.rb'
require 'menus.rb'

describe BreadMenus do
	before (:each) do
		@menu = BreadMenus.new
	end

	it "should make a new Bread Menu" do
		@menu.should be_instance_of(BreadMenus)
	end

	it "should also create a new DayCollector object" do
		DayCollector.should_receive(:new)
		@menu2 = BreadMenus.new
	end

	describe "the begin method" do
		before(:each) do
			@which_day = @menu.instance_variable_get(:@which_day)
			@breads = @menu.instance_variable_get(:@breads)
			@main_menu = Menus::MainMenu.new(@which_day, @breads)
		end

		it "should have a begin method" do
			@menu.should respond_to(:begin)
		end

		it "should create a MainMenu object" do
			Menus::MainMenu.should_receive(:new).with(@which_day, @breads).and_return(@main_menu)
			@menu.begin
		end
	end

end