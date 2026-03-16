/*
 *  king.cpp
 *  ChessProject
 */
#include "king.h"
#include "player.h"
#include "rook.h"
#include "game.h"

King::King(bool isWhite) : RestrictedPiece(isWhite)
{
}

King::~King()
{
}

int King::value() const
{
    return 0;
}

bool King::canMoveTo(Square& location) const
{
    bool validMove = false;
    int translationX = location.getX() - this->location()->getX();
    int translationY = location.getY() - this->location()->getY();

    // valid move if moving 1 square forward/backwards
    if(abs(translationY) == 1 && translationX == 0)
    {
        validMove = true;
    }

    // valid move if moving 1 square sideways
    else if(abs(translationX) == 1 && translationY == 0)
    {
        validMove = true;
    }

    // valid move if moving 1 square diagonally
    else if(abs(translationX) == 1 && abs(translationY) == 1)
    {
        validMove = true;
    }

    // valid geometry for castling: 2 squares horizontally, no vertical movement
    else if(abs(translationX) == 2 && translationY == 0)
    {
        validMove = true;
    }

    return validMove;
}

bool King::moveTo(Player& byPlayer, Square& toSquare)
{
    int translationX = toSquare.getX() - this->location()->getX();
    int translationY = toSquare.getY() - this->location()->getY();

    // if this is a castling attempt (2-square horizontal move)
    if(abs(translationX) == 2 && translationY == 0)
    {
        // castling conditions:
        // 1. king must not have moved
        if(hasMoved())
        {
            return false;
        }

        // 2. king must not be in check
        if(byPlayer.inCheck())
        {
            return false;
        }

        // determine which rook to castle with
        int rookX;
        int rookDestX;
        int direction;

        if(translationX > 0)
        {
            // kingside castling
            rookX = 7;
            rookDestX = 5;
            direction = 1;
        }
        else
        {
            // queenside castling
            rookX = 0;
            rookDestX = 3;
            direction = -1;
        }

        int kingY = this->location()->getY();
        Square* rookSquare = Board::getBoard()->squareAt(rookX, kingY);

        // 3. rook must be present and be a rook of the same color
        if(!rookSquare->occupied())
        {
            return false;
        }

        Piece* rookPiece = rookSquare->occupiedBy();
        if(rookPiece->isWhite() != _isWhite)
        {
            return false;
        }

        // check if rook is actually a RestrictedPiece that hasn't moved
        RestrictedPiece* rook = dynamic_cast<RestrictedPiece*>(rookPiece);
        if(!rook || rook->hasMoved())
        {
            return false;
        }

        // 4. path between king and rook must be clear
        if(!Board::getBoard()->isClearHorizontal(*(this->location()), *rookSquare))
        {
            return false;
        }

        // 5. king must not pass through a square under attack
        // check the intermediate square (1 square in the castling direction)
        Square* intermediateSquare = Board::getBoard()->squareAt(
            this->location()->getX() + direction, kingY);

        // tentatively move king to intermediate square to check for attacks
        Square* originalKingSquare = this->location();
        originalKingSquare->setOccupier(NULL);
        setLocation(intermediateSquare);
        intermediateSquare->setOccupier(this);

        bool passesThroughCheck = byPlayer.inCheck();

        // undo tentative move
        intermediateSquare->setOccupier(NULL);
        setLocation(originalKingSquare);
        originalKingSquare->setOccupier(this);

        if(passesThroughCheck)
        {
            return false;
        }

        // 6. king must not end up in check
        // tentatively move king to destination
        originalKingSquare->setOccupier(NULL);
        setLocation(&toSquare);
        toSquare.setOccupier(this);

        bool endsInCheck = byPlayer.inCheck();

        // undo tentative move
        toSquare.setOccupier(NULL);
        setLocation(originalKingSquare);
        originalKingSquare->setOccupier(this);

        if(endsInCheck)
        {
            return false;
        }

        // all castling conditions met -- execute the castling move

        // move the king
        originalKingSquare->setOccupier(NULL);
        setLocation(&toSquare);
        toSquare.setOccupier(this);

        // move the rook
        Square* rookDest = Board::getBoard()->squareAt(rookDestX, kingY);
        rookSquare->setOccupier(NULL);
        rookPiece->setLocation(rookDest);
        rookDest->setOccupier(rookPiece);

        return true;
    }

    // normal king move (1 square) -- delegate to RestrictedPiece::moveTo
    return RestrictedPiece::moveTo(byPlayer, toSquare);
}

void King::display() const
{
    cout << _color + "K";
}

char King::symbol() const
{
    return 'K';
}
