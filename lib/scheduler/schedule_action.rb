class ScheduleAction
  attr_accessor :time, :action_description, :action_name, :action_duration, :schedule_item

  def initialize(options)
    @time = options[:time] || Time.now
    @action_description = options[:action_description] || "No action given"
    @action_name = options[:action_name] || "No action"
    @action_duration = options[:action_duration] || 0
    @schedule_item = options[:schedule_item] || nil
  end

  def <=>(other)
    self.time <=> other.time
  end
end
