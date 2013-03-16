#!/usr/bin/env ruby

$: << File.join(File.dirname(__FILE__), "/..")

require 'lib/BasicMenu.rb'
require 'rubygems'
gem 'highline'
require 'highline/import'

BreadMenus.new.begin
