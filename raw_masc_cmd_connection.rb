# Date 8-Jun-2017
# Author Thor Mortensen, THM (THM@rovsing.dk)

require 'socket'
#require_relative 'test_value'


class TestValue
  include Comparable
  attr_accessor :value, :id #, :isValid
  @value
  @isValid
  @id

  def initialize(value, isValid = true, id = nil)
    @value = value
    @isValid = isValid
    @id = id
  end

  def isOk
    return @isValid
  end

  alias isValid isOk

  # def ==(other)
  #   other.is_a?(TestValue) ? eql?(other) : @value == other
  # end
  #
  # def ===(other)
  #   return self == other if isOk
  #   false
  # end
  #
  # def eql?(other)
  #   other.is_a?(TestValue) ? (@value == other.value and isOk == other.isOk) : false
  # end
  def id_to_s
    return @id.nil? ? '' : "ID: [#{@id}], "
  end

  def isValid_to_s
    return "Valid: [#{@isValid}], "
  end

  def value_to_s
    "Value: [#{@value}]"
  end

  def to_s()
    return id_to_s + isValid_to_s + value_to_s
  end

  def to_f
    @value.to_f
  end

  def to_i
    @value
  end

  # def between?(other1, other2)
  #   return true
  # end

  def -(other)
    other.is_a?(TestValue) ? @value - other.value : @value - other
  end

  def *(other)
    other.is_a?(TestValue) ? @value * other.value : @value * other
  end

  def /(other)
    other.is_a?(TestValue) ? @value / other.value : @value / other
  end

  def +(other)
    other.is_a?(TestValue) ? @value + other.value : @value + other
  end

  def coerce(other)
    return [@value, other]
  end

  def <=>(other)
    if other.is_a?(TestValue)
      return 0 if !isOk and !other.isOk
      return 0 if @value == other.value and isOk == other.isOk
      return -1 if @value < other.value or (isOk == false and other.isOk == true)
      return 1 if @value > other.value or (isOk == true and other.isOk == false)
    else
      #return -1 unless isOk
      @value <=> other
    end
  end


end

#@formatter:off
  class String
    def white;      defined?(ReportCommands) ? self : "\e[30m#{self}\e[0m" end
    def black;      defined?(ReportCommands) ? self : "\e[97m#{self}\e[0m" end
    def red;        defined?(ReportCommands) ? self : "\e[31m#{self}\e[0m" end
    def green;      defined?(ReportCommands) ? self : "\e[32m#{self}\e[0m" end
    def greenLight; defined?(ReportCommands) ? self : "\e[92m#{self}\e[0m" end
    def brown;      defined?(ReportCommands) ? self : "\e[33m#{self}\e[0m" end
    def blue;       defined?(ReportCommands) ? self : "\e[34m#{self}\e[0m" end
    def magenta;    defined?(ReportCommands) ? self : "\e[35m#{self}\e[0m" end
    def cyan;       defined?(ReportCommands) ? self : "\e[36m#{self}\e[0m" end
    def gray;       defined?(ReportCommands) ? self : "\e[37m#{self}\e[0m" end

    def bg_black;   defined?(ReportCommands) ? self : "\e[40m#{self}\e[0m" end
    def bg_red;     defined?(ReportCommands) ? self : "\e[41m#{self}\e[0m" end
    def bg_green;   defined?(ReportCommands) ? self : "\e[42m#{self}\e[0m" end
    def bg_yell;    defined?(ReportCommands) ? self : "\e[103m#{self}\e[0m"end
    def bg_brown;   defined?(ReportCommands) ? self : "\e[43m#{self}\e[0m" end
    def bg_blue;    defined?(ReportCommands) ? self : "\e[44m#{self}\e[0m" end
    def bg_magenta; defined?(ReportCommands) ? self : "\e[45m#{self}\e[0m" end
    def bg_cyan;    defined?(ReportCommands) ? self : "\e[46m#{self}\e[0m" end
    def bg_gray;    defined?(ReportCommands) ? self : "\e[47m#{self}\e[0m" end

    def bold;       defined?(ReportCommands) ? self : "\e[1m#{self}\e[22m" end
    def italic;     defined?(ReportCommands) ? self : "\e[3m#{self}\e[23m" end
    def underline;  defined?(ReportCommands) ? self : "\e[4m#{self}\e[24m" end
    def blink;      defined?(ReportCommands) ? self : "\e[5m#{self}\e[25m" end
    def reverse_color;defined?(ReportCommands) ? self : "\e[7m#{self}\e[27m" end
  end
#@formatter:on


class CmdReturn < TestValue
  def to_s
    "Status: [#{isOk ? 'OK' : 'FAILED'}], Result: [#{@value}]"
  end

  def isOk
    @isValid == 0
  end
end

class RawMascCmdConnection
  attr_accessor :fakeIt

  @ip
  @port
  @socket
  @res
  @@fakeIt = false
  @@fakeVal = 0
  @isConnected

  def self.fakeIt(fakeIt, fakeVal = nil)
    @@fakeIt = fakeIt
    @@fakeVal = fakeVal
  end

  def self.getFakeIt
    @@fakeIt
  end

  def phony(arg2)
    return CmdReturn.new(arg2, 0) if @@fakeVal.nil?
    @fakeValIndex ||= 0
    testVal = @@fakeVal[@fakeValIndex]
    @fakeValIndex = (@fakeValIndex + 1) % @@fakeVal.length
    testVal.isValid ? CmdReturn.new(testVal.value, 0) : CmdReturn.new(0, 1)
  end

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
    return phony(arg2) if @@fakeIt
    connect unless @isConnected
    new_packet
    set_command_id cmdId
    set_packet_id 2
    set_sender_id 127
    set_arg1 arg1
    set_arg2 arg2
    sendPackage
    getRes
    # close
    CmdReturn.new((@res[9] << 24 | @res[10] << 16 | @res[11] << 8 | @res[12]), @res[8])
  end

  def print_packege
    puts 'Sender id: ' + @res[4].to_s
    puts 'Packet id: ' + (@res[5] << 8 | @res[6]).to_s
    puts 'Cmd id: ' + @res[7].to_s
    puts 'Cmd status: ' + @res[8].to_s
    puts 'Return val: ' + (@res[9] << 24 | @res[10] << 16 | @res[11] << 8 | @res[12]).to_s
    puts 'Tag: ' + @res[13].to_s
  end

  def startManualMode
    cmd = 0
    arg1 = 0
    arg2 = 0

    shmCmd = 0
    shmCmdEx = 0
    shmIndex = 0
    packegeCount = 0


    loop do

      puts
      puts

      begin
        puts "Using CMD  ~>".black.bg_brown + " #{cmd} ".bold.black.bg_brown
        puts "Enter new value or press enter to continue..."
        input = STDIN.gets
        cmd = Integer(input) unless input == "\n"
        raise if cmd < 0 || cmd > 255
      rescue
        puts 'Not valid input try again'
        retry
      end

      if (cmd >= 160 && cmd <= 163)
        puts '--- Using shm cmd ---'

        begin
          puts "Shm CMD  ~> #{shmCmd} ".bold
          input = STDIN.gets
          shmCmd = Integer(input) unless input == "\n"
          raise if cmd < 0 || cmd > 255
        rescue
          puts 'Not valid input try again'
          retry
        end

        begin
          puts "Shm cmdExd  ~> #{shmCmdEx} ".bold
          input = STDIN.gets
          shmCmdEx = Integer(input) unless input == "\n"
          raise if cmd < 0 || cmd > 255
        rescue
          puts 'Not valid input try again'
          retry
        end

        begin
          puts "Shm index  ~> #{shmIndex} ".bold
          input = STDIN.gets
          shmIndex = Integer(input) unless input == "\n"
          raise if cmd < 0 || cmd > 255
        rescue
          puts 'Not valid input try again'
          retry
        end

        arg1 = shmCmd << 16 | shmCmdEx << 8 | shmIndex

        # if (cmd % 2) == 1 # No need to ask for arg2 when reading
        #   sendCmd(cmd, arg1, arg2)
        #   print_packege
        #   close # Close as we are very slow in man mode
        #   next
        # end

      else

        begin
          puts "Using ARG1 ~>".black.bg_blue + " #{arg1} ".bold.black.bg_blue
          puts "Enter new value or press enter to continue..."
          input = STDIN.gets
          arg1 = Integer(input) unless input == "\n"
        rescue
          puts 'Not valid input try again'
          retry
        end

      end

      begin
        puts "Using ARG2 ~>".black.bg_cyan + " #{arg2} ".bold.black.bg_cyan
        puts "Enter new value or press enter to continue..."
        input = STDIN.gets
        arg2 = Integer(input) unless input == "\n"
      rescue
        puts 'Not valid input try again'
        retry
      end

      puts("Sending package arg1 = [0x#{arg1.to_s(16)}]".green)
      puts("Sending package arg2 = [0x#{arg2.to_s(16)}]".green)


      sendCmd(cmd, arg1, arg2)
      packegeCount += 1
      # while @res[8] == 0
      #   sendCmd(cmd, arg1, arg2)
      #   packegeCount += 1
      # end
      print_packege
      puts "Packages sendt -------> #{ packegeCount}"
      close # Close as we are very slow in man mode


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
#		Run
##############################################
@mascIp = ARGV[0]
ARGV.clear
raw = RawMascCmdConnection.new(@mascIp)
raw.startManualMode
