%%%%% Check if the game is over
checkGameover :-
    gameover(Winner),
    !,
    write('Game is Over. Winner: '),
    writeln(Winner),
    displayBoard,
    board(Board),
    retract(board(Board)). % The game is not over, we play the next turn

%%%%% Termination conditions
gameover(Winner) :-
    board(Board),
    length(Board, BoardLength),
    BoardDimension is round(sqrt(BoardLength)),
    aligned(Board, Board, Winner, 0, 5, BoardLength, BoardDimension),
    !.
gameover('Draw') :-
    board(Board),
    isBoardFull(Board).

%%%%% Dynamically check for alignments of player markers on the board
aligned(Board, [T|_], Player, A, C, BoardLength, BoardDimension) :-
    LastIndex is BoardLength-4*BoardDimension-1, %% 76=11*11-4*11-1
    A =< LastIndex, 
    nonvar(T),
    vertWinner(Board, A, Player, 0, C, BoardDimension).
aligned(Board, [T|_], Player, A, C, _, BoardDimension) :-
    RowLastIndex is BoardDimension-1-4, %%6=11-1-4
    A mod BoardDimension=<RowLastIndex, 
    nonvar(T),
    horiWinner(Board, A, Player, 0, C, BoardDimension).
aligned(Board, [T|_], Player, A, C, BoardLength, BoardDimension) :-
    LastIndex is BoardLength-4*BoardDimension-1,
    A=<LastIndex,
    A mod BoardDimension>=4, 
    nonvar(T),
    leftDiagWinner(Board, A, Player, 0, C, BoardDimension).
aligned(Board, [T|_], Player, A, C, BoardLength, BoardDimension) :-
    LastIndex is BoardLength-4*BoardDimension-1-4,
    A=<LastIndex, %%76-4
    RowLastIndex is BoardDimension-1-4,
    A mod BoardDimension=<RowLastIndex,
    nonvar(T),
    rightDiagWinner(Board, A, Player, 0, C, BoardDimension).
aligned(Board, [_|Q], Player, A, C, BoardLength, BoardDimension) :-
    NewA is A+1,
    aligned(Board, Q, Player, NewA, C, BoardLength, BoardDimension).

%%%%% Check vertical alignments
vertWinner(Board, X, E, A, Y, BoardDimension) :-
    checkWinner(Board, X, E, A, Y, BoardDimension).

%%%%% Check horizontal alignments
horiWinner(Board, X, E, A, Y, _) :-
    checkWinner(Board, X, E, A, Y, 1).

%%%%% Check left diagonal alignments (top right - bottom left)
leftDiagWinner(Board, X, E, A, Y, BoardDimension) :-
    BottomLeft is BoardDimension-1,
    checkWinner(Board, X, E, A, Y, BottomLeft).

%%%%% Check right diagonal alignments (top left - bottom right)
rightDiagWinner(Board, X, E, A, Y, BoardDimension) :-
    BottomRight is round(BoardDimension+1),
    checkWinner(Board, X, E, A, Y, BottomRight).

%%%%% Check for alignments, direction is chosen by the last argument
checkWinner(_, _, _, Y, Y, _).
checkWinner(Board, X, E, A, Y, Direction) :-
    not(nth0(X, Board, var)),
    integer(Direction),
    nth0(X, Board, E),
    NewA is A+1,
    NewX is X+Direction,
    checkWinner(Board, NewX, E, NewA, Y, Direction).

%%%% Human player
human(Board, Index, _) :-
    repeat,
    write('C: '),
    read(MoveC),
    write('R: '),
    read(MoveR),
    Index is MoveC+11*MoveR,
    nth0(Index, Board, Elem),
    var(Elem),
    !.

%%%% Artificial intelligence 1
%%%% This AI plays randomly and does not care who is playing: it chooses a free position in the Board (an element which is an free variable).
ia(Board, Index, _) :-
    repeat,
    length(Board, BoardLength),
    Index is random(BoardLength),
    isPosEmpty(Board, Index),
    !.