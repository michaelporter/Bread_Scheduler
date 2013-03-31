require 'lib/database_aware.rb'

class Bread
  include DatabaseAware

  attr_accessor( 
    :bake, 
    :loaves, 
    :name, 
    :pan, 
    :pan_rise, 
    :rise
   )

  attr_reader :total

  def initialize(options)
    @bake = options[:bake].to_f || 35
    @loaves = options[:loaves] || 2
    @name = options[:name] || "New Bread, #{Time.now.strftime('%m:%h, %d/%m/%Y')}"
    @pan = options[:pan] || false
    @pan_rise = options[:pan_rise] || 0
    @rise = options[:rise].to_f || 120 
    @total = @rise + @bake + 20
  end

  def describe_bread
    puts "-----------------*********-----------------\n\n"
    puts " #{@name}:"
    puts "    Rise: #{@rise}"
    puts "    Bake: #{@bake}"
    puts "    Loaves: #{@loaves}"
    puts "\n-----------------*********-----------------\n"
  end
end
