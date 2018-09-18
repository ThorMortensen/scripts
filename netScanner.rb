require 'tty'
require 'socket'
require 'differ'
require_relative 'rubyHelpers.rb'


cmd = TTY::Command.new(printer: :null)

addr_infos = Socket.ip_address_list
spinner    = TTY::Spinner.new(":spinner".blue + " Scanning net...".brown , format: :bouncing_ball)



# diff = Differ.diff "foo", "boo"

# puts diff.format_as :color

# File.open(netScanDump, 'w') { |file| file.write("your text") }

addr_infos.each do |ip|
  next if ip.ip_address == "127.0.0.1"
  if range = ip.ip_address.match(/(\d{1,3}\.\d{1,3}\.\d{1,3}\.)\d{1,3}/)
    spinner.auto_spin
    out, err = cmd.run("nmap -sP #{range[1]+'0'}/24")
    spinner.stop('Done!'.green)
    puts out
    # (\d{1,3}\.\d{1,3}\.\d{1,3}\.)\d{1,3}
  end 
end


# cmd.run('ls -la')


# cmd.run('ls -la')
# cmd.run('echo Hello!')