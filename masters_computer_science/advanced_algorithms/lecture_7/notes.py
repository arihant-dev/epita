## Given a power_set([1, 2, 3]), return the list of all its subsets.
## The order of the subsets does not matter.
def power_set(s):
    """
    >>> power_set([1, 2])
    [[], [1], [2], [1, 2]]
    >>> power_set([])
    [[]]
    >>> power_set([1, 2, 3])
    [[], [1], [2], [3], [1, 2], [1, 3], [2, 3], [1, 2, 3]]
    """
    ans = [[]]
    for elem in s:
        ans += [subset + [elem] for subset in ans]
    return ans