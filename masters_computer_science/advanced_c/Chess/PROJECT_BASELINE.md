# Chess Project - Baseline Documentation

> **Document Purpose:** This document captures the complete state of the chess project as
> provided by the professor before any student enhancements. It serves as the authoritative
> reference for what exists, how it works, what is missing, and what assumptions hold true.
> All future enhancements must be documented against this baseline.
---
> **Date of Baseline:** 2026-03-03
> **Original Author:** Professor (course-provided starter code)
> **Course:** Advanced C++ / Object-Oriented Programming

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [File Inventory](#2-file-inventory)
3. [Build System](#3-build-system)
4. [Architecture & Class Hierarchy](#4-architecture--class-hierarchy)
5. [Data Structures](#5-data-structures)
6. [Class-by-Class Reference](#6-class-by-class-reference)
   - 6.1 [Square](#61-square)
   - 6.2 [Board](#62-board)
   - 6.3 [Piece (Abstract Base)](#63-piece-abstract-base)
   - 6.4 [RestrictedPiece](#64-restrictedpiece)
   - 6.5 [King](#65-king)
   - 6.6 [Queen](#66-queen)
   - 6.7 [Rook](#67-rook)
   - 6.8 [Bishop](#68-bishop)
   - 6.9 [Knight](#69-knight)
   - 6.10 [Pawn](#610-pawn)
   - 6.11 [Player](#611-player)
   - 6.12 [Game](#612-game)
7. [Program Flow](#7-program-flow)
8. [Coordinate System & Board Representation](#8-coordinate-system--board-representation)
9. [Move Validation Pipeline](#9-move-validation-pipeline)
10. [Move Execution Process](#10-move-execution-process)
11. [Player Input Handling](#11-player-input-handling)
12. [Memory Management](#12-memory-management)
13. [Design Patterns Used](#13-design-patterns-used)
14. [Features Implemented](#14-features-implemented)
15. [Features NOT Implemented (Gaps)](#15-features-not-implemented-gaps)
16. [Known Bugs & Issues](#16-known-bugs--issues)
17. [Assumptions & Constraints](#17-assumptions--constraints)
18. [Enhancement Opportunities](#18-enhancement-opportunities)

---

## 1. Project Overview

This is a **2-player command-line chess game** written in C++. It was provided as starter
code for an Object-Oriented Programming course. The game implements standard chess piece
movement rules, piece capturing, check detection, and pawn promotion. Players alternate
turns entering moves in algebraic notation (e.g., `a2 a4`).

The project demonstrates:

- Inheritance and polymorphism (Piece hierarchy)
- Singleton pattern (Board)
- Delegation pattern (Pawn promotion)
- STL container usage (`std::set`)
- Virtual function dispatch for piece-specific behavior

**What the game does NOT do:** It has no checkmate/stalemate detection, no castling, no
en passant, no draw conditions, no AI opponent, and no game termination logic. The game
loop runs infinitely via `while(true)`.

---

## 2. File Inventory

### Source Files (13 .cpp files)

| File | Lines | Last Modified | Purpose |
|------|-------|---------------|---------|
| `main.cpp` | 29 | Feb 17 | Entry point; game loop |
| `game.cpp` | 190 | Feb 17 | Game initialization; player management |
| `board.cpp` | 190 | Feb 23* | Board singleton; path-clear checks; display |
| `player.cpp` | 142 | Feb 17 | Player input; check detection; capture |
| `piece.cpp` | 131 | Feb 17 | Base move validation with check verification |
| `restrictedPiece.cpp` | 36 | Feb 17 | Move tracking for castling-eligible pieces |
| `king.cpp` | 50 | Feb 17 | King movement (1 square any direction) |
| `queen.cpp` | 51 | Feb 17 | Queen movement (vertical/horizontal/diagonal) |
| `rook.cpp` | 43 | Feb 17 | Rook movement (vertical/horizontal) |
| `bishop.cpp` | 38 | Feb 17 | Bishop movement (diagonal) |
| `knight.cpp` | 50 | Feb 17 | Knight movement (L-shape) |
| `pawn.cpp` | 132 | Feb 17 | Pawn movement + promotion to Queen |
| `square.cpp` | 39 | Feb 17 | Square getters/setters |

**board.cpp was the only file modified from original (Feb 23 vs Feb 17 for everything else)*

### Header Files (12 .h files)

| File | Lines | Purpose |
|------|-------|---------|
| `game.h` | 66 | Game class declaration |
| `board.h` | 99 | Board class declaration |
| `player.h` | 101 | Player class declaration |
| `piece.h` | 112 | Piece abstract base class declaration |
| `restrictedPiece.h` | 55 | RestrictedPiece class declaration |
| `king.h` | 56 | King class declaration |
| `queen.h` | 56 | Queen class declaration |
| `rook.h` | 57 | Rook class declaration |
| `bishop.h` | 57 | Bishop class declaration |
| `knight.h` | 57 | Knight class declaration |
| `pawn.h` | 78 | Pawn class declaration |
| `square.h` | 78 | Square class declaration |

### Other Files

| File | Purpose |
|------|---------|
| `README.md` | 3-line original readme ("A C++ chess program.") |
| `Chess.vcxproj` | Visual Studio 2022 project file (v143 toolset) |
| `chess` | Pre-compiled macOS executable (136KB) |
| `chess.dSYM/` | macOS debug symbols directory |
| `x64/` | Visual Studio build output directory |
| `.vscode/` | VS Code configuration directory |

---

## 3. Build System

### Visual Studio (Original)

The project was originally set up for **Visual Studio 2022** (MSVC v143 toolset) on
Windows 10, as defined in `Chess.vcxproj`. It supports Debug/Release configurations
for both Win32 and x64 platforms.

### macOS Compilation (Current)

The existing binary was compiled on macOS using clang++. The compilation command
(reconstructed from the binary and dSYM directory) is:

```bash
g++ -g -o chess main.cpp game.cpp board.cpp player.cpp piece.cpp \
    restrictedPiece.cpp king.cpp queen.cpp rook.cpp bishop.cpp \
    knight.cpp pawn.cpp square.cpp
```

**Note:** No Makefile or CMakeLists.txt exists. A build system should be created as
part of enhancements.

---

## 4. Architecture & Class Hierarchy

```bash
                        Piece (abstract base)
                       /    |    \        \
                 Bishop   Queen   Knight   RestrictedPiece
                                          /      |      \
                                       Pawn    Rook    King
```

### Inheritance Relationships

- **`Piece`** (abstract): Base class for all chess pieces. Defines the core `moveTo()`
  logic including tentative-move-and-check-verification. Has pure virtual methods:
  `value()`, `display()`, `canMoveTo()`.

- **`RestrictedPiece`** (extends `Piece`): Intermediate class for pieces that need to
  track whether they have moved (relevant for castling eligibility and pawn double-move).
  Overrides `moveTo()` to set `_moved = true` after first valid move.

- **`Bishop`**, **`Queen`**, **`Knight`** (extend `Piece` directly): Pieces whose
  movement rules do not depend on whether they have moved before.

- **`Pawn`**, **`Rook`**, **`King`** (extend `RestrictedPiece`): Pieces whose behavior
  depends on movement history.

### Composition Relationships

- `Board` **contains** 64 `Square` objects (8x8 2D array of pointers)
- `Square` **has-a** `Piece*` (nullable; the occupying piece)
- `Piece` **has-a** `Square*` (nullable; its current location, `NULL` if captured)
- `Player` **has-a** `King&` (reference to their king)
- `Player` **has-a** `set<Piece*>&` (reference to their active piece set)
- `Player` **has-a** `set<Piece*>` (own set of captured enemy pieces)
- `Game` **has** 2 `Player*` and 2 `set<Piece*>` (static members)
- `Pawn` **has-a** `Piece* _delegate` (points to a `Queen` after promotion)

---

## 5. Data Structures

### Board Representation

```cpp
Square* _squares[8][8];  // 2D array indexed as _squares[x][y]
                          // x = column (0=a, 7=h)
                          // y = row    (0=rank1/white-side, 7=rank8/black-side)
```

### Piece Collections

```cpp
static set<Piece*> whitePieces;  // All white pieces (including captured ones)
static set<Piece*> blackPieces;  // All black pieces (including captured ones)
```

**Important detail:** Captured pieces remain in these sets. They are identified as
captured because their `_square` member is `NULL` (checked via `isOnSquare()`). The
`inCheck()` method filters for on-board pieces when checking attack paths.

### Captured Pieces

```cpp
set<Piece*> _capturedPieces;  // Per-player; pieces this player has captured
```

---

## 6. Class-by-Class Reference

### 6.1 Square

**Files:** `square.h`, `square.cpp`

**Purpose:** Represents one cell on the chess board. Knows its coordinates and what
piece (if any) occupies it.

**Members:**

| Member | Type | Access | Description |
|--------|------|--------|-------------|
| `_x` | `int` | private | Column coordinate (0-7) |
| `_y` | `int` | private | Row coordinate (0-7) |
| `_piece` | `Piece*` | private | Pointer to occupying piece, `NULL` if empty |

**Methods:**

| Method | Signature | Description |
|--------|-----------|-------------|
| Constructor | `Square(int x, int y)` | Initializes coordinates, sets `_piece = NULL` |
| Constructor | `Square()` | **Declared in header but NOT implemented** |
| Destructor | `~Square()` | Empty body |
| `setOccupier` | `void setOccupier(Piece* piece)` | Sets or clears the piece on this square |
| `getX` | `int getX() const` | Returns x coordinate |
| `getY` | `int getY() const` | Returns y coordinate |
| `occupied` | `bool occupied() const` | Returns `_piece` (truthy if occupied) |
| `occupiedBy` | `Piece* occupiedBy() const` | Returns the piece pointer |

**Notes:**

- `occupied()` uses implicit pointer-to-bool conversion (returns the raw pointer, which is truthy if non-null)
- The parameterless `Square()` constructor is declared at `square.h:25` but has no
  implementation in `square.cpp`. This would cause a linker error if ever used.

---

### 6.2 Board

**Files:** `board.h`, `board.cpp`

**Purpose:** Singleton class representing the 8x8 chess board. Provides square access,
path-clearance checks for sliding pieces, end-row detection, and display rendering.

**Members:**

| Member | Type | Access | Description |
|--------|------|--------|-------------|
| `_theBoard` | `static Board*` | private | Singleton instance (initialized to `NULL`) |
| `_DIMENSION` | `static const int = 8` | private | Board dimension constant |
| `_squares` | `Square*[8][8]` | private | 2D array of dynamically allocated squares |

**Methods:**

| Method | Signature | Lines | Description |
|--------|-----------|-------|-------------|
| Constructor | `Board()` | board.cpp:8-18 | Private. Creates 64 `new Square(i, j)` objects |
| Destructor | `~Board()` | board.cpp:20-31 | Deletes all 64 squares, sets pointers to `nullptr` |
| `getBoard` | `static Board* getBoard()` | board.cpp:33-38 | Lazy singleton; creates Board on first call |
| `squareAt` | `Square* squareAt(int x, int y) const` | board.cpp:40-43 | Direct array access. **No bounds checking** |
| `isClearVertical` | `bool isClearVertical(Square& from, Square& to) const` | board.cpp:45-83 | Checks vertical line between two squares for obstacles |
| `isClearHorizontal` | `bool isClearHorizontal(Square& from, Square& to) const` | board.cpp:85-123 | Checks horizontal line between two squares for obstacles |
| `isClearDiagonal` | `bool isClearDiagonal(Square& from, Square& to) const` | board.cpp:125-162 | Checks diagonal line between two squares for obstacles |
| `isEndRow` | `bool isEndRow(Square& location) const` | board.cpp:164-167 | Returns true if `y == 0` or `y == 7` |
| `display` | `void display(ostream& outStream) const` | board.cpp:169-188 | Renders board with algebraic notation labels |

**Path-Clearing Algorithm Details:**

- `isClearVertical`: Ensures `from.x == to.x`, then iterates intermediate y values
  checking for occupancy. Does NOT check the from/to squares themselves.
- `isClearHorizontal`: Ensures `from.y == to.y`, then iterates intermediate x values.
- `isClearDiagonal`: Ensures `|dx| == |dy|`, then walks diagonally checking each
  intermediate square.
- All three return `false` if the path geometry doesn't match (e.g., calling
  `isClearVertical` on a diagonal path returns `false`).
- All three return `true` for adjacent squares (the loop body executes zero times).

**Display Format:**

```bash
   a  b  c  d  e  f  g  h
 -------------------------
8|BR|BN|BB|BQ|BK|BB|BN|BR|8
 -------------------------
7|BP|BP|BP|BP|BP|BP|BP|BP|7
 -------------------------
6|  |  |  |  |  |  |  |  |6
 -------------------------
5|  |  |  |  |  |  |  |  |5
 -------------------------
4|  |  |  |  |  |  |  |  |4
 -------------------------
3|  |  |  |  |  |  |  |  |3
 -------------------------
2|WP|WP|WP|WP|WP|WP|WP|WP|2
 -------------------------
1|WR|WN|WB|WQ|WK|WB|WN|WR|1
 -------------------------
   a  b  c  d  e  f  g  h
```

---

### 6.3 Piece (Abstract Base)

**Files:** `piece.h`, `piece.cpp`

**Purpose:** Abstract base class for all chess pieces. Implements the core move
validation and execution logic, including the tentative-move-and-check-reversal
pattern. Subclasses only need to implement geometry-specific `canMoveTo()`.

**Members:**

| Member | Type | Access | Description |
|--------|------|--------|-------------|
| `_isWhite` | `bool` | protected | Piece color |
| `_color` | `string` | protected | `"W"` or `"B"` for display |
| `_square` | `Square*` | private | Current location; `NULL` if captured |

**Methods:**

| Method | Signature | Description |
|--------|-----------|-------------|
| Constructor | `Piece(bool isWhite)` | Sets color fields, `_square = NULL` |
| Destructor | `virtual ~Piece()` | Empty body (virtual for proper cleanup) |
| `moveTo` | `virtual bool moveTo(Player&, Square&)` | **Core move logic** (see detailed breakdown below) |
| `setLocation` | `virtual void setLocation(Square*)` | Updates `_square` |
| `value` | `virtual int value() const = 0` | Pure virtual; piece point value |
| `isWhite` | `bool isWhite() const` | Returns `_isWhite` |
| `color` | `string color() const` | Returns `_color` |
| `display` | `virtual void display() const = 0` | Pure virtual; prints piece symbol |
| `canMoveTo` | `virtual bool canMoveTo(Square&) const = 0` | Pure virtual; geometry check |
| `isOnSquare` | `bool isOnSquare() const` | Returns `_square` (truthy if on board) |
| `location` | `Square* location() const` | Returns `_square` |

**`Piece::moveTo()` Detailed Logic (piece.cpp:21-104):**

```markdown
1. Check piece belongs to the player making the move (color match)
2. Call canMoveTo() for piece-specific geometry validation
3. If destination is occupied:
   a. If same color as player -> move is INVALID (can't capture own piece)
   b. If different color -> mark as capturable
4. If destination is empty -> move is valid so far
5. TENTATIVE MOVE:
   a. Remove captured piece from board (if any) by setting its location to NULL
   b. Clear source square's occupier
   c. Set piece's internal square to destination
   d. Set destination square's occupier to this piece
6. CHECK VERIFICATION:
   a. Call byPlayer.inCheck()
   b. If in check -> UNDO everything:
      - Reset piece location to source square
      - Restore source square occupier
      - Restore destination square occupier (captured piece or NULL)
      - Restore captured piece's location
   c. If NOT in check -> FINALIZE:
      - Call byPlayer.capture() on captured piece (if any)
7. Return validity
```

This tentative-move pattern is the safety mechanism ensuring no move can leave the
player's own king in check.

---

### 6.4 RestrictedPiece

**Files:** `restrictedPiece.h`, `restrictedPiece.cpp`

**Purpose:** Intermediate abstract class for pieces that need to know if they've been
moved. This is used by:

- **Pawn:** First move can be 2 squares forward
- **Rook:** Castling eligibility (not yet implemented)
- **King:** Castling eligibility (not yet implemented)

**Members:**

| Member | Type | Access | Description |
|--------|------|--------|-------------|
| `_moved` | `bool` | private | Initially `false`; set to `true` after first valid move |

**Methods:**

| Method | Signature | Description |
|--------|-----------|-------------|
| Constructor | `RestrictedPiece(bool isWhite)` | Calls `Piece(isWhite)`, sets `_moved = false` |
| Destructor | `virtual ~RestrictedPiece()` | Empty body |
| `moveTo` | `virtual bool moveTo(Player&, Square&)` | Calls `Piece::moveTo()`, then sets `_moved = true` if valid and not already moved |
| `hasMoved` | `bool hasMoved() const` | Returns `_moved` |

**Key Detail:** Once `_moved` is set to `true`, it can never be reset to `false`. This
means undo/rollback of a first move would incorrectly leave `_moved` as `true`. However,
`Piece::moveTo()` handles the undo before `RestrictedPiece::moveTo()` sets `_moved`,
so this is actually safe: `_moved` is only set after `Piece::moveTo()` returns `true`
(i.e., the check verification passed).

---

### 6.5 King

**Files:** `king.h`, `king.cpp`

**Purpose:** King piece. Moves 1 square in any direction.

**Inherits from:** `RestrictedPiece`

**Methods:**

| Method | Return | Description |
|--------|--------|-------------|
| `value()` | `0` | King has no capture value (game ends before king is captured) |
| `canMoveTo(Square&)` | `bool` | `|dx| <= 1 && |dy| <= 1` (but not both 0, since `canMoveTo` is only called when from != to) |
| `display()` | void | Prints `WK` or `BK` |

**canMoveTo Logic:**

```bash
Valid if: (|dy| == 1 AND dx == 0)           // vertical
      OR (|dx| == 1 AND dy == 0)           // horizontal
      OR (|dx| == 1 AND |dy| == 1)         // diagonal
```

**Note:** Castling is NOT implemented despite King extending RestrictedPiece.

---

### 6.6 Queen

**Files:** `queen.h`, `queen.cpp`

**Purpose:** Queen piece. Moves any number of squares vertically, horizontally, or diagonally.

**Inherits from:** `Piece` (directly, NOT RestrictedPiece)

**Methods:**

| Method | Return | Description |
|--------|--------|-------------|
| `value()` | `9` | Standard chess piece value |
| `canMoveTo(Square&)` | `bool` | Clear vertical OR clear horizontal OR clear diagonal |
| `display()` | void | Prints `WQ` or `BQ` |

**canMoveTo Logic:**

```markdown
Valid if: Board::isClearVertical(current, target)
      OR Board::isClearHorizontal(current, target)
      OR Board::isClearDiagonal(current, target)
```

---

### 6.7 Rook

**Files:** `rook.h`, `rook.cpp`

**Purpose:** Rook piece. Moves any number of squares vertically or horizontally.

**Inherits from:** `RestrictedPiece`

**Methods:**

| Method | Return | Description |
|--------|--------|-------------|
| `value()` | `5` | Standard chess piece value |
| `canMoveTo(Square&)` | `bool` | Clear vertical OR clear horizontal |
| `display()` | void | Prints `WR` or `BR` |

---

### 6.8 Bishop

**Files:** `bishop.h`, `bishop.cpp`

**Purpose:** Bishop piece. Moves any number of squares diagonally.

**Inherits from:** `Piece` (directly)

**Methods:**

| Method | Return | Description |
|--------|--------|-------------|
| `value()` | `3` | Standard chess piece value |
| `canMoveTo(Square&)` | `bool` | Clear diagonal |
| `display()` | void | Prints `WB` or `BB` |

---

### 6.9 Knight

**Files:** `knight.h`, `knight.cpp`

**Purpose:** Knight piece. Moves in an L-shape. Can jump over other pieces.

**Inherits from:** `Piece` (directly)

**Methods:**

| Method | Return | Description |
|--------|--------|-------------|
| `value()` | `3` | Standard chess piece value |
| `canMoveTo(Square&)` | `bool` | L-shape pattern |
| `display()` | void | Prints `WN` or `BN` (N for kNight to avoid King conflict) |

**canMoveTo Logic:**

```markdown
Valid if: (|dy| == 1 AND |dx| == 2)
      OR (|dx| == 1 AND |dy| == 2)
```

No path-clearing check is needed because knights jump over pieces.

---

### 6.10 Pawn

**Files:** `pawn.h`, `pawn.cpp`

**Purpose:** Pawn piece. Most complex movement rules. Supports forward movement,
initial double-move, diagonal capture, and promotion to Queen.

**Inherits from:** `RestrictedPiece`

**Additional Members:**

| Member | Type | Access | Description |
|--------|------|--------|-------------|
| `_delegate` | `Piece*` | private | `NULL` normally; points to a `Queen` object after promotion |

**Methods:**

| Method | Description |
|--------|-------------|
| Constructor | `Pawn(bool isWhite)` - initializes `_delegate = NULL` |
| Destructor | Deletes `_delegate` if it exists |
| `setLocation(Square*)` | Calls `Piece::setLocation()` (pass-through) |
| `value()` | Returns `1` |
| `moveTo(Player&, Square&)` | Promotion-aware move logic |
| `canMoveTo(Square&)` | Pawn-specific geometry |
| `display()` | Delegates to Queen display if promoted, else `WP`/`BP` |

**Pawn `moveTo()` Logic (pawn.cpp:30-72):**

```sh
IF promoted (delegate exists):
  1. Use delegate's (Queen's) moveTo() for validation
  2. If valid, manually move the Pawn object:
     - Clear source square
     - Update Pawn's location
     - Set destination square occupier to Pawn (not delegate)
ELSE (not promoted):
  1. Call RestrictedPiece::moveTo() for standard move
  2. If valid AND pawn reached end row (y==0 or y==7):
     - Create new Queen as delegate
     - Set delegate's location to pawn's current square
```

**Pawn `canMoveTo()` Logic (pawn.cpp:74-118):**

```sh
IF promoted: delegate to Queen's canMoveTo()
ELSE:
  - Compute translationX and translationY
  - For black pieces, negate both translations (so "forward" is always +Y)

  Valid if:
    1. 1 square forward to EMPTY square (ty==1, tx==0, !occupied)
    2. 2 squares forward on first move to EMPTY square with clear path
       (ty==2, tx==0, !hasMoved(), isClearVertical)
    3. 1 square forward-diagonal to OCCUPIED square (capture)
       (ty==1, |tx|==1, occupied)
```

**Promotion Details:**

- Promotion is automatic (no player choice) and always creates a Queen
- After promotion, the Pawn object stays in the game's piece set
- The delegate Queen handles movement geometry and display
- The Pawn's `moveTo()` must manually handle the board square updates after
  the delegate validates the move, because the delegate's `moveTo()` moves
  the delegate piece object (not the Pawn) on the board
- The promoted Pawn is displayed as the delegate (Queen), making it visually
  indistinguishable from a regular Queen

**Critical Promotion Subtlety:** When a promoted pawn moves, the delegate's
`moveTo()` performs its own tentative-move-and-check-verification on the
*delegate* piece. Then the Pawn's `moveTo()` separately moves the *Pawn* piece.
This means after the delegate moves, the delegate occupies the new square,
but then the Pawn overwrites it. The delegate's square is never cleaned up
properly - a subtle inconsistency that works in practice because the delegate
is never referenced for board display (the Pawn is) and check detection scans
the player's piece set (which contains the Pawn, not the delegate).

---

### 6.11 Player

**Files:** `player.h`, `player.cpp`

**Purpose:** Represents a chess player. Handles move input, input validation, check
detection, and piece capture tracking.

**Members:**

| Member | Type | Access | Description |
|--------|------|--------|-------------|
| `_name` | `string` | private | `"White"` or `"Black"` |
| `_isWhite` | `bool` | private | Player's color |
| `_myPieces` | `set<Piece*>&` | private | **Reference** to the Game's piece set for this color |
| `_capturedPieces` | `set<Piece*>` | private | Pieces this player has captured |
| `_myKing` | `King&` | private | **Reference** to this player's King piece |

**Methods:**

| Method | Signature | Description |
|--------|-----------|-------------|
| Constructor | `Player(string, bool, King&, set<Piece*>&)` | Stores all params |
| Destructor | `~Player()` | Empty body |
| `makeMove` | `bool makeMove()` | Get and execute a move (see detailed flow below) |
| `inCheck` | `bool inCheck()` | Check if king is attacked (see below) |
| `capture` | `void capture(Piece*)` | Set piece location to NULL, add to captured set |
| `getName` | `string getName() const` | Returns `_name` |
| `isWhite` | `bool isWhite() const` | Returns `_isWhite` |
| `score` | `int score() const` | Sum of `value()` of all captured pieces |
| `myPieces` | `set<Piece*>* myPieces() const` | Returns `&_myPieces` |
| `myKing` | `King* myKing() const` | Returns `&_myKing` |

**`makeMove()` Detailed Flow (player.cpp:25-79):**

```sh
1. Check and announce if player is in check: "White is in check!"
2. Prompt: "White player enter move (e.g. a2 a4): "
3. Read two strings from cin: fromSquare, toSquare
4. Validate input in a while loop:
   - Both strings must be exactly 2 characters
   - First char must be in [a-h] (case-insensitive via tolower)
   - Second char must be in [1-8]
   - Source square must be occupied
   - If invalid: "Invalid move. Try again." (to cerr), re-prompt
5. Convert algebraic to coordinates:
   - fromX = char - 'a', fromY = char - '1'
   - toX   = char - 'a', toY   = char - '1'
6. Call piece->moveTo(*this, toSquare) and return result
```

**`inCheck()` Logic (player.cpp:81-100):**

```sh
For each piece in opponent's piece set:
  If piece is still on the board (location != NULL):
    If piece.canMoveTo(myKing's square):
      return true
return false
```

**Important:** This checks geometric reachability via `canMoveTo()`, which accounts
for path blocking (for sliding pieces) but does NOT call `moveTo()` (no check
verification). This is correct because we're asking "can this piece attack this
square" not "can this piece legally move there while verifying its own king safety."

**Capture Handling Note:** When `capture()` is called, it only sets the piece's
location to NULL and adds it to the captured set. The piece is NOT removed from
the Game's piece set (`whitePieces` or `blackPieces`). The `inCheck()` method
handles this by checking `location() != NULL` before testing `canMoveTo()`.

---

### 6.12 Game

**Files:** `game.h`, `game.cpp`

**Purpose:** Static utility class that manages game initialization and player
turn alternation. All data members and key methods are static.

**Members (all static):**

| Member | Type | Description |
|--------|------|-------------|
| `player1` | `Player*` | White player (initialized to `NULL`) |
| `player2` | `Player*` | Black player (initialized to `NULL`) |
| `nextPlayer` | `Player*` | Pointer used for turn alternation |
| `whitePieces` | `set<Piece*>` | All white pieces |
| `blackPieces` | `set<Piece*>` | All black pieces |

**Methods:**

| Method | Description |
|--------|-------------|
| `Game()` | Private empty constructor (prevents instantiation) |
| `~Game()` | Deletes all pieces and players (see bugs section) |
| `initialize()` | Creates all 32 pieces, places them on board, creates 2 players |
| `getNextPlayer()` | Alternates `nextPlayer` between player1 and player2 |
| `opponentOf(Player&)` | Returns the other player (compares by name string) |

**`initialize()` Piece Creation Order (game.cpp:40-162):**

```markdown
1.  White Queen  at d1 (3,0)    |  Black Queen  at d8 (3,7)
2.  White Bishop at c1 (2,0)    |  Black Bishop at c8 (2,7)
3.  White Bishop at f1 (5,0)    |  Black Bishop at f8 (5,7)
4.  White Knight at b1 (1,0)    |  Black Knight at b8 (1,7)
5.  White Knight at g1 (6,0)    |  Black Knight at g8 (6,7)
6.  White Rook   at a1 (0,0)    |  Black Rook   at a8 (0,7)
7.  White Rook   at h1 (7,0)    |  Black Rook   at h8 (7,7)
8.  White Pawns  at a2-h2 (i,1) |  Black Pawns  at a7-h7 (i,6) [loop i=0..7]
9.  White King   at e1 (4,0)
10. Create Player("White", true, whiteKing, whitePieces)
11. Black King   at e8 (4,7)
12. Create Player("Black", false, blackKing, blackPieces)
13. Set nextPlayer = player2
```

**Turn Alternation Logic:**

```markdown
nextPlayer starts as player2 (Black)
getNextPlayer() calls opponentOf(*nextPlayer):
  First call:  opponentOf(Black) -> White  (nextPlayer = White, return White)
  Second call: opponentOf(White) -> Black  (nextPlayer = Black, return Black)
  ...alternates
```

**`opponentOf()` Implementation Detail:** Uses string comparison
(`player.getName() == player1->getName()`) rather than pointer comparison.
This works but is less efficient than comparing pointers or booleans.

---

## 7. Program Flow

### Complete Execution Trace

```sh
main()
  |
  +-> Game::initialize()
  |     |
  |     +-> Board::getBoard()          // creates singleton Board (64 Squares)
  |     +-> Create 32 pieces           // each: new Piece -> set square -> set location -> add to set
  |     +-> new Player("White", ...)   // with references to whiteKing and whitePieces
  |     +-> new Player("Black", ...)   // with references to blackKing and blackPieces
  |     +-> nextPlayer = player2       // so first getNextPlayer() returns player1 (White)
  |
  +-> Board::getBoard()->display(cout) // show initial board state
  |
  +-> INFINITE LOOP:
        |
        +-> currentPlayer = Game::getNextPlayer()  // alternates W/B/W/B...
        |
        +-> RETRY LOOP (until valid move):
        |     |
        |     +-> currentPlayer->makeMove()
        |     |     |
        |     |     +-> Check/announce if in check
        |     |     +-> Get input from user
        |     |     +-> Validate input format
        |     |     +-> Convert algebraic notation to coords
        |     |     +-> piece->moveTo(*this, toSquare)
        |     |           |
        |     |           +-> Verify piece belongs to player
        |     |           +-> canMoveTo() for geometry
        |     |           +-> Check capture validity
        |     |           +-> Tentative move
        |     |           +-> Check for self-check
        |     |           +-> Undo or finalize
        |     |
        |     +-> If invalid: "Invalid move... Try again." -> retry
        |
        +-> Board::getBoard()->display(cout)  // show updated board
        |
        +-> (repeat forever - no exit condition)
```

### Player Turn Order

1. White moves
2. Board displayed
3. Black moves
4. Board displayed
5. Repeat from 1

---

## 8. Coordinate System & Board Representation

### Internal Coordinates

```sh
       x=0  x=1  x=2  x=3  x=4  x=5  x=6  x=7
       (a)  (b)  (c)  (d)  (e)  (f)  (g)  (h)
y=7(8) BR   BN   BB   BQ   BK   BB   BN   BR   <- Black back rank
y=6(7) BP   BP   BP   BP   BP   BP   BP   BP   <- Black pawns
y=5(6)  .    .    .    .    .    .    .    .
y=4(5)  .    .    .    .    .    .    .    .
y=3(4)  .    .    .    .    .    .    .    .
y=2(3)  .    .    .    .    .    .    .    .
y=1(2) WP   WP   WP   WP   WP   WP   WP   WP   <- White pawns
y=0(1) WR   WN   WB   WQ   WK   WB   WN   WR   <- White back rank
```

### Coordinate Conversion

```sh
Algebraic -> Internal:
  'a' -> x=0,  'b' -> x=1, ..., 'h' -> x=7
  '1' -> y=0,  '2' -> y=1, ..., '8' -> y=7

Internal -> Algebraic:
  x=0 -> 'a',  x=1 -> 'b', ..., x=7 -> 'h'
  y=0 -> '1',  y=1 -> '2', ..., y=7 -> '8'
```

### Array Indexing Convention

```cpp
_squares[x][y]  // x is column, y is row
// This is column-major access pattern
// Standard chess: _squares[file][rank]
```

---

## 9. Move Validation Pipeline

A move goes through these validation stages in order:

### Stage 1: Input Format Validation (Player::makeMove)

- Input is two space-separated strings
- Each string is exactly 2 characters
- First character: `[a-h]` (case-insensitive)
- Second character: `[1-8]`
- Source square must be occupied
- **Failure:** "Invalid move. Try again." (to cerr), re-prompt

### Stage 2: Ownership Validation (Piece::moveTo)

- The piece on the source square must match the current player's color
- **Failure:** returns `false`

### Stage 3: Geometry Validation (Piece::canMoveTo - per-piece)

- Each piece type checks its specific movement pattern
- Sliding pieces (Queen, Rook, Bishop) also verify the path is clear
- Knight checks L-shape pattern (no path check - can jump)
- King checks 1-square movement
- Pawn checks forward/double-forward/diagonal-capture rules
- **Failure:** returns `false` from `moveTo()`

### Stage 4: Capture Validation (Piece::moveTo)

- If destination is occupied by same-color piece: **INVALID**
- If destination is occupied by opponent's piece: valid capture
- If destination is empty: valid move

### Stage 5: Check Verification (Piece::moveTo -> Player::inCheck)

- Move is tentatively executed on the board
- `Player::inCheck()` iterates ALL opponent pieces still on the board
- For each opponent piece, checks if it `canMoveTo()` the player's king square
- If any opponent piece can reach the king: move is **INVALID**, undo
- If no opponent piece can reach the king: move is finalized

### Stage 6: Post-Move Effects

- Captured piece (if any) is recorded via `Player::capture()`
- For RestrictedPiece: `_moved` is set to `true` on first valid move
- For Pawn: check if reached end row and promote to Queen

---

## 10. Move Execution Process

### Successful Move (step by step)

```sh
BEFORE:  fromSquare has piece P, toSquare may have piece C

1. toSquare.occupied by enemy piece C?
   -> C.setLocation(NULL)           // tentatively remove from board

2. fromSquare.setOccupier(NULL)     // clear source square

3. P._square = &toSquare            // update piece's internal location

4. toSquare.setOccupier(P)          // place piece on destination

5. byPlayer.inCheck()?
   YES -> UNDO:
     P._square = &fromSquare
     fromSquare.setOccupier(P)
     toSquare.setOccupier(C or NULL)
     if C: C.setLocation(&toSquare)
   NO -> FINALIZE:
     if C: byPlayer.capture(C)
       -> C.setLocation(NULL)       // already NULL, sets again
       -> _capturedPieces.insert(C) // record capture
```

### Important: Capture sets location to NULL twice

The captured piece's location is set to `NULL` during the tentative move (step 1) and
again in `Player::capture()` (step 5). This is redundant but harmless.

---

## 11. Player Input Handling

### Input Method

Standard `cin >>` reads two whitespace-separated tokens.

### Input Validation Loop (player.cpp:49-68)

```cpp
while(fromSquare.length() != 2 ||
      toSquare.length() != 2 ||
      tolower(fromSquare.at(0)) < 'a' ||
      tolower(fromSquare.at(0)) > 'h' ||
      tolower(toSquare.at(0)) < 'a' ||
      tolower(toSquare.at(0)) > 'h' ||
      tolower(fromSquare.at(1)) < '1' ||
      tolower(fromSquare.at(1)) > '8' ||
      tolower(toSquare.at(1)) < '1' ||
      tolower(toSquare.at(1)) > '8' ||
      !(Board::getBoard()->squareAt(...)->occupied())
      )
```

### Input Edge Cases

- The validation DOES NOT check that the player is moving their own piece (that's
  done later in `Piece::moveTo()`). So a player can select an opponent's piece
  square; the move will fail at Stage 2 with "Invalid move... Try again."
- The `cin.clear()` call inside the validation loop clears error flags but the
  commented-out `getline(cin, badInput)` means invalid input isn't fully consumed
  from the stream, potentially causing cascading errors with malformed input.
- Case-insensitive: `tolower()` is used on both characters.

### Error Messages

- Invalid format/empty square: `"Invalid move. Try again."` (to `cerr`)
- Valid format but illegal move: `"Invalid move... Try again."` (to `cerr`, from main.cpp)

Note the slight difference: the inner loop says "Invalid move. Try again." (period)
while the outer loop says "Invalid move... Try again." (ellipsis).

---

## 12. Memory Management

### Allocation Summary

| What | Where Created | How Many | Owned By |
|------|---------------|----------|----------|
| Board (singleton) | `Board::getBoard()` | 1 | Static pointer `_theBoard` |
| Square objects | `Board::Board()` | 64 | Board's `_squares[][]` array |
| Piece objects | `Game::initialize()` | 32 | Game's `whitePieces`/`blackPieces` sets |
| Delegate Queens | `Pawn::moveTo()` | 0-8 | Individual Pawn's `_delegate` pointer |
| Player objects | `Game::initialize()` | 2 | Game's `player1`/`player2` pointers |
| Piece sets | `Game::initialize()` | 2 | **LEAKED** (see bugs) |

### Deallocation

| What | Where Deleted | Notes |
|------|---------------|-------|
| Square objects | `Board::~Board()` | Properly deleted in nested loop |
| Piece objects | `Game::~Game()` | Iterates both sets and deletes each |
| Delegate Queens | `Pawn::~Pawn()` | Deleted if `_delegate != NULL` |
| Player objects | `Game::~Game()` | **BUG:** `delete &player1` - deletes address of pointer, not the pointer's target |
| Board singleton | **NEVER** | No cleanup code; `_theBoard` is never deleted |
| Piece sets | **NEVER** | Allocated with `new set<Piece*>` but never freed |

### Memory Leak Details

1. **Piece set leak (game.cpp:47-48):**

   ```cpp
   whitePieces = *(new set<Piece*>);
   blackPieces = *(new set<Piece*>);
   ```

   This creates a `set` on the heap, copies it into the static member, and loses the
   pointer to the heap allocation. The static members are value types, not pointers,
   so this `new` is both unnecessary and leaks memory.

2. **Board singleton leak:** The `Board` instance created by `getBoard()` is never
   deleted. Since it's a singleton, this typically doesn't matter in practice (the OS
   reclaims at process exit).

3. **No cleanup in main():** `main()` has an infinite loop with no exit path, so
   destructors are never called. The program terminates via Ctrl+C or similar signal,
   at which point the OS reclaims all memory.

---

## 13. Design Patterns Used

### 1. Singleton Pattern (Board)

```cpp
static Board* _theBoard = NULL;
static Board* getBoard() {
    if (!_theBoard) _theBoard = new Board();
    return _theBoard;
}
```

- Lazy initialization on first access
- Thread-unsafe (no mutex/locking)
- Never cleaned up

### 2. Template Method Pattern (Piece::moveTo + canMoveTo)

The base class `Piece::moveTo()` defines the overall move-validation algorithm,
calling `canMoveTo()` as a "hook" that subclasses override for piece-specific
geometry. This is the Template Method pattern.

### 3. Delegation Pattern (Pawn promotion)

A promoted Pawn delegates `canMoveTo()` and `display()` to an internal `Queen`
object. The Pawn remains in the game's piece set, but its behavior changes.

### 4. Polymorphism

All piece types are accessed through `Piece*` pointers. Virtual methods
(`canMoveTo`, `moveTo`, `value`, `display`) dispatch to the correct subclass.

### 5. Static Factory (Game::initialize)

`Game::initialize()` acts as a factory method that creates all game objects
and wires them together. The `Game` class itself is never instantiated.

---

## 14. Features Implemented

| Feature | Status | Details |
|---------|--------|---------|
| 2-player alternating turns | COMPLETE | White always moves first |
| All 6 piece types | COMPLETE | King, Queen, Rook, Bishop, Knight, Pawn |
| Standard piece movement | COMPLETE | Each piece follows correct geometry |
| Path blocking for sliding pieces | COMPLETE | Queen, Rook, Bishop check clear paths |
| Knight jumping | COMPLETE | No path-clear check for knights |
| Piece capturing | COMPLETE | With point-value tracking |
| Check detection | COMPLETE | Announced to player |
| Move-leaves-king-in-check prevention | COMPLETE | Tentative move + undo pattern |
| Pawn double-move on first turn | COMPLETE | Uses `hasMoved()` |
| Pawn promotion to Queen | COMPLETE | Automatic, only to Queen |
| Algebraic notation input | COMPLETE | e.g., "a2 a4" |
| Board display with coordinates | COMPLETE | ASCII art with rank/file labels |
| Score tracking | COMPLETE | `Player::score()` sums captured piece values |
| Case-insensitive input | COMPLETE | `tolower()` applied to input |

---

## 15. Features NOT Implemented (Gaps)

| Missing Feature | Chess Rule | Difficulty | Notes |
|-----------------|------------|------------|-------|
| **Checkmate detection** | Game ends when king is in check and cannot escape | Medium | Requires checking all possible moves for the player in check |
| **Stalemate detection** | Draw when player has no legal moves but is not in check | Medium | Same mechanism as checkmate but checking for zero legal moves |
| **Castling** | King moves 2 squares toward rook; rook jumps over king | Medium | `RestrictedPiece` already tracks `hasMoved()` for King and Rook |
| **En passant** | Pawn captures opponent's pawn that just moved 2 squares | Medium | Requires tracking the last move made |
| **Pawn under-promotion** | Pawn can promote to Rook, Bishop, or Knight (not just Queen) | Easy | Currently hardcoded to Queen |
| **Game termination** | Game should end on checkmate, stalemate, or resignation | Easy | Currently `while(true)` with no exit |
| **Draw conditions** | 50-move rule, 3-fold repetition, insufficient material | Hard | Requires move history and position tracking |
| **Move history/notation** | Record of all moves in standard notation | Easy | No move history exists |
| **AI opponent** | Computer player using minimax/alpha-beta | Hard | Currently 2-player only |
| **Undo/redo** | Take back moves | Medium | No move history exists |
| **Save/load game** | Persist game state to file | Medium | No serialization exists |
| **Timer/clock** | Timed games | Medium | No timing mechanism |
| **Legal move hints** | Show available moves for a piece | Easy | `canMoveTo()` exists but not exposed to UI |
| **Move counter** | Track number of moves played | Easy | No counter exists |
| **Captured pieces display** | Show which pieces have been captured | Easy | `_capturedPieces` exists but not displayed |
| **Input: "quit" command** | Allow graceful exit | Easy | No command parsing |

---

## 16. Known Bugs & Issues

### Bug 1: Game Destructor Deletes Pointer Address (game.cpp:36-37)

```cpp
delete &player1;  // BUG: deletes the address of the pointer variable itself
delete &player2;  // Should be: delete player1; delete player2;
```

**Severity:** Critical (would cause undefined behavior if destructor were called)
**Impact:** None in practice because the destructor is never called (main loops forever)

### Bug 2: Memory Leak in Piece Set Initialization (game.cpp:47-48)

```cpp
whitePieces = *(new set<Piece*>);  // allocates set on heap, copies to static, leaks
blackPieces = *(new set<Piece*>);
```

**Severity:** Minor (small fixed leak, 2 set objects)
**Fix:** Simply remove the `new`: `whitePieces.clear();` or just let default construction handle it.

### Bug 3: Unimplemented Default Constructor (square.h:25)

```cpp
Square();  // declared but never defined
```

**Severity:** Low (linker error only if used, and it's never used)
**Fix:** Remove the declaration or provide an implementation.

### Bug 4: Commented-Out Input Buffer Clearing (player.cpp:65)

```cpp
//getline(cin, badInput); // take bad input off the stream and ignore it
```

**Severity:** Medium (invalid input may not be properly consumed, causing repeated
error messages or unexpected behavior)
**Fix:** Uncomment or use `cin.ignore(numeric_limits<streamsize>::max(), '\n')`.

### Bug 5: Board Singleton Never Freed

**Severity:** Low (OS reclaims at exit)
**Fix:** Add cleanup function or use `atexit()`.

### Bug 6: `isClearVertical`/`isClearHorizontal` Don't Short-Circuit

When an occupied square is found along the path, the functions set `valid = false`
but continue iterating the remaining squares. This is inefficient but not incorrect.

### Bug 7: Promoted Pawn Delegate Inconsistency

After promotion, the delegate Queen's `moveTo()` moves the delegate piece on the
board, then the Pawn's `moveTo()` moves the Pawn piece separately. The delegate
ends up occupying a square that the Pawn then displaces. While this works in
practice, it violates the principle that each square has exactly one occupant.

---

## 17. Assumptions & Constraints

### Design Assumptions

1. **Two human players only.** No AI, no network play.
2. **Players must know chess.** No legal move hints, no move suggestions.
3. **Standard chess rules** except the missing features in Section 15.
4. **Console-only.** No GUI, no color, no Unicode chess symbols.
5. **Single game session.** No save/load, no rematch option.
6. **English-only.** All prompts and messages in English.
7. **Standard initial position.** No custom board setup.

### Technical Constraints

1. **C++ with STL** (`std::set`, `std::string`, `<iostream>`)
2. **No external libraries** required.
3. **Originally Visual Studio 2022** (MSVC v143), adapted for clang++ on macOS.
4. **Single-threaded.** No concurrency.
5. **No build system** (no Makefile, no CMake). Manual compilation required.
6. **All source in single directory** (flat file structure).

### Naming Conventions

- Class names: PascalCase (`RestrictedPiece`, `Board`)
- Member variables: underscore-prefixed (`_isWhite`, `_square`, `_theBoard`)
- Methods: camelCase (`canMoveTo`, `getNextPlayer`, `setOccupier`)
- Files: camelCase matching class name (`restrictedPiece.h`, `restrictedPiece.cpp`)
- Header guards: `CLASSNAME_H` (`PIECE_H`, `BOARD_H`, `RESTRICTED_H`)
  - Exception: `restrictedPiece.h` uses `RESTRICTED_H` instead of `RESTRICTEDPIECE_H`

### Coding Style

- Braces on new line (Allman style)
- Consistent indentation with 4 spaces
- Extensive use of comments (professor's style)
- `using namespace std;` in all headers (not ideal practice but consistent)
- `NULL` used instead of `nullptr` in most places (C-style)
  - Exception: `board.cpp` destructor uses `nullptr` (line 28)

---

## 18. Enhancement Opportunities

The following opportunities are identified by analyzing gaps, bugs, and missing standard
chess features. These are organized by category and will be detailed in a separate
enhancement plan document.

### Category A: Core Chess Rule Completeness

1. **Checkmate detection** - End the game when a player is checkmated
2. **Stalemate detection** - Declare a draw when a player has no legal moves
3. **Castling** (kingside and queenside) - Infrastructure exists (`RestrictedPiece`)
4. **En passant** capture
5. **Pawn under-promotion** (choice of piece, not just Queen)

### Category B: Game Flow & UX

1. **Game termination** - Replace `while(true)` with proper end conditions
2. **Score/captured pieces display** - Show what has been captured
3. **Move history display** - Record and display moves in algebraic notation
4. **Quit/resign command** - Allow graceful exit
5. **Move counter display** - Show current move number

### Category C: Bug Fixes & Code Quality

1. **Fix Game destructor** - `delete player1` instead of `delete &player1`
2. **Fix memory leaks** - Remove unnecessary `new` on piece sets
3. **Remove unimplemented Square()** - Dead declaration
4. **Fix input buffer handling** - Uncomment or replace `getline()`
5. **Add path-clear short-circuiting** - Performance improvement
6. **Add Makefile/CMake** - Proper build system

### Category D: Advanced Features

1. **AI opponent** - Computer player with minimax/alpha-beta pruning
2. **Save/load game** - Serialize game state
3. **Undo/redo** - Move history with rollback
4. **Timer** - Timed games
5. **Legal move display** - Show available moves for selected piece

---

> **End of Baseline Documentation**
>
> This document should be referenced by all enhancement documents. Any change to
> the codebase must be traceable to this baseline. When implementing enhancements,
> create an `ENHANCEMENT_PHASE_N.md` document that references section numbers from
> this baseline and describes exactly what changed, why, and how.
