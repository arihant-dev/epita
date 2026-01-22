import pygame
from constants import *
from game_of_life import GameOfLife
from ui import draw_grid

def main() -> None:
    pygame.init()
    screen = pygame.display.set_mode((WINDOW_WIDTH, WINDOW_HEIGHT))
    pygame.display.set_caption("Game of Life")

    clock = pygame.time.Clock()
    sim = GameOfLife(ROWS, COLS)
    running = 1
    playing = 0

    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = 0
            
            elif event.type == pygame.MOUSEBUTTONDOWN:
                mx, my = event.pos
                col = mx // CELL_SIZE
                row = my // CELL_SIZE
                sim.toggle_cell(row, col)
            
            elif event.type == pygame.KEYDOWN:
                if event.key == pygame.K_SPACE:
                    playing = playing ^ 1
                elif event.key == pygame.K_r:
                    sim.reset()
                elif event.key == pygame.K_UP:
                    constants.FPS = min(constants.FPS+1, 60)
                elif event.key == pygame.K_DOWN:
                    constants.FPS = max(constants.FPS-1, 1)
        if playing:
            sim.step()
        screen.fill(BACKGROUND_COLOR)
        draw_grid(screen, sim.grid)
        pygame.display.flip()
        clock.tick(FPS)
    pygame.quit()

if __name__ == "__main__":
    main()