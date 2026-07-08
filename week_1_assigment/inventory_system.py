inventory = {
'P001': {'name': 'Notebook', 'qty': 50, 'price': 3.99},
'P002': {'name': 'Pen', 'qty': 0, 'price': 0.99},
'P003': {'name': 'Stapler', 'qty': 12, 'price': 7.49},
'P004': {'name': 'Tape', 'qty': 0, 'price': 1.49},
'P005': {'name': 'Highlighter','qty': 34, 'price': 2.29},
}

for item in inventory.items() :
    if item[1].get('qty') == 0 :
        print(item)


def restock(inventory,list) :
    for item in list :
        inventory[item[0]]['qty'] = inventory[item[0]]['qty'] + item[1]
print(inventory)
restock(inventory,[('P001',5),['P003',1]])
print(inventory)

total = sum([item['qty']*item['price'] for item in inventory.values()])
print(total)

new_inventory = dict()
for item in inventory.items() :
    new_inventory[item[1]['name']] = item[0]
print(new_inventory)

all = [item for item in inventory.items() if item[1]['qty']!=0]
most_expensive = sorted(all,key = lambda item : item[1]['price'], reverse = True)[0]
print(most_expensive)

