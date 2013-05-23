require_relative '../time_utility.rb'
require_relative 'schedule_item.rb'
require_relative 'schedule_action.rb'

class Scheduler
  include Utility::Time

  attr_reader :start_time, :items

  def initialize(options)
    @items = options[:items] || []
    @no_conflict = options[:no_conflict] || nil
    @schedule_on = options[:schedule_on] || [] # [:rise, :pan_rise, :bake]
    @start_time = options[:start_time] || Time.now
    @padding_seconds = options[:padding_seconds] || 0
  end

  def self.show(schedule)
    schedule.sort.each do |schedule_item|
      puts schedule_item.time.strftime("%H:%M %d %b %Y")
      puts "  #{schedule_item.action}"
      puts "-----------"
    end
  end

  def schedule!
    _schedule = []
    action_time = start_time
    action_time_for_next_item = start_time

    items.each do |item|
      action_map = {}
      @schedule_on.each do |action|
        schedule_item = ScheduleItem.new(:time => action_time, :action => "do #{action} for #{item}")
        _schedule << schedule_item

        action_map[action] = action_time
        action_time += to_seconds(item[action])
      end

      if @no_conflict
        action_time_for_next_item = action_map[@no_conflict]
      else
        action_time_for_next_item = action_time[@schedule_on.first] + @padding_seconds
      end
    end

    self.class.show(_schedule)

    _schedule
  end

  private

  def range_conflict?(range1, range2)
    range2_a = range2.to_a

    range1.cover?(range2_a.first) && range1.cover?(range2_a.last)
  end
end
