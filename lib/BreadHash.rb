# Storage for Schedules and their breads;
# This class also houses the methods that deal with editing breads and making changes to the lists;

require 'lib/BreadCalc.rb'
require 'lib/BreadClass.rb'
require 'lib/time_manipulation.rb'

require 'rubygems'   # Do I really need this?  does it not inherit?
gem 'highline'
require 'highline/import'

class DayCollector < Hash

  def initialize
  end

  def delete_day(which_day)
    if self.has_key?(which_day)
      alt_name = stringify_alt(which_day)
      self.delete(which_day)
      puts "'#{which_day}#{alt_name}' deleted from record!"
     elsif self.empty?
      puts "No recorded baking schedules."
     else
      puts "Sorry, that bread could not be found."
    end
    puts "-----------------*********-----------------"
  end

  def add_bread(which_day)
    self[which_day].set_up_day("edit")
    self[which_day].run
    puts "Thank you, and good luck!"
  end

  def change_date_and_time(which_day)
    old_obj = which_day
    old_time = self[old_obj].store_time.strftime("%D")
    old_alt = stringify_alt(old_obj)
    alt_text = nil
    alt_name = nil
    alt_give = nil
    
    date_input, time_input, alt_text, alt_name = get_day_info(true, old_obj)
    new_day = make_new_day(date_input, time_input, alt_text)
    day = incorporate_new_day(date_input, new_day, old_obj)

    if alt_name != nil && alt_name != false then alt_name = "#{alt_name}"
    else alt_name = ""
    end
    puts "\n\n#{old_time}#{old_alt} changed to #{day}#{alt_name}."

    return day
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
      puts "That was the last bread for this day. The baking day has been deleted."
    else
      self[which_day].run
    end
  end
  
  def edit_bread(which_day, the_bread, data)
    new_data = ask("What is the new value?")
    bread_obj = the_bread

    case data
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

  def get_day_info(change = false, old_obj = nil) # new day--false; existing day--true
   check = false
   until check == true
     date_input = ask("What day will you be baking? (Please enter 'YYYY/MM/DD')", Date) do |q|
      q.default = Date.today.to_s;
      q.validate = lambda { |p| Date.parse(p) >= Date.today };
      q.responses[:not_valid] = "Enter a date greater than or equal to today"
     end

     sleep(0.05); puts "\n"
  
     time_input = ask("What time will you start? Please enter in 24-hour format (hour:minute)", String){|q| q.validate = /(([1]?[0-9]{1})|([2][0-4]{1})):([0-5]{1}[0-9]{1})/}; sleep(0.05); puts "\n"
  
     if change == false
       alt_text = agree("Would you like to give this baking day a short description? (YES/NO)"); sleep(0.05); puts "\n"
  
       if alt_text == true
         alt_text = ask("What is this baking day for?", String)
         alt_name = ", #{alt_text}"
       else
         alt_name = ""
       end
       sleep(0.05); puts "\n"
        
     elsif change == true
       if self[old_obj].alt_name != (nil|false)
         old_alt = ", #{self[old_obj].alt_name}"
         alt_give = agree("Would you like to change the alt description? (YES/NO)")
       elsif self[old_obj].alt_name == (nil|false)
         old_alt = ""
         alt_give = agree("Would you like to add a description? (YES/NO)")
       end
       sleep(0.05); puts "\n"

       if alt_give == true
         alt_text = ask("What is the new description?", String)
         alt_name = ", #{alt_text}"
       elsif alt_give == false
         alt_text = self[old_obj].alt_name
         alt_name = stringify_alt(old_obj)
       end
     end
    puts "** You entered #{date_input.strftime("%m/%d/%Y")}, at #{time_input}#{alt_name}. **\n\n"
    check = agree("Is this correct?"); sleep(0.05); puts "\n"
    end

    return date_input, time_input, alt_text, alt_name
  end

  def incorporate_new_day(date_input, new_obj, old_obj = nil)
    self[date_input] = new_obj

    if old_obj != nil
      self[date_input].bread_list = self[old_obj].bread_list
    else
      self[date_input].set_up_day
    end

    self[date_input].run
    day = self[date_input].store_time.strftime("%D")
    self[day] = self[date_input]
    self.delete(date_input)

    if old_obj != nil
      self.delete(old_obj)
    end

    return day
  end

  def list_breads(which_day)
    alt = stringify_alt(which_day)
    
    puts "\n" * 6
    puts "BREADS FOR:"
    puts "#{self[which_day].bake_day.strftime("%m/%d/%Y")}#{alt}"
    
    i = 0
    self[which_day].bread_list.each do |k|
      puts "#{i+=1}. #{k.name}."
    end

    puts "\n" * 6
  end

  def make_new_day(date, time, alt_text)
    time_hr, time_min = parse_times(time)

    begin
    new_day = BreadCalc.new(date, time_hr, time_min, alt_text)
    rescue SyntaxError => e
      puts "*************EXCEPTION RAISED*************"
      puts "Oops!  Syntax Error when creating baking day:"
      puts "#{e}"
      puts "EXITING PROGRAM"
      Process.exit
    end
  end

  def new_day
    alt_text = nil
    alt_name = nil

    date_input, time_input, alt_text, alt_name = get_day_info
    new_day = make_new_day(date_input, time_input, alt_text)
    incorporate_new_day(date_input, new_day)

    puts "Thank you, and good luck!"
  end

  def parse_times(input)
    input = input.split(":")
    hr = input[0].to_i
    min = input[1].to_i

    return hr, min
  end
  
  def publish_lists
    if self.empty?
      puts "No recorded baking schedules."
    else
      puts "-----------------*********-----------------"
      self.each_pair do |k, v|
        v.publish
        puts "\n" * 6
      end
      puts "-----------------*********-----------------"
    end
  end

  def stringify_alt(day)     # Because some alt's are nil by default ( I should probably fix this part rather than write a new method...)
    if self[day].alt_name != (nil|false)
      alt = ", #{self[day].alt_name}"
    else
      alt = nil
    end
  end
end
