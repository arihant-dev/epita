# constants.py
"""Configuration values for the Game of Life
"""

# Grid size
ROWS = 50
COLS = 50

# Visual settings
CELL_SIZE = 10  # pixels per cell
WINDOW_WIDTH = COLS * CELL_SIZE
WINDOW_HEIGHT = ROWS * CELL_SIZE
BACKGROUND_COLOR = (30, 30, 47)  # dark background
ALIVE_COLOR = (76, 175, 80)      # green for live cells
DEAD_COLOR = (50, 50, 70)        # slightly lighter dark for dead cells

# Simulation speed (frames per second)
FPS = 10

# Rule set – default Conway's Game of Life (B3/S23)
RULES = (3, (2, 3))
