submissions = ['alice','bob','carol','alice','dave','bob','alice','eve','carol']

freq = dict()
for entry in submissions :
    freq[entry] = freq.setdefault(entry,0) + 1
duplicates = []
for key, value in freq.items() :
    if value > 1 :
        duplicates.append(key)
print(duplicates)

unique_submissions = list(set(submissions))
print(unique_submissions)

two_times = []
three_times = []
for key,value in freq.items() :
    if value == 2 :
        two_times.append(key)
    elif value == 3 :
        three_times.append(key)
print(two_times)
print(three_times)

names = set(submissions)
def lookup (set,name) :
    if name in set :
        return True
    return False
print(lookup(names,"alice"))
print(lookup(names,"gigel"))


unique_count = len(unique_submissions)
print(unique_count)

