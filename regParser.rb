bitdex = 0
# while (true)
  puts "Enter status bits (in hex)"
  statusBits = gets.to_i(16)
  puts '+-----+-------+-------------+'
  puts '| Bit | State | Description |' 
  puts '+-----+-------+-------------+'

  for i in statusBitsDef
    puts "|  #{' ' if bitdex < 10}#{bitdex} |   #{statusBits&0x1}   | #{i.to_s}" 
    bitdex += 1
    foo >>= 1
  end 
# end 