# Chess Project - Phase Summary

## What We Achieved (Phase 1)

This project started as a basic chess implementation with several bugs and missing core features. Here's what we fixed and added:

### Fixes & Infrastructure
- **Makefile** — Automated compilation for macOS/Linux (`make`, `make clean`, `make debug`)
- **Memory Bugs** — Fixed game destructor, piece set initialization, input buffer handling
- **Square Constructor** — Removed unused default constructor

### Core Chess Rules Implemented
- **Checkmate Detection** — Game ends when a player is in check with no legal moves
- **Stalemate Detection** — Game draws when a player has no legal moves but isn't in check
- **Game Termination** — Proper game-over logic and display
- **Castling** — Both kingside (O-O) and queenside (O-O-O) with full validation

### UI Polish & Quality of Life ✨
- **Captured Pieces Display** — Shows material captured by each player with score
- **Move Counter** — Displays current move number before each turn

### Result
The game is now **fully playable, rule-correct, enjoyable, and polished** for local 2-player matches.

---

## What We Didn't Do (Phase 2) — Optional Features

These are standard chess rules we could add. They're listed here for completeness, but they can enhance gameplay further.

### 2.1 En Passant
**Complexity:** Medium — Requires tracking the last move and special pawn capture logic.
**Status:** ⏸️ Not started

En passant is a special pawn capture that occurs when an opponent's pawn moves 2 squares forward from its starting position and lands adjacent to your pawn. Your pawn can then capture it as if it had only moved 1 square.

**Implementation notes:** Would need to track the last move in the Game class, then add logic to Pawn to recognize and execute the capture.

### 2.2 Pawn Under-Promotion
**Complexity:** Low — Mostly UI/prompting.
**Status:** ⏸️ Not started

Currently, pawns always promote to Queens. Under-promotion allows choosing Queen, Rook, Bishop, or Knight (useful in rare tactical situations).

**Implementation notes:** When a pawn reaches the end rank, prompt the player for their choice instead of auto-promoting to Queen.

### ~~2.3 Captured Pieces Display~~ ✅ DONE

**Complexity:** Low
**Status:** ✅ Implemented in Phase 1.5

Display showing which pieces each player has captured, displayed after each turn with material scores. Gives a quick visual of material advantage.

**How it works:**
- Each piece now implements a `symbol()` method returning 'P', 'N', 'B', 'R', 'Q', or 'K'
- Player class has `capturedPiecesString()` method that formats captured pieces
- After each move, the game displays: `White captured: P P B (Score: 4)`
- Displays "(none)" if no pieces captured yet

### 2.4 Resign & Quit Commands
**Complexity:** Low — Command parsing in input handling.
**Status:** ⏸️ Not started

Allow players to type "resign" or "quit" during play to end the game prematurely. Useful for tournaments or when a player knows they've lost.

**Implementation notes:** Add special command parsing to the player input handler before attempting to parse moves.

### ~~2.5 Move Counter Display~~ ✅ DONE

**Complexity:** Trivial
**Status:** ✅ Implemented in Phase 1.6

Display showing current move number before each player's turn.

**How it works:**
- Game class has static `moveCount` variable incremented after each full move (White's move)
- Methods: `incrementMoveCount()` to increment, `getMoveCount()` to retrieve
- Main loop displays: `--- Move 1 - White's turn ---` before each move prompt

---

## How the Code is Organized

```
Chess/
├── main.cpp              # Game loop and initialization
├── game.cpp/h            # Game orchestration and state
├── board.cpp/h           # 8x8 board and move validation
├── player.cpp/h          # Player state and input handling
├── piece.cpp/h           # Abstract Piece base class
├── king.cpp/h            # King piece (with castling)
├── queen.cpp/h           # Queen piece
├── rook.cpp/h            # Rook piece
├── bishop.cpp/h          # Bishop piece
├── knight.cpp/h          # Knight piece
├── pawn.cpp/h            # Pawn piece (with promotion)
├── square.cpp/h          # Board square (position + piece)
├── Makefile              # Build automation
└── README.md             # This file
```

---

## Key Decisions

- **Terminal UI** — Simple ASCII board display. No graphics library.
- **C++17** — Uses modern C++ features but keeps code readable.
- **Memory safety** — Proper cleanup and no leaks.

---

## Testing Tips

To verify the game works correctly:

1. **Checkmate** — Try Scholar's mate (4 moves for White to win)
2. **Stalemate** — Position a king and queen to create a stalemate
3. **Castling** — Move king 2 squares toward a corner (if rook hasn't moved)
4. **Pawn Promotion** — Move a pawn to the opposite end with no obstruction

---

> This was a satisfying project that touches real OOP concepts: inheritance, polymorphism, strategy patterns, and proper object lifecycle management.
