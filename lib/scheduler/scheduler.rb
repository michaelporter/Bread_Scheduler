# makes sense to have classes descend from this, so more domain-specific
# scheduling requirements can be hashed out;
# Keeping major scheduling methods independent is probably very important
# Alternatively, this could become a module with just a bunch of helper methods
# OR BOTH
class Scheduler
  def initialize(options)
    @items = options[:items] || []
    @no_conflict = options[:no_conflict] || nil # 1 => :bake
    @schedule_on = options[:schedule_on] || [] # [:rise, :pan_rise, :bake] || { 1 => :rise, 2 => :pan_rise, 3 => :bake }
    @start_time = options[:start_time] || Time.now
    @padding_seconds = options[:padding_seconds] || 0
  end

  def schedule!
    _schedule = []

    @items.each do |item|
      _schedule << item  
    end

    _schedule
  end

  private

  def range_conflict?(range1, range2)
    range2_a = range2.to_a

    range1.cover?(range2_a.first) && range1.cover?(range2_a.last)
  end
end
