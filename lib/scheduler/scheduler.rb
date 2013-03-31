class Scheduler
  def initialize(options)
    @items = options[:items]
    @no_conflict = options[:no_conflict]
  end

  def schedule!
    _schedule = []

    @items.each do |item|
      _schedule << item  
    end

    _schedule
  end
end
