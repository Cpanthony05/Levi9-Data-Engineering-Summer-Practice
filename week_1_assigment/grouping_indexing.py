employees = [
{'name':'Alice', 'dept':'Engineering', 'salary':85000, 'manager':'Carol'},
{'name':'Bob', 'dept':'Marketing', 'salary':52000, 'manager':'Dave'},
{'name':'Carol', 'dept':'Engineering', 'salary':95000, 'manager':'Eve'},
{'name':'Dave', 'dept':'Marketing', 'salary':61000, 'manager':'Eve'},
{'name':'Frank', 'dept':'Engineering', 'salary':38000, 'manager':'Carol'},
{'name':'Grace', 'dept':'Support', 'salary':41000, 'manager':'Dave'},
]

dept_index = dict()
for employee in employees :
    dept_index.setdefault(employee['dept'],[]).append(employee['name'])
print(dept_index)

salary_bracket = dict()
for employee in employees :
    if employee['salary'] < 40000 :
        salary_bracket.setdefault('junior',[]).append(employee['name'])
    elif employee['salary'] <= 70000 :
        salary_bracket.setdefault('mid', []).append(employee['name'])
    else :
        salary_bracket.setdefault('senior', []).append(employee['name'])
print(salary_bracket)

dept_average = dict()
for employee in employees :
    dept_average.setdefault(employee['dept'],[]).append(employee['salary'])
highest_salary = 0
best_department = ""
for key,value in dept_average.items() :
    average_salary = sum(value) / len(value)
    if average_salary > highest_salary :
        highest_salary = average_salary
        best_department = key
print(best_department)

manager_dict = dict()
for employee in employees :
    manager_dict.setdefault(employee['manager'],[]).append(employee['name'])
print(manager_dict)

lookup_dict = dict()
for employee in employees :
    lookup_dict.setdefault(employee['name'],[]).append(employee)
print(lookup_dict)
