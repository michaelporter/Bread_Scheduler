require 'rubygems'
gem 'highline', '= 1.5.0'
require 'highline/import'
require 'lib/BreadClass.rb'
require 'lib/BreadHash.rb'
require 'lib/menus.rb'

class BreadMenus

  def initialize
    @which_day = ""
    @breads = DayCollector.new
  end

  def begin
    puts greeting; sleep(0.8)

    current_menu = Menus::MainMenu.new(@which_day, @breads)
    current_menu.display_options
  end

  def greeting
    %Q{











      *** Welcome to Mike's Baking Calculator! ***










    }
  end
=begin
  def main_menu
    @menu = :main

    current_menu = Menus::MainMenu.new(@which_day, @breads)
    current_menu.display_options
  end
  
  def edit_menu(dayobjs)
    @menu = :edit
    
    current_menu = Menus::EditMenu.new(@which_day, @breads)
    current_menu.display_options
  end
  
  def delete_menu(which_day)
    @menu = :delete
    
    current_menu = Menus::DeleteMenu.new(@which_day, @breads)
    current_menu.display_options
  end
  
  def bread_menu
    @menu = :bread
    
    current_menu = Menus::BreadsMenu.new(@which_day, @breads)
    current_menu.display_options
  end
  
  def data_menu(bread_choice)
    @menu = :data
    bread = bread_choice
    
    current_menu = Menus::BreadDataMenu.new(@which_day, @breads, bread)
  end

  def day_menu # For returning a BreadCalc object value for a chosen day to the edit menu;
      print_menu_title("Schedules Menu")
      choose do |s|
        s.prompt = "Please choose a schedule."
        @breads.keys.each do |b|
          s.choice(:"#{b}") {@day_obj = @breads[b]; @which_day = b}
        end
        s.choice(:"Return to Main Menu") {wrapper{main_menu}}
      end
    @which_day
  end
=end
end