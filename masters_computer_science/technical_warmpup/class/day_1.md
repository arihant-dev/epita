ingredients/input

1 - 1/4 pounds of yellow potatoes, boiled until tender, drained, peeled, then mashed

3 ounces of unsalted butter

4 ounces of heavy cream or creme fraiche

1 clove garlic mashed

sea salt, pepper

1 pound of shredded cheese (no, that is not a typo - see the notes)

directions

Cook and mash the potatoes in whatever way that makes you happy. My only suggestion would be to make sure that in the end, they are nice and smooth. Put the potatoes into a Dutch oven or large skillet. Stir in the butter and cream with a wooden spoon over low heat until fully incorporated, about 5 minutes. 

Add the cheese and keep stirring with a wooden spoon for 10 to 15 minutes. Yes, 10 to 15 minutes. I realize that sounds like a long time but the excess stirring really changes the consistency of the potatoes. What you are looking for is that the potatoes and cheese have fully mixed together and that the mixture becomes elastic. Test by pulling a spoonful up and out of the pot and it resembles molten cheese.

tools -
1. pot
2. skillet
3. 1 ounce cup
4. masher



instructions -
1. take a pan
    a. put 2 ltr of water in it.
    b. take 1/4 pounds of yellow potatoes and put them in the pan.
    c. put the pan on the stove and ignite the stove to medium heat for 15 minutes.
    d. after that let it cool, remove the potatoes and peel them.
    e. mash the peeled potatoes in a bowl.
2. Put the mashed potatoes in a large skillet on low heat.
    a. add 3 ounces(3 cups) of unsalted butter and stir with a wooden spoon.
    b. after 5 minutes, add 4 ounces(4 cups) of heavy cream, and keep stiring.
    c. after that, add 1 pound of shredded cheese, and keep stiring for 10-15 minutes, until smooth.
    d. add a pinch of sea salt and black pepper.

output -
after step 1. mashed potatoes
after step 2. One pan of Pommes Aligot.






1. A = 3, B = 4
2. A = "423",  B = "12",  C = "42312"
3. C = 13, B = 13, A = 13

4. Variable Permutaion
Variables A, B as Integers
BEGIN
    A <- user inputs a number1
    B <- user inputs a number2
    B = A + B
    A = B - A
    B = B - A
END


Exercise 1:
        Variables N, i as integers
        BEGIN
            i <- 1
            Display "Enter a number to display it's multiplication"
            Read N as user input
            For i <= 12
                Print N + " * " + i + " = " + i * N
            ENDFor
        END

        Variable N, sum, i as integers
        BEGIN
            sum <- 0
            i <- 0
            Display "Enter a number to display the sum of all numbers until it"
            Read N as user input
            For i <= N
                sum = sum + i
            ENDFor
            Print sum
        END

        Variable N, i as integers
        BEGIN
            Display "Enter a number to display the next 10 numbers"
            Read N as user input
            i <- 1
            Do
                Print N + i
            While i <= 10
        END

Exercise 2:
*
**
***
****
*****
        Variable i, j as integers
        BEGIN
            For i = 1; i <= 5;
                For j = 1; j <= i;
                    Print "*"
                    j += 1
                ENDFor
                i += 1
            ENDFor
        END

Exercise 3:
*
**
***
**
*
        Variable i, j as integers
        BEGIN
            For i = 1; i <= 3;
                For j = 1; j <= i;
                    Print "*"
                    j += 1
                ENDFor
                i += 1
            ENDFor
            For i = 2; i >= 1;
                For j = 1; j <= i;
                    Print "*"
                    j +=1
                ENDFor
                i -= 1
            ENDFor
        END


  *
 ***
*****
        Variable i, j, k as integers
        BEGIN
            For i = 1; i <= 3;
                For j = 1; j <= 3;
                    if i + j >= 4:
                        Print "*"
                    j += 1
                ENDFor
                For k = 1; k < i;
                    Print "*"
                    k += 1
                ENDFor
                i += 1
            ENDFor
        END


Exercise 4:
Write an algorithm that asks the user for a number and displays whether it is positive, negative, or zero
        Variable N as integer
        BEGIN
            Display "Enter a number"
            Read N from user input
            if N == 0:
                Print "Zero"
            ElseIf N < 0:
                Print "Negative"
            Else
                Print "Positive"
        END


Write an algorithm that asks for a grade (0-100) and displays:
"Excellent" if grade >= 90
"Good" if grade >= 70
"Pass" if grade >= 50
"Fail" otherwise

        Variable N as integer
        BEGIN
            Display "Enter your grade between 0 to 100:"
            Read N from user input
            if N >= 90:
                Print "Excellent"
            ElseIf N >= 70:
                Print "Good"
            ElseIf N >= 50:
                Print "Pass"
            Else:
                Print "Fail"


Write an algorithm that determines if a year is a leap year (divisible by 4, but not by 100, unless also divisible by 400)

        Variable Y as integer
        BEGIN
            Display "Enter a year to check if it's a leap year"
            If Y % 100 == 0 and Y % 400 == 0:
                Print "Leap Year"
            ElseIf Y % 4 == 0 and Y % 100 != 0:
                Print "Leap Year"
            Else:
                Print "Not a Leap Year"
        END

Exercises 5

Write an algorithm that displays all even numbers from 1 to 50
        BEGIN
            For i = 1; i <= 50;
                If i % 2 == 0:
                    Print i + " is an Even Number"
                ENDIf
                i += 1
            ENDFor
        END


Write an algorithm that asks for a number N and calculates the factorial of N
Example: 5! = 5 x 4 x 3 x 2 x 1 = 120

        Variables N, fact as integer
        BEGIN
            Display "Enter a number to calculate it's factorial"
            Read N
            fact <- 1
            For i = 1; i <= N;
                fact = fact * i
                i += 1
            ENDFor
            Print "Factorial of " + N + " is: " + fact
        END


Write an algorithm that displays the Fibonacci sequence up to the 10th term
0, 1, 1, 2, 3, 5, 8, 13, 21, 34

        Variables a, b, c, i as integers
        a <- 0
        b <- 1
        c <- a + b
        Print c + ", "
        BEGIN
            For i = 2; i <= 10;
                a = b;
                b = c;
                c = a + b;
                Print c + ", "
                i += 1
            ENDFor
        END


Exercises (6)  

Write an algorithm that asks the user to enter a number between 1 and 10, and keeps asking until a valid number is entered

    Variable N as integer
    BEGIN
        Do
            Display "Please enter a number between 1 and 10"
            Read N as input from user
        While not (N >= 1 and N <= 10):
        Print "OK"
    END


Write an algorithm that asks for a password and gives the user 3 attempts. Display "Access granted" or "Access denied" accordingly

    Variable password, answer as String, i as integer, access as Boolean
    BEGIN
        answer = epita
        i <- 1
        Do
            Display "Please enter the password: "
            Read password from the user input
            if password = answer:
                access = true
            else:
                i += 1
        While not (access = true or i > 3)
        if access == true:
            Print "Access granted"
        else:
            Print "Access denied"
    END



Write an algorithm that asks the user to enter "yes" or "no" and keeps asking until one of these exact words is entered (case insensitive)

        Variable word as String
        BEGIN
            Do
                Display " Please enter 'yes' or 'no'"
                Read word as input from user
            While not(word == "yes" or word == "no")
        END



Exercise 7

Write an algorithm that:
Write an algorithm that:
1. Asks for temperature in Celsius
2. Converts to Fahrenheit
3. Displays the result

Formula: F = (C × 9/5) + 32

        Variable F, C as decimals
        BEGIN
            Display "Please enter the temperature in Celsius: "
            Read C as input from user
            F = (C * 9/5) + 32
            Print "Temperature in Fahrenheit: " + F
        END


Write an algorithm that:
1. Asks for two numbers (A and B)
2. Asks for an operation (+, -, *, /)
3. Performs the operation
4. Displays the result

        Variables A and B as integers; Operation as String
        BEGIN
            Display "Please enter two numbers for an operation: "
            Read A and B from user input
            Display "Please enter operation to be performed(+, -, *, /) : "
            Read Operation as user input
            If Operation == "+":
                Print A + B
            ElseIf Operation == "-":
                Print A - B
            ElseIf Operation == "*":
                Print A * B
            ElseIf operation == "/":
                Print A/B
            Else:
                Print "Invalid Operation"
        END


Exercises (8)

Write an algorithm that displays a countdown from 10 to 1, then displays "Liftoff!"
10
9
8
...
1
Liftoff!
        Variable i as Integer
        BEGIN
            i <- 10
            For i <= 1;
                Print i
                i -= 1
            ENDFor
            Print "Liftoff!"

Write an algorithm that asks for a number N and displays all its divisors

        Variables N, i as Integers
        BEGIN
            For i = 1; i <= N
                if N % i == 0:
                    Print i
                ENDIf
            ENDFor
        END
    

Write an algorithm that asks for width and height, then displays a rectangle made of asterisks

Example with width=5 and height=3:
*****
*****
*****

    BEGIN
        Function createRectangleOfChar(char as String, width as Integer, height as Integer) as String
          Variables 
            i, j as Integer,
            char as String
          BeginFunction
            result <- ""
            For i <- 1 to height
                For j <- 1 to width
                    result <- result + char
                result <- "/n"
            EndFor
            Return result
        EndFunction

        Function createEmptyRectangleOfChar(char as String, width as Integer, height as Integer) as String
          Variables 
            i, j as Integer,
            char as String
          BeginFunction
            result <- ""
            For i <- 1 to height
                For j <- 1 to width
                    if i == 1 or i == height
                        result <- result + char
                    elseif i == height/2 + 1:
                        if j == 1 or j == width:
                            result <- result + char
                result <- "/n"
            EndFor
            Return result
        EndFunction

₹₹₹