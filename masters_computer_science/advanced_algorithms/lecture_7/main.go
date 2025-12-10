package main

import "fmt"

func main() {
	//Given a power_set([1, 2, 3]), return the list of all its subsets.
	// The order of the subsets does not matter.
	ans := [][]int{}
	power_set := []int{1, 2, 3}
	power_set_creator(power_set, &ans, len(power_set))
	fmt.Println(ans)
}
func power_set_creator(power_set []int, ans *[][]int, n int) {
	if n == 0 {
		*ans = append(*ans, []int{})
		return
	}
	power_set_creator(power_set[:n-1], ans, n-1)
	size := len(*ans)
	for i := range size {
		subset := make([]int, len((*ans)[i]))
		copy(subset, (*ans)[i])
		subset = append(subset, power_set[n-1])
		*ans = append(*ans, subset)
	}
}
