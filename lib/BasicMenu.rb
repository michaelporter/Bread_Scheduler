require 'rubygems'
gem 'highline', '= 1.5.0'
require 'highline/import'
require 'lib/BreadClass.rb'
require 'lib/BreadHash.rb'

class BreadMenus

  def initialize
  @which_day = ""
  @breads = DayCollector.new
  end
  
  def main_menu
    @menu = :main
    loop do
    puts "\n\n\n\n\n\n\n\n-----------------*********-----------------\n\n"
    puts " MAIN MENU \n\n"
    puts "-----------------*********-----------------\n\n\n\n"
    
      choose do |m|
        m.prompt = "What would you like to do?"
        m.choice(:"New Baking Day" ) {wrapper{@breads.new_day}}
        m.choice(:"Show All Current Schedules" ) {wrapper{@breads.publish_lists}}
        m.choice(:"Select a Day to View" ) {wrapper{which_list}}
        m.choice(:"Delete A Day" ) {wrapper{day_menu; @breads.delete_day(@which_day)}}
        m.choice(:"Edit a Day" ) {wrapper{edit_menu(check_for_day)}}
        m.choice(:"Exit" ) {Process.exit}
      end
    end
  end
  
  def edit_menu(dayobjs)
    @menu = :edit
    loop do
      puts "\n\n\n\n\n-----------------*********-----------------"
      puts " You are editing for #{@which_day} "
      puts "-----------------*********-----------------\n\n"
      puts " EDIT MENU \n\n"
      puts "-----------------*********-----------------\n\n\n\n"
      choose do |e|
        e.prompt = "What would you like to do?"
        e.choice(:"Change Day Name" ) {wrapper{change_times}}
        e.choice(:"View Schedule" ) {wrapper{@day_obj.publish}}
        e.choice(:"Add a Bread") {wrapper{@breads.add_bread(@which_day)}}
        e.choice(:"Delete a Bread" ) {wrapper{delete_menu(@which_day)}}
        e.choice(:"Edit a Bread's Info" ) {wrapper{bread_menu}}
        e.choice(:"Return to Main Menu" ) {wrapper{main_menu}}
      end
    end
  end
  
  def delete_menu(which_day)
    @menu = :delete
    loop do
      puts "\n\n\n\n\n\n\n\n\n\n\n-----------------*********-----------------\n\n"
      puts " BREAD-DELETE MENU \n\n"
      puts "-----------------*********-----------------\n\n\n\n\n\n\n\n\n\n"
      sleep(0.8)
      @day_obj.publish
      puts "\n\n-----------------*********-----------------\n\n"
      sleep(1)
      
      choose do |b|
        b.prompt = "Which bread would you like to delete?"
        @day_obj.bread_list.each do |k|
          b.choice(:"#{k.name}") {wrapper{@breads.delete_bread(@which_day, k)}}
        end
        b.choice(:"Return to Edit Menu" ) {wrapper{edit_menu(check_for_day)}}
      end
    end
  end
  
  def bread_menu
    @menu = :bread
    loop do
      puts "\n\n\n\n\n\n\n\n\n\n-----------------*********-----------------\n\n"
      puts " BREADS MENU \n\n"
      puts "-----------------*********-----------------\n\n\n\n\n\n\n\n\n\n"
      sleep(0.8)
      @day_obj.bread_list.each do |k|
        k.publish_data
      end
      sleep(0.8)
      puts ""

      puts "Which bread would you like to edit?"
      
      choose do |p|
        p.prompt = ""
        @day_obj.bread_list.each do |k|
          p.choice(:"#{k.name}") {wrapper{data_menu(k)}}
        end
        p.choice(:"Return to Edit Menu") {wrapper{edit_menu(@which_day)}}
      end
    end
  end
  
  def data_menu(bread_choice)
    @menu = :data
    bread = bread_choice
    loop do
      puts "\n\n\n\n\n\n\n\n\n\n-----------------*********-----------------\n\n"
      puts " DATA EDITING MENU \n\n"
      puts "-----------------*********-----------------\n\n\n\n\n\n\n\n\n\n"
      sleep(0.7)
      bread.publish_data
    
      choose do |d|
        d.prompt = "Which piece of data would you like to edit?"
        d.choice(:"Name" ) {wrapper{@breads.edit_bread(@which_day, bread, :name)}}
        d.choice(:"Rise Time" ) {wrapper{@breads.edit_bread(@which_day, bread, :rise)}}
        d.choice(:"Bake Time" ) {wrapper{@breads.edit_bread(@which_day, bread, :bake)}}
        d.choice(:"Number of Loaves" ) {wrapper{@breads.edit_bread(@which_day, bread, :loaves)}}
        d.choice(:"Show Updated Schedule") {wrapper{@day_obj.publish}}
        d.choice(:"Choose a different bread" ) {wrapper{bread_menu}}
        d.choice(:"Return to Edit Menu" ) {wrapper{edit_menu(check_for_day)}}
        d.choice(:"Return to Main Menu" ) {wrapper{main_menu}}
      end
    end
  end

  def day_menu # For returning a BreadCalc object value for a chosen day to the edit menu;
      puts "\n\n\n\n\n\n\n\n\n\n\n\n-----------------*********-----------------\n\n"
      puts " DAYS MENU \n\n"
      puts "-----------------*********-----------------\n\n\n\n"
      choose do |s|
        s.prompt = "Please choose a schedule."
        @breads.keys.each do |b|
          s.choice(:"#{b}") {@day_obj = @breads[b]; @which_day = b}
        end
        s.choice(:"Return to Main Menu") {wrapper{main_menu}}
      end
    @which_day
  end

  def wrapper # Provides automatic option to return to the previous menu, or the most
              # sensible one following any major action;
    yield if block_given?
    
    if @menu == :main then which = "main "
    elsif @menu == :edit then which = "edit "
    elsif @menu == :delete then which = "delete "
    elsif @menu == :bread then which = "bread choice "
    elsif @menu == :data then which = "data choice "
    elsif @menu == :save then which = "save "
    end
    
    puts "\n\n"

    sleep(0.5)

    an = agree("Return to #{which}menu?") #by default continues on with loop if answer is positive;
    
    if an == false && @menu == :main
      say "Good-bye, and thank you!"
      Process.exit
    elsif an == false && @menu == :edit
      main_menu
    elsif an == false && @menu == :delete
      edit_menu(check_for_day)
    elsif an == true && @menu == :delete && !@breads.has_key?(@which_day)
      puts "This day is now empty, and has been deleted."
      puts "-----------------*********-----------------"
      sleep(0.2)
      main_menu
    elsif an == false && @menu == :bread
      edit_menu(check_for_day)
    elsif an == false && @menu == :data
      bread_menu
    elsif an == false && @menu == :day
      main_menu
    elsif an == false && @menu == :save
      main_menu
    end
  end
  
  def change_times
    new_which_day = @breads.change_date_and_time(@which_day)
    @day_obj = @breads[new_which_day]
    @which_day = new_which_day
  end
    
  def which_list
    if @breads.empty?
      puts "No recorded baking schedules."
    else
      day_menu
    
      if @breads.has_key?(@which_day)
        @day_obj.publish
      else
        puts "Sorry, could not find that list."
      end
    end
  end
    
  def check_for_day # Manages access to single baking days for editing;
    if @breads.length == 1
      @which_day = @breads.keys[0]
      @day_obj = @breads[@breads.keys[0]]
      puts "\n\n\n\n\n\n\n\n\n\n\n\n"
      puts "** NOTE: You only have one baking day saved. **"
      puts "\n\n\n\n\n\n\n\n\n\n\n"
      sleep(1)
    else
      day_menu
    end
  
    if @breads.has_key?(@which_day)
      puts "\n\n\n\n\n\n"
      @which_day
    else
      puts "Sorry, couldn't find that day!"
      main_menu
    end
  end

end