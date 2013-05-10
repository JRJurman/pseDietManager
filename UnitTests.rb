# Created by Jesse Jurman
# UnitTests.rb
# Part of Project 3 PSE DietManager Project

require 'test/unit'
require 'stringio'
require './FoodDB.rb'
require './ICL.rb'
require './LogItem.rb'
require './Log.rb'

require 'date'

class UnitTests < Test::Unit::TestCase

  def setup
    @outBuffer = StringIO.new
    $stdout = @outBuffer
    @inBuffer = StringIO.new
    $stdin = @inBuffer

    @foodFile = File.open("./FakeDB.txt")
    @foodDb = FoodDB.new(@foodFile)
    @log = Log.new("./FakeLog.txt")

    @today = Date.today.strftime("%D")

    @icl = ICL.new( @foodDb, @log )
  end

  def test_logItem
    li = LogItem.new( "Jelly" )
    assert_equal( "Jelly", li.name )
    assert_equal( @today, li.date )
  end

  def test_logItem_date
    li = LogItem.new( "Jelly", "1/10/13" )
    assert_equal( "Jelly", li.name )
    assert_equal( "1/10/13", li.date )
  end

  def test_logItem_to_s
    li = LogItem.new( "Jelly", "1/10/13" )
    assert_equal( "1/10/13,Jelly", li.to_s )
  end

  def test_log
    newLog = Log.new( "./FakeLog.txt" )
    li = LogItem.new( "Jelly", "1/10/13" )
    newLog.add( li )
    assert_equal( "1/10/13\n  Jelly\n", newLog.show( "1/10/13" ) )
    li = LogItem.new( "Jello", "1/10/13" )
    newLog.add( li )
    assert_equal( "1/10/13\n  Jelly\n  Jello\n", newLog.show( "1/10/13" ) )
  end

  def test_log_save
    newLog = Log.new( "./FakeLog.txt" )
    assert_equal( true, newLog.saved? )
    li = LogItem.new( "Jelly", "1/10/13" )
    newLog.add( li )
    assert_equal( false, newLog.saved? )
    newLog.save
    assert_equal( true, newLog.saved? )
    check = ["  Jelly\n","1/10/13\n"]
    f = File.open("./FakeLog.txt", 'r')
    f.each do |line|
      assert_equal(check.pop(1)[0], line)
    end
  end

  def test_log_show_all
    newLog = Log.new( "./FakeLog.txt" )
    li = LogItem.new( "Jelly", "1/10/13" )
    newLog.add( li )
    assert_equal( "1/10/13\n  Jelly\n", newLog.show_all )
    li = LogItem.new( "Jello", "1/11/13" )
    newLog.add( li )
    assert_equal( "1/10/13\n  Jelly\n1/11/13\n  Jello\n", newLog.show_all )
  end

  def test_delete
    newLog = Log.new( "./FakeLog.txt" )
    li = LogItem.new( "Jelly", "1/10/13" )
    newLog.add( li )
    assert_equal( "1/10/13\n  Jelly\n", newLog.show_all )
    newLog.delete( "Jelly", "1/10/13" )
    assert_equal( "1/10/13\n", newLog.show_all )
  end

  def test_new_BasicFood
    bFoo = BasicFood.new( "foo", 3000 )
    assert_equal( "foo", bFoo.name )
    assert_equal( 3000, bFoo.cal )
  end

  def test_new_Recipe
    bFoo = BasicFood.new( "foo", 3000 )
    bar = [bFoo, bFoo, bFoo] 
    rBar = Recipe.new( "bar", bar )
    assert_equal( "bar", rBar.name )
    assert_equal( ["foo", "foo", "foo"], rBar.content )
  end

  def test_BasicFood_to_s
    assert_equal( "Jelly 155", @foodDb.get("Jelly").to_s )
  end

  def test_Recipe_to_s
    assert_equal( 
    "PB&J Sandwich 490\n  Bread slice (2) 160\n  Peanut butter 175\n  Jelly 155\n",
    @foodDb.get("PB&J Sandwich").to_s )
  end

  def test_food_get
    jellFood = BasicFood.new( "Jelly", 155 )
    assert_equal( jellFood.name, @foodDb.get("Jelly").name )
    assert_equal( jellFood.cal, @foodDb.get("Jelly").cal )
  end

  def test_foodDB_has
    assert_equal( false, @foodDb.has?("Jally") )
    assert_equal( true, @foodDb.has?("Jelly") )
  end

  def test_foodDB_parse
    assert_equal( ["Bread slice", 
                  "Jam",
                  "Jelly",
                  "Orange (medium)",
                  "Peanut butter"],
                  @foodDb.get_foods )
  end

  def test_recipe_parse
    assert_equal( ["PB&J Sandwich"], @foodDb.get_recipes )
  end

  def test_log_icl
    @inBuffer.reopen( "log Jelly" )
    @icl.step
    @outBuffer.rewind
    assert_equal( "#{@today}\n  Jelly\n", @log.show_all )
    assert_equal( "#{@today}\n  Jelly\n", @log.show( @today ) )
  end

  def test_icl_show
    @inBuffer.reopen( "log Jelly" )
    @icl.step
    @inBuffer.reopen( "show all" )
    @icl.step
    tracker = @outBuffer.pos
    @outBuffer.rewind
    assert_equal( "#{@today}\n  Jelly\n", @outBuffer.read )

    @inBuffer.reopen( "show #{@today}" )
    @icl.step
    @outBuffer.pos=tracker
    assert_equal( "#{@today}\n  Jelly\n", @outBuffer.read )
  end

  def test_icl_log_date
    @inBuffer.reopen( "log Jelly,1/10/13" )
    @icl.step
    @outBuffer.rewind
    assert_equal( "1/10/13\n  Jelly\n", @log.show( "1/10/13" ) )
    assert_equal( "1/10/13\n  Jelly\n", @log.show_all )
  end

  def test_ICL_print
    @inBuffer.reopen( "print Jelly" )
    @icl.step
    @outBuffer.rewind
    assert_equal( "Jelly 155\n", @outBuffer.read )
    tracker = @outBuffer.pos

    @inBuffer.reopen( "print PB&J Sandwich" )
    @icl.step
    @outBuffer.pos=tracker
    assert_equal(  
    "PB&J Sandwich 490\n  Bread slice (2) 160\n  Peanut butter 175\n  Jelly 155\n",
    @outBuffer.read )
  end

  def test_ICL_find
    @inBuffer.reopen( "find Jell" )
    @icl.step
    @outBuffer.rewind
    assert_equal( "Jelly 155\n", @outBuffer.read )
    tracker = @outBuffer.pos

    @inBuffer.reopen( "find J" )
    @icl.step
    @outBuffer.pos=tracker
    assert_equal( "Jelly 155\nJam 155\n", @outBuffer.read )
    tracker = @outBuffer.pos

    @inBuffer.reopen( "find j" )
    @icl.step
    @outBuffer.pos=tracker
    assert_equal( "Jelly 155\nJam 155\n", @outBuffer.read )
  end

  def test_ICL_print_all
    @inBuffer.reopen( "print all" )
    @icl.step
    @outBuffer.rewind
    assert_equal("Orange (medium) 67\n" +
                 "Bread slice 80\n" +
                 "Peanut butter 175\n" +
                 "Jelly 155\n" +
                 "Jam 155\n" +
                 "PB&J Sandwich 490\n  Bread slice (2) 160\n  Peanut butter 175\n  Jelly 155\n",
                  @outBuffer.read )
  end

  def test_FoodDB_add_food
    @foodDb.add("b","Jally",155)
    assert_equal( true, @foodDb.has?("Jally") )
  end

  def test_FoodDB_add_recipe
    jell = @foodDb.get("Jelly")
    @foodDb.add("r", "Super Jam", [jell, jell, jell])
    assert_equal( true, @foodDb.has?("Super Jam") )
  end

  def test_ICL_new_food
    @inBuffer.reopen( "new food Jelly,155" )
    @icl.step
    @outBuffer.rewind
    assert_equal( "ERROR: Food 'Jelly' already in database\n", @outBuffer.read )
    tracker = @outBuffer.pos

    @inBuffer.reopen( "new food Jello,155" )
    @icl.step
    assert_equal( true, @foodDb.has?("Jello") )
  end

  def test_ICL_new_recipe
    @inBuffer.reopen( "new recipe PB&J Sandwich,Jelly,Jelly" )
    @icl.step
    @outBuffer.rewind
    assert_equal( "ERROR: Recipe 'PB&J Sandwich' already in database\n", @outBuffer.read )
    tracker = @outBuffer.pos

    @inBuffer.reopen( "new recipe Super Jam,Jally,Jelly" )
    @icl.step
    @outBuffer.pos=tracker
    assert_equal( "ERROR: Food 'Jally' not in database\n", @outBuffer.read )
    tracker = @outBuffer.pos


    @inBuffer.reopen( "new recipe Super Jam,Jelly,Jelly" )
    @icl.step
    # I feel like there should be output, but it's not in the description,
    # and I don't want to break tests
    #@outBuffer.pos=tracker
    #assert_equal( @outBuffer.read, "ADDED RECIPE: 'Super Jam'")
    assert_equal( true, @foodDb.has?("Super Jam") )
  end

  def test_BasicFood_line
    assert_equal("Orange (medium),b,67", @foodDb.get("Orange (medium)").line) 
  end

  def test_Recipe_line
    assert_equal("PB&J Sandwich,r,Bread slice,Bread slice,Peanut butter,Jelly",
                    @foodDb.get("PB&J Sandwich").line) 
  end

  def test_FoodDB_to_txt
    assert_equal("Orange (medium),b,67\n"+
                 "Bread slice,b,80\n"+
                 "Peanut butter,b,175\n"+
                 "Jelly,b,155\n"+
                 "Jam,b,155\n"+
                 "PB&J Sandwich,r,Bread slice,Bread slice,Peanut butter,Jelly\n",
                 @foodDb.to_txt )

    @inBuffer.reopen( "new food Jello,155" )
    @icl.step
    assert_equal("Orange (medium),b,67\n"+
                 "Bread slice,b,80\n"+
                 "Peanut butter,b,175\n"+
                 "Jelly,b,155\n"+
                 "Jam,b,155\n"+
                 "PB&J Sandwich,r,Bread slice,Bread slice,Peanut butter,Jelly\n"+
                 "Jello,b,155\n",
                 @foodDb.to_txt )
  end

  def test_save_database
    assert_equal( false, @foodDb.has?("Jello") )
    @inBuffer.reopen( "new food Jello,155" )
    @icl.step
    assert_equal( false, @foodDb.saved? )
    @inBuffer.reopen( "save ./FakeDB2.txt" )
    @icl.step

    @foodFile2 = File.open("./FakeDB2.txt")
    @foodDb2 = FoodDB.new(@foodFile2)
    assert_equal( true, @foodDb2.has?("Jello") )
    assert_equal( true, @foodDb.saved? )
  end

#  def test_save_quit
#    backup = @foodDb
#    @inBuffer.reopen( "new food Jello,155" )
#    @icl.step
#    assert_equal( false, @foodDb.saved? )
#    
#    @inBuffer.reopen( "quit" )
#    @icl.step
#    @outBuffer.rewind
#    assert_equal( "Thank you, have a nice day\n", @outBuffer.read )
#    assert_equal( true, @foodDb.saved? )
#
#    backup.save( "./FakeDB.txt" )
#  end

  def test_quit
    @inBuffer.reopen( "quit" )
    @icl.step
    @outBuffer.rewind
    assert_equal( "Thank you, have a nice day\n", @outBuffer.read )
  end

  def tear_down
    $stdout = STDOUT
    $stdin = STDIN
    @outBuffer.close
    @inBuffer.close
    foodFile.close
  end

end
