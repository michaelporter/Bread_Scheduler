#!/usr/bin/env ruby

$: << File.join(File.dirname(__FILE__), "/..")

require 'lib/BasicMenu.rb'
require 'rubygems'
gem 'highline', '= 1.5.0'
require 'highline/import'

BreadMenus.new.begin
