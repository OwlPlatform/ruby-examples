################################################################################
#This program will connect to a world model at a user-provided address and port
#and request a few pieces of information, which it will then print.
################################################################################

#Require rubygems for old (pre 1.9 versions of Ruby and Debian-based systems)
require 'rubygems'
require 'libowl'

if (ARGV.length != 2)
  puts "This program needs the ip address and client port of a world model to connect to!"
  exit
end

wmip = ARGV[0]
port = ARGV[1]

#Connect to the world model as a client
cwm = ClientWorldConnection.new(wmip, port)

#Search for all uris and get all of their attributes
#There two arguments to the snapshotRequest. The first is a REGEX pattern of the
#names of objects to search for. The second is a list of patterns that match
#attributes (in this case we just give one pattern that matches all attributes).
puts "Searching for all URIs and attributes"
result = cwm.snapshotRequest('.*', ['.*']).get()
result.each_pair {|uri, attributes|
  puts "Found uri \"#{uri}\" with attributes:"
  attributes.each {|attr|
		puts attr
		#Example of decoding some data
		if (attr.name == "temperature.celsius")
			puts "temperature in celsius is #{attr.data.unpack('G')}"
		end
  }
}

