from constants import RULES
from typing import List, Tuple

class GameOfLife:
    def __init__(self, rows: int, cols:int, rules: Tuple[int, Tuple[int, ...]] = RULES):
        self.rows = rows
        self.cols = cols
        self.rules = rules
        self.grid: List[List[int]] = [[0] * cols for _ in range(rows)]
    
    def toggle_cell(self, row: int, col: int):
        self.grid[row][col] = self.grid[row][col] ^ 1
        
    def _live_neighbors(self, row: int, col: int) -> int:
        offsets = [(-1, -1), (-1, 0), (-1, 1),
                   (0, -1),          (0, 1),
                   (1, -1),  (1, 0), (1, 1)]
        
        count = 0
        
        for dr, dc in offsets:
            nr, nc = row + dr, col + dc
            if 0 <= nr < self.rows and 0 <= nc < self.cols:
                count += self.grid[nr][nc]
        return count
    
    def step(self) -> None:
        birth, survival = self.rules
        new_grid = [[0] * self.cols for _ in range(self.rows)]
        
        for r in range(self.rows):
            for c in range(self.cols):
                live_neighbours = self._live_neighbors(r, c)
                if self.grid[r][c]:
                    new_grid[r][c] = live_neighbours in survival
                else:
                    new_grid[r][c] = live_neighbours == birth
        
        self.grid = new_grid

    def reset(self) -> None:
        self.grid = [[0] * self.cols for _ in range(self.rows)]