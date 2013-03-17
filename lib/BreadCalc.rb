require 'lib/Bread.rb'
require 'lib/TimeManipulation.rb'

# Current Assumptions
  # 20-minute Prep Time before Rise begins
  # 1 oven
  # Consolidated oven-time will mark proper scheduling, rather than breads-per-hour

class BreadCalc
  include TimeManipulation

  attr_accessor :bread_list, :bake_day, :loaf_count, :store_time, :alt_name, :pans

  def initialize(date, hour, minute, desc = nil)
    @bake_day = date
    @start_hour = hour
    @start_min = minute
    
    begin
      @sched_time = Time.local(@bake_day.year, @bake_day.month, @bake_day.day, @start_hour, @start_min, 0)
    rescue ArgumentError => e
      puts "*************EXCEPTION RAISED*************"
      puts "Oops!  The time input does not fit within reason!"
      puts "#{e}"
      puts "EXITING PROGRAM"
      Process.exit
    end

    @all_groups = []
    @all_times = {}
    @alt_name = desc
    @bake_hash = {}
    @bake_list = []
    @bread_count = 0
    @bread_list = []
    @first_grouping = nil
    @interior1 = []
    @interior2 = []
    @loaf_count = 0
    @longest_list = {}
    @longest_rise = nil
    @pans = 0
    @rise_hash = {}
    @rise_list = []
    @store_time = @sched_time
    @temp = 78
    @to_delete = nil
    @total_hash = {}
    @total_list = []
  end

  def adjust_for_temp(temp)    # Estimates for now, based on colloquial knowledge, found on several bread blogs,
                               # pending discovery of more accurate claims; everything points to rising being quite complicated,
                               # but these measures have worked very accurately for me so far in practice.
    unless temp == nil
      @bread_list.each do |k|
        if temp < 70
          k.rise = k.rise * 1.5
          k.pan_rise = k.pan_rise * 1.5
          k.int_rise = k.rise - k.pan_rise
          k.total = k.rise + k.bake + 20
        elsif temp < 61
          k.rise = k.rise * 2
          k.pan_rise = k.pan_rise * 2
          k.int_rise = k.rise - k.pan_rise
          k.total = k.rise + k.bake + 20
        end
      end
    end
  end

  def count_loaves
    @loaf_count = 0
    @bread_list.each do |k|
      @loaf_count += k.loaves
    end
  end

  def dot_count(current, next_one) # Places one dot per line for every span of 35 minutes between
                                   # two scheduled actions;
    diff = next_one - current
    count = (diff/in_seconds(:min, 35)).to_i
    count.times {puts "~"}
  end

  def final_ordering             # Checks the breads' times against those of other breads, and adjusts the current
                                 # bread's times accordingly. 20 minutes is the standard time for change, to
                                 # account for the typical prep time for each bread. Other values are variable, 
                                 # depending onthe bread's relation in time to previously-scheduled breads.
    @final_sched.each do |k|
      if k == nil || k == false
        @final_sched.delete(k)
        next
      end
      k.check_against_times(@all_times, @pans, [k.start_at, k.pan_at, k.bake_at, k.done_at]) do
        @all_times[k.start_at] = ["Start #{k.name}", k]
        if k.need_pan != false
          @all_times[k.pan_at] = ["Put #{k.name} into the loaf pan", k]
        end
        @all_times[k.bake_at] = ["Put #{k.name} into the oven", k]
        @all_times[k.done_at] = ["Take #{k.name} out of the oven", k]
      end
      @all_times = k.check_first_bread(@all_times, @pans, @store_time)
    end
  end

  def find_longest
    make_hash(@rise_hash, :rise)
    make_hash(@bake_hash, :bake)
    make_hash(@total_hash, :total)

    # Find the Longest Rise Time
    @longest_rise = @rise_hash.sort[@rise_hash.sort.length-1][1]
    @to_delete = @longest_rise                                       # Removes the longest rise from this because it will not
                                                                     # be scheduled like the rest; it provides the relative
                                                                     # time marker around which other breads will be scheduled
    @rise_hash.delete(@rise_hash.index(@to_delete))

    # Find the Longest Bake Time
    @longest_bake = @bake_hash.sort[0][1]    # I don't do anything with this yet, so it's not protected from the longest rise

    # Find the Longest Total Time
    @total_hash.delete(@total_hash.index(@to_delete))

    longest = @total_hash.sort[@total_hash.sort.length-1][1] unless @total_hash.empty?
    @longest_total = longest unless (longest == @to_delete || @total_hash.empty?)        # Protects @longest_total from taking the
                                                                                         # longest rise as it's value
  end

  def gather_breads(menu_type)           # Gets each breads' info and makes the bread objects
    this_many = 0
    while this_many < @bread_count.to_i
      
      name, rise, bake, need_pan, pan_rise, loaves = get_bread_info(this_many, menu_type)
      

      begin
        @bread_list.push(Bread.new(name, rise, bake, loaves, pan_rise, need_pan))
      rescue SyntaxError => e
        puts "*************EXCEPTION RAISED*************"
        puts "Oops!  Syntax Error when adding that bread:"
        puts "#{e}"
        puts "EXITING PROGRAM"
        Process.exit
      rescue => e
        puts "*************EXCEPTION RAISED*************"
        puts "Something about this bread's data is incompatible with the current program."
        puts "EXITING PROGRAM"
        Process.exit
      end
      this_many += 1
      puts ""; sleep(0.2); puts "Thanks!"; puts ""; sleep(0.2)
    end
    adjust_for_temp(@temp)
    count_loaves
  end

  def gather_conditions(menu_type)               # Gets number of breads, pans, and kitchen temp (optional)
    add_make = ""
    case menu_type
      when /edit/i
        add_make = "adding"
      else
        add_make = "making"
    end

    @temp = get_temp
    sleep(0.1); puts"\n\n"
    @bread_count = ask("How many breads will you be #{add_make}?", Integer); sleep(0.1)
    
    case menu_type
      when /main/i
        @pans = ask("And how many loaf pans do you have?", Integer)
      when /edit/i
        do_pans = agree("You are currently using #{@pans} loaf pans.  Would you like to change this?")
        if do_pans == true
          @pans = ask("How many loaf pans do you have?", Integer)
        end
      end
    sleep(0.1); puts""
  end

  def get_temp
    puts "\n\n\n\n\n\n\n\n\n\n\n\n\n\nNOTE: Rising times are estimates and may vary depending on the temperature\nand humidity of your kitchen.\n\n\n\n\n\n\n\n\n\n\n"
    temp = agree("Would you like to specify a kitchen temperature? (Default is 78 Deg. Fahrenheit)\n")
    if temp == true
      temp = ask("What is the new temperature?", Integer)
    elsif temp == false
      temp = nil
    end
  end

  def get_bread_info(how_many, menu_type)   # Derp
    add_or = ""

    case menu_type
    when /edit/i
        add_or = " added"
    end
    
    name = ""
    rise = 0
    bake = 0
    need_pan = false
    pan_rise = 0
    loaves = 0

    case how_many
    when 0
      name = ask("What is the name of your first#{add_or} bread?", String)   # ask() is from the Highline gem; very handy
      how_many += 1
    else
      name = ask("What is the name of your next bread?", String)
    end
    sleep(0.1); puts ""

    rise = ask("For how long, in minutes, does it rise?", Integer); sleep(0.1); puts ""

    pan = agree("Does it rise in the pan at all?"); sleep(0.1); puts ""
    if pan == true
      pan_rise = ask("For how long?", Integer); sleep(0.1); puts ""
      need_pan = true
      until pan_rise < rise  
        pan_rise = ask("For how long?", Integer); sleep(0.1); puts ""
        if pan_rise > rise
          puts "That is longer than the total rise!"
        end
      end
    end
    bake = ask("For how long does it bake?", Integer); sleep(0.1); puts ""

    p = 0
    until p == 1
      intro = case p
      when -1
        "H"
      when 0
        "And h"
      end

      loaves = ask("#{intro}ow many loaves do you expect from this recipe?", Integer); sleep(0.1); puts ""
      if loaves > @pans && pan == true                    # This should really just become conditional on
                                  # whether the bread has pans; how many recipes use
                                  # both pans and stone?
        puts "That is more loaves than you have pans!"
        p = -1
      else
        p = 1
      end
    end
    return name, rise, bake, need_pan, pan_rise, loaves
  end

  def interior_scheduling
    make_interiors
    time_interiors
    order_breads
    final_ordering
  end

  def publish                # This gives the final resulting schedule, ordered, as it should be read by
                             # users. This is currently the only place where the schedule is completely
                             # ordered;
    @loaf_count = 0
    count_loaves

    alt = ""

    if @alt_name != false && @alt_name != nil
      alt = ", #{@alt_name}"
    else
      alt = ""
    end
    puts "\nHere is your baking order for #{@bake_day.strftime("%m/%d/%Y")}#{alt}. \n"
    
    sorted_all_times = @all_times.sort #[ [date_obj, [str, obj]], [date_obj2, [str2, obj2]], etc ]

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

  def run
    run_basic
    publish
  end

  def run_basic
    reset_all_things
    find_longest
    interior_scheduling
  end
    
  def run_without_text
    run_basic
    count_loaves
  end

  def set_up_day(menu_type = "main")
    gather_conditions(menu_type)
    gather_breads(menu_type)
  end

  private

  def make_hash(which_hash, which_value)    # Gathers all related times for each bread into a hash
    @bread_list.each do |k|
      key = case which_value
      when :rise
        k.rise
      when :bake
        k.bake
      when :total
        k.total
      end

      if which_hash.has_key?(key) then key += 1
      end

      which_hash[key] = k     # [value => object_id, value2 => object_2_id, etc...]
    end
  end
  
  def make_interiors # Gathers the breads whose total time together fits in the longest ones' rise times;
                       # It first gathers the breads that fit within the time of the longest of all into 
                       # @interior1; the remaining breads are gathered into @interior2;

    reverse_tot = @total_hash.sort.reverse
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

  def order_breads # Places the timed, unchecked breads into this collection, ordered roughly by start time
    @final_sched = []
 
    @final_sched.push(@longest_rise)
    @final_sched.push(@long_interior) unless @long_interior == ""  # In case I'm only doing 1 or two long breads, or there was 
                                                                   # for some other reason no bread to fill this value

    @interior1.each do |k|
     @final_sched.push(k)
    end
    
    if !@interior2.empty?
     @interior2.each do |v|
     @final_sched.push(v)
     end
    end
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

    @sched_time = Time.local(@bake_day.year, @bake_day.month, @bake_day.day, @start_hour, @start_min, 0)  # Sets time to original values
  end
  
  def time_interiors            # Assigns times to each bread's starting, baking, and finishing, according to their
                                # order from the start time. @interior1 searches for a longest bread within itself (-> @long_interior),
                                # which is set then to begin just after the longest-rising bread (grabbed before in find_longest.
                                # The remaining breads within @interior1 get their start time by subtracting their rise time 
                                # from the end time of @long_interior, so they bake when that one finishes, and so
                                # on. This last part of the process repeats for each bread in @interior2,
                                # except instead of @long_interior as the base, it is @longest_rise;
                                # This should result in two fairly loaded periods of near-consistent baking, when loaf pans
                                # are infinite, or in great enough quantity that sharing them is never an issue;

    @interior1 = @interior1.sort.reverse #Currently sorting for total.

    @longest_rise.start_at = @sched_time
    @longest_rise.pan_at   = @sched_time + in_seconds(:min, @longest_rise.int_rise) unless @longest_rise.need_pan == false
    @longest_rise.bake_at  = @sched_time + in_seconds(:min, @longest_rise.rise)
    @longest_rise.done_at  = @sched_time + in_seconds(:min, @longest_rise.total)

    unless @interior1.empty?
      @long_interior = @interior1[0]
      @sched_time += in_seconds(:min, 20)

      @long_interior.start_at = @sched_time
      @long_interior.pan_at   = @sched_time + in_seconds(:min, @long_interior.int_rise) unless @long_interior.need_pan == false
      @long_interior.bake_at  = @sched_time + in_seconds(:min, @long_interior.rise)
      @long_interior.done_at  = @sched_time + in_seconds(:min, @long_interior.total)

      @sched_time += in_seconds(:min, @long_interior.total)

      @interior1.delete_at(0)

      @interior1.each do |k|
        k.start_at   = @sched_time - in_seconds(:min, k.rise)
        k.pan_at     = k.start_at  + in_seconds(:min, k.int_rise) unless k.need_pan == false
        k.bake_at    = @sched_time + in_seconds(:min, 2)
        @sched_time += in_seconds(:min, k.bake)
        k.done_at    = @sched_time += in_seconds(:min, 2)
      end
    end

    if !@interior2.empty?
      @interior2 = @interior2.reverse
      starting = @longest_rise.done_at

      @interior2.each do |k|
        k.start_at = starting - in_seconds(:min, k.rise) # 20 to account for prep time before rise
        k.pan_at   = starting - in_seconds(:min, k.int_rise)
        k.bake_at  = starting + in_seconds(:min, 2) # 2 to account for time to switch pans in oven
        starting  += in_seconds(:min, k.bake+2)
        k.done_at  = starting
      end
    end
  end
end 
