#include<stdio.h>
#include<stdlib.h>

int comp(const void* a, const void* b) {
  	return (*(int*)a - *(int*)b);
}

int main() {
    int arr[11];
    printf("Enter 11 integers: ");

    for(int i = 0; i < 11; i++) {
        scanf("%d", &arr[i]);
    }

    int sum = 0;
    for(int i = 0; i < 11; i++) {
        sum += arr[i];
    } 
    
    float average = sum / 11.0;
    printf("The average of the entered integers is: %f\n", average);

    qsort(arr, 11, sizeof(int), comp);

    printf("The median of the entered integers is: %d\n", arr[5]);

}