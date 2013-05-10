# Created by Jesse Jurman
# Recipe.rb
# Part of Project 3 PSE DietManager Project

require './BasicFood.rb'

class Recipe

  attr_accessor :name, :content, :basics, :cal

  #   Creates a new Recipe object,
  #   takes in a name (string) and
  #   a list of BasicFood objects
  def initialize( name, content )
    @name = name
    @basics = []
    @content = []
    @cal = 0
    content.each do |f| 
      @basics += [f]
      @content += [f.name]
      @cal += f.cal
    end
  end

  #   Method that returns a CSV formatted
  #   string with the name, type, and contents
  def line
    "#{@name},r,#{content.join(",")}"
  end

  #   Returns a print ready string of the
  #   Recpie name and all it's content
  def to_s
    hashCount = Hash.new(0)
    basics.each { | food | hashCount[food] += 1 }
    result = "#{@name} #{@cal}\n"
    hashCount.each do | food, c | 
      if c < 2
        result += "  #{food.to_s}\n"
      else
        result += "  #{food.name} (#{c}) #{food.cal*c}\n"
      end
    end
    result
  end

end
