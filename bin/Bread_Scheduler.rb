#!/usr/bin/env ruby

$: << File.join(File.dirname(__FILE__), "/..")

require 'lib/basic_menu.rb'
require 'rubygems'
gem 'highline'
require 'highline/import'

BreadMenus.new.begin
