# Lecture 2 — Data Structures

## Table of contents
- [Lists](#lists)
- [Dynamic array](#dynamic-array)
- [Linked List](#linked-list)
- [Containers based on Lists](#containers-based-on-lists)



## Lists


## Dynamic Array

## Linked List

## Containers based on Lists

# Stacks

# Queue
Exercice 6 : Print numbers in binary
Consider the following problem: given a positive integer , print all the binary numbers between 1 and  in increasing order.

For example, for , the algorithm should print: 1, 10, 11, 100, 101, 110, 111, 1000, 1001, 1010

A simple algorithm can solve this problem with a queue. The idea is the following one: we start with the number 1, and we enqueue it. Then, we dequeue the first number  in the queue, print it, and enqueue its two successors  and  in the queue (for example, if , we enqueue 100 and 101). We repeat this operation until we have printed  numbers.

enqueue(ne): insert a new element at the back of the queue
peek(): return the element at the front of the queue
dequeue(): remove the element at the front of the queue

Write this algorithm in pseudocode.

BEGIN
    Function PrintAllBinaryNumbers(n as Integer)
        Variables i, queue
        queue <- Queue()
        queue.enqueue("1")
        count <- 0

        WHILE count < n DO
            s <- queue.dequeue()
            PRINT s
            count = count + 1

            queue.enqueue(s + "0")
            queue.enqueue(s + "1")
        END WHILE
    END Function
END
```


iteration 1:
    Print : 1 
    queue = {"10", "11"}
iteration 2:
    Print : 10
    queue = {"11", "100", "101"}
iteration 3:
    Print : 11
    queue : {"100", "101", "110", "111"}
iteration 4:
    Print: 100
    queue : {"101", "110", "111", "1000", "1001"}


Exercice 8 : K-smallest element
Given an array of numbers of size , print the  smallest elements of the array in increasing order (we assume that printing is done in constant time).

Propose a first algorithm in pseudocode with a linearithmic runtime Theta(n*log(n)) using heap-sort.
BEGIN
    Function smallestElementsOfTheArray(array as []Integers, k as Integers) as []Integers
        Variables 
        heap <- BinaryHeap()
        WHILE element in array DO
            heap.insert(element)
        END WHILE
        
        WHILE k >= 0 DO
            Print heap.find_min()
            heap.delete_min()
        END WHILE
END
--> So when we are inserting elements into our heap it takes - O(log(n)), so for all the elements in the array it would take - O(n*log(n))
--> Printing the first k smallest-elements would take - k*O(log(n)) {{find: Theta(1) and delete-min: O(log(n))}}

---------------------------------------------------

Propose a second algorithm in pseudocode with a runtime Theta(n + k*log(n))  using a binomial heap.
BEGIN
    Function smallestElementsOfTheArray(array as []Integers, k as Integers) as []Integers
        Variables 
        heap <- BinomialHeap()
        WHILE element in array DO
            heap.insert(element)
        END WHILE
        
        WHILE k >= 0 DO
            Print heap.find_min()
            heap.delete_min()
        END WHILE
END
--> So when we are inserting elements into our heap it takes - Theta(1), so for all the elements in the array it would take - O(n)
--> Printing the first k smallest-elements would take - k*O(log(n)) {{find: Theta(1) and delete-min: O(log(n))}}

----------------------------------------------------

Propose a third algorithm in pseudocode with a runtime Theta(n*log(k)) using a binary heap (you can consider that the heap gives access to the maximal element instead of the minimal one).