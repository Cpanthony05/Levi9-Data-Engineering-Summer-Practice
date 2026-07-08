logs = [
'auth: User alice logged in',
'db: Query executed in 12ms',
'auth: ERROR invalid token for user bob',
'api: GET /orders 200 OK',
'db: ERROR connection timeout',
'api: POST /checkout 201 Created',
'auth: User carol logged in',
'api: GET /products 200 OK',
]


print(logs[-5:])


print(logs[::2])


logs.reverse()
print(logs)

errors = [entry for entry in logs if entry.find("ERROR")!= -1]
print(errors)

count = {}
for entry in logs :
    source = entry.split(':')[0]
    if source in count.keys() :
        count[source] = count[source] + 1
    else :
        count[source] = 1
print(count)

