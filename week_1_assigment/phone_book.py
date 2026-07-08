phonebook = dict()
phonebook["Alice"] = "555-0101"
phonebook["Bob"] = "555-0202"
phonebook["Carol"] = "555-0101"
phonebook["Dave"] = "444-0303"
phonebook["Eve"] = "444-0404"
print(phonebook)

def lookup(phonebook,name) :
    if (phonebook.get(name)!= None) :
        print(phonebook.get(name))
    else:
        print("Name not ofound.")

lookup(phonebook,"Alice")
lookup(phonebook,"Gigel")

phonebook.pop("Alice",None)
phonebook.pop("Gigel",None)
print(phonebook)

contacts = sorted(phonebook.items(),key = lambda x : x[0])
print(contacts)

same_area_code = dict()
for contact in phonebook.items() :
    area_code = contact[1][:3]
    if area_code not in same_area_code.keys() :
        same_area_code[area_code] = []
    same_area_code[area_code].append(contact)
print(same_area_code)