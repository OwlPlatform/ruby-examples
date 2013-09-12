################################################################################
#This program will connect to a world model at a user-provided address and port
#and push a sensor entry into it. For use with the gwt owl demo.
################################################################################

#Require rubygems for old (pre 1.9 versions of Ruby and Debian-based systems)
require 'rubygems'
require 'libowl'

if (ARGV.length != 6)
  puts "This program needs six arguments."
  puts "The ip address and solver port a world model to connect to"
  puts "and a username for the solver connection"
	puts "The next three arguments are the full demo object name,"
  puts "a sensor ID (in decimal), and a display name of a pip to add"
  puts "to the demo page."
  exit
end

wmip = ARGV[0]
solver_port = ARGV[1].to_i
username = ARGV[2]

wmid = ARGV[3]
sensorid = ARGV[4].to_i
displayname = ARGV[5]


#The third argument is the origin name, which should be your solver or
#client's name
swm = SolverWorldModel.new(wmip, solver_port, username)
#All data is given a timestamp in milliseconds. The getMsecTime function is in the wm_data file.
datatime = getMsecTime()

#Physical layer 1 plus the ID for the sensor attribute
attribs = [WMAttribute.new('sensor', [0x01].pack('C') + packuint128(sensorid), datatime),
					WMAttribute.new('displayName', strToUnicode(displayname), datatime)]
#Making a world model data entry with these attributes
data_a = WMData.new(wmid, attribs)

swm.pushData([data_a], true)

