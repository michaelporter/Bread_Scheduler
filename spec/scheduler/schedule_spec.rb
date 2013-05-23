require 'spec_helper.rb'

Item = Struct.new(:step1, :step2, :name)

describe Scheduler do
  before :each do
    items = []

    for i in (0..2)
      items << Item.new(
        :step1 => 30 + i,
        :step2 => 40 + i,
        :name => "Step #{i}"
      )
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

  describe "default attribtues" do
    before :each do
      @schedule = Scheduler.new(@schedule_values)
    end

    it "should have a default padding time" do
      @schedule.instance_variable_get("@padding_seconds").should_not be_nil
    end

    it "should have a default starting time" do
      @schedule.instance_variable_get("@start_time").should_not be_nil
    end
  end
end

