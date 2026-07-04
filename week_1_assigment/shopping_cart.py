cart = [
{'name': 'Headphones', 'price': 79.99, 'qty': 1},
{'name': 'USB Cable', 'price': 9.99, 'qty': 3},
{'name': 'Keyboard', 'price': 49.99, 'qty': 0},
{'name': 'Mouse', 'price': 29.99, 'qty': 2},
{'name': 'USB Cable', 'price': 9.99, 'qty': 2},
]

total_price = sum([item['price'] for item in cart])
print(total_price)

for item in cart :
    if item['price'] >= 50 :
        item['price'] = item['price'] - item['price']/10;
print(cart)


cart = [item for item in cart if item['qty']!=0]
print(cart)


cart = sorted(cart, key = lambda x : x['price']* x['qty'], reverse=True)
print(cart)

new_cart = []
for item in cart :
    found = False
    for new_item in new_cart :
        if new_item['name'] == item['name'] :
            found = True
            new_item['qty'] += item['qty']
    if found == False :
        new_cart.append(item)
cart = new_cart
print(cart)