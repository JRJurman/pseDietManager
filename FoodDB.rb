# Created by Jesse Jurman
# FoodDB.rb
# Part of Project 3 PSE DietManager Project

require './BasicFood.rb'
require './Recipe.rb'

class FoodDB

  attr_accessor :foodbase, :path

  #   Creates a new food object,
  #   takes in a file object
  def initialize( file )
    @path = file.path
    @foodbase = Hash.new

    # for each line in the file
    # add the food/recipe object
    # to the database
    file.each do | line |

      line.chomp!
      sline = line.split(',')

      name = sline[0]
      case sline[1]
      when 'b'
        add( 'b', name, sline[2])
      when 'r'
        fList = []
        sline[2..-1].each { | food | fList += [@foodbase[food]] }
        add( 'r', name, fList )
      end

    end
    @save_check = true
  end

  #   Method to add foods to the database
  #   takes in a type ( 'b' | 'r' )
  #   a name ( a String )
  #   and various arguments ( calories or ingredients )
  def add( type, name, args )
    case type
    when "b"
      @foodbase[name] = BasicFood.new( name, args )
    when "r"
      @foodbase[name] = Recipe.new( name, args )
    end
    # since we have a new food, the database is no longer
    # in a saved state
    @save_check = false
  end

  #   returns a BasicFood or Recipe object given
  #   a string (which is the key to the foodbase object)
  def get( item )
    @foodbase[item]
  end

  #   Checks the foodbase if the given name is in the
  #   database, returns either true or false
  def has?( item )
    @foodbase.key?(item)
  end

  #   Returns all the BasicFoods in a sorted list
  def get_foods
    v = @foodbase.values
    res = v.inject([]) { | memo, i | i.class==BasicFood ? memo+[i.name] : memo }
    res.sort
  end

  #   Returns all the Recipes in a sorted list
  def get_recipes
    v = @foodbase.values
    res = v.inject([]) { | memo, i | i.class==Recipe ? memo+[i.name] : memo }
    res.sort
  end

  #   Method to get a file formated string
  #   of the current database
  def to_txt
    res = ""
    @foodbase.each { | k,v | res += "#{v.line}\n" }
    res
  end

  #   Saves the given database into a file.
  #   Takes in either a file object or a file path
  def save( file )
    if file.class == File
      p = file.path
    elsif file.class == String
      p = file
    end

    if p == nil
      p = @path
    end

    File.open( p, 'w' ) do | f |
      f.write( self.to_txt )
    end
    @save_check = true
  end

  #   Returns whether or not the database has been
  #   saved (either true or false)
  def saved?
    @save_check
  end

end
