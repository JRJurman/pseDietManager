# Created by Jesse Jurman
# ICL.rb
# Part of Project 3 PSE DietManager Project

require './FoodDB.rb'
require './Log.rb'
require './LogItem.rb'
require 'date'

class ICL

  attr_accessor :foodDB, :log, :commands

  #   Creates new instance of ICL
  #   Takes in a FoodDB object
  #   and a Log object
  def initialize( foodDatabase, log )
    @foodDB = foodDatabase
    @log = log

    # all possible commands are saved in a hash
    @commands = {
      "print"=> lambda{ | a | icl_print(a) },
      "find" => lambda{ | a | icl_find(a)  },
      "new"  => lambda{ | a | icl_new(a)   },
      "save" => lambda{ | a | icl_save(a)  },
      "delete"=>lambda{ | a | icl_delete(a)},
      "log"  => lambda{ | a | icl_log(a)   },
      "show" => lambda{ | a | icl_show(a)  },
      "quit" => lambda{ | a | icl_quit(a)  }
    }

  end

  #   The method to take in a command through $stdin
  #   It then passes that command (and args) into the
  #   commands Hash.
  def step
    n = gets
    if n == nil
      puts ""
      return 0
    end
    n.chomp!
    meth = n.split(' ')[0]
    if n.split(' ').size > 1
      arg = n[n.index(' ')..-1].strip
    else
      arg = nil
    end
    if commands.keys.include?(meth)
      commands[meth].call( arg )
    else
      puts "Command '#{meth}' not recognized."
    end
  end

  #   Method to keep prompting for commands
  #   Ends if step returns 0 (on quit)
  def loop
    puts "Diet Manager 3000!"
    puts "Created by Jesse Jurman"
    check = 1
    while check != 0
      print "> "
      check = step
    end
  end

  #   Find command that takes in a prefix
  #   and returns information on foods with
  #   the given prefix
  #   i.e. find j => "Jello 155\n Jam 155\n"
  def icl_find( args )
    prefix = args.downcase
    @foodDB.foodbase.each_key do | item |
      check = item.downcase
      if (check.index(prefix) == 0)
        icl_print( @foodDB.get(item) )
      end
    end
  end

  #   New command that takes in a string
  #   that is the type, name, and either
  #   the calories (if it is a food) or
  #   the ingredients (if it is a recipe)
  #   i.e. new food Jello,155
  def icl_new( args )
    type = args.split(" ")[0]

    if type == "food"
      foo = args.split(" ")[1].split(",")
      name = foo[0]
      cal = foo[1]
      if @foodDB.has?(name)
        puts "ERROR: Food '#{name}' already in database"
        return
      else
        @foodDB.add('b', name, cal)
      end

    elsif type == "recipe"
      name = args.split(",")[0].split(" ")[1..-1].join(" ")
      foods = args.split(",")[1..-1]
      fList = []
      foods.each do | food | 
        if !@foodDB.has?(food)
          puts "ERROR: Food '#{food}' not in database"
          return
        end

        fList += [@foodDB.get(food)]
      end


      if @foodDB.has?(name)
        puts "ERROR: Recipe '#{name}' already in database"
        return
      else
        @foodDB.add('r', name, fList)
      end
    end

  end

  #   Add an item to the log instance
  #   takes in a name and date
  #   i.e. log Jello
  #   or   log Jello,1/10/13
  def icl_log( args )
    lsplit = args.split(",")
    name = lsplit[0]
    if @foodDB.has?(name)
      date = lsplit[1] || Date.today.strftime("%D")
    else
      puts "'#{name}' not in database"
    end
    @log.add( LogItem.new(name, date) )
  end

  #   Show command that takes in a date and
  #   shows all the logged items
  def icl_show( args )
    if args == "all"
      puts @log.show_all
    else
      puts @log.show( args )
    end

  end

  #   Print command that takes in a name and 
  #   prints the information on that item
  #   Also takes in a BasicFood and Recipe object
  #   so that print_all can pass all FoodDB items
  #   i.e. print Jello => Jello 155
  def icl_print( args )
    item = args
    if item.class == String
      if item == "all"
        print_all
      elsif @foodDB.has?( item )
        icl_print( @foodDB.get(item) )
      end

    elsif item.class == BasicFood
      puts item

    elsif item.class == Recipe
      puts item
    end
  end

  #   Print all command that passes all the
  #   foodDB items and calls the print command
  def print_all
    @foodDB.foodbase.each_value do | item |
      icl_print( item )
    end
  end

  #   Save command that takes in a path
  #   and tells the FoodDB class to save
  #   the current state to a file
  def icl_save( args )
    @foodDB.save( args )
    @log.save()
  end

  #   Delete command that takes in a name
  #   and a date to delete from the log
  def icl_delete( args )
    prop = args.split(',')
    name = prop[0]
    date = prop[1]
    puts name + " " + date
    @log.delete( name, date )
  end

  #   Quit command that takes in no arguments
  #   Tells the system to quit and stops the loop
  def icl_quit( args )
    if !(@foodDB.saved?) || !(@log.saved?)
      icl_save( @foodDB.path )
    end

    puts "Thank you, have a nice day"
    return 0
  end

end
