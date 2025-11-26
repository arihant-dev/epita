# Lecture 5: Greedy Algorithms

## Problem Statement

You are a thief in a grain store. Your bag can contain a maximum of gi kg of grain. On the shelves there are several bags of grain , each bag has a different weight wi and a price vi. Your goal is to maximize the value of the grains your are going to steal. You can open a bag of grain and only take a fraction of it. This problem is known as the fractional knapsack problem.
Propose a greedy algorithm to solve this problem, i.e. tell which quantity of which grain should be stolen to maximize your profit. Clearly state what are the inputs of your algorithm and the output.

## Solution

we can sort this array based on the ratio price to weight first and then start from the starting, to take the grains until the bag is full, we can take the fraction of the grains in the end if we have space which is less than the whole weight of the bag of grains at index i
def fractional_knapsack_algorithm(weights, prices, max_weight):
    n = len(weights)
    ratio = [prices[i] / weights[i] for i in range(n)]
    items = sorted(range(n), key=lambda i: ratio[i], reverse=True)

    total_value = 0
    remaining_weight = max_weight
    quantities = [0] * n

    for i in items;
        if remaining_weight <= 0:
            break
        if weights[i] <= remaining_weight:
            quantities[i] = 1
            total_value += prices[i]
            remaining_weight -= weights[i]
        else:
            quantities[i] = remaining_weight / weights[i]
            total_value += prices[i] * quantities[i]
            remaining_weight = 0
    return total_value, quantities
