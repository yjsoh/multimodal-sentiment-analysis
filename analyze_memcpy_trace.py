import operator
import numpy as np
with open("memcpy_trace.csv", 'r') as f:
	raw = f.readlines()

all_dict={}
for l in raw:
	try:
		key=l.split(",")[1]
	except:
		print(l.split(","))
	if key not in all_dict:
		all_dict[key] = 1
	else:
		all_dict[key] = all_dict[key] + 1

sorted_x = sorted(all_dict.items(), key=operator.itemgetter(1))

print("Unique : %d" % (len(sorted_x)))
print("All    : %d" % (len(raw)))
print(sorted_x[-1])

for i in [1, 2, 3]:
	host_addr=[]
	for l in raw:
		if l.count(",") < 2:
			print(l)
			continue
		try:
			key = l.split(",")[i]
			int_key = int(key, 0)
		except:
			print(l)
			continue
		host_addr.append(int_key)

	print("Host---------------------------")
	print("Min  : 0x%s" % format(min(host_addr), '015x'))
	print("Max  : 0x%s" % format(max(host_addr), '015x'))
	print("Min  : %d" % min(host_addr))
	print("Max  : %d" % max(host_addr))
	print("Range: %d" % (int(max(host_addr)) - int(min(host_addr))))
