# Date 8-Jun-2017
# Author Thor Mortensen, THM (THM@rovsing.dk)

gem 'tty-cursor'
require 'socket'
require 'tty-cursor'

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
  def italic;         "\e[3m#{self}\e[23m" end
  def underline;      "\e[4m#{self}\e[24m" end
  def blink;          "\e[5m#{self}\e[25m" end
  def reverse_color;  "\e[7m#{self}\e[27m" end

  def is_integer?
    self.to_i.to_s == self
  end
end
#@formatter:on


class UserPrompter

  @@IntegerBetween

  # @param [String] promptStr
  def initialize(promptStr, acceptedInput_lambda = -> input {input.match(/\d/)},errorMsg = 'Must be a number', inputConverter_lambda = -> input {input.to_i})
    @pormtStr = promptStr
    @checkValidInput = acceptedInput_lambda
    @cursor = TTY::Cursor
    @errorMsg = errorMsg
    @lastInput = nil
    @inputConverter_lambda = inputConverter_lambda
  end

  def prompt(promptStr = @pormtStr)
    while true
      print "#{promptStr}#{@lastInput.nil? ? '' : @lastInput.to_s.gray} "
      print @cursor.backward(@lastInput.to_s.length + 1)
      system("stty raw -echo") #=> Raw mode, no echo
      userInput = STDIN.getc
      system("stty -raw echo") #=> Reset terminal mode
      if userInput == "q"
        puts
        return nil
      elsif userInput != "\r"
        print @cursor.clear_line_before
        print userInput
        userInput += STDIN.gets.chomp
        if @checkValidInput.(userInput)
          return @lastInput = @inputConverter_lambda.(userInput)
        else
          puts @errorMsg
        end
      else
        puts @lastInput
        return @lastInput
      end
    end
  end

  def clear
    @lastInput = nil
  end

end


class RawCmdConnection

  def initialize(ipAddress = nil, port = 8888)
    @ip = ipAddress
    @port = port
  end

  def connect
    @socket = TCPSocket.open(@ip, @port)
    @isConnected = true
  end

  def close
    @isConnected = false
    @socket.close
  end

  def sendCmd(cmdId, arg1, arg2)
    # connect unless @isConnected
    new_packet
    set_command_id cmdId
    set_packet_id 2
    set_sender_id 127
    set_arg1 arg1
    set_arg2 arg2
    sendPackage
    getRes
    close # Close as we are very slow in man mode
  end

  def print_packege
    errorDescription = [
        "Successful completion".green,
        "Unknown command".red,
        "Argument 1 invalid".red,
        "Argument 2 invalid".red,
        "No such device".red,
        "Device file error".red,
    ]
    
    si = @res[4]
    pa = (@res[5] << 8 | @res[6])
    ci = @res[7]
    cs = @res[8]
    rv = (@res[9] << 24 | @res[10] << 16 | @res[11] << 8 | @res[12])
    ta = @res[13]
    
    puts
    puts "~~~~~~~~~~~~~~~~~~~~{ Package Returned }~~~~~~~~~~~~~~~~~~~~~~~".bg_blue
    puts "+----------------+------------+--------------------------------+"
    puts "| Package fields | Return val | Description                    |"
    puts "+----------------+------------+--------------------------------+"
    puts "|  Sender ID     : #{si.to_s.center(10, ' ')} | Originator ID"
    puts "|  Packet ID     : #{pa.to_s.center(10, ' ')} | Packet count, sender does ++"
    puts "|  Cmd ID        : #{ci.to_s.center(10, ' ')} | Command number/ID sent"
    puts "|  #{"Cmd status".bold}    : #{cs == 0 ? cs.to_s.center(10, ' ').green : cs.to_s.center(10, ' ').red} | #{errorDescription[cs] || "Undefined error".red}"
    puts "|  #{"Return value".bold.blue}  : #{rv.to_s.center(10, ' ').bold.blue} | #{"Value returned".bold.blue}"
    puts "|  Tag           : #{ta.to_s.center(10, ' ')} | Tag for each packets"
    puts "+----------------+------------+--------------------------------+"
    puts
  end

  def start

    betweenLambda = -> input {input.is_integer? && input.to_i.between?(0, 255)}
    betweenErrorMsg = "Must be between 0 and 255".red
    cmdPrompt = UserPrompter.new("\nEnter CMD (number)".green + " ~> ", betweenLambda, betweenErrorMsg)
    arg1Prompt = UserPrompter.new("Enter Arg1 ".magenta + " ~> ")
    arg2Prompt = UserPrompter.new("Enter Arg2 ".cyan + " ~> ")
    shmChmCmdPrompt = UserPrompter.new("Shm CMD ".bold + " ~> ", betweenLambda, betweenErrorMsg)
    shmCmdExdCmdPrompt = UserPrompter.new("Shm cmdExd ".bold + " ~> ", betweenLambda, betweenErrorMsg)
    shmIndexCmdPrompt = UserPrompter.new("Shm index ".bold + " ~> ", betweenLambda, betweenErrorMsg)

    while true
      cmd = cmdPrompt.prompt
      if cmd >= 160 && cmd <= 163
        puts '--- Using shm cmd ---'
        shmCmd = shmChmCmdPrompt.prompt
        shmCmdEx = shmCmdExdCmdPrompt.prompt
        shmIndex = shmIndexCmdPrompt.prompt
        arg1 = shmCmd << 16 | shmCmdEx << 8 | shmIndex
      else
        arg1 = arg1Prompt.prompt
      end
      arg2 = arg2Prompt.prompt
      sendCmd(cmd, arg1, arg2)
      # packegeCount += 1
      print_packege
      # puts "Packages sendt -------> #{ packegeCount}"
    end
  end

  private

  def sendPackage
    @socket.write(@data.map(&:to_i).pack('c*'))
  end

  def getRes
    @res = @socket.readline.bytes.to_a
  end

  def new_packet
    @data = Array.new(18)
    @data[0] = 77 # 'M'
    @data[1] = 65 # 'A'
    @data[2] = 83 # 'S'
    @data[3] = 67 # 'C'

    @data[17] = 0x0A
  end

  def set_sender_id(sid)
    @data[4] = sid
  end

  def set_packet_id(pid)
    @data[5] = (pid >> 8) & 0xFF
    @data[6] = (pid & 0xFF)
  end

  def set_command_id(cid)
    @data[7] = cid
  end

  def set_arg1(val)
    @data[8] = 1
    @data[9] = (val >> 24) & 0xFF
    @data[10] = (val >> 16) & 0xFF
    @data[11] = (val >> 8) & 0xFF
    @data[12] = (val & 0xFF)
  end

  def set_arg2(val)
    @data[8] = 2
    @data[13] = (val >> 24) & 0xFF
    @data[14] = (val >> 16) & 0xFF
    @data[15] = (val >> 8) & 0xFF
    @data[16] = (val & 0xFF)
  end


end

##############################################
#		              MAIN
##############################################
@mascIp = ARGV[0]
ARGV.clear
commandAndConquer = RawCmdConnection.new(@mascIp)
commandAndConquer.start