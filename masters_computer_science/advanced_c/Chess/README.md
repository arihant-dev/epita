# Chess

A fully playable, rule-correct chess game written in C++ for a 2-player terminal experience.

## Building & Running

### macOS & Linux

**Prerequisites:** A C++ compiler (g++ or clang++) and make.

```bash
# Compile the project
make

# Run the game
./chess

# Clean up build artifacts
make clean

# Build with debug info and address sanitizer
make debug
```

### Windows

**Option 1: Windows Subsystem for Linux (WSL)**

If you have WSL installed, follow the macOS/Linux instructions above.

**Option 2: MinGW or Manual Compilation**

If you have a C++ compiler like MinGW or MSVC installed:

```bash
# With MinGW (g++)
g++ -Wall -Wextra -std=c++17 -o chess *.cpp

# With MSVC (cl.exe)
cl /EHsc /W4 *.cpp
```

Then run:
```bash
./chess          # MinGW
chess.exe        # MSVC
```

**Option 3: Visual Studio**

1. Create a new C++ Console App project
2. Add all `.cpp` and `.h` files to the project
3. Build and run

## How to Play

The game displays an 8×8 board with pieces labeled as follows:

- **K** = King, **Q** = Queen, **R** = Rook
- **B** = Bishop, **N** = Knight, **P** = Pawn
- Uppercase = White, Lowercase = Black

### Basic Rules

Pieces move according to standard chess rules:

- **Pawns** move forward 1 square (or 2 from starting position), capture diagonally, and promote when reaching the opposite end
- **Rooks** move horizontally or vertically
- **Bishops** move diagonally
- **Knights** move in an L-shape (2 squares in one direction, 1 perpendicular)
- **Queens** move like rooks or bishops
- **Kings** move 1 square in any direction, and can castle (move 2 squares if neither king nor rook has moved)

### Move Input

When prompted, enter a move like `e2 e4`:

- First part = current position of your piece (e.g., `e2`)
- Second part = destination square (e.g., `e4`)

Columns are labeled `a–h` (left to right), rows are `1–8` (bottom to top for White).

### Game End Conditions

The game ends when:

- **Checkmate** — One player's king is under attack and has no escape
- **Stalemate** — One player has no legal moves but is not under attack (draw)

## Features

✅ Legal move validation
✅ Check and checkmate detection
✅ Pawn promotion (to Queen by default)
✅ Castling (kingside and queenside)
✅ Stalemate detection (draw condition)
✅ **Captured pieces display** — See what material each player captured
✅ **Move counter** — Track the game progression with move numbers
✅ Clean terminal display with game state

## Project Structure

```
Chess/
├── main.cpp              # Game loop and initialization
├── game.cpp/h            # Game orchestration
├── board.cpp/h           # Board state and move validation
├── player.cpp/h          # Player state and input
├── piece.cpp/h           # Abstract base class for all pieces
├── king.cpp/h            # King (with castling support)
├── queen.cpp/h           # Queen
├── rook.cpp/h            # Rook
├── bishop.cpp/h          # Bishop
├── knight.cpp/h          # Knight
├── pawn.cpp/h            # Pawn (with promotion support)
├── square.cpp/h          # Board square abstraction
├── Makefile              # Build automation
└── README.md             # This file
```

## Implementation Notes

- **Language:** C++17
- **Build System:** Makefile (macOS/Linux)
- **Architecture:** Object-oriented with polymorphic pieces
- **Memory:** Proper cleanup with no leaks
- **UI:** Simple ASCII board in the terminal

## Possible Enhancements

If you want to extend the game further, check `ENHANCEMENT_PLAN.md` for ideas like:

- En passant capture
- Pawn under-promotion
- ~~Display of captured pieces~~ ✅ Done
- Resign/quit commands
- ~~Move counter~~ ✅ Done

Most of the remaining features are straightforward additions that don't require deep refactoring.

## Known Scope

It's a 2-player game meant for learning OOP concepts and chess rules. Perfect for playing with a friend or testing your chess knowledge.

Enjoy!
