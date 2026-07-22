# Lecture 8: .NET and C# - Threading & Synchronization

## Threading

### System.Threading

- Asynchronous tasks
- Thread start & stop
- Thread synchronization

Key types in `System.Threading`:

- `Thread`
- `ThreadPool`
- `WaitHandle`
- `Monitor`
- ...

---

### Thread

#### Definition

- `public sealed class Thread`
- Execution units — unique thread available from the framework
- A single method is the entry point

#### Life Cycle — Creation

##### I — Entry Point Delegates

```csharp
public delegate void ThreadStart();
public delegate void ParameterizedThreadStart(object obj);
```

##### II — Thread Method & Start

```csharp
void MyMethod() { /* Do something here */ }

ThreadStart myThreadEntryPoint;
myThreadEntryPoint = new ThreadStart(MyMethod);

Thread logicalThread;
logicalThread = new Thread(myThreadEntryPoint);
logicalThread.Start();
```

##### III — Static Entry Point

```csharp
class ThreadableClass
{
    private int myMember;

    private static void StaticMethod()
    {
        // Cannot access myMember
    }

    private void LaunchThread()
    {
        Thread staticThread
            = new Thread(new ThreadStart(StaticMethod));
        staticThread.Start();
    }
}
```

##### IV — Instance Entry Point

```csharp
class ThreadableClass
{
    private int myMember;

    private void InstanceMethod()
    {
        Console.WriteLine("My member is {0}.", myMember);
    }

    static void Main()
    {
        ThreadableClass myInstance = new ThreadableClass();
        Thread instanceThread = new Thread(
            new ThreadStart(myInstance.InstanceMethod));
        instanceThread.Start();
    }
}
```

##### V — Entry Point on `this`

```csharp
class ThreadableClass
{
    private int myMember;

    private void InstanceMethod()
    {
        Console.WriteLine("My member is {0}.", myMember);
    }

    private void LaunchThread()
    {
        Thread thisThread = new Thread(
            new ThreadStart(this.InstanceMethod));
        thisThread.Start();
    }
}
```

#### Life Cycle — Execution

```csharp
// Get current thread
Thread currentThread = Thread.CurrentThread;

// Sleep
Thread.Sleep(100);

// Check if alive
if (logicalThread.IsAlive)
    if (!logicalThread.IsBackground)
        Console.WriteLine("Process life depends on me!");

// Suspend / Resume (DEPRECATED)
// logicalThread.Suspend();
// logicalThread.Resume();
```

#### Life Cycle — Destruction

##### Implicit

- Thread function ends

##### Explicit — Abort

```csharp
logicalThread.Abort();

// Handling the abort
catch (ThreadAbortException abortInProgress)
{
    Console.WriteLine(abortInProgress.Message);
    Thread.ResetAbort(); // Don't give up!
}
```

#### Thread States

10 possible states:

```csharp
switch (Thread.CurrentThread.ThreadState)
{
    case System.Threading.ThreadState.Aborted:
    case System.Threading.ThreadState.AbortRequested:
    case System.Threading.ThreadState.Stopped:
    case System.Threading.ThreadState.StopRequested:
        Console.WriteLine("Goodbye!");
        break;
    case System.Threading.ThreadState.Suspended:
    case System.Threading.ThreadState.SuspendRequested:
    case System.Threading.ThreadState.WaitSleepJoin:
        Console.WriteLine("Good night!");
        break;
    case System.Threading.ThreadState.Unstarted:
        Console.WriteLine("Good luck!");
        break;
    case System.Threading.ThreadState.Background:
    case System.Threading.ThreadState.Running:
        Console.WriteLine("Good job!");
        break;
}
```

#### Properties

```csharp
Thread currentThread = Thread.CurrentThread;

Console.WriteLine($"Name: {currentThread.Name}");
Console.WriteLine($"ID: {currentThread.ManagedThreadId}");
Console.WriteLine($"Background: {currentThread.IsBackground}");
Console.WriteLine($"Priority: {currentThread.Priority}");

currentThread.Priority = ThreadPriority.Highest;
```

#### Priorities — 5 Levels

| Level         | Description                               |
| ------------- | ----------------------------------------- |
| `Lowest`      | Below process base                        |
| `BelowNormal` | Below/Equal to process base               |
| `Normal`      | Below/Above to process base               |
| `AboveNormal` | Equal/Above to process base               |
| `Highest`     | Above to process base                     |

---

### ThreadPool

#### Model

- **Producer/Consumer**
  - A producer has resources
  - Consumers access these resources independently

#### Technical Answer

- A thread pool — each consumer is handled by a producer thread in the pool

#### Life Cycle

- **Creation / Destruction**: Implicit — one thread pool per process

#### Execution

```csharp
// Receiver prototype
public delegate void WaitCallback(object state);

// Sender method
ThreadPool.QueueUserWorkItem(
    new WaitCallback(UserProc),
    producedObject);
```

#### Example

```csharp
class ShopClass
{
    private static int productionInProgress = 0;

    private void Produce(int serial)
    {
        ThreadPool.QueueUserWorkItem(
            new WaitCallback(Consume),
            "serial #" + serial.ToString());
        productionInProgress++;
    }

    private void Consume(object product)
    {
        Console.WriteLine(
            "Thread " + Thread.CurrentThread.GetHashCode()
            + " buys product " + product.ToString());
        Thread.Sleep(100);
        productionInProgress--;
    }

    static void Main(string[] args)
    {
        ShopClass myShop = new ShopClass();
        for (int prodSerial = 0; prodSerial < 20; prodSerial++)
            myShop.Produce(prodSerial);
        while (productionInProgress != 0)
            Thread.Sleep(100);
    }
}
```

#### Parameters

```csharp
// Total threads
ThreadPool.GetMaxThreads(out maxWorker, out maxIoCompletion);
ThreadPool.SetMaxThreads(maxWorker, maxIoCompletion);

// Available threads
ThreadPool.GetAvailableThreads(
    out availableWorker, out availableIoCompletion);
if (availableWorker == 0)
{
    Console.WriteLine("Overload!");
}
```

---

### Threading Summary

| Concept     | Description                                  |
| ----------- | -------------------------------------------- |
| Thread      | Abstraction of ProcessThread                 |
|             | 10 possible states                           |
|             | 5 levels of variable priorities              |
| ThreadPool  | Producer/Consumer model                      |
|             | One pool per process                         |

---

## Synchronization

### What is the Problem?

#### Race Condition

```text
Thread A          Counter          Thread B
Counter++                           Counter++
LOAD  0                              LOAD  0
INC   1                              INC   1
STO         1                       STO         1
              ← Preemption →
             2                     2
             3                     2
```

Counter goes backwards due to concurrent unsynchronized access!

---

### Why Synchronization?

#### Aim

- Exchange data in a multi-thread environment
  - Simultaneous access (concurrency)
  - Writer/Reader sequences

#### Means

- Use synchronization mechanisms
  - **Signalization**
  - **Protection**

---

### Signalization and Protection

#### Signalization

- One thread waits for a signal from another
- Used for coordination (e.g., producer/consumer)

#### Protection

- Only one thread accesses a resource at a time
- Used for critical sections

---

### Deadlock

#### Causes

- Wrong architecture
- Ported code

#### Effects

- Application freeze
- System error

#### Solutions

- Change the architecture

```text
Thread1                     Thread2
  Lock(A)                     Lock(B)
  Wait for B                  Wait for A
  → DEADLOCK                  → DEADLOCK
```

---

### Intra-Process Synchronization

#### Context

- Same address space
- Same handle table

#### Mechanisms

- **Interlocked**
- **Critical Section** (`Monitor` / `lock`)

```text
Process
├── Thread1
└── Thread2
    ├── Interlocked (atomic ops)
    └── Critical Section (Monitor/lock)
```

---

### Intra-Process — Interlocked

#### Atomic Operations

- Simultaneous access to a single value-type variable

#### Static Methods

```csharp
// Increment / Decrement / Add
long newVal = Interlocked.Increment(ref myLong);
int newVal  = Interlocked.Decrement(ref myInt);
int newVal  = Interlocked.Add(ref myInt, valueToAdd);
long newVal = Interlocked.Read(ref myLong);

// Exchange / CompareExchange
int oldVal = Interlocked.Exchange(ref target, source);
int oldVal = Interlocked.CompareExchange(ref target, compare, with);
```

---

### Intra-Process — Critical Section

#### Mechanism

- Serialize access to a code section
- At any time, **only one thread** executes the section
- Protection within the process only

#### Implementation

- **Class**: `Monitor`
- **Keyword**: `lock`

#### Monitor — Principle

```csharp
// Entry
Monitor.Enter(myObject);
bool gotIt = Monitor.TryEnter(myObject, myTimeout);

// Exit
Monitor.Exit(myObject);
```

#### Monitor — Tips & Tricks

```csharp
// Good practice: Exit inside a finally block
object myObject = new object();
Monitor.Enter(myObject);
try
{
    /* critical section */
}
finally
{
    Monitor.Exit(myObject);
}

// Common mistake: assigning a value to the lock object
object myObject = new object();
Monitor.Enter(myObject);
try
{
    myObject = 100; // WRONG — lock object changed!
}
finally
{
    Monitor.Exit(myObject); // Different object!
}
```

#### `lock` Keyword

- Implicit construct of `Monitor.Enter` / `Monitor.Exit`

```csharp
// Monitor (explicit)
object myObj = new object();
Monitor.Enter(myObj);
try
{
    // critical section
}
finally
{
    Monitor.Exit(myObj);
}

// lock (keyword — equivalent)
object myObj = new object();
lock (myObj)
{
    // critical section
}
```

---

### Inter-Process Synchronization

#### Context

- Different address spaces
- Different handle tables

#### Kernel Objects

- `Process` / `Thread`
- `Mutex`
- `Event`
- `Semaphore`

```text
Process1              Process2
  Thread1               Thread1
    Mutex                 Event
```

---

### Inter-Process — WaitHandle

#### Overview

- Based on Win32 — handle is exposed
- Synchronize with the "unmanaged world"
- Single/multiple wait — inter/intra process wait
- `WaitHandle` is an **abstract class**

#### WaitHandle Hierarchy

```text
WaitHandle
├── EventWaitHandle
│   └── Set() / Reset()
├── Mutex
│   └── ReleaseMutex()
└── Semaphore
    └── Release()
```

#### WaitAny & WaitAll

```csharp
WaitHandle[] handles = new WaitHandle[3];
handles[0] = myMutex;
handles[1] = myManualEvent;
handles[2] = myAutoEvent;

// First wins
int winnerIndex = WaitHandle.WaitAny(handles);

// Everybody runs
bool gotThem = WaitHandle.WaitAll(handles);
```

> Warning: Handles must be valid and distinct.

#### WaitOne

```csharp
WaitHandle waitOnThis = new Mutex(); // or EventWaitHandle / Semaphore

bool gotIt = waitOnThis.WaitOne();   // Wait (blocking)

waitOnThis.Close();                  // CloseHandle
```

#### SignalAndWait

```csharp
WaitHandle waitOnThis = new Mutex();
WaitHandle signalThisOne = new Mutex();

// Free a handle and wait on another (atomic)
bool gotIt = WaitHandle.SignalAndWait(signalThisOne, waitOnThis);
```

---

### Inter-Process — Event (EventWaitHandle)

#### Signalization

- Several threads may wait on one or several events
- **Automatic**: Auto reset on signaled thread
- **Manual**: Manual reset only

#### AutoReset vs ManualReset

```csharp
// AutoReset — resets automatically after one thread passes
EventWaitHandle objAuto = new EventWaitHandle(
    false, EventResetMode.AutoReset);

// ManualReset — stays signaled until explicitly reset
EventWaitHandle objManual = new EventWaitHandle(
    false, EventResetMode.ManualReset);

objManual.Set();   // Signal
objManual.Reset(); // Un-signal
```

---

### Inter-Process — Mutex

#### Mutual Exclusion

- A unique thread may own the mutex at any time
- Inter or Intra process exclusion

#### Wait Conditions

- The mutex is free
- Explicit call to `ReleaseMutex()`
- The owner thread dies (`WaitXXX` returns `true`)

#### Singleton Pattern Example

```csharp
class SingletonClass
{
    static void Main()
    {
        bool firstInstance = false;
        const string MUTEX_NAME =
            "MyMutex-{920F9165-8C2B-4760-B5D6-D05EA20A113A}";

        Mutex singletonMutex =
            new Mutex(true, MUTEX_NAME, out firstInstance);

        if (firstInstance)
        {
            // Do your job here...
            singletonMutex.ReleaseMutex();
        }
    }
}
```

---

### Inter-Process — Semaphore

- Resource counter
- May be used to synchronize with unmanaged code

#### Wait Conditions

- Counter is not 0
- Explicit call to `Release()`

---

### Inter-Process — Process / Thread

#### Wait For

```csharp
// Wait for a process to become idle (WinForms)
Process myPad = Process.Start("notepad");
bool padIsReady = myPad.WaitForInputIdle();

// Wait for process termination
bool processIsDead = myProcess.WaitForExit(1000);

// Wait for thread termination
bool threadIsDead = myThread.Join(2000);
```

#### Interrupt

A thread is "blocked" by:

```csharp
Thread.Sleep(1000);
myThread.Join();
myWaitHandle.WaitOne();
WaitHandle.WaitAny(handles); // or WaitAll
```

Unblock on request:

```csharp
myThread.Interrupt();

// Request handling
catch (ThreadInterruptedException interruption)
{
    Console.WriteLine(interruption.Message);
}
```

---

### Synchronization Summary

#### Key Points

- Application architecture is the key
- Choose the right mechanism for your scenario

#### Mechanisms Overview

| Context       | Mechanism         | Description                        |
| ------------- | ----------------- | ---------------------------------- |
| **Intra-process** | `Interlocked`  | Atomic operations on value types   |
|               | `Monitor` / `lock` | Critical section (code protection) |
| **Inter-process** | `Mutex`        | Mutual exclusion (named)           |
|               | `Event` (A/M)     | Signalization (Auto/Manual)        |
|               | `Semaphore`       | Resource counter                   |
|               | `Process`/`Thread`| Wait for termination / interrupt   |
