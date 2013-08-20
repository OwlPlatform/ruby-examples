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

#Search just for all names by providing the .* pattern.
result = cwm.URISearch('.*')
puts "Found uris #{result.get()}"

#Search for all uris and get all of their attributes
#There two arguments to the snapshotRequest. The first is a REGEX pattern of the
#names of objects to search for. The second is a list of patterns that match
#attributes (in this case we just give one pattern that matches all attributes).
puts "Searching for all URIs and attributes"
result = cwm.snapshotRequest('.*', ['.*']).get()
result.each_pair {|uri, attributes|
  puts "Found uri \"#{uri}\" with attributes:"
  attributes.each {|attr|
    puts "\t#{attr.name} is #{attr.data.unpack('G')}"
  }
}

#Get the locations of mugs with updates every second. The third argument to
#the stream request is the request update interval in milliseconds. The first
#two arguments are the same as the snapshot request.
#This is a streaming requests so it will persist until we cancel it
#Cancelling would look like this: mug_request.cancel
mug_request = cwm.streamRequest(".*\.mug\..*", ['location\..offset'], 1000)
while (cwm.connected and not mug_request.isComplete())
  result = mug_request.next()
  result.each_pair {|uri, attributes|
    puts "Found mug \"#{uri}\""
    puts "Location updates are:"
    attributes.each {|attr|
      puts "\t#{attr.name} is #{attr.data.unpack('G')}"
    }
  }
end

