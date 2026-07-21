# Lecture 6: .NET and C# - Classes, Heritage & Generics

## Classes – Heritage (Inheritance)

### Heritage - 1: The "Full Object" Concept

- **All classes inherit from `System.Object`**
  implicitly
- Inheritance follows an **"Is a"** relationship
  (e.g., Aeroplane is a FlyingObject)

```csharp
// Implicitly derived from Object
class FlyingObject
{
    // ...
}

// Aeroplane inherits FlyingObject
// and implements Transport interface
class Aeroplane : FlyingObject, Transport
{
    string PilotName;
}
```

### Heritage - 2: Simple Inheritance Rules

- **Single inheritance only**: A class can inherit
  from **one parent class**
- **Multiple interfaces**: A class may implement
  as many interfaces as wanted
- **Abstract Class** (`abstract` keyword):
  - Cannot be instantiated — must be derived
  - May contain definitions and code
- **Sealed Class** (`sealed` keyword):
  - Cannot be derived (cannot be abstract)
  - Prevents further inheritance

### Heritage - 3: Overriding (Code Specialization)

- To allow overriding, a method must be marked
  `virtual` or `abstract`
- Subclass defines new behavior using `override`
- Base class behavior called with `base` keyword

```csharp
class FlyingObject
{
    public virtual void Takeoff()
    {
        // default takeoff
    }
}

class Aeroplane : FlyingObject
{
    public override void Takeoff()
    {
        // custom takeoff
    }
}
```

> **Key Point**: The new behavior follows the
> **instance**, even if referenced as a base class.

### Heritage - 4: Redefinition (Shadowing)

- All methods can be redefined using `new`
- Base class behavior called with `base` keyword

```csharp
class Aeroplane : FlyingObject
{
    public new void Takeoff()
    {
        // redefined takeoff
    }
}
```

> **Key Point**: The new behavior only applies on
> the **specialized class type**, not on base class
> references.

### Heritage - 5: Constructors and Inheritance

- Constructors are explicit — **no polymorphism**
- Cannot be overridden or redefined
- Constructors may be **chained** using `base`

```csharp
class Person
{
    public Person(string name) { }
}

class Student : Person
{
    // Chaining to base constructor
    public Student(string n) : base(n) { }
}
```

- The compiler automatically chains constructors
  of subclasses to the empty constructor of
  the parent class.

---

## Constructor Chaining - 6

- Constructors may be chained **inside a class**
  using the `this()` keyword

```csharp
class Person
{
    private static int index = 0;
    private int ID;
    private string name;

    public Person()
    {
        this.ID = ++index;
    }

    // Chains to the parameterless constructor
    public Person(string name) : this()
    {
        this.name = name;
    }
}
```

---

## Aggregation vs Composition

### Aggregation ("Has a" — Instance level)

- One class **contains an instance** of another
- The contained object can exist independently

```csharp
class Person { /* name, skills, etc. */ }

class Aeroplane
{
    Person pilot;
}
```

### Composition ("Has a" — Class level)

- One class **defines another class inside itself**
- The inner class is tightly coupled

```csharp
class Aeroplane
{
    LandingGear zeLandingGear;

    class LandingGear
    {
        // number of wheels, etc.
    };
}
```

---

## Interfaces

### Interface Definition (Contract)

- An interface defines a **contract** that
  implementing classes must fulfill
- Contains only method signatures

```csharp
interface IFly
{
    void Takeoff();
    void Land();
}
```

### Interface Implementation

```csharp
class Pilot : IFly
{
    public void Takeoff() { }
    public void Land() { }
}
```

---

### IComparable Interface

- A simple interface for comparison
- Used with `Array.Sort`

```csharp
public interface IComparable
{
    int CompareTo(object o);
}

class Element : IComparable
{
    public float data;

    public int CompareTo(object obj)
    {
        return this.data.CompareTo(
            (obj as Element).data
        );
    }
}
```

### IComparer Interface

- Another comparison interface
- Used with `Array.Sort` for custom comparers

```csharp
public interface IComparer
{
    int Compare(object o, object i);
}

class Element
{
    public float data;

    class DataComparer : IComparer
    {
        public int Compare(object a, object b)
        {
            return ((a as Element).data)
                .CompareTo(
                    (b as Element).data
                );
        }
    }
}
```

---

## Collections

### Basic Concepts

- Native dynamic arrays
- Programming model for data handling
- Use `foreach` keyword to iterate

### System.Collections Namespace

Key types in `System.Collections`:

- CollectionBase
- DictionaryBase
- ArrayList
- Queue
- Stack
- HashTable
- SortedList

### Common Collection Operations

| Operation | Syntax                       |
| --------- | ---------------------------- |
| Count     | `myCollection.Count`         |
| Access    | `myCollection[itemIndex]`    |
| Add       | `myCollection.Add(myItem)`   |
| Insert    | `myCollection.Insert(idx,i)` |
| Remove    | `myCollection.Remove(i)`     |
| RemoveAt  | `myCollection.RemoveAt(i)`   |
| Clear     | `myCollection.Clear()`       |

### foreach Keyword

- Used to browse array elements, form controls,
  running processes, etc.

```csharp
// Array elements
int[] myArray = {1, 3, 5, 7, 9};
foreach (int val in myArray)
    Debug.WriteLine(val.ToString());

// Controls in a Form
foreach (Control c in myForm.Controls)
    Debug.WriteLine(c.Name);

// Running Processes
foreach (Process p in Process.GetProcesses())
    Debug.WriteLine(p.ProcessName);
```

---

## C# Syntax - Generics

### System.Collections.Generic

- Allows for **strongly typed** constructs
- Avoids **boxing/unboxing** overhead
- Better **performance** and **type safety**

Key types in `System.Collections.Generic`:

- `List<T>`
- `Dictionary<T>`
- `LinkedList<T>`
- `Queue<T>`
- `Stack<T>`

### Why Use Generics?

| Feature     | Non-Generic   | Generic       |
| ----------- | ------------- | ------------- |
| Type Safety | Runtime err   | Compile-time  |
| Performance | Boxing        | No boxing     |
| Code Reuse  | Type-specific | Type-agnostic |

### Example

```csharp
// Non-generic (boxing overhead)
ArrayList list = new ArrayList();
list.Add(42);
int value = (int)list[0];

// Generic (no boxing)
List<int> list = new List<int>();
list.Add(42);
int value = list[0];
```

---

## Summary

| Concept      | Key Points                              |
| ------------ | --------------------------------------- |
| Inheritance  | Single class, multiple interfaces       |
| Overriding   | `virtual` + `override` — polymorphic    |
| Redefinition | `new` — shadowing, not polymorphic      |
| Constructors | `base` (parent) or `this()` (same)      |
| Aggregation  | "Has a" — instance contains object      |
| Composition  | "Has a" — class inside class            |
| Interfaces   | Contract with signatures, multiple      |
| Collections  | Dynamic structures, `foreach` iteration |
| Generics     | Type-safe with `List<T>`, `Dict<K,V>`   |
