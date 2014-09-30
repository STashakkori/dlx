=begin

dlxassembler.rb - A simplified DLX assembler written by Sina Tashakkori.

     .---------------------------------.
     | Console message color reference |
     |---------------------------------|
     .--------.-------------------------------------------------------.
     |  cyan  | Normal execution program beginning and end indicators.|
     .--------.-------------------------------------------------------.
     | yellow | Normal execution program status messages.             |
     .--------.-------------------------------------------------------.
     |  red   | Error messages that result in program termination.    |
     .--------.-------------------------------------------------------.

=end 

require 'rsec'
require './binarytree'
include BinaryTree
include Rsec::Helpers

# Main - class that calls most of the methods involved in the dlxassembler program.
class Main
  @@instructionmap = Hash.new{|hsh,key|hsh[key] = {}}
  @@dlxfiletable = {}

  # Getter method for the instructionmap datastructure
  def instructionmap
    @@instructionmap
  end

  def filemap
    @@dlxfiletable
  end

  # Method that prints a beggining prompt for the assembler.
  def printBeginningMessage(color)
    puts color.cyan("\n\nDLXASSEMBLER RUNNING")
    puts color.cyan("======================================== START")
  end

  # Method that prints the ending prompt for the assembler.
  def end(color)
    puts color.cyan("DLXASSEMBLER FINISHED")
    puts color.cyan("======================================== END\n\n")
  end

  # Method that checks inputs to make sure that they are either an instruction information containing file
  # or a file of the proper dlx extenstion that will be used to produce output by the assembler..
  def validateInputs(color)
    puts color.yellow("VALIDATING INPUTS")
    puts color.yellow("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
    unless ARGV.length >= 4 # Ensure that we have at least all of the instruction info files and one .dlx file.                                                                                           puts color.red("Too few inputs given.")
      PUTS color.red("Need more inputs --> #{ARGV.length} given.")
      puts color.red("======================================== STOPPED")
      exit # Quit the program if inputs are too few.                                                                                                                                                         end
    end
    instructionFileNames = ["Itypes","Jtypes","Rtypes"] # An array of valid instruction info file names.                                                                                                     for i in 0..ARGV.length-1 # Loop through all the command line arguments.
    for i in 0..ARGV.length-1
      #if ARGV[i] == "Itypes" or ARGV[i] == "Jtypes" or ARGV[i] =="Rtypes" or File.extname(ARGV[i]) == ".dlx"
      if instructionFileNames.include? ARGV[i] or File.extname(ARGV[i]) == ".dlx" # Check if inputs are ok.
        puts color.yellow("#{ARGV[i]} file valid.")
      else puts color.red("#{ARGV[i]} is an invalid input.")
        puts color.red("======================================== STOPPED")
        exit
      end
    end
    puts color.yellow("---------------------------------------- DONE")
  end

  # Method that adds tokens taken from instruction info files to a map data structure that uses
  # opcode name as its main key.
  def initializeInstructionMap(color)
    puts color.yellow("CREATING INSTRUCTION MAP")
    puts color.yellow("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
    for i in 0..ARGV.length-1
      case ARGV[i]
      when "Itypes"
        itypecount = 0 # Keep track of how many itype instructions will be in the map.
	File.open(ARGV[i], 'r') do |f1| # Open Itypes file.
	while line = f1.gets
            opcode,encoding = line.chomp.split("\t")
            self.instructionmap[opcode].store "encoding",encoding.to_i
            self.instructionmap[opcode].store "type","i"
            self.instructionmap[opcode].store "functioncode",-1
            itypecount += 1
          end
        end
        puts color.yellow("Itypes downloaded ==> #{itypecount} instructions.")
      when "Jtypes"
        jtypecount = 0 # Keep track of how many jtype instructions will be in the map.
	File.open(ARGV[i], 'r') do |f1| # Open Jtypes file.
	while line = f1.gets
            opcode,encoding = line.chomp.split("\t")
            self.instructionmap[opcode].store "encoding",encoding.to_i
            self.instructionmap[opcode].store "type","j"
            self.instructionmap[opcode].store "functioncode",-1
            jtypecount += 1
          end
        end
        puts color.yellow("Jtypes downloaded ==> #{jtypecount} instructions.")
      when "Rtypes"
        rtypecount = 0 # Keep track of how many rtype instructions will be in the map.
	File.open(ARGV[i], 'r') do |f1| # Open Rtypes file.
	while line = f1.gets
            opcode,functioncode,encoding = line.chomp.split("\t")
            self.instructionmap[opcode].store "encoding",encoding.to_i
            self.instructionmap[opcode].store "type","r"
            self.instructionmap[opcode].store "functioncode",functioncode.to_i
            rtypecount += 1
          end
        end
        puts color.yellow("Rtypes downloaded ==> #{rtypecount} instructions.")
      end
    end
    puts color.yellow("---------------------------------------- DONE")
  end

  def processDlxFiles(color)
    puts color.yellow("PROCESSING DLX FILES")
    puts color.yellow("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
    memoryaddress = 0
    testnum = 5
    for i in 0..ARGV.length-1
      if File.extname(ARGV[i]) == ".dlx" # If the file is a .dlx file, we want to parse through it.
        file = File.open(ARGV[i], 'r') do |f1| # Open Itypes file.
          linearray = {}
          firstline = true
          while line = f1.gets
            if firstline then gotonext = 0
            else gotonext = 4
            end
            firstline = false
            memoryaddress = memoryaddress + gotonext
            formattedaddress = memoryaddress.to_s(16).rjust(8,"0")
            linearray.store(formattedaddress, line.chomp.split(" "))
          end
          self.filemap.store(ARGV[i],linearray)
          puts color.yellow("#{ARGV[i]} file processed.")
          #puts linearray
        end
      end
    end
    puts color.yellow("---------------------------------------- DONE")
  end

  def firstPass(color)
    puts color.yellow("FIRST PASS")
    puts color.yellow("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
    self.filemap.each do |item,price|
      puts color.yellow "symbol table created for #{item}"
    end
    puts color.yellow("---------------------------------------- DONE")
  end


  def increment(currentaddress)
    currentaddress += 4
  end

  def incrementaddress(currentaddress)
    i = 0
    while currentaddress[i] == 0 and i > -1
      i -= 1
    end
    currentaddress[i] = currentaddress[i] + 4
  end

  def addresstostring(address)
    address.join
  end

  #def parse line
  #  Hash.new = line.chomp.split("\t")
  #end
end


# Class that stores color codes and associated methods to be used throughout the assembler
#to print console messages in a variety of indicative hues.
class TextColor
  def colorize(text, color_code)
    "\e[#{color_code}m#{text}\e[0m"
  end
  def black(text); colorize(text, 30); end
  def red(text); colorize(text, 31); end
  def green(text); colorize(text, 32); end
  def yellow(text); colorize(text, 33); end
  def blue(text); colorize(text, 34); end
  def magenta(text); colorize(text, 35); end
  def cyan(text); colorize(text, 36); end
  def white(text); colorize(text, 37); end
  def default(text); colorize(text, 38); end
end

# Program execution
dlxassembler = Main.new
nicecolors = TextColor.new
dlxassembler.printBeginningMessage(nicecolors)
dlxassembler.validateInputs(nicecolors)
dlxassembler.initializeInstructionMap(nicecolors)
dlxassembler.processDlxFiles(nicecolors)
dlxassembler.firstPass(nicecolors)
dlxassembler.end(nicecolors)