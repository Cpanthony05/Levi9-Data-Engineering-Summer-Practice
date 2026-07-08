roles = {
'admin': {'read','write','delete','publish','manage_users'},
'editor': {'read','write','publish'},
'viewer': {'read'},
}
users = {'alice':'admin', 'bob':'editor', 'carol':'viewer', 'dave':'editor'}


def has_permission(user,action,users,roles) :
    if user not in users :
        return False
    role = users[user]
    if action in roles[role] :
        return True
    return False
print("Can Alice read " + str(has_permission('alice','read',users,roles)))
print("Can Dave delete " + str(has_permission('dave','delete',users,roles)))

print("Roles admins have but editors dont:" + str(roles['admin'].difference(roles['editor'])))

print("Actions both editor and viewer can do" + str(roles['editor'].intersection(roles['viewer'])))

capable_users = []
for key,value in users.items() :
    if 'delete' in roles[value] :
        capable_users.append(key)
print("Users that can delete " + str(capable_users))

def temporary_perms(user,temp_role,users,roles) :
    current_role = users[user]
    normal_perms = roles[current_role]
    temp_perms = roles[temp_role]
    return frozenset(normal_perms.union(temp_perms))
print("if Bob becomes admin he can : " + str(temporary_perms('bob','admin',users,roles)))
