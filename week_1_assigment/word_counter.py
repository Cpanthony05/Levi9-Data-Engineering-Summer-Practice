text = 'to be or not to be that is the question whether tis nobler in the mind to suffer'
counts = dict()
words = text.split()
print("Words in the text" + str(words))


for word in words :
    counts[word] = counts.get(word,0) + 1
print(counts)

first_three = sorted(counts.items(),key = lambda x : x[1], reverse = True)[:3]
print(first_three)

unique_words = [word for word in counts.items() if word[1] == 1]
print(unique_words)

def same_appearence(counts,word1,word2) :
    if(counts.get(word1,0) == counts.get(word2,0)) :
        return True
    return False

print(same_appearence(counts,"is","that"))
print(same_appearence(counts,"to","be"))

insensitive_count = dict()
for word in words :
    insensitive_count[word.lower()] = insensitive_count.get(word.lower(),0) + 1