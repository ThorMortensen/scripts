require 'tty'
require 'socket'
require 'differ'
require_relative 'rubyHelpers.rb'


@cmd = TTY::Command.new(printer: :null)

@addr_infos = Socket.ip_address_list



# diff = Differ.diff "foo", "boo"

# puts diff.format_as :color

# File.open(netScanDump, 'w') { |file| file.write("your text") }


def scanIp(ipAddress)
  @spinner    = TTY::Spinner.new("Scanning with \'nmap -sP #{ipAddress}/24\' ".brown + ":spinner".blue, format: :bouncing_ball)
  @spinner.auto_spin
  out, err = @cmd.run("nmap -sP #{ipAddress}/24")
  @spinner.stop('Done!'.green)
  puts out

end 



if ARGV[1].nil?
    @addr_infos.each do |ip|
    next if ip.ip_address == "127.0.0.1"
    if range = ip.ip_address.match(/(\d{1,3}\.\d{1,3}\.\d{1,3}\.)\d{1,3}/)
      scanIp(range[1]+'0')
    # (\d{1,3}\.\d{1,3}\.\d{1,3}\.)\d{1,3}
    end 
  end
else 

  if ARGV[1].match(/(\d{1,3}\.\d{1,3}\.\d{1,3}\.)\d{1,3}/)
    scanIp(ARGV[1])
  else 
    puts "Not a valid ip!"
  end 

end 

# cmd.run('ls -la')


# cmd.run('ls -la')
# cmd.run('echo Hello!')