posts = {
'A': {'python', 'tutorial', 'beginner', 'coding'},
'B': {'python', 'advanced', 'decorators', 'coding'},
'C': {'javascript', 'tutorial', 'beginner', 'web'},
'D': {'python', 'tutorial', 'coding', 'tips'},
}

print(posts['A'].intersection(posts['B']))


print(posts['A'].difference(posts['B']))


print(set.union(posts['A'],posts['B'],posts['C'],posts['D']))


print(set.intersection(posts['A'],posts['B'],posts['C'],posts['D']))


def posts_sharing_tags (post) :
    for key, value in posts.items() :
        if value == post :
            continue
        if len(post.intersection(value)) >= 2 :
            print(key)

posts_sharing_tags(posts['A'])