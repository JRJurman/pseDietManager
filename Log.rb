# Created by Jesse Jurman
# Log.rb
# Part of Project 3 PSE DietManager Project

require 'date'

class Log

  attr_accessor :path

  #   Creates a new Log object with
  #   the given path for saving
  def initialize( file_path )

    @path = file_path
    
    # dateHash is a hashtable of dates
    # to a list of LogItems
    @dateHash = Hash.new([])

    @save_check = true

  end

  #   Add method, which adds the given
  #   LogItem to the log stack
  def add( logItem )
    @save_check = false
    @dateHash[logItem.date] += [logItem]
  end

  #   Delete method, which removes a
  #   given item at a date
  def delete( name, date )
    @save_check = false
    @dateHash[date].delete( LogItem.new(name, date) )
  end

  #   Save method, which puts all the values
  #   into the file
  def save
    File.open( @path, 'w' ) do |f|
      f.write( show_all )
    end
    @save_check = true
  end

  def show( date )
    if date == nil
      date = Date.today.strftime("%D")
    end
    res = "#{date}\n"
    # Hash of LogItems to number of instances
    lList = Hash.new(0) 
    @dateHash[date].each {|l| lList[l] += 1 }
    lList.each { |k,v| res+= "  #{k.name}#{"(#{v})"if v > 1}\n" }
    res
  end

  def show_all
    res = ""
    @dateHash.each_key { |k| res += show(k) }
    res
  end
    
  def saved?
    @save_check
  end

end
