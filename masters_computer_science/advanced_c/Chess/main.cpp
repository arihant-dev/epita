#include <iostream>
#include "game.h"
#include "board.h"

/**
 * Main program for playing a chess game.
 */
int main (int argc, char * const argv[])
{
    Player* currentPlayer = NULL;
    bool gameOver = false;

    // initialize a chess game and display the initial state
    Game::initialize();
    Board::getBoard()->display(cout);

    // game loop in which players alternate making moves
    while(!gameOver)
    {
        currentPlayer = Game::getNextPlayer();

        // display move number and current player
        if(currentPlayer->isWhite())
        {
            Game::incrementMoveCount();
        }
        cout << "--- Move " << Game::getMoveCount() << " - " << currentPlayer->getName() << "'s turn ---" << endl;

        while(!currentPlayer->makeMove())
        {
            cerr << "Invalid move... Try again." << endl;
        }
        Board::getBoard()->display(cout);

        // display captured pieces and scores
        Player* opponent = Game::opponentOf(*currentPlayer);
        cout << currentPlayer->getName() << " captured: " << opponent->capturedPiecesString()
             << " (Score: " << opponent->score() << ")" << endl;

        // check for checkmate or stalemate
        gameOver = Game::isGameOver(currentPlayer);
    }

    // clean up allocated memory
    Game::cleanup();

    return 0;
}
