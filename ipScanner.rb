require 'socket'

addr_infos = Socket.ip_address_list

puts addr_infos.to_s