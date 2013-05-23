require 'spec_helper.rb'

ObjectItem = Struct.new(:name)
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

  describe "#update_schedule_action_times method" do
    before :each do
      @schedule = ScheduleItem.new(@schedule_item_attributes)
      @adjustment = 60 * 5

      @initial_times = @schedule.schedule_actions.map(&:time)
      @schedule.update_schedule_action_times(@adjustment)
      @result_times = @schedule.schedule_actions.map(&:time)
    end

    it "should have the #update_schedule_action_times method" do
      @schedule.should respond_to :update_schedule_action_times
    end

    it "should update the times of it's associated schedule_actions" do
      @initial_times.should_not eq @result_times
    end

    it "should update the times by the amount specified in the adjustment param" do
      diff = @result_times.first.to_i - @initial_times.first.to_i
      diff2 = @result_times.last.to_i - @initial_times.last.to_i

      diff.should eq @adjustment
      diff2.should eq @adjustment
    end
  end
end
