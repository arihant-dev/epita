#include<stdio.h>
#include<stdlib.h>

struct student
{
    int age;
    float marks;
    char name[20];
    int is_passed;
};


int main() {
    // int *arr;
    // int n, i, sum = 0;

    // printf("Enter the number of elements: ");
    // scanf("%d", &n);

    // // Dynamically allocate memory for n integers
    // arr = (int *)malloc(n * sizeof(int));
    // if (arr == NULL) {
    //     printf("Memory allocation failed\n");
    //     return 1;
    // }

    // // Read n integers from user
    // printf("Enter %d integers:\n", n);
    // for(i = 0; i < n; i++) {
    //     scanf("%d", &arr[i]);
    // }

    // // Calculate the sum of the integers
    // for(i = 0; i < n; i++) {
    //     sum += arr[i];
    // }

    // printf("The sum of the entered integers is: %d\n", sum);

    // // Free the allocated memory
    // free(arr);

    struct student s1;
    s1.age = 20;
    s1.marks = 85.5;
    struct student *ptr = &s1;
    ptr->age = 21; // Accessing age using pointer
    snprintf(s1.name, sizeof(s1.name), "Alice");
    s1.is_passed = 1;
    return 0;
}