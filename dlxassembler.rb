=begin

dlxassembler.rb - A simplified DLX assembler written in Ruby by Sina Tashakkori.

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

# Main - class that calls most of the methods involved in the dlxassembler program.
class Main
  @@instructionmap = Hash.new{|hash,key| hash[key] = {}}  # Datastructure that holds instruction type information.
  @@dlxfiletable = {} # Datastructure that holds linestructs keyed by file name.
  @@linestruct = Hash.new{|hash,key| hash[key] = {}} # Datastructure that holds lines from a .dlx file keyed by address.
  @@firstpasstables = Hash.new{|hash,key| hash[key] = {}} # Datastructure that holds symbol tables keyed by file name.
                                                          # Each symbol table holds addresses keyed by label name.

  # This map holds instruction structure keyed by the opcode. This is used for second pass encoding only.
  @@itypestructureref = {
    "nop" => "none",
    "trap" => "number",
    "j" => "name",
    "jal" => "name",
    "jr" => "gpr",
    "jalr" => "gpr",
    "beqz" => "gprname",
    "bnez" => "gprname",
    "movfp2i" => "gprfpr",
    "movd" => "dprdpr",
    "cvtf2i" => "fprfpr",
    "cvti2f" => "fprfpr",
    "movf" => "fprfpr",
    "lhi" => "gprnum",
    "movi2fp" => "fprgpr",
    "cvtd2f" => "fprdpr",
    "cvtd2i" => "fprdpr",
    "cvtf2d" => "dprfpr",
    "cvti2d" => "dprfpr",
    "addi" => "gprgprint",
    "seqi" => "gprgprint",
    "sgei" => "gprgprint",
    "sgti" => "gprgprint",
    "slei" => "gprgprint",
    "slti" => "gprgprint",
    "snei" => "gprgprint",
    "subi" => "gprgprint",
    "addui" => "gprgpruint",
    "andi" => "gprgpruint",
    "ori" => "gprgpruint",
    "slli" => "gprgpruint",
    "srai" => "gprgpruint",
    "srli" => "gprgpruint",
    "subui" => "gprgpruint",
    "xori" => "gprgpruint",
    "add" => "gprgprgpr",
    "addu" => "gprgprgpr",
    "and" => "gprgprgpr",
    "or" => "gprgprgpr",
    "seq" => "gprgprgpr",
    "sge" => "gprgprgpr",
    "sgt" => "gprgprgpr",
    "sle" => "gprgprgpr",
    "sll" => "gprgprgpr",
    "slt" => "gprgprgpr",
    "sne" => "gprgprgpr",
    "sra" => "gprgprgpr",
    "srl" => "gprgprgpr",
    "sub" => "gprgprgpr",
    "subu" => "gprgprgpr",
    "xor" => "gprgprgpr",
    "addd" => "dprdprdpr",
    "divd" => "dprdprdpr",
    "multd" => "dprdprdpr",
    "subd" => "dprdprdpr",
    "addf" => "fprfprfpr",
    "div" => "fprfprfpr",
    "divf" => "fprfprfpr",
    "divu" => "fprfprfpr",
    "mult" => "fprfprfpr",
    "multf" => "fprfprfpr",
    "multu" => "fprfprfpr",
    "subf" => "fprfprfpr",
    "lb" => "gproff",
    "lbu" => "gproff",
    "lh" => "gproff",
    "lhu" => "gproff",
    "lw" => "gproff",
    "ld" => "dproff",
    "lf" => "fproff",
    "sb" => "offgpr",
    "sh" => "offgpr",
    "sw" => "offgpr",
    "sd" => "offdpr",
    "sf" => "offfpr"
  }

  # Getter method for the instructionmap datastructure
  def instructionmap
    @@instructionmap
  end

  # Getter method for the dlxfiletable datastructure
  def filemap
    @@dlxfiletable  # Alias as filemap
  end

  # Getter method for the linestruct datastructure
  def linestruct
    @@linestruct
  end

  # Getter method for the firstpasstables datastructure
  def symboltables
    @@firstpasstables # Alias as symboltables
  end

  # Getter method for the itypestructionref datastructure
  def imap
    @@itypestructureref # Alias as imap
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
      puts color.red("Need more inputs --> #{ARGV.length} given.")
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
            self.instructionmap[opcode].store("encoding",encoding.to_i)
            self.instructionmap[opcode].store("type","i")
            self.instructionmap[opcode].store("functioncode",-1)
            itypecount += 1
          end
        end
        puts color.yellow("Itypes downloaded ==> #{itypecount} instructions.")
      when "Jtypes"
        jtypecount = 0 # Keep track of how many jtype instructions will be in the map.
	File.open(ARGV[i], 'r') do |f1| # Open Jtypes file.
	while line = f1.gets
            opcode,encoding = line.chomp.split("\t")
            self.instructionmap[opcode].store("encoding",encoding.to_i)
            self.instructionmap[opcode].store("type","j")
            self.instructionmap[opcode].store("functioncode",-1)
            jtypecount += 1
          end
        end
      when "Rtypes"
        rtypecount = 0 # Keep track of how many rtype instructions will be in the map.
	File.open(ARGV[i], 'r') do |f1| # Open Rtypes file.
	while line = f1.gets
            opcode,encoding,functioncode = line.chomp.split("\t")
            self.instructionmap[opcode].store("encoding",encoding.to_i)
            self.instructionmap[opcode].store("type","r")
            self.instructionmap[opcode].store("functioncode",functioncode.to_i)
            rtypecount += 1
          end
        end
        puts color.yellow("Rtypes downloaded ==> #{rtypecount} instructions.")
      end
    end
    puts color.yellow("---------------------------------------- DONE")
  end

  # Convert DLX files to internal datastructures.
  def processDlxFiles(color)
    puts color.yellow("PROCESSING DLX FILES")
    puts color.yellow("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")

    # Loop through every command line argument.
    for i in 0..ARGV.length-1
      if File.extname(ARGV[i]) == ".dlx" # If the file is a .dlx file, we want to parse through it.
        # Loop through every line .dlx file.
        file = File.open(ARGV[i], 'r') do |f1|
          memoryaddress = 0
          rightafterdirective = false
          opcode = false
          directive1 = false
          directive2 = false
          first = true
          datasize = Array.new
          data = Array.new
          datastrings = Array.new
          gotonext = 0 # We start the addresses at x00000000 and offset of 0

          # The loop logic.
          f1.each_line do |line|

            # Ignore lines that are empty.
            unless line.chomp.split(" ").any?
              next
            end

            line.gsub!(",",' ') # Rid the line of all commas and substitute for spaces.
            line.gsub!('\t',' ') # Rid the line of all tab characters and substitute for spaces.
            currentline = line.chomp.split(/\s+(?=(?:[^"]*"[^"]*")*[^"]*\z)/) # Split the line on all spaces not inside quotation marks.

            if currentline[0].empty?
              currentline.shift end

              # Check the line's first element in order to identify how to manipulate memoryaddress, then pass the line
              # to the appropriate function to manipulate the memoryaddress accordingly.
              case currentline[0]
                when /\.text/
                  memoryaddress = textdirective(memoryaddress,currentline)
                  directive1 = true

                when /\.data/
                  memoryaddress = datadirective(memoryaddress,currentline)
                  directive1 = true

                when /\.align/
                  memoryaddress = aligndirective(memoryaddress,currentline,gotonext)
                  directive1 = true

                when /\.asciiz/
                  datasize,datastrings = asciizdirective(currentline,datasize,datastrings,false)
                  directive2 = true
                  rightafterdirective = false

                when /\.double/
                  datasize,datastrings = doubledirective(currentline,datasize,datastrings,false)
                  directive2 = true
                  rightafterdirective = false

                when /\.float/
                  datasize,datastrings = floatdirective(currentline,datasize,datastrings,false)
                  directive2 = true
                  rightafterdirective = false

                when /\.word/
                  datasize,datastrings = worddirective(currentline,datasize,datastrings,false)
                  directive2 = true
                  rightafterdirective = false

                when /\.space/
                  memoryaddress = spacedirective(memoryaddress,currentline,gotonext,false)
                  directive3 = true

                # Ignore semicolons.
                when ";"
                  directive1, directive2, opcode, rightafterdirective = false

                # If the line starts with a label, identify the type of command by the next element.
                when /[a-z][a-zA-Z0-9]*:/
                    if currentline[1] =~ /;/ or currentline.length == 1
                      currentline[1] = "nop"
                      memoryaddress += gotonext
                      rightafterdirective = true
                    elsif currentline[1] =~ /\.text/
                      memoryaddress = textdirective(memoryaddress,currentline)
                      directive1 = true
                    elsif currentline[1] =~ /\.data/
                      memoryaddress = datadirective(memoryaddress,currentline)
                      directive1 = true
                    elsif currentline[1] =~ /\.align/
                      memoryaddress = aligndirective(memoryaddress,currentline,gotonext)
                      directive1 = true
                    elsif currentline[1] =~ /\.asciiz/
                      datasize,datastrings = asciizdirective(currentline,datasize,datastrings,true)
                      directive2 = true
                      rightafterdirective = false
                    elsif currentline[1] =~ /\.double/
                      datasize,datastrings = doubledirective(currentline,datasize,datastrings,true)
                      directive2 = true
                      rightafterdirective = false
                    elsif currentline[1] =~ /\.float/
                      datasize,datastrings = floatdirective(currentline,datasize,datastrings,true)
                      directive2 = true
                      rightafterdirective = false
                    elsif currentline[1] =~ /\.word/
                      rightafterdirective = false
                      datasize,datastrings = worddirective(currentline,datasize,datastrings,true)
                      directive2 = true
                    elsif currentline[1] =~ /\.space/
                      memoryaddress = spacedirective(memoryaddress,currentline,gotonext,true)
                      directive3 = true
                    else
                      opcode = true
                    end
                else opcode = true
                end

              #Case 1 : Line is right after a directive
              if(rightafterdirective)
                formattedaddress = memoryaddress.to_s(16).rjust(8,"0")
                self.linestruct[formattedaddress].store("line", currentline)
                gotonext = 4
                rightafterdirective = false
                opcode = false
                directive1 = false
                directive2 = false

              # Case 2 : Line contains an opcode
              elsif(opcode)
                memoryaddress += gotonext
                formattedaddress = memoryaddress.to_s(16).rjust(8,"0")
                self.linestruct[formattedaddress].store("line", currentline)
                gotonext = 4
                rightafterdirective = false
                opcode = false

              #Case 3 : Line is a directive
              elsif(directive1)
                directive1 = false
                directive2 = false
                opcode = false
                rightafterdirective = true


              #Case 4 : Line is a directive
              elsif(directive2)
                directive2 = false
                opcode = false
                rightafterdirective = true
                currentline.unshift("#{datasize.length}")
                for j in 0..datasize.length-1
                  formattedaddress = memoryaddress.to_s(16).rjust(8,"0")
                  self.linestruct[formattedaddress].store("line", currentline)
                  memoryaddress += datasize[j]
                end

              #Case 3 : Line is a directive
              elsif(directive3)
                  if !first
                    gotonext = 4
                  end
                directive1 = false
                directive2 = false
                opcode = false
                rightafterdirective = false
              end
            end
          first = false
          self.filemap.store(ARGV[i],self.linestruct.clone)
          puts color.yellow("#{ARGV[i]} file processed.")
        end
        linestruct.clear
      end
    end
    puts
    puts color.yellow("---------------------------------------- DONE")
  end

  # First pass of the assembler in which it scans through the files looking for
  # labels and once it finds them, adds them and the address at which they occur
  # into a datastructure known by most as the symbol table.
  def firstPass(color)
    puts color.yellow("FIRST PASS")
    puts color.yellow("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
    self.filemap.each do |nameoffile,filebody|
      filebody.each do |formattedaddress,linestring|
        # Build symbol tables for each dlx file input
        if linestring["line"][0] =~ /[a-z][a-zA-Z0-9]*:/
          self.symboltables[nameoffile].store(linestring["line"][0],formattedaddress)
        end
        if linestring["line"][1] =~ /[a-z][a-zA-Z0-9]*:/
          self.symboltables[nameoffile].store(linestring["line"][1],formattedaddress)
        end
      end
      puts color.yellow "symbol table created for #{nameoffile}"
    end
    puts color.yellow("---------------------------------------- DONE")
  end

  # Second pass of the assembler. Responsible for encoding instructions into hex and writing those values along with
  # corresponding addresses to a .hex file
  def secondPass(color)
    puts color.yellow("SECOND PASS")
    puts color.yellow("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
    datacounter = 0
    self.filemap.each do |nameoffile,filebody|
      newfilename = nameoffile.gsub(".dlx",".hex")
      hexfile = File.new("#{newfilename}","w")

      filebody.each do |formattedaddress,linestring|

        # Section handles lines headed with a decimal number that is used internally to identify which
        # subsequent addressed lines belong to the same directive. This is to ensure that they get treated
        # as needed based on what type of directive the subsequent lines belong to.
        if(linestring["line"][0] =~ /[\-]{0,1}\b([0-9]|[1-9][0-9]*)\b/)
          if datacounter == 0
            datacounter = linestring["line"][0].to_i
          end

          case linestring["line"][1]

            # Label first
            when /[a-z][a-zA-Z0-9]*:/
              if linestring["line"][2] =~ /(\.[a-zA-Z]+)/
                direncoding = encodedirective(nameoffile,formattedaddress,linestring["line"],self.symboltables,instructionmap,true, true, datacounter)
                directive = true
              else linestring["line"][2] =~ /[a-zA-Z][a-zA-Z0-9]*/
                  encoding = encodeopcode(nameoffile,formattedaddress,linestring["line"],self.symboltables,instructionmap,true)
              end

            # Directive
            when /(\.[a-zA-Z]+)/
              direncoding = encodedirective(nameoffile,formattedaddress,linestring["line"],self.symboltables,instructionmap,false, true, datacounter)
              directive = true

            # Opcode first
            when /[a-zA-Z][a-zA-Z0-9]*/
              encoding = encodeopcode(nameoffile,formattedaddress,linestring["line"],self.symboltables,instructionmap,false)
          end
          datacounter -= 1
        else
          # If the line is not headed with a decimal number, we encode it as the line itself specifies.
          case linestring["line"][0]

            # Label
            when /[a-z][a-zA-Z0-9]*:/
              if linestring["line"][1] =~ /(\.[a-zA-Z]+)/
                direncoding = encodedirective(nameoffile,formattedaddress,linestring["line"],self.symboltables,instructionmap,true,false, 0)
                directive = true
              else linestring["line"][1] =~ /[a-zA-Z][a-zA-Z0-9]*/
                encoding = encodeopcode(nameoffile,formattedaddress,linestring["line"],self.symboltables,instructionmap,true)
              end

            # Directive
            when /(\.[a-zA-Z]+)/
              direncoding = encodedirective(nameoffile,formattedaddress,linestring["line"],self.symboltables,instructionmap,false,false, 0)
              directive = true

            # Opcode
            when /[a-zA-Z][a-zA-Z0-9]*/
              encoding = encodeopcode(nameoffile,formattedaddress,linestring["line"],self.symboltables,instructionmap,false)
          end
        end
        if directive == true
          hexfile.syswrite(formattedaddress + ": " + direncoding + "\t#" + "\n")
          else hexfile.syswrite(formattedaddress + ": " + encoding.to_s(16).rjust(8,"0") + "\t#" + "\n")
        end
        directive = false
      end
      puts color.yellow "#{newfilename} file written"
      hexfile.close
    end
    puts color.yellow("---------------------------------------- DONE")
  end

  # Datastructure references used for the encoding of .dlx files to .hex files.

  #############################################################################
  #               opcodereference datastructure reference
  #############################################################################
  # opcodereference["opcode"]["encoding"] => encoding of type integer
  # opcodereference["opcode"]["type"] => instruction of type string
  # opcodereference["opcode"]["functioncode"] => function code of type integer
  #############################################################################

  #############################################################################
  #                  symboltable datastructure reference
  #############################################################################
  # symboltable["filename"]["label"] => address of type string
  #############################################################################

  # encodeopcode : method that encodes instructions by using a passed in line parameter
  #                and then indentifying the instruction by its opcode.
  def encodeopcode(filename,address,line,symboltable,opcodereference,labelflag)
    encodedline = 0
    twentysixbitmask = 0x3FFFFFF
    sixteenbitmask = 0xFFFF
    labelflag ? opcodeelement = 1 : opcodeelement = 0
    operandelement = opcodeelement + 1

    encodingvalue = opcodereference[line[opcodeelement]]["encoding"].to_s.to_i
    opcodetype = opcodereference[line[opcodeelement]]["type"].to_s
    functioncode = opcodereference[line[opcodeelement]]["functioncode"].to_s.to_i

    if opcodetype == "i"
      case self.imap[line[opcodeelement]]
        when "none"
          # Do nothing. Literally.

        when "number"
          encodedline = encodingvalue
          encodedline <<= (32-6)
          operand = line[operandelement].to_i
          encodedline |= operand

        when "gpr"
          targetaddress = 0
          encodedline = encodingvalue
          encodedline <<= (32 - 6)
          destinreg = line[operandelement].gsub!("r",'').to_i
          targetaddress |= destinreg
          targetaddress <<= (32 - 6 - 5)
          encodedline |= targetaddress

        when "gprname"
          pc = address.hex + 4
          targetaddress = 0
          labelelement = operandelement + 1
          encodedline = encodingvalue
          encodedline <<= (32 - 6)
          destinreg = line[operandelement].gsub!("r",'').to_i
          targetaddress |= destinreg
          targetaddress <<= (32 - 6 - 5)
          encodedline |= targetaddress
          targetaddress = 0
          label = line[labelelement] + ":"
          targetaddress |= symboltable[filename][label].hex
          targetaddress = (targetaddress - pc).to_i
          targetaddress &= sixteenbitmask
          encodedline |= targetaddress

        when "gprnum"
          encodedline = encodingvalue
          encodedline <<= (32 - 6)
          destinreg = line[operandelement].gsub!("r",'').to_i
          destinreg <<= (32 - 6 - 5 - 5)
          encodedline |= destinreg
          immfield = operandelement + 1
          immediate = line[immfield].to_i
          encodedline |= immediate

        when "gprgprint"
          encodedline = encodingvalue
          encodedline <<= (32 - 6)
          destinreg = line[operandelement+1].gsub!("r",'').to_i
          destinreg <<= (32 - 6 - 5)
          encodedline |= destinreg
          sourcereg = line[operandelement].gsub!("r",'').to_i
          sourcereg <<= (32 - 6 - 5 - 5)
          encodedline |= sourcereg
          immelement = operandelement + 2
          immedfield = line[immelement] + ":"
          if symboltable[filename].has_key?(immedfield)
            immediate = symboltable[filename][immedfield].hex
          else immediate = line[immelement].to_i
          end
          encodedline |= immediate

        when "gprgpruint"
          encodedline = encodingvalue
          encodedline <<= (32 - 6)
          destinreg = line[operandelement+1].gsub!("r",'').to_i
          destinreg <<= (32 - 6 - 5)
          encodedline |= destinreg
          sourcereg = line[operandelement].gsub!("r",'').to_i
          sourcereg <<= (32 - 6 - 5 - 5)
          encodedline |= sourcereg
          immelement = operandelement + 2
          immedfield = line[immelement] + ":"
          if symboltable[filename].has_key?(immedfield)
            immediate = symboltable[filename][immedfield].hex
          else immediate = line[immelement].to_i
          end
          encodedline |= immediate

        when "dproff"
          encodedline = encodingvalue
          encodedline <<= (32 - 6)
          immelement = operandelement + 1
          immedfield = line[immelement] + ":"
          if symboltable[filename].has_key?(immedfield)
            offset = symboltable[filename][immedfield].hex
            sourcereg = 0
          else
            operandpieces = line[operandelement+1].split("(")
            operandpieces[1].gsub!("r",'').to_i
            operandpieces[1].gsub!(")",'').to_i
            offset = operandpieces[0].to_i
            sourcereg = operandpieces[1].to_i
          end
          sourcereg <<= (32 - 6 - 5)
          encodedline |= sourcereg
          destinreg = line[operandelement].gsub("f",'').to_i
          destinreg <<= (32 - 6 - 5 -5)
          encodedline |= destinreg
          encodedline |= offset

        when "gproff"
          encodedline = encodingvalue
          encodedline <<= (32 - 6)
          immelement = operandelement + 1
          immedfield = line[immelement] + ":"
          if symboltable[filename].has_key?(immedfield)
            offset = symboltable[filename][immedfield].hex
            sourcereg = 0
          else
            operandpieces = line[operandelement+1].split("(")
            operandpieces[1].gsub!("r",'').to_i
            operandpieces[1].gsub!(")",'').to_i
            offset = operandpieces[0].to_i
            sourcereg = operandpieces[1].to_i
          end
          sourcereg <<= (32 - 6 - 5)
          encodedline |= sourcereg
          destinreg = line[operandelement].gsub("r",'').to_i
          destinreg <<= (32 - 6 - 5 -5)
          encodedline |= destinreg
          encodedline |= offset

        when "fproff"
          encodedline = encodingvalue
          encodedline <<= (32 - 6)
          immelement = operandelement + 1
          immedfield = line[immelement] + ":"
          if symboltable[filename].has_key?(immedfield)
            offset = symboltable[filename][immedfield].hex
            sourcereg = 0
          else
            operandpieces = line[operandelement+1].split("(")
            operandpieces[1].gsub!("r",'').to_i
            operandpieces[1].gsub!(")",'').to_i
            offset = operandpieces[0].to_i
            sourcereg = operandpieces[1].to_i
          end
          sourcereg <<= (32 - 6 - 5)
          encodedline |= sourcereg
          destinreg = line[operandelement].gsub("f",'').to_i
          destinreg <<= (32 - 6 - 5 -5)
          encodedline |= destinreg
          encodedline |= offset

        when "offgpr"
          encodedline = encodingvalue
          encodedline <<= (32 - 6)
          immedfield = line[operandelement] + ":"
          if symboltable[filename].has_key?(immedfield)
            offset = symboltable[filename][immedfield].hex
            sourcereg = 0
          else
            operandpieces = line[operandelement].split("(")
            operandpieces[1].gsub!("r",'').to_i
            operandpieces[1].gsub!(")",'').to_i
            offset = operandpieces[0].to_i
            sourcereg = operandpieces[1].to_i
          end
          sourcereg <<= (32 - 6 - 5)
          encodedline |= sourcereg
          destinreg = line[operandelement+1].gsub("r",'').to_i
          destinreg <<= (32 - 6 - 5 -5)
          encodedline |= destinreg
          offset &= sixteenbitmask
          encodedline |= offset

        when "offdpr"
          encodedline = encodingvalue
          encodedline <<= (32 - 6)
          immedfield = line[operandelement] + ":"
          if symboltable[filename].has_key?(immedfield)
            offset = symboltable[filename][immedfield].hex
            sourcereg = 0
          else
            operandpieces = line[operandelement].split("(")
            operandpieces[1].gsub!("r",'').to_i
            operandpieces[1].gsub!(")",'').to_i
            offset = operandpieces[0].to_i
            sourcereg = operandpieces[1].to_i
          end
          sourcereg <<= (32 - 6 - 5)
          encodedline |= sourcereg
          destinreg = line[operandelement+1].gsub("f",'').to_i
          destinreg <<= (32 - 6 - 5 -5)
          encodedline |= destinreg
          offset &= sixteenbitmask
          encodedline |= offset

        when "offfpr"
          encodedline = encodingvalue
          encodedline <<= (32 - 6)
          immedfield = line[operandelement] + ":"
          if symboltable[filename].has_key?(immedfield)
            offset = symboltable[filename][immedfield].hex
            sourcereg = 0
          else
            operandpieces = line[operandelement].split("(")
            operandpieces[1].gsub!("r",'').to_i
            operandpieces[1].gsub!(")",'').to_i
            offset = operandpieces[0].to_i
            sourcereg = operandpieces[1].to_i
          end
          sourcereg <<= (32 - 6 - 5)
          encodedline |= sourcereg
          destinreg = line[operandelement+1].gsub("f",'').to_i
          destinreg <<= (32 - 6 - 5 -5)
          encodedline |= destinreg
          offset &= sixteenbitmask
          encodedline |= offset
      end

    elsif opcodetype == "j" && self.imap[line[opcodeelement]] == "name"

      pc = address.hex + 4
      encodedline = encodingvalue
      encodedline <<= (32 - 6)
      label = line[operandelement] + ":"
      labeladdress = symboltable[filename][label].hex
      targetaddress = (labeladdress - pc).to_i
      targetaddress &= twentysixbitmask
      encodedline |= targetaddress

    # If the instruction is an rtype instruction, it gets encoded in the following section.
    elsif opcodetype == "r"
      case self.imap[line[opcodeelement]]
        when "gprfpr"
          encodedline = encodingvalue
          encodedline <<= (32 - 6)
          sourcereg1 = line[operandelement+1].gsub!("f",'').to_i
          sourcereg1 <<= (32 - 6 - 5)
          encodedline |= sourcereg1
          destinreg = line[operandelement].gsub!("r",'').to_i
          destinreg <<= (32 - 6 - 5 - 5 - 5)
          encodedline |= destinreg
          encodedline |= functioncode

        when "dprdpr"
          encodedline = encodingvalue
          encodedline <<= (32 - 6)
          sourcereg1 = line[operandelement+1].gsub!("f",'').to_i
          if sourcereg1 % 2 != 0
            puts "error in register operand for movd"
            exit
          end
          sourcereg1 <<= (32 - 6 - 5)
          encodedline |= sourcereg1
          destinreg = line[operandelement].gsub!("f",'').to_i
          if destinreg % 2 != 0
            puts "error in register operand for movd"
            exit
          end
          destinreg <<= (32 - 6 - 5 - 5 - 5)
          encodedline |= destinreg
          encodedline |= functioncode

        when "fprfpr"
          encodedline = encodingvalue
          encodedline <<= (32 - 6)
          sourcereg1 = line[operandelement+1].gsub!("f",'').to_i
          sourcereg1 <<= (32 - 6 - 5)
          encodedline |= sourcereg1
          destinreg = line[operandelement].gsub!("f",'').to_i
          destinreg <<= (32 - 6 - 5 - 5 - 5)
          encodedline |= destinreg
          encodedline |= functioncode

        when "fprgpr"
          encodedline = encodingvalue
          encodedline <<= (32 - 6)
          sourcereg1 = line[operandelement+1].gsub!("r",'').to_i
          sourcereg1 <<= (32 - 6 - 5)
          encodedline |= sourcereg1
          destinreg = line[operandelement].gsub!("f",'').to_i
          destinreg <<= (32 - 6 - 5 - 5 - 5)
          encodedline |= destinreg
          encodedline |= functioncode

        when "fprdpr"
          newpiece = 0
          encodedline |= encodingvalue
          encodedline <<= (32 - 6)
          sourcereg1 = line[operandelement+1].gsub!("f",'').to_i
          sourcereg1 <<= (32 - 6 - 5)
          encodedline |= sourcereg1
          destinreg = line[operandelement].gsub!("f",'').to_i
          destinreg <<= (32 - 6 - 5 - 5 - 5)
          encodedline |= destinreg
          encodedline |= functioncode

        when "dprfpr"
          encodedline = encodingvalue
          encodedline <<= (32 - 6)
          sourcereg1 = line[operandelement+1].gsub!("f",'').to_i
          sourcereg1 <<= (32 - 6 - 5)
          encodedline |= sourcereg1
          destinreg = line[operandelement].gsub!("f",'').to_i
          destinreg <<= (32 - 6 - 5 - 5 - 5)
          encodedline |= destinreg
          encodedline |= functioncode

        when "gprgprgpr"
          encodedline = encodingvalue
          encodedline <<= (32 - 6)
          sourcereg1 = line[operandelement+1].gsub!("r",'').to_i
          sourcereg1 <<= (32 - 6 - 5)
          encodedline |= sourcereg1
          sourcereg2 = line[operandelement+2].gsub!("r",'').to_i
          sourcereg2 <<= (32 - 6 - 5 - 5)
          encodedline |= sourcereg2
          destinreg = line[operandelement].gsub!("r",'').to_i
          destinreg <<= (32 - 6 - 5 - 5 - 5)
          encodedline |= destinreg
          encodedline |= functioncode

        when "dprdprdpr"
          encodedline = encodingvalue
          encodedline <<= (32 - 6)
          sourcereg1 = line[operandelement+1].gsub!("f",'').to_i
          sourcereg1 <<= (32 - 6 - 5)
          encodedline |= sourcereg1
          sourcereg2 = line[operandelement+2].gsub!("f",'').to_i
          sourcereg2 <<= (32 - 6 - 5 - 5)
          encodedline |= sourcereg2
          destinreg = line[operandelement].gsub!("f",'').to_i
          destinreg <<= (32 - 6 - 5 - 5 - 5)
          encodedline |= destinreg
          encodedline |= functioncode

        when "fprfprfpr"
          encodedline = encodingvalue
          encodedline <<= (32 - 6)
          sourcereg1 = line[operandelement+1].gsub!("f",'').to_i
          sourcereg1 <<= (32 - 6 - 5)
          encodedline |= sourcereg1
          sourcereg2 = line[operandelement+2].gsub!("f",'').to_i
          sourcereg2 <<= (32 - 6 - 5 - 5)
          encodedline |= sourcereg2
          destinreg = line[operandelement].gsub!("f",'').to_i
          destinreg <<= (32 - 6 - 5 - 5 - 5)
          encodedline |= destinreg
          encodedline |= functioncode
      end
    end
    encodedline
  end

  # encodedirective : method that returns a string encoding depending on the type of directive that is passed to
  #                   the method.
  def encodedirective(filename,address,line,symboltable,opcodereference,labelflag, indexedflag, dataitemcount)
    encodedline = 0
    sixtyfourbitmask = 0xFFFFFFFFFFFFFFFF  # Mask used for Double precision numbers.
    thirtytwobitmask = 0xFFFFFFFF          # Mask used for single precision numbers.

    if indexedflag && labelflag
      directiveelement = 2
    elsif !labelflag && !indexedflag
      directiveelement = 0
    else directiveelement = 1
    end

    dataindex = line.length - dataitemcount # Calculate where the data operand is in the line

    # Check the first element of the line for a directive.
    case line[directiveelement]

      # Check for a .text directive. Once found, encode it accordingly.
      when /\.text/
        line[dataindex] = line[dataindex].chomp('"').reverse.chomp('"').reverse
        encodedline = line[dataindex].unpack('U'*line[dataindex].length).collect {|x| x.to_s 16}.join

      # Check for a .asciiz directive. Once found, encode it accordingly.
      when /\.asciiz/
        line[dataindex] = line[dataindex].chomp('"').reverse.chomp('"').reverse
        encodedline =  line[dataindex].unpack('U'*line[dataindex].length).collect {|x| x.to_s 16}.join
        encodedline <<= "00"

      # Check for a .double directive. Once found, encode it accordingly.
      when /\.double/
        line[dataindex] = line[dataindex].chomp('"').reverse.chomp('"').reverse
        float = line[dataindex].to_f
        maskedfloat = [float].pack('E').unpack('l_')[0] & sixtyfourbitmask
        encodedline = maskedfloat.to_s(16)

      # Check for a .float directive. Once found, encode it accordingly.
      when /\.float/
        line[dataindex] = line[dataindex].chomp('"').reverse.chomp('"').reverse
        float = line[dataindex].to_f
        encodedline = [float].pack('F').unpack('L')[0].to_s(16)

      # Check for a .double directive. Once found, encode it accordingly.
      when /\.word/
        line[dataindex] = line[dataindex].chomp('"').reverse.chomp('"').reverse
        if line[dataindex] =~ /0x[0-9a-fA-F]+/
          string = line[dataindex]

          if string[0] == "-"
            newstring = string[3..string.length-1].insert(0,"-").hex
            newstring &= thirtytwobitmask
            encodedline = newstring.to_s(16).rjust(8,"0")
          else newstring = string[2..string.length-1]
          encodedline = newstring.to_s.rjust(8,"0")
          end
        else
          word = line[dataindex].to_i & thirtytwobitmask
          encodedline = word.to_s(16).rjust(8,"0")
        end
    end
    encodedline
  end

  # Manipulate address as needed for a .text directive
  def textdirective(address,line)
    line.length == 2 ? address = line[1].to_s.hex.to_i : address = 0
    address
  end

  # Manipulate address as needed for a .data directive
  def datadirective(address,line)
    line.length == 2 ? address = line[1].to_s.hex.to_i : address = 0
    address
  end

  # Manipulate address as needed for a .align directive
  def aligndirective(address,line,bump)
    nextaddress = address + bump
    operand = line[1].to_i
    boundary = 2**operand
    if nextaddress % boundary == 0
      nextaddress
    else
      address = nextaddress + (boundary - nextaddress % boundary)
      address
    end
  end

  # Manipulate address as needed for a .asciiz directive
  def asciizdirective(line,data,strings,labelflag)
    strings.clear
    data.clear
    if labelflag
      for i in 2..line.length-1
        string = line[i].gsub( /\A"/m, "" ).gsub( /"\Z/m, "" ) + '\0'
        strings.push string
        data.push string.length-1
      end
    else
      for i in 1..line.length-1
        string = line[i].gsub( /\A"/m, "" ).gsub( /"\Z/m, "" ) + '\0'
        strings.push string
        data.push string.length-1
      end
    end
    return data,strings
  end

  # Manipulate address as needed for a .double directive
  def doubledirective(line,data,strings,labelflag)
    strings.clear
    data.clear
    if labelflag
      for i in 2..line.length-1
        data.push 8
        strings.push line[i]
      end
    else
      for i in 1..line.length-1
        data.push 8
        strings.push line[i]
      end
    end
    return data,strings
  end

  # Manipulate address as needed for a .float directive
  def floatdirective(line,data,strings,labelflag)
    strings.clear
    data.clear
    if labelflag
      for i in 2..line.length-1
        data.push 4
        strings.push line[i]
      end
    else
      for i in 1..line.length-1
        data.push 4
        strings.push line[i]
      end
    end
    return data,strings
  end

  # Manipulate address as needed for a .word directive
  def worddirective(line,data,strings,labelflag)
    strings.clear
    data.clear
    if labelflag
      for i in 2..line.length-1
        data.push 4
        strings.push line[i]
      end
    else
      for i in 1..line.length-1
        data.push 4
        strings.push line[i]
      end
    end
    return data,strings
  end

  # Manipulate address as needed for a .space directive
  def spacedirective(address,line,bump,labelflag)
    if labelflag
      nextaddress = address + line[2].to_i
    else
      nextaddress = address + line[1].to_i
    end
    nextaddress
  end
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
dlxassembler.secondPass(nicecolors)
dlxassembler.end(nicecolors)
