## Lecture - 6 : Advanced Algorithms

## Kermit Jump Problem

Kermit the Frog is sitting on a stone in the middle of the river. Kermit wants to join its friend, Hypno Toad, who is waiting on another stone down the river. Kermit will have to jump from stone to stone to reach its friend: its goal is to reach Hypno Toad by making the least possible jumps.
The problem is encoded as follows. Stones are numbered from 0 to n. Kermit is on stone 0 while Hypno is on stone n. For each stone i, the value delta[i]  indicates the furstest stone that can be reach by Kermit by jumping from the stone i. In other words, when Kermit is on the stone i, it can jump on the stones i, i+1, ..., i+delta[i]. When Kermit is on a stone i located between the stones k and delta[k], Kermit can at least jump up to  delta[k]. In other words, for all i less than j delta[i] <= delta[j].
Propose a greedy algorithm that allows Kermit to reach Hypno Toad by making the least possible jumps. Clearly state what are the inputs of your algorithm and the output.

``` python
def kermit_jumps(delta):

    jumps = 0
    end = 0     
    far = 0     
    for i, d in enumerate(delta[:-1]):
        far = max(far, i + d)
        if i == end:
            jumps += 1
            end = far
    return jumps
```


Inputs: 
    a list of positive integers s_i,i∈[1,n] 
    a target integer T
We want to select the subset S of [1,n] such that ∑_(i∈S)▒s_i ≤T and ∑_(i∈S)▒s_i  is maximal

1. Propose a greedy algorithm which runs in O(n), by iteration over the list of integers. 
For each integer, if you can add it to the total, add it. 

def algorithm_blackjack_1(list_of_integers, target):
    total = 0
    for num in list_of_integers:
        if total + num <= target:
            total += num
    return total

2.	Find an example where it is not optimal
list_of_integers = [1, 4, 5, 6]
target = 8

3.Propose a greedy algorithm which runs in O(n×log(n)) by first sorting the list in descending order then iterating over it
def algorithm_blackjack_2(list_of_integers, target):
    sorted_list = sorted(list_of_integers, reverse=True)
    total = 0
    for num in sorted_list:
        if total + num <= target:
            total += num
    return total

4. Find an example where it is not optimal
list_of_integers = [3, 4, 5, 6] -> [6, 5, 4, 3]
target = 8 

5. Propose a greedy algorithm which runs in O(n×log(n)) by first sorting the list in ascending order then iterating over it
def algorithm_blackjack_3(list_of_integers, target):
    sorted_list = sorted(list_of_integers)
    total = 0
    for num in sorted_list:
        if total + num <= target:
            total += num
    return total

6. Find an example where it is not optimal
list_of_integers = [4, 5, 6]
target = 8

7. Propose a greedy algorithm which runs in (O(n^2))
This algorithm will:
    sort them according to their value
    for each element, consider it is selected
    launch the first algorithm on the remaining elements
return the best set of indices you found

def algorithm_blackjack_4(list_of_integers, target):
    n = len(list_of_integers)
    best_total = 0
    for i in range(n):
        current_total = list_of_integers[i]
        if current_total > target:
            continue
        for j in range(n):
            if j!= i and current_total+list_of_integers[j] <= target:
                current_total += list_of_integers[j]
        if current_total > best_total:
            best_total = current_total
    return best_total

7 a. Find an example where it is not optimal
list_of_integers = [3, 4, 5, 6]
target = 8

- it should return 8 but it returns 7, because it first selects 3 then 4 and stops there.

7 b. Prove that it is strictly better than the previous algorithm
list_of_integers = [4, 5, 6]
target = 8

7 c. Propose a global algorithm which runs in 〖O(2〗^n)
This algorithm will try every possible combination of elements (“brute search” algorithm)
def algorithm_blackjack_5(list_of_integers, target):
    n = len(list_of_integers)
    best_total = 0
    for i in range( 2 ** n):
        current_total = 0
        for j in range(n):
            if (i >> j) & 1:
                current_total += list_of_integers[j]
                if current_total > target:
                    break
        if current_total <= target and current_total > best_total:
            best_total = current_total
    return best_total

7 d. Propose a smarter global algorithm which runs in 〖O(2〗^n)
This algorithm will try every possible combination of elements (“brute search” algorithm). It will filter on the combinations and not do the entire sum if we go over the target. 
def algorithm_blackjack_6(list_of_integers, target):
    n = len(list_of_integers)
    best_total = 0
    for i in range( 2 ** n):
        current_total = 0
        for j in range(n):
            if (i >> j) & 1:
                current_total += list_of_integers[j]
                if current_total > target:
                    break
        if current_total <= target and current_total > best_total:
            best_total = current_total
    return best_total

8. Propose a global recursive algorithm which runs in 〖O(2〗^n)
This algorithm will stop if the target is zero and return an empty list. Otherwise, it considers the first element in the list, and do two calls to itself: 
    one time with the first element subtracted from the target and from the list. It will append the element to the result. 
one time with the first element subtracted from the list only. It will append an empty list to the result.
def algorithm_blackjack_7(list_of_integers, target):
    if target == 0:
        return 0
    if not list_of_integers:
        return 0
    first = list_of_integers[0]
    rest = list_of_integers[1:]

    include_first = 0
    if first <= target:
        include_first = first + algorithm_blackjack_7(rest, target - first)
    exclude_first = algorithm_blackjack_7(rest, target)

    return max(include_first, exclude_first)

9. Can we apply the following algorithm if the elements can be positive and negative? 
No, because if we have negative elements, we can always add them to increase the total sum without exceeding the target.

10. If you are given a variation of the problem where elements are positive and negative, can you think about a transformation of the instance such that this algorithm can be applied? 
Yes, we can transform the instance by separating the positive and negative elements.
 We can first apply the algorithm to the positive elements to get the maximum sum without exceeding the target. 
 Then, we can check if adding any negative elements would still keep the total sum within the target. If it does, we can include those negative elements to maximize the total sum.
def algorithm_blackjack_8(list_of_integers, target):
    positive_elements = [x for x in list_of_integers if x > 0]
    negative_elements = [x for x in list_of_integers if x < 0]

    max_positive_sum = algorithm_blackjack_7(positive_elements, target)

    for neg in negative_elements:
        if max_positive_sum + neg <= target:
            max_positive_sum += neg

    return max_positive_sum

11 a. Which of the global algorithms are better in terms of space complexity?
Algorithm 7 has a space complexity of O(n) due to the recursion stack, while Algorithm 8 also has a space complexity of O(n) for storing positive and negative elements separately. Therefore, both algorithms have similar space complexity.
11 b. Which of the global algorithms are better in terms of average computation time?
Algorithm 8 is generally better in terms of average computation time because it reduces the problem size by separating positive and negative elements, allowing for a more efficient calculation. Algorithm 7, on the other hand, explores all combinations without any optimization, leading to longer computation times on average.
