playlist = []
playlist.append("Blinding Lights")
playlist.append('Levitating')
playlist.append('Stay')
print(playlist)

playlist.insert(2,'Peaches')
print(playlist)

last = playlist.pop()
playlist.insert(0,last)
print(playlist)

def remove(list, item):
    if item in list :
        list.remove(item)
    else:
        print('item is not in the list!')
remove(playlist,'Peaches')
print(playlist)
remove(playlist,'Nature of the beast')
print(playlist)

counter = 0
for song in playlist:
    counter = counter + 1
    print("{}. {}".format(counter,song))


