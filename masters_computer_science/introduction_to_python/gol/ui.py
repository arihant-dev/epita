import pygame
from constants import CELL_SIZE, ALIVE_COLOR, DEAD_COLOR

def draw_grid(screen: pygame.Surface, grid, cell_size: int = CELL_SIZE) -> None:
    if not grid:
        return
    rows = len(grid)
    cols = len(grid[0])

    for r in range(rows):
        for c in range(cols):
            rect = pygame.Rect(c*cell_size, r*cell_size, cell_size, cell_size)
            if grid[r][c]:
                pygame.draw.rect(screen, ALIVE_COLOR, rect)
            else:
                pygame.draw.rect(screen, DEAD_COLOR, rect, 1)