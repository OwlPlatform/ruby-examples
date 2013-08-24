require 'rubygems'
require 'libowl'

if (ARGV.length != 3)
  puts "The first two arguments of this program are the ip address and"
  puts "solver port of a world model to connect to! The next argument is"
	puts "the name of an object to delete from the world model."
  exit
end

wmip = ARGV[0]
port = ARGV[1]
target = ARGV[2]

wm = SolverWorldModel.new(wmip, port, 'delete name script')

#Delete the object with the given name
wm.deleteURI(target)
