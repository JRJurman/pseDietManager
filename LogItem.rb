# Created by Jesse Jurman
# LogItem.rb
# Part of Project 3 PSE DietManager Project

require 'date'

class LogItem

  attr_accessor :name, :date

  #   Method to create a new LogItem
  def initialize( name, date=Date.today.strftime("%D") )
    @name = name
    @date = date
  end

  #   Method to return a CSV string for the log
  def to_s
    "#{date},#{name}"
  end

  #   Equal Operator
  def ==(other)
    self.to_s == other.to_s
  end

end
