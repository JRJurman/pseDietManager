# Created by Jesse Jurman
# BasicFood.rb
# Part of Project 3 PSE DietManager Project

class BasicFood

  attr_accessor :name, :cal

  #   Creates a new basic food object
  #   Takes in a name (string) and
  #   the number of calories (casts to int)
  def initialize( name, cal )
    @name = name
    @cal = cal.to_i
  end

  #   Returns a CSV formatted string
  #   with the name, type, and calories
  def line
    "#{@name},b,#{@cal}"
  end

  #   Returns a string
  #   with the name and calories
  def to_s
    "#{@name} #{@cal}"
  end

end
