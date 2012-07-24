require 'rubygems'
gem 'awesome_print', '= 1.0.2'
require 'awesome_print'

class Bread
  attr_accessor :name, :rise, :int_rise, :pan_rise, :need_pan, :bake, :total, :loaves, :start_at, :pan_at, :bake_at, :done_at
  
  def initialize(name, rise_time, bake_time, loaves, pan_rise = 0, need_pan = false)
    @name = name
    @rise = rise_time
    @int_rise = rise_time - pan_rise
    @pan_rise = pan_rise  #also need to update this for temp
    @need_pan = need_pan
    @pan_at = nil
    @bake = bake_time
    @total = rise_time + bake_time + 20
    @loaves = loaves
    @start_at = 0.0
    @conflict = nil # Container for Oven-time, Start-time, and Pan-time conflicts
  end

  def <=>(other)
    return nil unless other.is_a? Bread
    self.total <=> other.total
  end

  def self.first_bread
    @@first_bread
  end

  def self.orig_vals
    @@orig_vals = []
  end

  def publish_data
    puts " #{@name}:"
    puts " Rise: #{@rise}"
    puts " Bake: #{@bake}"
    puts " Loaves: #{@loaves}"
    puts " Start Time: #{@start_at.strftime("%I:%M %p")}"
    puts " Bake Time: #{@bake_at.strftime("%I:%M %p")}"
    puts " Done Time: #{@done_at.strftime("%I:%M %p")}"
    puts "-----------------*********-----------------"
    puts " "
  end

  def check_against_times(dest, pan_count, val_array)    # Runs recursively through the existing values in the hash
                                              # checking for both the value and the bread's name in
                                              # association to avoid overwriting and repeats; also
                                              # checks for oven occupancy, assuming only 1 oven.
    all_vals = []
    check = self

    if dest.empty?
      @@first_bread = check
      @@orig_vals = [check.start_at, check.pan_at, check.bake_at, check.done_at]
    end

    if val_array.is_a? Array
      all_vals = val_array
    else
      all_vals.push(val_array)
    end
                                                  
    all_vals.each do |l|
      if l == nil
        next
      end

      if (dest.has_key?(l) && !dest[l].include?(check)) || check_oven(check, dest) || check_starts(check, dest) || check_pans(check, dest, pan_count)
        count = 0
        inc = get_inc(check, l, dest, pan_count)

        run_equipment_checks(check, l, dest, pan_count, inc)

        check_new_values(check, l, pan_count, dest)
      end
    end
    yield if block_given?
  end

  def check_first_bread(dest, pan_count, start_time)
    check = @@first_bread
    @@orig_vals = [check.start_at, check.pan_at, check.bake_at, check.done_at]
    val_array = @@orig_vals

    val_array.each do |fb|
      if fb == nil
        next
      end

      if check_oven(check, dest) || check_starts(check, dest) || check_pans(check, dest, pan_count)

        inc = get_inc(check, fb, dest, pan_count)
        
        run_equipment_checks(check, fb, dest, pan_count, inc)
 
        check_new_values(check, fb, pan_count, dest)
      end
    end

    if check.start_at != @@orig_vals[0]
      @@orig_vals.each do |o|
        dest.delete(o)
      end

      dest[check.start_at] = ["Start #{check.name}", check]
      dest[check.pan_at] = ["Put #{check.name} into the loaf pan", check] unless check.need_pan == false && !dest.has_key?(check.pan_at)
      dest[check.bake_at] = ["Put #{check.name} into the oven", check]
      dest[check.done_at] = ["Take #{check.name} out of the oven", check]

      dest_earliest = dest.sort[0][0]
      diff = dest_earliest.to_i - start_time.to_i   # resets the whole schedule to the start time, in
      												# case the first bread's start time was shifted
      update_all_breads_times(dest, diff)
    end
    return dest
  end

 private

  def update_all_breads_times(dest, diff)   # Problem Area: For some reason, unable to loop through
                                            # the dest hash itself; it would write certain values twice,
                                            # subtracting the diff twice, and leading to an inaccurate
                                            # schedule.  This, so far, works.
    breads = []
    dest.each do |ke, va|
      if !breads.include?(va[1])
        breads.push(va[1])
      end
    end
    breads.each do |bread|                  # This can be refactored
      val = dest.values_at(bread.start_at)
      dest.delete(bread.start_at)
      bread.start_at -= diff
      dest[bread.start_at] = val[0]

      unless bread.need_pan == false
        val = dest.values_at(bread.pan_at)
        dest.delete(bread.pan_at)
        bread.pan_at -= diff
        dest[bread.pan_at] = val[0]
      end

      val = dest.values_at(bread.bake_at)
      dest.delete(bread.bake_at)
      bread.bake_at -= diff
      dest[bread.bake_at] = val[0]

      val = dest.values_at(bread.done_at)
      dest.delete(bread.done_at)
      bread.done_at -= diff
      dest[bread.done_at] = val[0]
    end
  end

  def get_inc(current_bread, current_value, dest, pan_count)   # sets time to increment when conflicts occur
    case
      when current_value == current_bread.bake_at && check_oven(current_bread, dest)
        if @conflict.bake_at < current_bread.bake_at && current_bread.bake_at < @conflict.done_at
          diff = current_bread.bake_at.to_i - @conflict.bake_at.to_i
          if diff == 0
            new_time = (@conflict.done_at.to_i-@conflict.bake_at.to_i) + in_seconds(:min, 2)
          else
            left = (@conflict.done_at.to_i-@conflict.bake_at.to_i) - diff.to_i
            new_time = left.to_f.abs
          end
        elsif current_bread.bake_at < @conflict.bake_at && @conflict.bake_at < current_bread.done_at
          new_time = @conflict.done_at-current_bread.bake_at + in_seconds(:min, 2)
        end
        new_time.to_i
      when !check_oven(current_bread, dest) && check_starts(current_bread, dest) # Priority to settling oven time
        diff = current_bread.start_at.to_i - @conflict.start_at.to_i
        new_time = in_seconds(:min, 20)-diff.to_i
        new_time = new_time + in_seconds(:min, 2)
      when check_pans(current_bread, dest, pan_count) && !check_oven(current_bread, dest) && !check_starts(current_bread, dest)
        #ap @conflict
        unless @conflict == nil
          new_time = (@conflict.done_at.to_i - current_bread.pan_at.to_i) + in_seconds(:min, 2)  # this may be a big issue for the loaf pans; is this really being the most conservative?  This relies on @conflict being set correctly, to account for more than 2 pans.
          new_time
        end
      else
        in_seconds(:min, 20)
    end
  end

  def run_equipment_checks(current_bread, current_value, dest, pan_count, inc)   # I bet a lot of this logic could be abstracted or otherwise refactored
    if current_value == current_bread.bake_at && check_oven(current_bread, dest)
      count = 0
      while dest.has_key?((current_value + count)) || (check_oven(current_bread, dest)) || check_starts(current_bread, dest)
        count += inc
        add_count(check, count, inc)
      end
    elsif current_value != current_bread.bake_at && !(dest.has_key?(current_value) && !dest[current_value].include?(current_bread)) && check_oven(current_bread, dest)
      count = 0
      while check_oven(current_bread, dest)
        count += inc
        add_count(current_bread, count, inc)
      end
    elsif !check_oven(current_bread, dest) && check_starts(current_bread, dest)
      count = 0
      while check_starts(current_bread, dest)
        count += inc
        add_count(current_bread, count, inc)
      end
    elsif check_pans(current_bread, dest, pan_count) && !check_oven(current_bread, dest) && !check_starts(current_bread, dest)
      count = 0
      while check_pans(current_bread, dest, pan_count)
        count += inc unless inc == nil
        add_count(current_bread, count, inc)
      end
    else
      count = 0
      while dest.has_key?((current_value + count))
        count += inc
      end
      add_count(current_bread, count, inc)
    end
  end 

  def check_new_values(current_bread, current_value, pan_count, dest)
    pot_vals = [current_bread.start_at, current_bread.pan_at, current_bread.done_at, current_bread.bake_at] #bake_at last, to ensure no oven conflicts
    pot_vals.delete(current_value)
    pot_vals.each do |b|
      orig = b
      if b == nil
        next
      end
      if (dest.has_key?(b) && !dest[b][0].include?(current_bread.name)) || check_oven(current_bread, dest) || check_starts(current_bread, dest) || check_pans(current_bread, dest, pan_count) then check_against_times(dest, pan_count, b)
      end
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
   
  def add_count(bread, count, inc)
    bread.start_at += count
    bread.pan_at += count unless bread.need_pan == false
    bread.bake_at += count
    bread.done_at += count
    inc = in_seconds(:min, 2)
  end

  def check_oven(current, dest_collection) # First checks that previously placed baking starts do not occur within
                                           # the current baking for this bread;
                                           # Second checks that the current baking does not occur within the baking
                                           # of a previously placed bread.
    if !dest_collection.empty?
      dest_collection.each do |k, v|
        if (current.bake_at < v[1].bake_at && v[1].bake_at < current.done_at) || (v[1].bake_at < current.bake_at && current.bake_at < v[1].done_at)
          @conflict = v[1]
          return true
        end
      end
    end
    return false
  end

  def check_pans(current, dest_collection, pan_num) # Ensures no pan overlap; Returns False if no conflicts
    @conflict = nil
    pan_track = []
    if !dest_collection.empty? && current.need_pan != false   # shouldn't need this false here; 
	    													  # was there a reason?
      pan_used = 0
      dest_collection.each do |k, v|
        unless v[1].need_pan == false || v[1] == current
          if v[1].pan_at < current.pan_at && current.pan_at < v[1].done_at  # checks other bread's needs at the
          																	# time when the current bread needs
          																	# the pans
            pan_used += v[1].loaves
            pan_track.push([v[1].done_at, v[1]])
            ap pan_track
            puts "-----"
          end
        end
        if pan_used + current.loaves > pan_num || pan_used == pan_num  # if we are over, or already full
          pan_track.sort!  # should be in the unless statement yes?  Will check on this
          pan_track.reverse!
          unless pan_track.empty?
            @conflict = pan_track[0][1]  # this grabs the latest bread obj in the schedule
            return true
          end
        end
      end
    end
    return false
  end

  def check_starts(current, dest_collection) # Ensures 20 minute prep time for each bread;
    if !dest_collection.empty?
      dest_collection.each do |k, v|
        diff = current.start_at-v[1].start_at
        diff = diff.to_f.abs
        if diff > 0
          if diff.to_i < in_seconds(:min, 20)
            @conflict = v[1]
            return true
          end
        else return false
        end
      end
    end
    return false
  end
end