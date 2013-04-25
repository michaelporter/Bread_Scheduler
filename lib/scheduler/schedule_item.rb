class ScheduleItem
  attr_accessor :time, :action

  def initialize(options)
    @time = options[:time] || Time.now
    @action = options[:action] || "No action given"
  end

  def <=>(other)
    time <=> other.time
  end
end
