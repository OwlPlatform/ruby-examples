################################################################################
#This program will connect to an aggregator and request all packets on phy 1.
#Updates are requested for every 4000 milliseconds.
################################################################################

#Require rubygems for old (pre 1.9 versions of Ruby and Debian-based systems)
require 'rubygems'
require 'libowl'

if (ARGV.length != 2)
  puts "This program needs the ip address and client port of an aggregator to connect to!"
  exit
end

aggip = ARGV[0]
port = ARGV[1]

sq = SolverAggregator.new(aggip, port)

#Request packets from physical layer 1, don't specify a transmitter ID or
#mask, and request packets every 4000 milliseconds
#Phy 1 is for pips. Phy 0 is for all devices on every phy.
sq.sendSubscription([AggrRule.new(1, [], 1000)])
#If we wanted to only search for a specific transmitter, this is the way:
#sq.sendSubscription([AggrRule.new(1, [IDMask.new(2890)], 0)])

while (sq.handleMessage) do
  if (sq.available_packets.length != 0) then
    puts "Processing some packets!"
    for packet in sq.available_packets do
      puts packet
    end
		#Clear the queue of incoming packets.
		sq.available_packets = []
  end
end

puts "connection closed"

