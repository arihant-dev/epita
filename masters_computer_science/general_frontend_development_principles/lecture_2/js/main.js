let score_o = 0;
let score_x = 0;

const cellElements = document.querySelectorAll('[data-cell]');
const board = document.getElementById('board');
const winningMessage = document.getElementById('msg');
const restartButton = document.getElementById('restart-btn');


const winningCombinations = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6]
];

const firstPlayerScore = document.getElementById('score_1');
const secondPlayerScore = document.getElementById('score_2');


startGame();

function startGame() {
    cellElements.forEach(cell => {
        cell.classList.remove('x', 'o');
    })
    restartButton.classList.add('hide');

    board.addEventListener('click', handleClick, { once: true });
    winningMessage.textContent = '';

    // updateScores();
    firstPlayerScore.textContent = `Player 1 (X): ${score_x}`;
    secondPlayerScore.textContent = `Player 2 (O): ${score_o}`;
}

function handleClick(e) {
    const cell = e.target;
    const currentPlayer = getCurrentPlayer();

    if (cell.classList.contains('x') || cell.classList.contains('o')) {
        return; // Cell already occupied
    }

    cell.classList.add(currentPlayer);

    if (checkWin(currentPlayer)) {
        winningMessage.textContent = `${currentPlayer.toUpperCase()} wins!`;
        updateScores(currentPlayer.toUpperCase());
        restartButton.classList.remove('hide');
        board.removeEventListener('click', handleClick);
    } else if (isDraw()) {
        winningMessage.textContent = "It's a draw!";
        restartButton.classList.remove('hide');
        board.removeEventListener('click', handleClick);
    } else {
        // Continue game
        board.addEventListener('click', handleClick, { once: true });
    }
}

function getCurrentPlayer() {
    const xCount = document.querySelectorAll('.x').length;
    const oCount = document.querySelectorAll('.o').length;
    return xCount <= oCount ? 'x' : 'o';
}

function checkWin(player) {
    return winningCombinations.some(combination => {
        return combination.every(index => {
            return cellElements[index].classList.contains(player);
        });
    });
}

function isDraw() {
    return [...cellElements].every(cell => {
        return cell.classList.contains('x') || cell.classList.contains('o');
    });
}

function updateScores(player) {
    if (player === 'X') {
        score_x++;
    } else {
        score_o++;
    }
    firstPlayerScore.textContent = `Player 1 (X): ${score_x}`;
    secondPlayerScore.textContent = `Player 2 (O): ${score_o}`;
}

restartButton.addEventListener('click', startGame);