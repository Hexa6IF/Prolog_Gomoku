%%%% Declare board as dynamic predicate
:- (dynamic board/1).

%%%% Load other files
:- [helpers].

%%%%% Play a Move, the new Board will be the same, but one value will be instanciated with the Move
playMove(Board, Move, NewBoard, Player) :-
    Board=NewBoard,
    nth0(Move, NewBoard, Player).

%%%%% Remove old board save new on in the knowledge base
applyIt(Board, NewBoard) :-
    retract(board(Board)),
    assert(board(NewBoard)).

%%%% Gomoku

%%%%% Start the game
init :-
    length(Board, 121),
    assert(board(Board)),
    playHuman.

%%%%% Termination conditions
gameover(Winner) :-
    board(Board),
    aligned(Board, Board, Winner, 0, 5),
    !.
gameover('Draw') :-
    board(Board),
    isBoardFull(Board).

%%%%% Dynamically check for alignements of player markers on the board
aligned(Board, [T|_], Player, A, C) :-
    A=<76,
    nonvar(T),
    vertWinner(Board, A, Player, 0, C).
aligned(Board, [T|_], Player, A, C) :-
    A mod 11=<6,
    nonvar(T),
    horiWinner(Board, A, Player, 0, C).
aligned(Board, [T|_], Player, A, C) :-
    A=<76,
    A mod 11>=4,
    nonvar(T),
    leftDiagWinner(Board, A, Player, 0, C).
aligned(Board, [T|_], Player, A, C) :-
    A=<72,
    A mod 11=<6,
    nonvar(T),
    rightDiagWinner(Board, A, Player, 0, C).
aligned(Board, [_|Q], Player, A, C) :-
    NewA is A+1,
    aligned(Board, Q, Player, NewA, C).

%%%%% Check vertical alignements
vertWinner(_, _, _, Y, Y).
vertWinner(Board, X, E, A, Y) :-
    not(nth0(X, Board, var)),
    nth0(X, Board, E),
    NewA is A+1,
    NewX is X+11,
    vertWinner(Board, NewX, E, NewA, Y).

%%%%% Check horizontal alignements
horiWinner(_, _, _, Y, Y).
horiWinner(Board, X, E, A, Y) :-
    not(nth0(X, Board, var)),
    nth0(X, Board, E),
    NewA is A+1,
    NewX is X+1,
    horiWinner(Board, NewX, E, NewA, Y).

%%%%% Check left diagonal alignements (top right - bottom left)
leftDiagWinner(_, _, _, Y, Y).
leftDiagWinner(Board, X, E, A, Y) :-
    not(nth0(X, Board, var)),
    nth0(X, Board, E),
    NewA is A+1,
    NewX is X+10,
    leftDiagWinner(Board, NewX, E, NewA, Y).

%%%%% Check right diagonal alignements (top left - bottom right)
rightDiagWinner(_, _, _, Y, Y).
rightDiagWinner(Board, X, E, A, Y) :-
    not(nth0(X, Board, var)),
    nth0(X, Board, E),
    NewA is A+1,
    NewX is X+12,
    rightDiagWinner(Board, NewX, E, NewA, Y).

%%%% Recursive predicate for playing the game. % The game is over, we use a cut to stop the proof search, and display the winner board.
playHuman :-
    gameover(Winner),
    !,
    write('Game is Over. Winner: '),
    writeln(Winner),
    displayBoard,
    board(Board),
    retract(board(Board)). % The game is not over, we play the next turn
playHuman :-
    write('New turn for:'),
    writeln('HOOMAN'),
    board(Board), % instanciate the board from the knowledge base
    displayBoard, % print it
    human(Board, Move, x),
    playMove(Board, Move, NewBoard, x),
    applyIt(Board, NewBoard),
    playAI. % next turn!
playAI :-
    gameover(Winner),
    !,
    write('Game is Over. Winner: '),
    writeln(Winner),
    displayBoard,
    board(Board),
    retract(board(Board)). % The game is not over, we play the next turn
playAI :-
    write('New turn for:'),
    writeln('AI'),
    board(Board), % instanciate the board from the knowledge base
    displayBoard, % print it
    ia3(Board, Move, o),
    playMove(Board, Move, NewBoard, o),
    applyIt(Board, NewBoard),
    playHuman. % next turn!

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
    Index is random(121),
    isPosEmpty(Board, Index),
    !.

%%%% Artificial intelligence 3 - Heuristic MinMax
%%%% This AI picks the best possible move for a given state that increases as much as possible its chances of winning whilst reducing the chances of its opponent winning
ia3(Board, Index, Player) :-
    findBestMove(Board, Player, Index).

%%%% Heuristic MinMax - Based on MinMax theory at 2 level depth

%%%%% Get a list of all possible moves in a given state of the board
getPossibleMoves(_, Moves, AllMoves, 121) :-
    AllMoves=Moves.
getPossibleMoves(Board, Moves, AllMoves, Acc) :-
    NewAcc is Acc+1,
    isPosEmpty(Board, Acc),
    getPossibleMoves(Board, [Acc|Moves], AllMoves, NewAcc),
    !.
getPossibleMoves(Board, Moves, AllMoves, Acc) :-
    NewAcc is Acc+1,
    getPossibleMoves(Board, Moves, AllMoves, NewAcc),
    !.

%%%%% Get the best move for the given player for a given state of the board
findBestMove(Board, Player, BestMove) :-
    getPossibleMoves(Board, [], AllMoves, 0),
    minmax(Player, AllMoves,  (nil, -1000), BestMove).

%%%%% Recursive MinMax algorithm to find the explore all possible moves and get the best move for the player
minmax(_, [],  (BestMove, _), BestMove).
minmax(Player, [Move|Moves], CurrBest, BestMove) :-
	board(Board),
	nth0(Move, Board, Player),
    evalBoard(Board, Player, 0, BoardScore, 0),
	compareMove(Move, BoardScore, CurrBest, UpdatedBest),
	nth0(Move, Board, _),
	nth0(Move, Board, Player),
    minmax(Player, Moves, UpdatedBest, BestMove),
    !.

%%%%% Compare a given move to the current best move and swap if necessary
compareMove(CurrMove, CurrScore,  (_, BestScore),  (CurrMove, CurrScore)) :-
    CurrScore>=BestScore.
compareMove(_, CurrScore,  (BestMove, BestScore),  (BestMove, BestScore)) :-
    CurrScore<BestScore.

%%%%% Attribute a score to each consecutive sets of player marker alignements
getScore(1, 0, 100) :-
    !.
getScore(2, 0, 1000) :-
    !.
getScore(3, 0, 10000) :-
    !.
getScore(4, 0, 100000) :-
    !.
getScore(5, 0, 1000000) :-
    !.
getScore(_, _, 0) :-
    !.

%%%%% Increment the count of player/oppent markers in a row
incrementCount(Player, Elem, PlyCount, OppCount, NewPlyCount, NewOppCount) :-
    Elem==Player,
    NewPlyCount is PlyCount+1,
    NewOppCount is OppCount.
incrementCount(_, _, PlyCount, OppCount, NewPlyCount, NewOppCount) :-
    NewPlyCount is PlyCount,
    NewOppCount is OppCount+1.

%%%%% Recursively calculate the total value of a given state of the board to the player
evalBoard(_, _, Score, Score, 121).
evalBoard(Board, Player, AccScore, BoardScore, Acc) :-
    evalHori(Board, Player, HScore, Acc, 0, 0, 0),
    evalVert(Board, Player, VScore, Acc, 0, 0, 0),
    evalLeftDiag(Board, Player, LDScore, Acc, 0, 0, 0),
    evalRightDiag(Board, Player, RDScore, Acc, 0, 0, 0),
    NewAccScore is AccScore+HScore+VScore+LDScore+RDScore,
    NewAcc is Acc+1,
    evalBoard(Board, Player, NewAccScore, BoardScore, NewAcc),
    !.

%%%%% Recursively calculate the total value of a given state of the board to the player - horizontal alignements
evalHori(_, _, HScore, _, 5, PlyCount, OppCount) :-
    getScore(PlyCount, OppCount, HScore),
    !.
evalHori(Board, Player, HScore, Index, Acc, PlyCount, OppCount) :-
    Acc=<5,
    Index mod 11=<6,
    not(isPosEmpty(Board, Index)),
    nth0(Index, Board, Elem),
    NewAcc is Acc+1,
    NewIndex is Index+1,
    incrementCount(Player,
                   Elem,
                   PlyCount,
                   OppCount,
                   NewPlyCount,
                   NewOppCount),
    evalHori(Board,
             Player,
             HScore,
             NewIndex,
             NewAcc,
             NewPlyCount,
             NewOppCount).
evalHori(Board, Player, VScore, Index, Acc, PlyCount, OppCount) :-
    Acc=<5,
    NewIndex is Index+1,
    NewAcc is Acc+1,
    evalHori(Board,
             Player,
             VScore,
             NewIndex,
             NewAcc,
             PlyCount,
             OppCount).

%%%%% Recursively calculate the total value of a given state of the board to the player - verical alignements
evalVert(_, _, VScore, _, 5, PlyCount, OppCount) :-
    getScore(PlyCount, OppCount, VScore),
    !.
evalVert(Board, Player, VScore, Index, Acc, PlyCount, OppCount) :-
    Acc=<5,
    Index=<76,
    not(isPosEmpty(Board, Index)),
    nth0(Index, Board, Elem),
    NewAcc is Acc+1,
    NewIndex is Index+11,
    incrementCount(Player,
                   Elem,
                   PlyCount,
                   OppCount,
                   NewPlyCount,
                   NewOppCount),
    evalVert(Board,
             Player,
             VScore,
             NewIndex,
             NewAcc,
             NewPlyCount,
             NewOppCount).
evalVert(Board, Player, VScore, Index, Acc, PlyCount, OppCount) :-
    Acc=<5,
    NewIndex is Index+11,
    NewAcc is Acc+1,
    evalVert(Board,
             Player,
             VScore,
             NewIndex,
             NewAcc,
             PlyCount,
             OppCount).

%%%%% Recursively calculate the total value of a given state of the board to the player - left-diagonal alignements
evalLeftDiag(_, _, LDScore, _, 5, PlyCount, OppCount) :-
    getScore(PlyCount, OppCount, LDScore),
    !.
evalLeftDiag(Board, Player, LDScore, Index, Acc, PlyCount, OppCount) :-
    Index=<76,
    Index mod 11>=4,
    not(isPosEmpty(Board, Index)),
    nth0(Index, Board, Elem),
    NewAcc is Acc+1,
    NewIndex is Index+10,
    incrementCount(Player,
                   Elem,
                   PlyCount,
                   OppCount,
                   NewPlyCount,
                   NewOppCount),
    evalLeftDiag(Board,
                 Player,
                 LDScore,
                 NewIndex,
                 NewAcc,
                 NewPlyCount,
                 NewOppCount).
evalLeftDiag(Board, Player, LDScore, Index, Acc, PlyCount, OppCount) :-
    Acc=<5,
    NewIndex is Index+10,
    NewAcc is Acc+1,
    evalLeftDiag(Board,
                 Player,
                 LDScore,
                 NewIndex,
                 NewAcc,
                 PlyCount,
                 OppCount).

%%%%% Recursively calculate the total value of a given state of the board to the player - right-diagonal alignements
evalRightDiag(_, _, RDScore, _, 5, PlyCount, OppCount) :-
    getScore(PlyCount, OppCount, RDScore),
    !.
evalRightDiag(Board, Player, RDScore, Index, Acc, PlyCount, OppCount) :-
    Index=<76,
    Index mod 11=<6,
    not(isPosEmpty(Board, Index)),
    nth0(Index, Board, Elem),
    NewAcc is Acc+1,
    NewIndex is Index+12,
    incrementCount(Player,
                   Elem,
                   PlyCount,
                   OppCount,
                   NewPlyCount,
                   NewOppCount),
    evalRightDiag(Board,
                  Player,
                  RDScore,
                  NewIndex,
                  NewAcc,
                  NewPlyCount,
                  NewOppCount).
evalRightDiag(Board, Player, RDScore, Index, Acc, PlyCount, OppCount) :-
    Acc=<5,
    NewIndex is Index+12,
    NewAcc is Acc+1,
    evalRightDiag(Board,
                  Player,
                  RDScore,
                  NewIndex,
                  NewAcc,
                  PlyCount,
                  OppCount).



%%%% Displaying the board

%%%%% Print a row
printRow(Row) :-
    nonvar(Row),
    Val0 is Row*11+0,
    printVal(Val0),
    Val1 is Row*11+1,
    printVal(Val1),
    Val2 is Row*11+2,
    printVal(Val2),
    Val3 is Row*11+3,
    printVal(Val3),
    Val4 is Row*11+4,
    printVal(Val4),
    Val5 is Row*11+5,
    printVal(Val5),
    Val6 is Row*11+6,
    printVal(Val6),
    Val7 is Row*11+7,
    printVal(Val7),
    Val8 is Row*11+8,
    printVal(Val8),
    Val9 is Row*11+9,
    printVal(Val9),
    Val10 is Row*11+10,
    printVal(Val10).

%%%%% Print a value of the board at index N
printVal(N) :-
    board(B),
    nth0(N, B, Val),
    var(Val),
    write('_ '),
    !.
printVal(N) :-
    board(B),
    nth0(N, B, Val),
    write(Val),
    write(' ').

%%%%% Display the board
displayBoard :-
    writeln('  C 0 1 2 3 4 5 6 7 8 9 10'),
    writeln(' R *----------------------*'),
    write(' 0 |'),
    printRow(0),
    writeln('|'),
    write(' 1 |'),
    printRow(1),
    writeln('|'),
    write(' 2 |'),
    printRow(2),
    writeln('|'),
    write(' 3 |'),
    printRow(3),
    writeln('|'),
    write(' 4 |'),
    printRow(4),
    writeln('|'),
    write(' 5 |'),
    printRow(5),
    writeln('|'),
    write(' 6 |'),
    printRow(6),
    writeln('|'),
    write(' 7 |'),
    printRow(7),
    writeln('|'),
    write(' 8 |'),
    printRow(8),
    writeln('|'),
    write(' 9 |'),
    printRow(9),
    writeln('|'),
    write('10 |'),
    printRow(10),
    writeln('|'),
    writeln('   *----------------------*').

















