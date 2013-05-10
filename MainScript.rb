# Created by Jesse Jurman
# MainScript.rb
# Part of Project 3 PSE DietManager Project

require './ICL.rb'

foodFile = File.open( "./FoodDB.txt" )
fdb = FoodDB.new( foodFile )
log = Log.new( "./DietLog.txt" )
icl = ICL.new( fdb, log )

icl.loop
