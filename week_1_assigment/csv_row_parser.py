csv_data = '''name,category,price,quantity
Widget A,Electronics,29.99,100
Widget B,Electronics,49.99,50
Gadget C,Accessories,9.99,300
Gadget D,Accessories,14.99,0
Device E,Electronics,199.99,25'''

rows = csv_data.strip().splitlines()
rows = [tuple(line.split(',')) for line in rows]
print(rows)

headers = rows[0]
entries = []
for i in range (1,len(rows),1) :
    new_entry = dict()
    for j in range (0,len(headers),1) :
        new_entry[headers[j]] = rows[i][j]
    entries.append(new_entry)
print(entries)

def conversion(dict) :
    try:
        dict['price'] = float(dict['price'])
        dict['quantity'] = int(dict['quantity'])
    except(ValueError,TypeError) :
        pass
    return dict
entries = [conversion(entry) for entry in entries]
print(entries)


print("Total rows " + str(len(entries)))
print("Column names " + str(headers))
for i in range (2,4,1) :
    average = sum([entry[headers[i]] for entry in entries])/len(entries)
    print("Column " + str(headers[i]) + " has average " + str(average))

highest_value = sorted(entries,key = lambda x : x['price']*x['quantity'],reverse=True)[0]
print("Row with highest value " + str(highest_value))