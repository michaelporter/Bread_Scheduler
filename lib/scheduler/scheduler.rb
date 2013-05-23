require_relative '../time_utility.rb'
require_relative 'schedule_item.rb'
require_relative 'schedule_action.rb'
require_relative 'range_conflict_aware.rb'

class Scheduler
  include Utility::Time
  include RangeConflictAware

  attr_reader :start_time, :items

  def initialize(options)
    @items = options[:items] || []
    @no_conflict = [options[:no_conflict]].flatten || []
    @schedule_on = options[:schedule_on] || [] # [:rise, :pan_rise, :bake]
    @start_time = options[:start_time] || Time.now
    @padding_seconds = options[:padding_seconds] || 60 * 5
    @mark_as_done = options[:mark_as_done] || []

    @schedule_items = []
  end

  def show
    all_schedule_actions.sort.each do |schedule_action|
      puts schedule_action.time.strftime("%H:%M %d %b %Y")
      puts "  #{schedule_action.action_description}"
      puts "-----------"
    end
  end

  def schedule!
    action_time_for_next_item = start_time

    @items.each do |item|
      schedule_item = ScheduleItem.new(:object => item)
      action_time = action_time_for_next_item

      action_map = {}
      @schedule_on.each do |action|
        schedule_action = schedule_item.new_schedule_action(action, :time => action_time)

        if @no_conflict.include? action
          action_time = adjust_time_for_no_conflicts(schedule_action)
        end

        schedule_action.time = action_time
        action_map[action] = schedule_action.time
        action_time += to_seconds(schedule_action.action_duration)

        create_done_action(schedule_action) if @mark_as_done.include? action
      end

      @schedule_items << schedule_item

      action_time_for_next_item = time_with_padding(action_map[@schedule_on.first])
    end

    show
  end

  private

  def adjust_time_for_no_conflicts(schedule_action)
    action = schedule_action.action_name
    action_time = schedule_action.time
    schedule_item = schedule_action.schedule_item

    matching_items = schedule_actions_with_action_name(action, schedule_item)

    unless matching_items.empty?
      # how to utilize all the matching items?
      test_item = matching_items.first

      compare = {}
      compare[:lower] = schedule_action.time < test_item.time ? schedule_action : test_item
      compare[:higher] = schedule_action.time < test_item.time ? test_item : schedule_action
     
      until no_conflict?(compare[:lower], compare[:higher])
        adjustment = to_seconds(compare[:lower].action_duration) + 300
        compare[:higher].schedule_item.update_schedule_action_times(adjustment)
        action_time += adjustment
      end
    end

    action_time
  end

  def all_schedule_actions(options = {})
    exclude_item = options[:exclude_item] || nil
    valid_schedule_items = @schedule_items.dup.keep_if {|schedule_item| schedule_item != exclude_item}

    valid_schedule_items.map {|x| x.schedule_actions}.flatten
  end

  def create_done_action(schedule_action)
    schedule_item = schedule_action.schedule_item

    schedule_action = schedule_item.new_schedule_action(
      :done,
      :action_duration => 0,
      :time => schedule_action.time + to_seconds(schedule_action.action_duration)
    )
  end

  def schedule_actions_with_action_name(action_name, current_schedule_item)
    matching_actions = all_schedule_actions(:exclude_item => current_schedule_item).dup

    matching_actions.keep_if do |matching_item|
      matching_actions.action_name == action_name
    end

    matching_actions
  end

  def no_conflict?(existing_item, new_item)
    if existing_item == new_item
      return true
    end

    existing_range = Range.new(
      existing_item.time.to_i, 
      existing_item.time.to_i + existing_item.action_duration.to_i
    )

    new_range = Range.new(
      new_item.time.to_i, 
      new_item.time.to_i + new_item.action_duration.to_i
    )

    super(existing_range, new_range)
  end

  def time_with_padding(time)
    time + @padding_seconds
  end
end
