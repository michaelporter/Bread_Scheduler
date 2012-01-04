class Bread
  attr_accessor :name, :rise, :bake, :total, :loaves, :start_at, :bake_at, :done_at
  
  def initialize(name, rise_time, bake_time, loaf)
    @name = name
    @rise = rise_time + 20
    @bake = bake_time
    @total = rise_time + bake_time + 20
    @loaves = loaf
    @start_at = 0.0
    @conflict = nil    # Container for Oven-time and Start-time conflicts
  end

  def <=>(other)
    return nil unless other.is_a? Bread
    self.total <=> other.total
  end

  def publish_data
    puts "  #{@name}:"
    puts "		Rise: #{@rise}"
    puts "		Bake: #{@bake}"
    puts "		Loaves: #{@loaves}"
    puts "    Start Time: #{@start_at.strftime("%I:%M %p")}"
    puts "    Bake Time:  #{@bake_at.strftime("%I:%M %p")}"
    puts "    Done Time:  #{@done_at.strftime("%I:%M %p")}"
    puts "-----------------*********-----------------"
    puts " "
  end

  def in_seconds(type, number)
    case type
      when :min
        number * 60
      when :hour
        number * 60 * 60
    end
  end

  def check_against_times(in_hash, val_array, dest_col)# Runs recursively through the existing values in the hash
                                                       # checking for both the value and the bread's name in 
                                                       # association to avoid overwriting and repeats; also
                                                       # checks for oven occupancy, assuming only 1 oven.
    all_vals = []
    check = self
    dest = dest_col

    if val_array.is_a? Array
      all_vals = val_array
    else
      all_vals.push(val_array)
    end
                                                  
    all_vals.each do |l|
      if (in_hash.has_key?(l) && !in_hash[l].include?(check)) || check_oven(check, dest) || check_starts(check, dest)
        saver = l
        count = 0
        inc = case
          when (l == check.bake_at && check_oven(check, dest)) #|| (l != check.bake_at && !(in_hash.has_key?(l) && !in_hash[l].include?(check)))
            if @conflict.bake_at < check.bake_at && check.bake_at < @conflict.done_at
              diff = check.bake_at.to_i - @conflict.bake_at.to_i
              if diff == 0
                new_time = (@conflict.done_at.to_i-@conflict.bake_at.to_i) + in_seconds(:min, 2)
              else
                left = (@conflict.done_at.to_i-@conflict.bake_at.to_i) - diff.to_i
                new_time = left.to_f.abs           
              end
            elsif check.bake_at < @conflict.bake_at && @conflict.bake_at < check.done_at
              new_time = @conflict.done_at-check.bake_at + in_seconds(:min, 2)
            end
            new_time.to_i
          when !check_oven(check, dest) && check_starts(check, dest) # Priority to settling oven time
            diff = check.start_at.to_i - @conflict.start_at.to_i
            ap diff
            new_time = in_seconds(:min, 20)-diff.to_i
            #new_time = new_time.to_f.abs
            new_time = new_time + in_seconds(:min, 2)
          else
            in_seconds(:min, 20)        
          end

        if l == check.bake_at && check_oven(check, dest)
          puts "inside the if"
          count = 0
          while in_hash.has_key?((l + count)) || (check_oven(check, dest)) || check_starts(check, dest)
            count += inc
            check.start_at += count
            check.bake_at += count
            check.done_at += count
            inc = in_seconds(:min, 2) # allows inc to be set higher for the first estimate , 
                                      # but shrinks so as not to overshoot.
          end
        elsif l != check.bake_at && !(in_hash.has_key?(l) && !in_hash[l].include?(check)) && check_oven(check, dest)
          count = 0
          while check_oven(check, dest)
            count += inc
            check.start_at += count
            check.bake_at += count
            check.done_at += count
            inc = in_seconds(:min, 2)
          end
        elsif !check_oven(check, dest) && check_starts(check, dest)
          count = 0
          while check_starts(check, dest)
            puts "checking start for #{check}, #{l}"
            ap check
            puts "inc"
            ap inc
            count += inc
            check.start_at += count
            check.bake_at += count
            check.done_at += count
            inc = in_seconds(:min, 2)
          end
        else
          count = 0
          count += inc until !in_hash.has_key?((l + count))
          check.start_at += count
          check.bake_at += count
          check.done_at += count
        end
 
        pot_vals = [check.start_at, check.done_at, check.bake_at]  #bake_at last, to check the oven again
        pot_vals.delete(l)
        pot_vals.each do |b|
          orig = b
          if (in_hash.has_key?(b) && !in_hash[b][0].include?(check.name)) || check_oven(check, dest) || check_starts(check, dest) then check_against_times(in_hash, b, dest)
          end
        end
      end
    end
     yield if block_given?
   end

  def check_oven(current, dest_collection)    # First checks that previously placed baking starts do not occur within 
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

  def check_starts(current, dest_collection)  # Ensures that each bread gets 20 minutes for prep time before the next 
                                            # bread starts;
    if !dest_collection.empty?
      dest_collection.each do |k, v|
        diff = current.start_at-v[1].start_at
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