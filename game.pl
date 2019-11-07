%%%%% Check if the game is over
checkGameover :-
    gameover(Winner),
    !,
    write('Game is Over. Winner: '),
    writeln(Winner),
    displayBoard,
    board(Board),
    retract(board(Board)). % The game is over, dynamic board is retracted to allow another game.

%%%%% Termination conditions
gameover(Winner) :-
    board(Board),
    aligned(Board, Winner, 5, Count, 0),
	Count > 0,
    !.
gameover('Draw') :-
    board(Board),
    isBoardFull(Board).

%%%% Human player
human(Board, Index, _) :-
    repeat,
    write('C: '),
    read(MoveC),
    write('R: '),
    read(MoveR),
    length(Board, BoardLength),
    BoardDimension is round(sqrt(BoardLength)),
    Index is MoveC+BoardDimension*MoveR,
    isPosEmpty(Board, Index),
	!.
