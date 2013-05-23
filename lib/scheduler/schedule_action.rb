class ScheduleAction
  attr_accessor :time, :action, :action_item, :action_duration, :schedule_item

  def initialize(options)
    @time = options[:time] || Time.now
    @action = options[:action] || "No action given"
    @action_item = options[:action_item] || "No action"
    @action_duration = options[:action_duration] || 0
  end

  def <=>(other)
    time <=> other.time
  end
end
