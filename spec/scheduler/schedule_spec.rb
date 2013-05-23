require 'spec_helper.rb'

Item = Struct.new(:step1, :step2, :name)

describe Scheduler do
  before :each do
    items = []

    for i in (0..2)
      items << Item.new(30 + i, 40 + i, "Step #{i}")
    end

    @schedule_values = {
      :items => items,
      :no_conflict => nil,
      :schedule_on => [:step1, :step2],
      :start_time => nil,
      :padding_seconds => nil
    }
  end

  describe "creation" do
    it "should create a new schedule object" do
      Scheduler.new(@schedule_values).should be_a Scheduler
    end
  end

  describe "attributes" do
    before :each do
      @scheduler = Scheduler.new(@schedule_values)
    end

    it "should have a default padding time" do
      @scheduler.instance_variable_get("@padding_seconds").should_not be_nil
    end

    it "should have a default starting time" do
      @scheduler.instance_variable_get("@start_time").should_not be_nil
    end

    it "should accept an array for @no_conflict" do
      @scheduler2 = Scheduler.new(@schedule_values.merge(:no_conflict => [:step1, :step2]))
      @scheduler2.instance_variable_get("@no_conflict").should be_a Array
    end
                                 
    it "should accept a single value for @no_conflict" do
      @scheduler2 = Scheduler.new(@schedule_values.merge(:no_conflict => :step1))
      @scheduler2.instance_variable_get("@no_conflict").should be_a Array
    end
  end

  describe "methods" do
    before :each do 
      @scheduler = Scheduler.new(@schedule_values)
    end

    describe "#show" do
      it "should have a #show method" do
        @scheduler.should respond_to :show
      end
    end

    describe "#schedule!" do
      it "should have a #schedule! method" do
        @scheduler.should respond_to :schedule!
      end

      it "should fill the @schedule_items array" do
        @scheduler.stub(:show).and_return("")
        @scheduler.instance_variable_set("@schedule_items", [])

        @scheduler.schedule!
        schedule_items = @scheduler.instance_variable_get("@schedule_items")
        schedule_items.length.should eq @schedule_values[:items].length
      end
    end
  end
end

