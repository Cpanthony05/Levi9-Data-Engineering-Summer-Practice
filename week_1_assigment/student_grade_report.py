students = [('Alice',92),('Bob',88),('Carol',74),('Dave',55),('Eve',61),('Frank',95),('Grace',48)]


sorted_list = sorted(students, key = lambda x: x[1], reverse = True)
print(sorted_list)

above_60 = [x for x in students if x[1] >= 60]
print(above_60)

first = sorted(students,key = lambda x : x[1], reverse = True)[0]
last = sorted(students,key = lambda x : x[1], reverse = False)[0]
print(first)
print(last)

average = sum([x[1] for x in students])/ len(students)
print(round(average,1))

count = 0
for x in sorted_list :
    count =  count + 1
    first_part = ""
    if count % 10 == 1 and count != 11:
        first_part = "{}st".format(count)
    elif count %10 == 2 and count != 12:
        first_part = "{}nd".format(count)
    elif count % 10 == 3 and count != 13 :
        first_part = "{}rd".format(count)
    else :
        first_part = "{}th".format(count)
    print(first_part + " {} {}".format(x[0],x[1]))

