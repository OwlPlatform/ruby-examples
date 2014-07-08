################################################################################
#This program will connect to a world model at a user-provided address and port
#and push some example data into it. The data will then be fetched to verify
#that it was pushed.
################################################################################

#Require rubygems for old (pre 1.9 versions of Ruby and Debian-based systems)
require 'rubygems'
require 'libowl'

if (ARGV.length != 4)
  puts "This program needs four arguments."
  puts "The ip address, solver port, client port of a world model to connect to"
  puts "and a username for the solver connection"
  exit
end

wmip = ARGV[0]
solver_port = ARGV[1].to_i
client_port = ARGV[2].to_i
username = ARGV[3]

#The third argument is the origin name, which should be your solver or
#client's name
swm = SolverWorldModel.new(wmip, solver_port, username)
#All data is given a timestamp in milliseconds. The getMsecTime function is in the wm_data file.
datatime = getMsecTime()

#We'll make two objects, called yourexample.a and yourexample.b
#We'll give the first one a location and the second will describe some candy

#Make two attributes for an x and y location. Store them as doubles (the 'G'
#directive to the pack command).
attribs = [WMAttribute.new('location.x', [3.14].pack('G'), datatime),
           WMAttribute.new('location.y', [4.13].pack('G'), datatime)]
#Making a world model data entry with these attributes
data_a = WMData.new('yourexample.a', attribs)

#Let's also make another object with string and integer data
#The string we'll store in UTF16 (using the buffer_manip package) and the
#integer will be stored as a 32 bit unsigned integer.
attribs = [WMAttribute.new('description', strToSizedUTF16("Yummy orange slices"), datatime),
           WMAttribute.new('amount', [12].pack('N'), datatime)]
#Make another data entry
data_b = WMData.new('yourexample.b', attribs)

#Now let's send this data to the world model with the pushData function
#Set the second argument to true to create the object with the given
#names (yourexample.a and yourexample.b) if they do not already exist

swm.pushData([data_a, data_b], true)
#Sleep to make sure the push data message arrives before we search for it
sleep 1

#Connect to the world model as a client
cwm = ClientWorldConnection.new(wmip, client_port)

#Search for the bus name that we just added and anything else named yourexample.*
puts "Searching for URIs"
result = cwm.URISearch('yourexample\\..*')
names = result.get()
puts "Found objects #{names}"
#Notice that each object has an empty set of attributes. This is because we
#just searched for object names with the URISearch. Now we'll request
#attributes as well.

puts "Fetching attributes"
names.each_key{|name|
  result = cwm.snapshotRequest(name, ['.*']).get()
  result.each_pair {|name, attributes|
    puts "Found object \"#{name}\" with attributes:"
    attributes.each {|attr|
      if (attr.name.match "location")
        puts "\t#{attr.name} is #{attr.data.unpack('G')}"
      elsif (attr.name.match "amount")
        puts "\t#{attr.name} is #{attr.data.unpack('N')}"
      elsif (attr.name.match "description")
        #The readUTF16 function from buffer_manip unpacks data packed with the
        #strToSizedUTF16 function
        puts "\t#{attr.name} is '#{readUTF16(attr.data)}'"
      elsif (attr.name == "creation")
        #Creation times are packed as 64 bit integers
        puts "\tCreation time is #{attr.creation}"
      else
        puts "\t#{attr.name} is unrecognized"
      end
    }
  }
}

#Now delete the URIs we added
#swm.deleteURI('yourexample.a')
#swm.deleteURI('yourexample.b')

puts "Searching to verify that the URI has been deleted."
#Verify that it is now gone
result = cwm.URISearch('yourexample\\..*')
names = result.get()
puts "There are #{names.length} matching names"

