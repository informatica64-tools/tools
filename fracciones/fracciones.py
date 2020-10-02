#!/usr/bin/env python3

print("You need to give me 4 numbers for each option.\n")

def suma_fracciones():
	# Valores
	n1 = int(input("Give me the first number: "))
	n2 = int(input("Give me the second number: "))
	n3 = int(input("Give me the third number: "))
	n4 = int(input("Give me the fourth number: "))

	# Mcm
	x = n2
	y = n4
	z = max(x, y)

	while True:
		if (z%x == 0) and (z%y == 0):
			return z
		z +=1
	#mcm = z
	mcm = z
	# Operaciones
	print(mcm)
	print(11)

s = suma_fracciones()
print(s)
# print("the result for",str(n1)+"/"+str(n2)+"+"+str(n3)+"/"+str(n4), "is: ")

