#!/usr/bin/rvm-auto-ruby

require 'lib/BasicMenu.rb'
require 'rubygems'
gem 'highline', '= 1.5.0'
require 'highline/import'

puts %Q{\n\n\n\n\n\n\n\n\n\n\n\n*** Welcome to Mike's Baking Calculator! ***\n\n\n\n\n\n\n\n\n\n\n\n}
main_menu = BreadMenus.new

sleep(1.5)

main_menu.main_menu
