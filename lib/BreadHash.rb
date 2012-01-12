# Storage for Schedules and their breads;
# This class also houses the methods that deal with editing breads and making changes to the lists;

require 'lib/BreadCalc.rb'
require 'lib/BreadClass.rb'
require 'rubygems'
gem 'highline', '= 1.5.0'
require 'highline/import'

class DayCollector < Hash

  def initialize
  end

  def new_day                  # Gathers particular data for a new baking day; creates it, launches the day's calc 
                               # methods;
    check = false
    until check == true
      date_input = ask("What day will you be baking? (Please enter 'MM/DD/YYYY')", Date) {|q| q.validate = /(([0-1]?[0-9]{1})|([2][0-4]?))\/(([0-2]?[0-9]{1})|([3][0-1]))\/([0-9]{4})/}
      sleep(0.05); puts ""
      time_input = ask("What time will you start?  Please enter in 24-hour format (hour:minute)", String) {|q| q.validate = /(([1]?[0-9]{1})|([2][0-4]{1})):([1-6]?[0-9]{1})/}
      sleep(0.05); puts ""

      alt_name = agree("Would you like to give this baking day a short description? (YES/NO)")
      sleep(0.05); puts ""

      if alt_name == true
        alt_name = ask("What is this baking day for?", String)
      end
      sleep(0.05); puts ""
    
      if alt_name != nil && alt_name != false
        alt_text = " for #{alt_name}"
      else
        alt_text = ""
      end


      puts "** You entered #{date_input.strftime("%m/%d/%Y")}, at #{time_input}#{alt_text}. **\n\n"
      check = agree("Is this correct? (YES/NO)")
      sleep(0.05); puts ""
    end

    time_hr, time_min = parse_times(time_input)
    new_day = BreadCalc.new(date_input, time_hr, time_min, alt_name) 

    manage_new_day(date_input, new_day)

    puts "Thank you, and good luck!"
  end

  def delete_day(which_day)
    if self.has_key?(which_day)
      if self[which_day].alt_name != nil && self[which_day].alt_name != false
        alt_name = ", #{self[which_day].alt_name}, "
      end
      self.delete(which_day)
      puts "'#{which_day}#{alt_name}' deleted from record!"
     elsif self.empty?
      puts "No recorded baking schedules."
     else
      puts "Sorry, that bread could not be found."
    end
    puts "-----------------*********-----------------"
  end
  
  def delete_bread(which_day, bread_obj)
    ans = agree("Are you sure you want to delete #{which_day}?")
    if ans == true
      self[which_day].bread_list.delete(bread_obj)
    else
      return
    end

    if self[which_day].bread_list.empty?
      self.delete(which_day)
      puts "That was the last bread for this day.  The baking day has been deleted."
    else
      self[which_day].run
    end
  end

  def add_bread(which_day)
    self[which_day].get_breads("edit")
    self[which_day].run
    puts "Thank you, and good luck!"
  end
  
  def edit_bread(which_day, the_bread, the_data)               # Allows already-processed breads to be edited;
                                                               # The schedules are updated accordingly;
    new_data = ask("What is the new value?")
    bread_obj = the_bread

    case the_data
      when :name
        bread_obj.name = new_data
      when :rise
        bread_obj.rise = new_data.to_i + 20
        bread_obj.total = bread_obj.rise + bread_obj.bake
      when :bake
        bread_obj.bake = new_data.to_i
        bread_obj.total = bread_obj.rise + bread_obj.bake
      when :loaves
        bread_obj.loaves = new_data.to_i
    end
    
    new_schedule = self[which_day].run_without_text
    puts "Bread and Schedule Updated!"
  end
  
  def publish_lists
    i=0
    l=0
    if self.empty?
      puts "No recorded baking schedules."
    else
      puts "-----------------*********-----------------"
      self.each_pair do |k, v|
        v.publish
        puts "\n\n"
      end
      puts "-----------------*********-----------------"
    end
  end

  def list_breads(which_day)
    i = 0
    if self[which_day].alt_name != nil && self[which_day].alt_name != false
      alt = ", #{self[which_day].alt_name}"
    else
      alt = ""
    end
    puts "\n\n\n\n\n\n"
    puts "BREADS FOR:"
    puts "#{self[which_day].bake_day.strftime("%m/%d/%Y")}#{alt}"
    self[which_day].bread_list.each do |k|
      puts "#{i+=1}.  #{k.name}."
    end
    puts "\n\n\n\n\n\n"
  end
  
  def change_date_and_time(which_day) 
    old_obj = which_day
    alt_name = nil
    alt_give = nil
    check = false
    until check == true 
      date_input = ask("What is the new date? (Please enter 'MM/DD/YYYY')", Date) {|q| q.validate = /(([0-1]?[0-9]{1})|([2][0-4]?))\/(([0-2]?[0-9]{1})|([3][0-1]))\/([0-9]{4})/}
      sleep(0.05); puts ""

      time_input = ask("What time will you start?  Please enter in 24-hour format (hour:minute)", String) {|q| q.validate = /(([1]?[0-9]{1})|([2][0-4]{1})):([1-6]?[0-9]{1})/}
      sleep(0.05); puts ""

    
      if self[old_obj].alt_name != nil && self[old_obj].alt_name != false
        old_alt = ", #{self[old_obj].alt_name},"
        alt_give = agree("Would you like to change the alt description? (YES/NO)")
      elsif self[old_obj].alt_name == nil || self[old_obj].alt_name == false
        old_at = ""
        alt_give = agree("Would you like to add a description?")
      end
      sleep(0.05); puts ""

      if alt_give == true
        alt_text = ask("What is the new description?", String)
      elsif alt_give == false && self[old_obj].alt_name == nil && self[old_obj].alt_name == false
        alt_text = ""
      elsif alt_give == false && self[old_obj].alt_name != nil && self[old_obj].alt_name != false
        alt_text = self[old_name].alt_name
      end 

      puts "** You entered #{date_input.strftime("%m/%d/%Y")}, at #{time_input}#{alt_text}. **\n\n"
      check = agree("Is this correct?")
      sleep(0.05); puts ""
    end
    
    time_hr, time_min = parse_times(time_input)
    new_day = BreadCalc.new(date_input, time_hr, time_min, alt_name) 

    day = manage_new_day(date_input, new_day)

    if alt_name != nil && alt_name != false then alt_name = ", #{alt_name}"
    else alt_name = ""
    end
    puts "\n\n#{old_time}#{old_alt} changed to #{day}#{alt_name}."

    return day
  end
  
  def parse_times(input)
    input = input.split(":")
    hr = input[0].to_i
    min = input[1].to_i
    return hr, min
  end
end