# Chess Project - Enhancement Plan

> **Reference:** All section numbers (e.g., "Baseline S15.3") refer to
> `PROJECT_BASELINE.md` sections.
>
> **Strategy:** Two phases of increasing complexity. Each phase builds on the
> previous one and leaves the project in a fully functional, compilable state.
> The scope is focused on making the game a complete, rule-correct, playable
> chess game -- not on advanced algorithms or AI.

---

## Phase Overview

| Phase | Focus | Summary |
|-------|-------|---------|
| **Phase 1** | Bug Fixes + Build System + Core Rules | Fix existing bugs, add Makefile, implement checkmate/stalemate, castling, game termination |
| **Phase 2** | Remaining Chess Rules + UX Polish | En passant, pawn under-promotion, captured pieces display, resign/quit, move counter |

---

## Phase 1: Foundation & Core Rules

**Goal:** Fix all known bugs, establish a proper build system, and implement the most
critical missing chess rules so the game can actually end properly.

### 1.1 Create Makefile (Baseline S3)

**What:** Create a `Makefile` for compiling on macOS/Linux with g++/clang++.

**Why:** Currently requires manual compilation command. A Makefile enables `make`,
`make clean`, and `make debug` targets.

**Details:**

- Compiler: `g++` (or `clang++`)
- Flags: `-Wall -Wextra -std=c++17`
- Debug flags: `-g -fsanitize=address`
- Target: `chess` executable
- Automatic dependency tracking on headers
- `make clean` removes binary and object files

**Files changed:** New file `Makefile`

---

### 1.2 Fix Known Bugs (Baseline S16)

#### 1.2.1 Fix Game Destructor (Bug 1)

**File:** `game.cpp:36-37`
**Change:** `delete &player1;` -> `delete player1;` (same for player2)
**Risk:** None. Fixing undefined behavior that was never triggered.

#### 1.2.2 Fix Memory Leak in Piece Set Init (Bug 2)

**File:** `game.cpp:47-48`
**Change:** Remove `*(new set<Piece*>)` pattern. Use `whitePieces.clear();` or no-op
(static sets are already default-constructed).
**Risk:** None.

#### 1.2.3 Remove Unimplemented Square() Constructor (Bug 3)

**File:** `square.h:25`
**Change:** Remove `Square();` declaration.
**Risk:** None; never used.

#### 1.2.4 Fix Input Buffer Handling (Bug 4)

**File:** `player.cpp:65`
**Change:** Replace commented-out `getline()` with proper stream clearing:
`cin.ignore(numeric_limits<streamsize>::max(), '\n');`
**Risk:** Low. Changes input behavior on malformed input.

#### 1.2.5 Add Short-Circuit to Path-Clear Functions (Bug 6)

**File:** `board.cpp` (lines 72-78, 112-118, 150-157)
**Change:** Add `break;` after setting `valid = false` in each loop.
**Risk:** None. Optimization only, same result.

---

### 1.3 Implement Checkmate Detection (Baseline S15, row 1)

**What:** Detect when a player in check has no legal moves (checkmate).

**Why:** The game currently runs forever. Checkmate is the primary win condition
in chess.

**Approach:**

1. Add method `bool Player::hasLegalMove()`:
   - For each of this player's pieces still on the board
   - For each square on the board (8x8 = 64 squares)
   - Attempt `piece->moveTo(*this, square)` tentatively
   - If any move succeeds, return `true`
   - If no move succeeds, return `false`
   - NOTE: `moveTo()` already handles the tentative-move-and-undo pattern,
     so we can directly call it. But we need to UNDO successful moves too,
     or use a copy-based approach.
2. Actually, better approach: Add `bool Piece::canLegallyMoveTo(Player&, Square&)`:
   - Same as `moveTo()` but always undoes the move (dry-run)
   - Returns whether the move would be valid
3. After each move in `main.cpp`, check if the OPPONENT is in checkmate:
   - `if (opponent->inCheck() && !opponent->hasLegalMove())` -> checkmate
   - `if (!opponent->inCheck() && !opponent->hasLegalMove())` -> stalemate

**Files changed:** `player.h`, `player.cpp`, `piece.h`, `piece.cpp`, `main.cpp`

---

### 1.4 Implement Stalemate Detection (Baseline S15, row 2)

**What:** Detect when a player has no legal moves but is NOT in check (stalemate/draw).

**Why:** Stalemate is a standard draw condition.

**Approach:** Same `hasLegalMove()` mechanism from 1.3. The difference is only
in the check condition:

- Check + no legal moves = **checkmate** (opponent wins)
- No check + no legal moves = **stalemate** (draw)

**Files changed:** Same as 1.3 (shared implementation)

---

### 1.5 Implement Game Termination (Baseline S15, row 6)

**What:** Replace `while(true)` with a proper game loop that exits on
checkmate, stalemate, or resignation.

**Why:** The game must end.

**Approach:**

1. Change `main.cpp` loop to `while(!gameOver)`
2. After each move, check for checkmate and stalemate
3. Display appropriate message: "Checkmate! White wins." or "Stalemate! Draw."
4. Display final score
5. Clean exit with proper memory cleanup

**Files changed:** `main.cpp`, `game.h`, `game.cpp` (add cleanup method)

---

### 1.6 Implement Castling (Baseline S15, row 3)

**What:** Allow kingside (O-O) and queenside (O-O-O) castling.

**Why:** Standard chess rule. Infrastructure (`RestrictedPiece.hasMoved()`) already exists.

**Castling Rules:**

1. Neither king nor rook has previously moved (`hasMoved() == false`)
2. No pieces between king and rook (clear path)
3. King is not currently in check
4. King does not pass through a square under attack
5. King does not end up in check

**Approach:**

1. Modify `King::canMoveTo()` to recognize 2-square horizontal moves
2. Add castling validation in `King::moveTo()` or a new method:
   - Check `hasMoved()` for king
   - Identify the relevant rook (kingside or queenside)
   - Check `hasMoved()` for that rook
   - Check path is clear
   - Check king doesn't pass through check
3. Execute both king and rook moves

**Input format:** Player enters `e1 g1` (kingside) or `e1 c1` (queenside).
The king's 2-square move is the trigger.

**Files changed:** `king.h`, `king.cpp`, `piece.cpp` (or new castling logic in
king's `moveTo()` override)

---

### Phase 1 Deliverables

- All 5 bugs fixed
- Makefile created
- Game ends on checkmate or stalemate
- Castling works
- All existing features still work

---

## Phase 2: Remaining Chess Rules & UX Polish

**Goal:** Implement the remaining standard chess rules and add quality-of-life
improvements for a polished, complete chess game.

### 2.1 Implement En Passant (Baseline S15, row 4)

**What:** Allow pawns to capture an opponent's pawn that just moved 2 squares
forward and landed adjacent to the capturing pawn.

**En Passant Rules:**

1. Opponent's pawn just moved 2 squares forward (in the immediately preceding move)
2. The opponent's pawn is now adjacent (same rank, +-1 file) to your pawn
3. Your pawn captures diagonally to the square the opponent's pawn passed through

**Approach:**

1. Add a `lastMovedPiece` and `lastMoveFrom`/`lastMoveTo` to Game (or a Move struct)
2. In `Pawn::canMoveTo()`, add en passant check:
   - Target square is empty
   - Target square is on the diagonal
   - The square directly behind the target (relative to capture direction) has an
     opponent pawn that just moved 2 squares
3. In `Pawn::moveTo()`, after a valid en passant, capture the opponent's pawn
   (which is NOT on the destination square)

**Files changed:** `game.h`, `game.cpp`, `pawn.h`, `pawn.cpp`, `piece.cpp`

---

### 2.2 Implement Pawn Under-Promotion (Baseline S15, row 5)

**What:** Allow pawn to promote to Queen, Rook, Bishop, or Knight (player's choice).

**Why:** Under-promotion is a legal chess rule and sometimes strategically important
(e.g., promoting to Knight for a fork).

**Approach:**

1. When pawn reaches end row, prompt player: "Promote to (Q)ueen, (R)ook, (B)ishop, (K)night?"
2. Create the chosen piece as the delegate instead of always Queen
3. Update `Pawn::display()` to show correct delegated piece

**Files changed:** `pawn.cpp` (promotion logic)

---

### 2.3 Captured Pieces Display (Baseline S15, row 7)

**What:** Show which pieces each player has captured, displayed with the board.

**Approach:**

1. After board display, show captured pieces for each player
2. Format: `White captured: PP BBN R` (sorted by value)
3. Show score difference

**Files changed:** `board.cpp` (display), or `main.cpp`

---

### 2.4 Quit/Resign Command (Baseline S15, row 9)

**What:** Allow players to type "quit" or "resign" to end the game.

**Approach:**

1. In `Player::makeMove()`, check for special commands before algebraic parsing
2. "resign" -> opponent wins
3. "quit" -> game ends (no winner)
4. Return a status enum instead of just `bool`

**Files changed:** `player.h`, `player.cpp`, `main.cpp`

---

### 2.5 Move Counter Display (Baseline S15, row 10)

**What:** Show current move number (e.g., "Move 15 - White's turn").

**Approach:**

1. Add static move counter to Game
2. Increment after each full move (White + Black = 1 move)
3. Display before each player's prompt

**Files changed:** `game.h`, `game.cpp`, `player.cpp`

---

### Phase 2 Deliverables

- En passant works
- Pawn can promote to any piece
- Captured pieces shown after board
- Players can resign or quit
- Move counter shown

---

## Implementation Guidelines for All Phases

### Documentation Requirements

For each change:

1. Record **what** changed (file, line, function)
2. Record **why** (reference to this plan and baseline)
3. Record **how** (brief description of the approach)
4. Record **assumptions** made
5. Update the baseline document if the change affects documented behavior

### Testing Approach

- After each sub-task, compile and verify no regressions
- Test specific scenarios manually:
  - **Checkmate:** Scholar's mate (4 moves), Fool's mate (2 moves)
  - **Stalemate:** King vs King + Queen positioning
  - **Castling:** Both sides, both directions, blocked/invalid cases
  - **En passant:** Standard and edge cases
  - **Promotion:** All 4 piece types

### Code Style

- Follow existing conventions (Baseline S17: Naming Conventions)
- Allman brace style
- 4-space indentation
- `_` prefix for member variables
- camelCase for methods
- PascalCase for classes
- Comment all non-obvious logic

### Git Strategy

- One commit per sub-task (e.g., "Phase 1.2.1: Fix Game destructor")
- Descriptive commit messages referencing this plan
- Tag each phase completion: `v1.0-phase1`, `v1.0-phase2`

---

> **End of Enhancement Plan**
>
> This document should be referenced alongside `PROJECT_BASELINE.md` during
> all implementation work. Each phase should produce an `ENHANCEMENT_LOG_PHASE_N.md`
> documenting exactly what was done.
