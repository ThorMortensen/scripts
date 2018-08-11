# Date 8-Jun-2017
# Author Thor Mortensen, THM (THM@rovsing.dk)

gem 'tty-cursor'
require 'socket'
require 'tty-cursor'
require 'tty-reader'


#@formatter:off
class String
  def white;          "\e[30m#{self}\e[0m" end
  def black;          "\e[30m#{self}\e[0m" end
  def red;            "\e[31m#{self}\e[0m" end
  def green;          "\e[32m#{self}\e[0m" end
  def greenLight;     "\e[92m#{self}\e[0m" end
  def brown;          "\e[33m#{self}\e[0m" end
  def blue;           "\e[34m#{self}\e[0m" end
  def magenta;        "\e[35m#{self}\e[0m" end
  def cyan;           "\e[36m#{self}\e[0m" end
  def gray;           "\e[37m#{self}\e[0m" end
  def yellow;         "\e[43m#{self}\e[0m" end

  def bg_black;       "\e[40m#{self}\e[0m" end
  def bg_red;         "\e[41m#{self}\e[0m" end
  def bg_green;       "\e[42m#{self}\e[0m" end
  def bg_yell;        "\e[103m#{self}\e[0m"end
  def bg_brown;       "\e[43m#{self}\e[0m" end
  def bg_blue;        "\e[44m#{self}\e[0m" end
  def bg_magenta;     "\e[45m#{self}\e[0m" end
  def bg_cyan;        "\e[46m#{self}\e[0m" end
  def bg_gray;        "\e[47m#{self}\e[0m" end

  def bold;           "\e[1m#{self}\e[22m" end
  def dim;            "\e[2m#{self}\e[22m" end
  def italic;         "\e[3m#{self}\e[23m" end
  def underline;      "\e[4m#{self}\e[24m" end
  def blink;          "\e[5m#{self}\e[25m" end
  def reverse_color;  "\e[7m#{self}\e[27m" end

  def clearColor
    gsub(/(#{"\e"}\[\d*m)/n, '')
  end

  def is_integer?
    self.to_i.to_s == self
  end
end
#@formatter:on


# class UserPrompter

#   @@callStack = []
#   @@controlKeys = {"b" => :back, "h" => :help}

#   # @param [String] promptStr
#   def initialize(promptStr, acceptedInput_lambda = -> input {input.match(/\d/)}, errorMsg = 'Must be a number', inputConverter_lambda = -> input {input.to_i}, nurseInput = false)
#     @pormtStr = promptStr
#     @checkValidInput = acceptedInput_lambda
#     @cursor = TTY::Cursor
#     @errorMsg = errorMsg
#     @lastInput = nil
#     @inputConverter_lambda = inputConverter_lambda
#     @nurse = nurseInput
#   end

#   def nurseInput
#     if @nurse
#       @lastInput += 1 unless @lastInput.nil?
#     end
#   end

#   def prompt(promptStr = @pormtStr)
#     while true
#       nurseInput()
#       print "#{promptStr}#{@lastInput.nil? ? '' : @lastInput.to_s.gray} "
#       print @cursor.backward(@lastInput.to_s.length + 1)
#       system("stty raw -echo") #=> Raw mode, no echo


#       userInput = STDIN.getc

#       if userInput == "q"
#         puts
#         return nil
#       elsif userInput != "\r"
#         print @cursor.clear_line_before
#         print userInput
#         userInput += STDIN.gets.chomp
#         if @checkValidInput.(userInput)
#           return @lastInput = @inputConverter_lambda.(userInput)
#         else
#           puts @errorMsg
#         end
#       else
#         puts @lastInput
#         return @lastInput
#       end


#       system("stty -raw echo") #=> Reset terminal mode

#     end
#   end

#   def pushToCallStack
#     @@callStack << self
#   end

#   def clearCallStack

#   end

#   def clear
#     @lastInput = nil
#   end

#   private

#   def navigate

#   end


# end


# class RawCmdConnection

#   def initialize(ipAddress = nil, port = 8888)
#     @ip = ipAddress
#     @port = port
#   end

#   def connect
#     @socket = TCPSocket.open(@ip, @port)
#     @isConnected = true
#   end

#   def close
#     @isConnected = false
#     @socket.close
#   end

#   def sendCmd(cmdId, arg1, arg2)
#     # connect unless @isConnected
#     new_packet
#     set_command_id cmdId
#     set_packet_id 2
#     set_sender_id 127
#     set_arg1 arg1
#     set_arg2 arg2
#     # sendPackage
#     # getRes
#     # close # Close as we are very slow in man mode
#   end

#   def print_packege
#     errorDescription = [
#         "Successful completion".green,
#         "Unknown command".red,
#         "Argument 1 invalid".red,
#         "Argument 2 invalid".red,
#         "No such device".red,
#         "Device file error".red,
#     ]

#     si = @res[4]
#     pa = (@res[5] << 8 | @res[6])
#     ci = @res[7]
#     cs = @res[8]
#     rv = (@res[9] << 24 | @res[10] << 16 | @res[11] << 8 | @res[12])
#     ta = @res[13]

#     puts
#     puts "~~~~~~~~~~~~~~~~~~~~{ Package Returned }~~~~~~~~~~~~~~~~~~~~~~~~".bg_blue
#     puts "+----------------+------------+--------------------------------+"
#     puts "| Package fields | Return val | Description                    |"
#     puts "+----------------+------------+--------------------------------+"
#     puts "|  Sender ID     : #{si.to_s.center(10, ' ')} | Originator ID"
#     puts "|  Packet ID     : #{pa.to_s.center(10, ' ')} | Packet count, sender does ++"
#     puts "|  Cmd ID        : #{ci.to_s.center(10, ' ')} | Command number/ID sent"
#     puts "|  #{"Cmd status".bold}    : #{cs == 0 ? cs.to_s.center(10, ' ').green : cs.to_s.center(10, ' ').red} | #{errorDescription[cs] || "Undefined error".red}"
#     puts "|  #{"Return value".bold.blue}  : #{rv.to_s.center(10, ' ').bold.blue} | #{"Value returned".bold.blue}"
#     puts "|  Tag           : #{ta.to_s.center(10, ' ')} | Tag for each packets"
#     puts "+----------------+------------+--------------------------------+"
#     puts
#   end

#   def start

#     betweenLambda = -> input {input.is_integer? && input.to_i.between?(0, 255)}
#     betweenErrorMsg = "Must be between 0 and 255".red
#     cmdPrompt = UserPrompter.new("Enter CMD (number)".green + " ~> ", betweenLambda, betweenErrorMsg)
#     arg1Prompt = UserPrompter.new("Enter Arg1 ".magenta + " ~> ", -> input {input.match(/\d/)}, 'Must be a number', -> input {input.to_i}, true)
#     arg2Prompt = UserPrompter.new("Enter Arg2 ".cyan + " ~> ")
#     shmChmCmdPrompt = UserPrompter.new("Shm CMD ".bold + " ~> ", betweenLambda, betweenErrorMsg)
#     shmCmdExdCmdPrompt = UserPrompter.new("Shm cmdExd ".bold + " ~> ", betweenLambda, betweenErrorMsg)
#     shmIndexCmdPrompt = UserPrompter.new("Shm index ".bold + " ~> ", betweenLambda, betweenErrorMsg)

#     while true
#       cmd = cmdPrompt.prompt
#       if cmd >= 160 && cmd <= 163
#         puts '--- Using shm cmd ---'
#         shmCmd = shmChmCmdPrompt.prompt
#         shmCmdEx = shmCmdExdCmdPrompt.prompt
#         shmIndex = shmIndexCmdPrompt.prompt
#         arg1 = shmCmd << 16 | shmCmdEx << 8 | shmIndex
#       else
#         arg1 = arg1Prompt.prompt
#       end
#       arg2 = arg2Prompt.prompt
#       sendCmd(cmd, arg1, arg2)
#       # packegeCount += 1
#       print_packege
#       # puts "Packages sendt -------> #{ packegeCount}"
#     end
#   end

#   private

#   def sendPackage
#     @socket.write(@data.map(&:to_i).pack('c*'))
#   end

#   def getRes
#     @res = @socket.readline.bytes.to_a
#   end

#   def new_packet
#     @data = Array.new(18)
#     @data[0] = 77 # 'M'
#     @data[1] = 65 # 'A'
#     @data[2] = 83 # 'S'
#     @data[3] = 67 # 'C'

#     @data[17] = 0x0A
#   end

#   def set_sender_id(sid)
#     @data[4] = sid
#   end

#   def set_packet_id(pid)
#     @data[5] = (pid >> 8) & 0xFF
#     @data[6] = (pid & 0xFF)
#   end

#   def set_command_id(cid)
#     @data[7] = cid
#   end

#   def set_arg1(val)
#     @data[8] = 1
#     @data[9] = (val >> 24) & 0xFF
#     @data[10] = (val >> 16) & 0xFF
#     @data[11] = (val >> 8) & 0xFF
#     @data[12] = (val & 0xFF)
#   end

#   def set_arg2(val)
#     @data[8] = 2
#     @data[13] = (val >> 24) & 0xFF
#     @data[14] = (val >> 16) & 0xFF
#     @data[15] = (val >> 8) & 0xFF
#     @data[16] = (val & 0xFF)
#   end


# end


##############################################
#		              MAIN
##############################################
# @mascIp = ARGV[0]
# ARGV.clear
# commandAndConquer = RawCmdConnection.new(@mascIp)
# commandAndConquer.start


#
# Things to add
# - Main meny
# - Help section
# - Back
# - history
# - accept math function
# - Fix delete
#  -clone if given as arg in constructer
#


class UserPrompter

  attr_reader :promptStr, :checkValidInput, :errorMsg, :inputConverter_lambda, :nextPrompt, :prevPrompt


  @controlKeys = {'r' => :autoRun, 'b' => :back, 'h' => :help, 'q' => :quit}


  # @param [String] promptStr
  def initialize(promptStr, acceptedInput_lambda = -> input {input.is_integer?}, errorMsg = 'Must be (or produce) a number', inputConverter_lambda = -> input {input.to_i})
    @nextPrompt      = []
    @cursor          = TTY::Cursor
    @reader          = TTY::Reader.new(interrupt: -> {puts "\nBye"; exit(1)})
    @branchCond      = -> res {false}
    @lastLambdaInput = nil
    @ppState         = :start
    @ppCaller        = :user


    @promptStr = promptStr
    if acceptedInput_lambda.is_a?(UserPrompter) # Clone rest of the parameters from any incoming objects of the same type
      @checkValidInput       = acceptedInput_lambda.checkValidInput
      @errorMsg              = acceptedInput_lambda.errorMsg
      @inputConverter_lambda = acceptedInput_lambda.inputConverter_lambda
    else
      @checkValidInput = acceptedInput_lambda
      if errorMsg.is_a?(UserPrompter)
        @errorMsg              = errorMsg.errorMsg
        @inputConverter_lambda = errorMsg.inputConverter_lambda
      else
        @errorMsg = errorMsg
        if inputConverter_lambda.is_a?(UserPrompter)
          @inputConverter_lambda = inputConverter_lambda.inputConverter_lambda
        else
          @inputConverter_lambda = inputConverter_lambda
        end
      end
    end
  end

  def getFormattedPromptStr(promptStr)
    "#{promptStr}#{
    (@lastInput.nil? and @lastLambdaInput.nil?) ?
        '' :
        '(' + (((@ppCaller == :lambda or @ppState == :lastWasLambdaInput) ? @lastLambdaInput.to_s + " = " : '') + @lastInput.to_s).gray.dim + ')'} ~> "
  end


  def appendTextToLastUserInput(offsetOrPromptStr, strToAppend)
    endOfPrevLine = offsetOrPromptStr.is_a?(Integer) ? offsetOrPromptStr : getFormattedPromptStr(offsetOrPromptStr).clearColor.length
    print @cursor.prev_line + @cursor.forward(endOfPrevLine)
    print strToAppend
    print @cursor.next_line
  end

  def handleLambdaInput(m, wasEmptyInput)
    lambdaHelpStr    = "Please start with number I.e 42 -> r {r + 1}"
    lastPromptStrLen = getFormattedPromptStr(promptStr).clearColor.length
    @ppCaller        = :lambda


    case @ppState
      when :start
        if m[1].empty? and @lastInput.nil?
          puts "Missing input to lambda." + lambdaHelpStr
          @ppCaller = :user
          return false
        end
      when :lastWasLambdaInput
        if m[1].empty?
          puts "Can't use nested lambdas. " + lambdaHelpStr
          return false
        end
    end

    unless m[1].empty?
      pp(promptStr, m[1])
    end

    lambdaResult = nil

    begin
      lambdaResult = eval(m[2]).call(@lastInput)
    rescue SyntaxError, NameError => boom
      puts "Input lambda doesn't compile: \n" + boom.to_s
      @ppCaller = :user
      return false
    rescue StandardError => bang
      puts "Error running input lambda: \n" + bang.to_s
      @ppCaller = :user
      return false
    end

    if pp(promptStr, lambdaResult)
      @lastLambdaInput = m[2]
      case @ppState
        when :start
          appendTextToLastUserInput(lastPromptStrLen + m[0].length, " = " + result.to_s.green)
        when :lastWasLambdaInput
          if m[1].empty?
            appendTextToLastUserInput(promptStr, (wasEmptyInput ? '' : ' = ') + result.to_s.green)
          else
            appendTextToLastUserInput(lastPromptStrLen + m[0].length, " = " + result.to_s.green)
          end
        when :auto
          appendTextToLastUserInput(promptStr, (wasEmptyInput ? '' : ' = ') + result.to_s.green)
      end
    else
      return false
    end
    @ppState  = :lastWasLambdaInput
    @ppCaller = :user
    return true

  end

  def pp(promptStr = @promptStr, trumpUserInput = nil)

    userInput = trumpUserInput.nil? ? @reader.read_line(getFormattedPromptStr(promptStr)) : trumpUserInput.to_s
    userInput.chomp!
    wasEmptyInput = userInput.empty?
    wasOk         = true

    if wasEmptyInput
      if @ppState == :lastWasLambdaInput
        userInput = @lastLambdaInput
      else
        appendTextToLastUserInput(promptStr, @lastInput.to_s.green)
        userInput = @lastInput.to_s
      end
      @ppState = :auto
    end

    if @branchCond.call(userInput)
      @lastInput = userInput
    elsif (m = userInput.match(/(\d*)(\s?lambda\s?{.*}\s|\s?->.*{.*})/))
      return handleLambdaInput(m, wasEmptyInput) # Must return here else pp state is overwritten further down
    elsif @checkValidInput.(userInput)
      @lastInput = @inputConverter_lambda.(userInput)
    elsif userInput == "b"
      wasOk = :back
    elsif userInput == "r"
      wasOk = :autoRun
    else
      puts @errorMsg
      wasOk = false
    end

    if @ppCaller == :user
      @ppState = :start
    end

    return wasOk

  end

  def autoRun
    pp(trumpUserInput=@lastInput)
  end
  
  def setDefault(defaultValue)
    @lastInput = defaultValue
  end

  def runPrompt
    promptToRun = self
    until promptToRun.nil?
      case promptToRun.pp
        when true
          if promptToRun.nextPrompt.empty?
            return
          end
          promptToRun.nextPrompt.each do |branchTree|
            condition, branchTo = branchTree.first
            if condition.call(promptToRun.result)
              branchTo << promptToRun
              promptToRun = branchTo
              break
            end
          end
        when :back
          promptToRun = promptToRun.prevPrompt
        when :autoRun
          promptToRun = promptToRun.prevPrompt
      end
    end
  end

  def printBranchTree
    prompter = self
    until prompter.nil?
      puts "I'm " + @promptStr
      prompter.nextPrompt.each do |branchTree|
        condition, branchTo = branchTree.first
        prompter            = branchTo
      end
    end
  end

  def tree?

  end

  def clear
    @lastInput = nil
  end

  def result
    @lastInput
  end

  def firstLink
    @prevPrompt.nil? ? self : @prevPrompt.firstLink
  end

  def <<(other)
    @prevPrompt = other
    self
  end

  def >>(other)
    if other.is_a?(Hash)
      #Change last
      @branchCond = other.first.first
      @nextPrompt.prepend ({other.first.first => other.first.last.firstLink})
      other.first.last << self
    else
      @nextPrompt << ({-> res {true} => other})
      other << self
    end
  end

end

puts "starting.."
# puts
# puts


a  = UserPrompter.new(" asdasdasda ".bg_cyan)
b  = UserPrompter.new(" b ".bg_cyan)
c  = UserPrompter.new(" c ".bg_cyan)
d  = UserPrompter.new(" d ".bg_cyan)
e  = UserPrompter.new(" e ".bg_cyan)
ca = UserPrompter.new("ca ".bg_cyan)
cb = UserPrompter.new("cb ".bg_cyan)

a >> b >> c >> d >> a

c >> {-> res {res.to_i.between? 160, 170} => ca >> cb >> d}

a.runPrompt

puts "result for a is #{a.result}"
puts "result for b is #{b.result}"
puts "result for c is #{c.result}"
puts "result for d is #{d.result}"
puts "result for e is #{e.result}"


# foo = "-f> res {res + 1}"
# m   = foo.match(/(\d*)(\s?lambda\s?{.*}\s|\s?->.*{.*})/)
#
# puts m[0]
# puts m[1]
# puts m[2]
#
# reader = TTY::Reader.new(interrupt: -> {puts "hello"})
# reader.read_line
#
#
















