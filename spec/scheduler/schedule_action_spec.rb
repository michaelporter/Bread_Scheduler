require 'spec_helper.rb'

describe ScheduleAction do
  before :each do
    @schedule_action_attributes = {
      :time => nil,
      :action => "execute #{:step1}",
      :action_item => :step1,
      :action_duration => 45
    }
  end

  describe "creation" do
    it "should create a new ScheduleAction" do
      ScheduleAction.new(@schedule_action_attributes).should be_a ScheduleAction
    end
  end

  describe "default attributes" do
    it "should have a default time" do
      schedule = ScheduleAction.new(@schedule_action_attributes)
      schedule.instance_variable_get("@time").should_not be_nil
    end

    it "should have a default action" do
      schedule_action_attributes = @schedule_action_attributes.merge(:action => nil)
      schedule = ScheduleAction.new(schedule_action_attributes)
      schedule.instance_variable_get("@action").should_not be_nil
    end

    it "should have a default action item" do
      schedule_action_attributes = @schedule_action_attributes.merge(:action_item => nil)
      schedule = ScheduleAction.new(schedule_action_attributes)
      schedule.instance_variable_get("@action_item").should_not be_nil
    end

    it "should have a default action duration" do
      schedule_action_attributes = @schedule_action_attributes.merge(:action_duration => nil)
      schedule = ScheduleAction.new(schedule_action_attributes)
      schedule.instance_variable_get("@action_duration").should_not be_nil
    end
  end
end
