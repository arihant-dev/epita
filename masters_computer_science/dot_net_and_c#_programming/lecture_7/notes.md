# Lecture 7: .NET and C# - Structured Error Handling

## Structured Error Handling (SEH)

### Objective

- No more return codes for errors
- Isolate error handling from normal flow

### Means

- Use Structured Exception Handling (SEH)
- Keywords: `try` / `catch` / `finally` / `throw`
- Framework class: `System.Exception`

---

## Why Exceptions?

### The Old C Way

- Functions return error codes (e.g., `-1`)
- Caller must check return value every time
- Error handling mixed with normal logic

```c
// Old C style — error codes
int fnct2()
{
    return 0;  // OK
    return -1; // Fault
}
```

### The C# Way

- Exceptions separate error handling from logic
- CLR handles stack unwinding and context saving
- Chained handlers allow layered error handling

---

## How SEH Works (Runtime Service)

### Internal Complexity

- **Context saving**: Stack state, registers
- **Error handling**:
  - Subscription to exception events
  - Callback on error
  - Chained handlers

### Chained Mechanism

```text
Main()          Method1()        Method2()
  try {           try {             try {
    Method1();      Method2();        // Fault
  }               }                 }
  catch {         catch {           catch {
    // Default      // Not my fault   // My fault
  }               }                 }
```

---

## Compiler Mapping

- SEH callbacks mapped to keywords

### `try` Block

- Code block under surveillance

```csharp
try
{
    // Big brother is watching you
}
```

### `catch` Block

- Exception handler connected to SEH

```csharp
catch (Exception e)
{
    // What's your problem?
}
```

### `finally` Block

- Termination handler — always executes

```csharp
finally
{
    // Every path leads here
}
```

---

## Examples

### Example I — Unhandled Exception

```csharp
object myObject = null;
Console.WriteLine("Let's start");

// Null object access — crashes!
myObject.ToString();

Console.WriteLine("End");
```

Output: `NullReferenceException` thrown, program crashes.

---

### Example II — Basic try/catch

```csharp
object myObject = null;
Console.WriteLine("Let's start");

try
{
    Console.WriteLine("Enter try");
    myObject.ToString(); // Null object access
}
catch (System.Exception e)
{
    Console.WriteLine(
        "Execute catch : " + e.Message
    );
}

Console.WriteLine("End");
```

Output:

```text
Let's start
Enter try
Execute catch : Object reference not set
End
```

---

### Example III — Multiple Catch Blocks

```csharp
object myObject = null;
Console.WriteLine("Let's start");

try
{
    Console.WriteLine("Enter try");
    myObject.ToString(); // Null object access
}
catch (System.NullReferenceException e)
{
    Console.WriteLine(
        "Execute 'NullRef' catch : " + e.Message
    );
}
catch (System.Exception e)
{
    Console.WriteLine(
        "Execute 'Exception' catch : " + e.Message
    );
}

Console.WriteLine("End");
```

- Catch blocks evaluated in order
- First matching catch is executed
- Most specific exception first

---

### Example IV — Throwing Exceptions

```csharp
Console.WriteLine("Let's start");

try
{
    Console.WriteLine("Enter try");
    throw new System.OutOfMemoryException(
        "Too greedy!"
    );
}
catch (System.NullReferenceException e)
{
    Console.WriteLine(
        "Execute 'NullRef' catch : " + e.Message
    );
}
catch (System.Exception e)
{
    Console.WriteLine(
        "Execute 'Exception' catch : " + e.Message
    );
}

Console.WriteLine("End");
```

- Use `throw` to explicitly raise an exception
- `OutOfMemoryException` caught by general
  `Exception` handler

---

### Example V — Finally Block

```csharp
object myObject = null;
Console.WriteLine("Let's start");

try
{
    Console.WriteLine("Enter try");
    myObject.ToString(); // Null object access
}
catch (System.Exception e)
{
    Console.WriteLine(
        "Execute catch : " + e.Message
    );
}
finally
{
    Console.WriteLine("Execute finally");
}

Console.WriteLine("End");
```

Output:

```text
Let's start
Enter try
Execute catch : Object reference not set
Execute finally
End
```

- `finally` always runs, whether exception
  occurs or not

---

### Example VI — Nested try/finally

```csharp
object myObject = null;
Console.WriteLine("Let's start");

try
{
    Console.WriteLine("Enter try1");
    try
    {
        Console.WriteLine("Enter try2");
        myObject.ToString(); // Null access
    }
    finally
    {
        Console.WriteLine("Execute finally");
    }
}
catch
{
    Console.WriteLine("Execute catch");
}

Console.WriteLine("End");
```

Output:

```text
Let's start
Enter try1
Enter try2
Execute finally
Execute catch
End
```

- Inner `finally` runs before outer `catch`
- Exception propagates up to nearest handler

---

## Key Rules

| Rule | Description                                    |
| ---- | ---------------------------------------------- |
| 1    | `try` must be followed by `catch` or `finally` |
| 2    | Multiple `catch` blocks allowed                |
| 3    | Catch order: specific to general               |
| 4    | `finally` always executes                      |
| 5    | `throw` raises an exception explicitly         |
| 6    | Exception propagates up the call stack         |

---

## Common Exception Types

| Exception                  | Cause                   |
| ---------------------------| ----------------------- |
| `NullReferenceException`   | Accessing null object   |
| `IndexOutOfRangeException` | Index out of bounds     |
| `InvalidCastException`     | Invalid type conversion |
| `OutOfMemoryException`     | Not enough memory       |
| `DivideByZeroException`    | Division by zero        |
| `ArgumentException`        | Invalid method argument |

---

## SEH Summary

- SEH replaces error return codes
- `try` — code under surveillance
- `catch` — exception handler
- `finally` — termination handler (always runs)
- `throw` — raise an exception
- Exceptions propagate up the call stack
- Catch specific exceptions first, general last
- `finally` block guarantees cleanup execution

---

## Delegates

### Workflow

- **Sender** — The one who is at the origin of the action
- **Receiver** — The one who implements the action

```text
Sender: "Let's have a Barbecue"
        Cal = Cook.BBQ();

Receiver (Cook):
        int BBQ() { return 3000; }
```

---

### Strong Coupling

#### Derivation ("Is a")

- Sender **is a** Receiver (inheritance)
- Direct calls to public methods of the receiver

```csharp
class Cook
{
    public int BBQ() { return 3000; }
}

class Student : Cook
{
    // Student is a Cook — direct access
}
```

#### Aggregation ("Has a")

- Sender **has a** reference to the Receiver

```csharp
class Cook
{
    public int BBQ() { return 3000; }
}

class Student
{
    Cook myCook = new Cook();
    // Student has a Cook — calls via reference
}
```

---

### Interfaces (Contract Coupling)

- Sender defines action prototypes in an interface
- Sender holds a reference to the interface
- Receiver implements **all** methods of the interface

```csharp
public interface Ireceiver
{
    int FeeMe();
}

class USCook : Ireceiver
{
    public int FeeMe() { return 3000; }
}

class Indian : Ireceiver
{
    public int FeeMe() { return 1800; }
}

// Sender uses interface reference
Ireceiver KFC = new USCook();
int cal = KFC.FeedMe();
```

- Keyword: `interface`
- Set of methods — contract oriented programming
- Multiple interface inheritance

---

### Delegate (Light Coupling)

- Sender defines the prototype of **one** method
- Sender sets a delegate instance to the receiver's method
- Receiver only implements **the** method

```csharp
// Delegate declaration (prototype)
delegate int FeedMe();

class Italian
{
    public int Pasta() { return 1800; }
}

// Sender
Italian Luigi = new Italian();
FeedMe Lunch = new FeedMe(Luigi.Pasta);
int cal = Lunch.Invoke();
```

#### Language & Framework

| Aspect   | Details                                                  |
| -------- | -------------------------------------------------------- |
| Keyword  | `delegate` — defines a unique method prototype           |
|          | Must be instantiated                                     |
|          | Any method matching the prototype can be used            |
| Class    | `System.Delegate` — may be ignored by the developer      |
|          | Has specific methods and properties                      |

---

### Delegate Syntax

```csharp
// 1. Define a delegate type & prototype
delegate int delExample(float fl);

// 2. Receiver implements the prototype
int methExample(float f) { /* ... */ }

// 3. Sender creates a delegate instance
delExample myDel = new delExample(methExample);

// 4. Sender calls the delegate instance
int result = myDel.Invoke(2.3f);
```

---

### Anonymous Methods

- No need for a named method when used in one context
- Method body given inline

```csharp
S3.Students = myCourse.Selector(
    delegate(Student std)
    {
        if (std.score > 10)
            return true;
        else
            return false;
    }
);
```

---

### Lambda Expressions

- Shortcut syntax for anonymous methods
- Types are known from delegate declaration
- `=>` operator: "A is transformed into B"

```csharp
S4.Students = myCourse.Selector(
    std => { return (std.score > 10) ? true : false; }
);
```

---

### MulticastDelegate

#### Problem

- A standard delegate has a **unique** receiver

#### Solution

- `MulticastDelegate` inherits from `Delegate`
- Allows a **list of receivers**
- Is the class behind the `delegate` keyword

```csharp
// Chaining multiple receivers
myInstance.myDeleg += M1;
myInstance.myDeleg += M2;
myInstance.myDeleg += M3;

// Invoke — all methods called in order
myInstance.myDeleg();  // M1(), M2(), M3()
```

#### Operators & Methods

| Member                | Description                          |
| --------------------- | ------------------------------------ |
| `=`                   | Set delegate                         |
| `+=`                  | Add method to invocation list        |
| `-=`                  | Remove method from invocation list   |
| `GetInvocationList()` | Get collection of methods            |
| `Method`              | Description of the delegate method   |
| `Target`              | Target object of the delegate        |

---

### Events

- An **event** is a `MulticastDelegate` **without** the `=` operator (only `+=` / `-=`)
- **Sender**: Graphical object receiving user input (Button, etc.)
- **Receiver**: Application class reacting to user input (Form, etc.)

```csharp
// Event handler signature
void DoMyClick(object sender, EventArgs e)
{
    // Code for Button1 Click
}

// Subscription
Button1.Click += DoMyClick;
```

---

### Delegates Summary

| Concept           | Focus                    |
| ----------------- | ------------------------ |
| Class             | State & behavior (encapsulation) |
| Interface         | Behavior (contract)      |
| Delegate          | Action (method)          |
| MulticastDelegate | Linked list of actions   |
| Event             | Specific MulticastDelegate for GUI (Click, Load, Draw, etc.) |
