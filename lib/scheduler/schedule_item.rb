class ScheduleItem
  attr_accessor :schedule_actions

  def initialize(options = {})
    @object = options[:object] || nil
    @schedule_actions = options[:schedule_actions] || []
  end

  def update_schedule_action_times(adjustment)
    schedule_actions.each do |schedule_action|
      schedule_action.time += adjustment
    end
  end
end
