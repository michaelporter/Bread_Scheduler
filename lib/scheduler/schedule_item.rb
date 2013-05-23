require_relative "schedule_action.rb"

class ScheduleItem
  attr_accessor :schedule_actions

  def initialize(options = {})
    @object = options[:object] || nil
    @schedule_actions = options[:schedule_actions] || []
  end

  def new_schedule_action(action, options = {})
    action_duration = options[:action_duration] || @object[action]
    schedule_item = self

    schedule_action = ScheduleAction.new(
      options.merge(
        :schedule_item => schedule_item,
        :action_description => "do #{action} for #{@object[:name]}",
        :action_duration => action_duration,
        :action_name => action
      )
    )

    @schedule_actions << schedule_action

    schedule_action
  end

  def update_schedule_action_times(adjustment)
    schedule_actions.each do |schedule_action|
      schedule_action.time += adjustment
    end
  end
end
