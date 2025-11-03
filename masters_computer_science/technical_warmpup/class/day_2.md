Write an algorithm. that will be able to find the following words in the table on the right:


How to find a word:
    i = 0 {to signify we are at the starting character of the word}
    word = "ALLIGATOR"
    2-D array of characters
    If suppose you are standing on (x, y)
        - first check if the array(x, y) == word[i]
            - if yes, 
                - i += 1
                - if i == length(word) 
                    - "FOUND"
                - else
                    - trigger the function to check again with {
                    {(x + 1,y),  word[i + 1]}} and 
                    {{ (x - 1, y),  word[i + 1]}} and 
                    {{(x, y + 1),  word[i + 1]}} and 
                    {{ (x, y - 1), word[i + 1]}}; 
                        - with a base condition (x,y) should not exceed the boundary of the 2-D array of characters
                        
            - if false, 
                - i = 0
                - trigger the function to check with 
                {{(x + 1,y),  word[i]}} and 
                {{ (x - 1, y),  word[i]}} and 
                {{(x, y + 1),  word[i]}} and 
                {{ (x, y - 1), word[i]}}
                    - with a base condition (x,y) should not exceed the boundary of the 2-D array of characters



Implement the factorial in a reusable function
Bonus : implement factorial in 3 different ways

Function factorialOfANumber(N as Integer) as Integer
          Variables 
            N as Integer
          BeginFunction
            if N == 1 Then:
                Return 1
            ENDIf
            Return factorialOfANumber(N-1) * N
        EndFunction

Function factorialOfANumber(N as Integer) as Integer
          Variables 
            N, i, factorial as Integer
            factorial <- 1
          BeginFunction
            For i <- 1 to N
                factorial <- factorial * i
            ENDFor
            Return factorial
        EndFunction

What will this algorithm produce?

        Variable N as Integer[6]
        Variable i,k as Integer
        Begin
            N[0] <- 1
            For k <- 1 to 5
                N[k] <- N[k-1] + 2
            EndFor
            For i <- 0 to 5
                Display N[i]
            EndFor
        End
---> N[0] = 1, N[1] = 3, N[2] = 5, N[3] = 7, N[4] = 9, N[5] = 11


Question
Variable T as Integer[4][2]
        Variables k,m as Integer
        Begin
            For k <- 0 to 3
                For m <- 0 to 1
                    T[k][m] <- k + m
                EndFor
            EndFor
            For k <- 0 to 3
                For m <- 0 to 1
                    Display T[k][m]
                EndFor
            EndFor
        End

Answer
T -> 0, 1
     1, 2
     2, 3
     3, 4


Question: Take the cards in that order: 7, 3, 5, 9, Jack (11), King (13), 6
Write an algorithm that will display the cards in ascending order (using a function)

Answer: 
    Function SortCards(cards as []String) as []String
        Variables i, j, minIdx as Integer, cardNumber1, cardNumber2 as String
        BeginFunction
            For i = 0; i < length(cards) - 1; i += 1
                minIdx = i
                For j = i+1; j < length(cards); j +=1
                    cardNumber1 = cards[j]
                    cardNumber2 = cards[minIdx]
                    If cardNumber1 == "Jack":
                        cardNumber1 = "11"
                    Else If cardNumber1 == "King":
                        cardNumber1 = "13"
                    Else If cardNumber1 == "Queen":
                        cardNumber1 = "12"
                    ENdIf
                    If cardNumber2 == "Jack":
                        cardNumber2 = "11"
                    Else If cardNumber2 == "King":
                        cardNumber2 = "13"
                    Else If cardNumber2 == "Queen":
                        cardNumber2 = "12"
                    EndIf  
                    If (cardNumber1 < cardNumber2):
                        minIdx = j
                    EndIf
                EndFor  
                swap(cards[i], cards[minIdx])
            EndFor
            Return cards
        EndFunction
    
    Function PrintCards()
        Variables cards as []String, i as Integer
        BeginFunction
            cards = ["7", 3", "5", "9", "Jack", "King", "6"]
            cards = SortCards(cards)
            For i = 0; i < length(cards); i++
                Print(cards[i])
            ENDFor
        EndFunction


Variable cards <- {7, 5, 9, 11, 13, 5} as Integer[7], i as Integer, sortedCards as []Integer
Begin
    Function swapArrayValues(array as []Integer, indexA as Integer, indexB as Integer) -> array as []Integer
        Variable temp as Integer
        temp = array[indexA]
        array[indexA] = array[indexB]
        array[indexB] = temp

        Return array
    EndFunction

    Function sort(cards as []Integer) -> []Integers
        Variables i, j, minIdx, temp as Integers
        For i = 0; i < length(cards) - 1; i++
            minIdx = i
            For j = i+1; j < length(cards); j++
                If cards[j] < cards[minIdx]:
                    minIdx = j
                EndIf
            EndFor
            swapArrayValues(cards, minIdx, i)
        EndFor
        Return cards
    EndFunction

    sortedCards = sort(cards)
    For i := 0; i < length(sortedCards); i ++
        Display sortedCards[i]
    EndFor
End


Exercise: implement FIFO and LIFO strategies using a linked list


        Begin Structure Node
            value as Integer
            next as Node
        End Structure

        Begin Structure Node
            value as Integer
            nexts as []Node
        End Structure






Function Integer fn(table as Integer[])
Variable i,sauv as Integer;
BeginFunction
  sauv <- 0; 
  For i <- 1 to length(table) -1, increment by 1
     If table[i] < table[sauv]  Then  
        sauv <- i 
     EndIf
  EndFor
  Return sauv
EndFunction