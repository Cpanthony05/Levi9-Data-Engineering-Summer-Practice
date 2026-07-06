from http.cookiejar import cut_port_re

points = [(3,4),(0,0),(-1,2),(5,-3),(3,4),(1,1),(-4,-4),(2,0)]
def distance (tuple) :
    x = tuple[0]
    y = tuple[1]
    return (x**2 + y**2) ** 0.5

sorted_points = sorted(points,key = lambda x : distance(x))
print("Closest to origin" + str(sorted_points[0]))

first_quadrant = [tuple for tuple in points if tuple[0] > 0 and tuple[1] > 0]
print("Points in first quadrant " + str(first_quadrant))

print("Sorted points " + str(sorted_points))

min_x = min([tuple[0] for tuple in points])
min_y = min([tuple[1] for tuple in points])
max_x = max([tuple[0] for tuple in points])
max_y = max([tuple[1] for tuple in points])
bounding_box = (min_x,min_y,max_x,max_y)
print("Bounding box " + str(bounding_box))

current_points = set()
for point in points :
    if point in current_points :
        print("Duplicate found: " + str(point))
    current_points.add(point)

