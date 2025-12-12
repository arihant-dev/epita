
base_numbers = [1, 3, 4]
def number_of_decompositions_recursive(n):
    if n == 0:
        return 1
    if n < 0:
        return 0
    
    return number_of_decompositions_recursive(n - 1) + number_of_decompositions_recursive(n - 3) + number_of_decompositions_recursive(n-4)

print(number_of_decompositions_recursive(4))

## dry-run
## n = 4

'''
sub-graph of the problem
    6
    5     
    4
    3
    2
    1

'''
