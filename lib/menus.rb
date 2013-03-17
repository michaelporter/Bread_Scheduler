require 'lib/MenuMethods.rb'

module Menus
  class Menu
    include MenuMethods

    def initialize(which_day, breads_list)
      @which_day = which_day
      @breads = breads_list
    end

    def display_options(title, &block)
      loop do
        print_menu_title(title)
        yield
      end
    end
  end

  class BreadsMenu < Menu
    def display_options
      menu = lambda {
        @current_day.bread_list.each do |k|
         k.publish_data
        end
        sleep(0.8)
        puts ""

        puts "Which bread would you like to edit?"
      
        choose do |p|
          p.prompt = ""
          @current_day.bread_list.each do |k|
            p.choice(:"#{k.name}") {wrapper{data_menu(k)}}
          end
          p.choice(:"Return to Edit Menu") {EditMenu.new(@which_day, @breads, @which_day).display_options}
        end
      }

      super "Breads Menu", &menu
    end
  end

  class BreadDataMenu < Menu
    def initialize(which_day, breads_list, current_bread)
      super(which_day, breads_list)
      @current_bread = current_bread
    end

    def display_options
      menu = lambda {
        bread.publish_data
    
        choose do |d|
          d.prompt = "Which piece of data would you like to edit?"
          d.choice(:"Name" ) {wrapper{@breads.edit_bread(@which_day, @current_bread, :name)}}
          d.choice(:"Rise Time" ) {wrapper{@breads.edit_bread(@which_day, @current_bread, :rise)}}
          d.choice(:"Bake Time" ) {wrapper{@breads.edit_bread(@which_day, @current_bread, :bake)}}
          d.choice(:"Number of Loaves" ) {wrapper{@breads.edit_bread(@which_day, @current_bread, :loaves)}}
          d.choice(:"Show Updated Schedule") {wrapper{@current_day.publish}}
          d.choice(:"Choose a different bread" ) {wrapper{BreadMenu.new(@which_day, @breads).display_options}}
          d.choice(:"Return to Edit Menu" ) {wrapper{EditMenu.new(@which_day, @breads).display_options}}
          d.choice(:"Return to Main Menu" ) {wrapper{MainMenu.new(@which_day, @breads).display_options}}
        end
      }

      super "Bread Info Editing Menu", &menu
    end
  end

  class DeleteMenu < Menu
    def display_options
      menu = lambda {
        @current_day.publish
        puts "\n\n-----------------*********-----------------\n\n"; sleep(1)
      
       choose do |b|
          b.prompt = "Which bread would you like to delete?"
          @current_day.bread_list.each do |k|
            b.choice(:"#{k.name}") {wrapper{@breads.delete_bread(@which_day, k)}}
          end
          b.choice(:"Return to Edit Menu" ) {EditMenu.new(@which_day, @breads).display_options}
        end
      }

      super "Delete Menu", &menu
    end
  end

	class EditMenu < Menu
		def initialize(which_day, breads_list, current_day = nil)
      super(which_day, breads_list)

			@current_day = current_day ? current_day : check_for_day
		end

		def display_options
      menu = lambda {
        puts "\n\n\n\n\n\n-----------------*********-----------------"
      	puts " You are editing for #{@which_day} "

    	  choose do |e|
    	    e.prompt = "What would you like to do?"
    	    e.choice(:"Change Day Name" ) {wrapper{change_times}}
    	    e.choice(:"View Schedule" ) {wrapper{@current_day.publish}}
    	    e.choice(:"Add a Bread") {wrapper{@breads.add_bread(@which_day)}}
    	    e.choice(:"Delete a Bread" ) {wrapper{delete_menu(@which_day)}}
    	    e.choice(:"Edit a Bread's Info" ) {wrapper{BreadsMenu.new(@which_day, @breads).display_options}}
    	    e.choice(:"Return to Main Menu" ) {wrapper{MainMenu.new(@which_day, @breads).display_options}}
    	  end
      }
        
      super "Edit Menu", &menu
    end
  end

  class MainMenu < Menu
    def display_options
      menu = lambda {
        choose do |m|
          m.prompt = "What would you like to do?"
          m.choice(:"New Baking Day" ) {wrapper{@breads.new_day}}
          m.choice(:"Show All Current Schedules" ) {wrapper{@breads.publish_lists}}
          m.choice(:"Select a Day to View" ) {wrapper{which_list}}
          m.choice(:"Delete A Day" ) {wrapper{SchedulesMenu.new(@which_day, @breads).display_options; @breads.delete_day(@which_day)}}
          m.choice(:"Edit a Day" ) {wrapper{EditMenu.new(@which_day, @breads).display_options}}
          m.choice(:"Exit" ) {Process.exit}
        end
      }

      super "Main Menu", &menu
    end
  end

  class SchedulesMenu < Menu
    # where is this used such that it is different?
 	  def display_options # For returning a BreadCalc object value for a chosen day to the edit menu;
      print_menu_title("Schedules Menu")

      choose do |s|
        s.prompt = "Please choose a schedule."
        @breads.keys.each do |b|
          s.choice(:"#{b}") {@current_day = @breads[b]; @which_day = b}
        end
        s.choice(:"Return to Main Menu") {MainMenu.new(@which_day, @breads).display_options}
      end

      @which_day
    end
  end
end