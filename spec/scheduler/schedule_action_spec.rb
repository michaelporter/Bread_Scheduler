require 'spec_helper.rb'

describe ScheduleAction do
  before :each do
    @schedule_action_attributes = {
      :time => nil,
      :action_description => "execute #{:step1}",
      :action_name => :step1,
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
      schedule_action = ScheduleAction.new(@schedule_action_attributes)
      schedule_action.instance_variable_get("@time").should_not be_nil
    end

    it "should have a default action" do
      schedule_action_attributes = @schedule_action_attributes.merge(:action_description => nil)
      schedule_action = ScheduleAction.new(schedule_action_attributes)
      schedule_action.instance_variable_get("@action_description").should_not be_nil
    end

    it "should have a default action item" do
      schedule_action_attributes = @schedule_action_attributes.merge(:action_name => nil)
      schedule_action = ScheduleAction.new(schedule_action_attributes)
      schedule_action.instance_variable_get("@action_name").should_not be_nil
    end

    it "should have a default action duration" do
      schedule_action_attributes = @schedule_action_attributes.merge(:action_duration => nil)
      schedule_action = ScheduleAction.new(schedule_action_attributes)
      schedule_action.instance_variable_get("@action_duration").should_not be_nil
    end
  end

  describe "methods" do
    before :each do 
      @schedule_action = ScheduleAction.new(@schedule_action_attributes)
    end

    describe "#<=>" do
      it "should define a #<=> method" do
        @schedule_action.should respond_to :<=>
      end
    end
  end
end
