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

## Summary

- SEH replaces error return codes
- `try` — code under surveillance
- `catch` — exception handler
- `finally` — termination handler (always runs)
- `throw` — raise an exception
- Exceptions propagate up the call stack
- Catch specific exceptions first, general last
- `finally` block guarantees cleanup execution
