class Bread
  include TimeManipulation

  attr_accessor( 
    :bake, 
    :bake_at, 
    :done_at,
    :int_rise, 
    :loaves, 
    :name, 
    :need_pan, 
    :pan_at, 
    :pan_rise, 
    :rise, 
    :start_at, 
    :total 
   )
  
  def initialize(name, rise_time, bake_time, loaves, pan_rise = 0, need_pan = false)
    @bake = bake_time
    @loaves = loaves
    @name = name
    @need_pan = need_pan
    @pan_rise = pan_rise
    @rise = rise_time
    @total = rise_time + bake_time + 20
  end

  def describe_bread
    puts " #{@name}:"
    puts "    Rise: #{@rise}"
    puts "    Bake: #{@bake}"
    puts "    Loaves: #{@loaves}"
    puts "-----------------*********-----------------\n"
  end
end
