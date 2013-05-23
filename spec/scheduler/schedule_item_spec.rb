require 'spec_helper.rb'

ObjectItem = Struct.new(:name, :step1)
ScheduleActionStruct = Struct.new(:time)

describe ScheduleItem do
  before :each do
    schedule_actions = []
    2.times do 
      schedule_actions << ScheduleActionStruct.new(Time.now + rand(1000))
    end

    @schedule_item_attributes = {
      :object => ObjectItem.new("test item"),
      :schedule_actions => schedule_actions
    }
  end
 
  describe "creation" do
    it "should create a new Schedule Item object" do
      ScheduleItem.new(@schedule_item_attributes).should be_a ScheduleItem
    end
  end

  describe "methods" do
    before :each do
      @schedule_item = ScheduleItem.new(@schedule_item_attributes)
    end

    describe "#new_schedule_action" do
      it "should have the #new_schedule_action method" do
        @schedule_item.should respond_to :new_schedule_action
      end

      it "should create a new schedule action" do
        schedule_action = @schedule_item.new_schedule_action(:step1, :time => Time.now)
        schedule_action.should be_a ScheduleAction
      end

      it "should associate the new schedule action with the item" do
        schedule_action = @schedule_item.new_schedule_action(:step1, :time => Time.now)
        schedule_action.schedule_item.should equal @schedule_item
      end

      it "should add the schedule action to the schedule_actions collection" do
        @schedule_item.schedule_actions = []
        schedule_action = @schedule_item.new_schedule_action(:step1, :time => Time.now)

        @schedule_item.schedule_actions.length.should eq 1
        @schedule_item.schedule_actions.first.action_name.should eq :step1
      end
    end
   
    describe "#update_schedule_action_times method" do
      before :each do
        @adjustment = 60 * 5
      end

      it "should have the #update_schedule_action_times method" do
        @schedule_item.should respond_to :update_schedule_action_times
      end

      it "should update the times of it's associated schedule_actions" do
        @initial_times = @schedule_item.schedule_actions.map(&:time)
        @schedule_item.update_schedule_action_times(@adjustment)
        @result_times = @schedule_item.schedule_actions.map(&:time)

        @initial_times.should_not eq @result_times
      end

      it "should update the times by the amount specified in the adjustment param" do
        @initial_times = @schedule_item.schedule_actions.map(&:time)
        @schedule_item.update_schedule_action_times(@adjustment)
        @result_times = @schedule_item.schedule_actions.map(&:time)

        diff = @result_times.first.to_i - @initial_times.first.to_i
        diff2 = @result_times.last.to_i - @initial_times.last.to_i

        diff.should eq @adjustment
        diff2.should eq @adjustment
      end
    end
  end
end
