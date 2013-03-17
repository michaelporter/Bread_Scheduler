require 'lib/Menus.rb'

module MenuMethods
  def print_menu_title(menu_name)
    puts "\n"*8 + "-----------------*********-----------------" + "\n"*2
    puts          "                 #{menu_name}              " + "\n"*2
    puts          "-----------------*********-----------------" + "\n"*5
    sleep(0.8)
  end

  def wrapper # Provides automatic option to return to the previous menu, or the most
              # sensible one following any major action;
    yield if block_given?

    case self
    when Menus::MainMenu
      which = "main "
    when Menus::EditMenu
      which = "edit "
    when Menus::DeleteMenu
      which = "delete "
    when Menus::BreadsMenu
      which = "bread choice "
    when Menus::BreadDataMenu
      which = "data choice "
    when Menus::SaveMenu
      which = "save "
    end
    
    puts "\n\n"; sleep(0.5)

    an = agree("Return to #{which}menu?") #by default continues on with loop if answer is positive;

    if an == false && @menu == :main
      say "Good-bye, and thank you!"
      Process.exit
    elsif (an == false && @menu == :edit) || (an == false && @menu == :day) || (an == false && @menu == :save)
      Menus::MainMenu.new(@which_day, @breads).display_options
    elsif (an == false && @menu == :delete) || (an == false && @menu == :bread)
      Menus::EditMenu.new(@which_day, @bread, check_for_day).display_options
    elsif an == true && @menu == :delete && !@breads.has_key?(@which_day)
      puts "This day is now empty, and has been deleted."
      puts "-----------------*********-----------------"
      sleep(0.2)
      Menus::MainMenu.new(@which_day, @breads).display_options
    elsif an == false && @menu == :data
      Menus::BreadsMenu.new(@which_day, @breads).display_options
    end
  end
  
  def change_times
    new_which_day = @breads.change_date_and_time(@which_day)
    @current_day = @breads[new_which_day]
    @which_day = new_which_day
  end
    
  def which_list
    if @breads.empty?
      puts "No recorded baking schedules."
    else
      Menus::SchedulesMenu.new(@which_day, @breads).display_options
    
      if @breads.has_key?(@which_day)               # This way of using @which_day is sloppy...possibly very confusing;
        @current_day.publish
      else
        puts "Sorry, could not find that list."
      end
    end
  end
    
  def check_for_day                                 # Manages access to single baking days for editing;
    if @breads.length == 1
      @which_day = @breads.keys[0]
      @current_day = @breads[@breads.keys[0]]
      puts "\n" * 12
      puts "** NOTE: You only have one baking day saved. **"
      puts "\n" * 12
      sleep(1)
    else
      Menus::SchedulesMenu.new(@which_day, @breads).display_options
    end
  
    if @breads.has_key?(@which_day)
      puts "\n" * 6
      @which_day
    else
      if @breads.length == 0
        puts "\n"*2 + "No schedules saved"
      else
        puts "\n"*2 + "Sorry, couldn't find that day!"
      end
      Menus::MainMenu.new(@which_day, @breads).display_options
    end
  end
end