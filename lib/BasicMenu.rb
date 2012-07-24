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

    Menus::MainMenu.new(@which_day, @breads).display_options
  end

  def greeting
    %Q{











      *** Welcome to Mike's Baking Calculator! ***










    }
  end
end