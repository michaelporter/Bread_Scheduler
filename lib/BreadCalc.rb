require 'lib/BreadClass.rb'

# Current Assumptions
  # Unlimited Loaf Pans
  # 20-minute Prep Time before Rise begins
  # All temperature and environment influence on the Rise time. (aka, it is always summertime in the kitchen)
  # 1 oven
  # Consolidated oven-time will mark proper scheduling, rather than breads-per-hour

class BreadCalc

  attr_accessor :bread_list, :bake_day, :loaf_count, :store_time, :alt_name

  def initialize(date, hour, minute, desc = nil)
    @bake_day = date
    @start_hour = hour
    @start_min = minute
    @sched_time = Time.local(@bake_day.year, @bake_day.month, @bake_day.day, @start_hour, @start_min, 0)
    @store_time = @sched_time
    @alt_name = desc
    if @alt_name != nil
      @alt = ", #{alt_name},"
    end

    @bread_list = []
    @rise_list = [] 
    @bake_list = []
    @total_list = []
    @all_groups = []
    @interior1 = []
    @interior2 = []
    @rise_hash = {}
    @bake_hash = {}
    @total_hash = {}
    @longest_list = {}
    @all_times = {}
    @to_delete = nil
    @longest_rise = nil
    @first_grouping = nil
  end

  def get_breads(menu_type = "main")
    i = 0
    r = 0
    @loaf_count = 0
    add_or = ""
    add_make = ""
    menu = menu_type
    case menu
      when /edit/i
        add_make = "adding"
        add_or = " added"
      else
        add_make = "making"
    end

    bread_count = ask("How many breads will you be #{add_make}?", Integer)
    sleep(0.1); puts""

    while i < bread_count.to_i
      case r
        when 0
	  puts "What is the name of your first#{add_or} bread?"
	  r += 1
	else 
          puts "What is the name of your next bread?"
      end

      name = ask("", String)

      sleep(0.1); puts""
  	rise = ask("For how long, in minutes, does it rise?", Integer)
      sleep(0.1); puts""
  	bake = ask("For how long does it bake?", Integer)
  	sleep(0.1); puts""
      loaves = ask("And how many loaves do you expect from this recipe?", Integer)
  		
  	begin
  	@bread_list.push(Bread.new(name, rise, bake, loaves))

  	rescue SyntaxError => e
          puts "*************EXCEPTION RAISED*************"
  	  puts "Is your bread's name a number?  That won't work!:"
  	  puts "#{e}"
 	  puts "EXITING PROGRAM"
  	  Process.exit
  	rescue => e
  	  puts "*************EXCEPTION RAISED*************"
 	  puts "Something about this bread's data is incompatible with the current program."
  	  puts "EXITING PROGRAM"
  	  Process.exit
  	end
      i+=1
      puts ""; sleep(0.2)
      puts "Thanks!"
      puts ""; sleep(0.2)
      end
	  
      count_loaves
  end
  def count_loaves
    @loaf_count = 0
    @bread_list.each do |k|
      @loaf_count += k.loaves
    end
  end

  def run
    reset_all_things
    find_longest_list
    interior_scheduling
    publish
  end
    
  def run_without_text
    reset_all_things
    find_longest_list
    interior_scheduling
    count_loaves
  end

  def publish(alt_giv = nil)             # This gives the final resulting schedule, ordered, as it should be read by 
                                         # users.  This is currently the only place where the schedule is completely 
                                         # ordered;
    if alt_giv != nil
      @alt_name = alt_give
    end
    @loaf_count = 0
    count_loaves

    alt = ""

    if @alt_name != false && @alt_name != nil
      alt = "--#{@alt_name}"
    else
      alt = ""
    end
    puts "\nHere is your baking order for #{@bake_day.strftime("%m/%d/%Y")}#{alt}. \n"
    
    sorted_all_times = @all_times.sort        #[ [date_obj, [str, obj]], [date_obj2, [str2, obj2]], etc ]

    sorted_all_times.each do |k|
      obj_part = k[1]
      puts "#{k[0].strftime("%I:%M %p")} -- #{obj_part[0]}"
      if sorted_all_times[sorted_all_times.index(k)+1]
        dot_count(k[0], sorted_all_times[sorted_all_times.index(k)+1][0])
      end
      sleep(0.05)
    end
	  
    if @loaf_count == 1
      loaf = "loaf"
    else
      loaf = "loaves"
    end
    puts ""
    puts "For a total of #{@loaf_count} #{loaf}!"
  end


  private 
  
  def find_longest_list
    find_longest_rise
    find_longest_bake
    find_longest_total
  end
    
  def find_longest_rise
    @bread_list.each do |k|
      if @rise_hash.has_key?(k.rise) then k.rise += 1
      end
      @rise_hash[k.rise] = k  # { rise =>obj, rise2 => obj2, etc...}
    end
    @longest_rise = @rise_hash.sort[@rise_hash.sort.length-1][1]
    @to_delete = @longest_rise
    @rise_hash.delete(@rise_hash.index(@to_delete))
  end 
  
  def find_longest_bake
    @bread_list.each do |k|
      if @bake_hash.has_key?(k.bake) then k.bake += 1
      end
      @bake_hash[k.bake] = k
    end
    
    @longest_bake = @bake_hash.sort[0][1]
  end
  
  def find_longest_total
    @bread_list.each do |k|
      if @total_hash.has_key?(k.total) then k.total += 1
      end
      @total_hash[k.total] = k
    end
    
    @total_hash.delete(@total_hash.index(@to_delete))

    longest = @total_hash.sort[@total_hash.sort.length-1][1] unless @total_hash.empty?
    @longest_total = longest unless (longest == @to_delete || @total_hash.empty?)

    @tot_sort = @total_hash.sort
    @tot_name = Array.new
    @tot_sort.each do |k|
      @tot_name.push(k[1])
    end
    @longest_total
  end

  def reset(collection)
    col = collection
    case col
      when Hash
        col.each_pair do |k, v|
          col.delete(k)
        end
      when Array
        col.each do |k|
          col.delete(k)
        end
      else
        col = nil
    end
  end
  
  def reset_all_things
    reset(@rise_list)
    reset(@bake_list)
    reset(@total_list)
    reset(@rise_hash)
    reset(@bake_hash)
    reset(@total_hash)

    @tot_sort = Array.new
    @tot_name = Array.new

    reset(@longest_list)

    @interior1 = Array.new
    @interior2 = Array.new

    reset(@all_times)
    @final_sched = Array.new

    @long_interior = nil
    @interior_time = nil

    @to_delete = nil
    @longest_rise = nil
    @longest_bake = nil
    @longest_total = nil

    @sched_time = Time.local(@bake_day.year, @bake_day.month, @bake_day.day, @start_hour, @start_min, 0)
  end

  def dot_count(current, next_one)        # Places one dot per line for every span of 35 minutes between 
                                          # two scheduled actions;
    diff = next_one - current
    count = (diff/in_seconds(:min, 35)).to_i
    count.times {puts "~"}
  end


  def interior_scheduling
    make_interiors
    time_interiors
    order_breads
    final_ordering
  end
  
  def make_interiors   # Gathers the breads whose total time together fits in the longest ones' rise times;
                       # It first gathers the breads that fit within the time of the longest of all into @interior1;
                       # the remaining breads are gathered into @interior2;
    reverse_tot = @tot_sort.reverse 
    #[[tot, obj], [tot2, obj2], etc ]

    @interior_time = 0
  
    unless reverse_tot.empty?
      @interior1.push(reverse_tot[0][1])
      @interior_time += reverse_tot[0][1].total

      if reverse_tot.length > 1
        reverse_tot.each do |k|
          unless @interior_time >= @longest_rise.rise || reverse_tot.empty?
            if @interior1.include?(k[1])   
              next
            end
            @interior1.push(k[1])
            @interior_time += k[1].bake
            reverse_tot.delete(k)
          end   
        end
      else
        unless @interior_time >= @longest_rise.rise || reverse_tot.empty?
          unless @interior1.include?(reverse_tot[0][1])
            @interior1.push(reverse_tot[0][1])
          end
          @interior_time += reverse_tot[0][1].bake
          reverse_tot.delete_at(0)
        end
      end
    end
    if !reverse_tot.empty?
    	reverse_tot.each do |k|
    	  @interior2.push(k[1]) unless @interior1.include?(k[1])
    	end
    end
  end
  
  def time_interiors            # Assigns times to each bread's starting, baking, and finishing, according to their 
                                # order from the start time.  @interior1 searches for a longest bread within itself,
                                # which is set then to begin just after the longest-rising bread.  The remaining breads
                                # within @interior1 get their start time by subtracting their rise time from the end 
                                # time of @long_interior, so they bake when that one finishes, and so on.  This last 
                                # part of the process process repeats for each bread in @interior2, except instead of 
                                # @long_interior as the base, it is @longest_rise;
    @interior1 = @interior1.sort.reverse  #Currently sorting for total.

    @longest_rise.start_at = @sched_time
    @longest_rise.bake_at = @sched_time + in_seconds(:min, (@longest_rise.rise))
    @longest_rise.done_at = @sched_time + in_seconds(:min, (@longest_rise.total))

    unless @interior1.empty?
      @long_interior = @interior1[0]
      @sched_time += in_seconds(:min, 20)

      @long_interior.start_at = @sched_time

      @long_interior.bake_at = @sched_time + in_seconds(:min, @long_interior.rise)
      @long_interior.done_at = @sched_time + in_seconds(:min, @long_interior.total)

      @sched_time += in_seconds(:min, @long_interior.total)

      @interior1.delete_at(0)

      @interior1.each do |k|
        k.start_at = @sched_time - in_seconds(:min, (k.rise))
        k.bake_at = @sched_time + in_seconds(:min, 2)
        @sched_time += in_seconds(:min, (k.bake))
        k.done_at = @sched_time += in_seconds(:min, 2)
      end
    end

    if !@interior2.empty?
      @interior2 = @interior2.reverse
      starting = @longest_rise.done_at

      @interior2.each do |k|
        k.start_at = starting - in_seconds(:min, (k.rise))  # 20 to account for prep time before rise
        k.bake_at = starting + in_seconds(:min, 2)             # 2 to account for time to switch pans in oven
        starting += in_seconds(:min, (k.bake+2))
        k.done_at = starting
      end
    end
  end
  
  def order_breads            # Places the timed, unchecked breads into this collection, ordered roughly by start time
    @final_sched = []
 
    @final_sched.push(@longest_rise)
    @final_sched.push(@long_interior) unless @long_interior == ""

    @interior1.each do |k|
    	@final_sched.push(k)
    end
    
    if !@interior2.empty?
    	@interior2.each do |v|
    	  @final_sched.push(v)
    	end
    end
  end
  
  def final_ordering             # Checks the breads' times against those of other breads, and adjusts the current
                                 # bread's times accordingly.  20 minutes is the standard time for change, to account
                                 # for the typical prep time for each bread.  Other values are variable, depending on
                                 # the bread's relation in time to previously-scheduled breads.
    @final_sched.each do |k|
      if k == nil || k == false
        @final_sched.delete(k)
        next
      end
      k.check_against_times(@all_times, [k.start_at, k.bake_at, k.done_at], @all_times) {@all_times[k.start_at]=["Start #{k.name}", k]; @all_times[k.bake_at]=["Put #{k.name} into the oven", k]; @all_times[k.done_at]=["Take #{k.name} out of the oven", k]}
    end
  end 
  
  def in_seconds(type, number)
     case type
       when :min
         number * 60
       when :hour
         number * 60 * 60
      end
  end

end 