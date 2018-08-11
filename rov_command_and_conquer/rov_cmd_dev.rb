# Date 8-Jun-2017
# Author Thor Mortensen, THM (THM@rovsing.dk)

require 'socket'
require 'tty'
require_relative '../user_prompter'



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
    # sendPackage
    # getRes
    # close # Close as we are very slow in man mode
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
    puts "~~~~~~~~~~~~~~~~~~~~{ Package Returned }~~~~~~~~~~~~~~~~~~~~~~~~".bg_blue
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
    cmdPrompt = UserPrompter.new("Enter CMD (number)".green + " ~> ", betweenLambda, betweenErrorMsg)
    arg1Prompt = UserPrompter.new("Enter Arg1 ".magenta + " ~> ", -> input {input.match(/\d/)}, 'Must be a number', -> input {input.to_i}, true)
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


#############################################
		              MAIN
#############################################
@mascIp = ARGV[0]
ARGV.clear
commandAndConquer = RawCmdConnection.new(@mascIp)
commandAndConquer.start


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




# puts "starting.."
# puts
# puts

#
a  = UserPrompter.new(" asdasdasda ".bg_cyan)
b  = UserPrompter.new(" b ".bg_cyan)
c  = UserPrompter.new(" c ".bg_cyan)
d  = UserPrompter.new(" d ".bg_cyan)
e  = UserPrompter.new(" e ".bg_cyan)
ca = UserPrompter.new("ca ".bg_cyan)
cb = UserPrompter.new("cb ".bg_cyan)

a >> b >> c #>> d >> a

#c >> {-> res {res.to_i.between? 160, 170} => ca >> cb >> d}

a.runPrompt
#

# a.setDefault(1)
# b.setDefault(2)
# c.setDefault(3)
#
#
# a.runPrompt


# puts "result for a is #{a.result}"
# puts "result for b is #{b.result}"
# puts "result for c is #{c.result}"
# puts "result for d is #{d.result}"
# puts "result for e is #{e.result}"
#
#



















