from functions import *

path = './'

tags = get_tags(path)

new_tags = get_new_tags(path, tags)

print "About to write",
print len(new_tags),
print "new tags. Here is the list:"
print
print_new_tags(new_tags)
print
var = raw_input("Do you want to do this? (no/yes)")
if var == "yes":
	write_new_tags(path, new_tags)
	print "Tags were written."
else:
	print "No tags were written."
