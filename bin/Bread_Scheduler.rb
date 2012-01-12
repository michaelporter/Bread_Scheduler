#!/usr/bin/ruby

require 'lib/BasicMenu.rb'
gem 'highline', '= 1.5.0'
require 'highline/import'


puts %Q{











  	*** Welcome to Mike's Baking Calculator! ***











}
main_menu = BreadMenus.new

sleep(1.5)

main_menu.main_menu