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
    minmax(Board, Player, AllMoves,  (nil, -1000), BestMove).

%%%%% Recursive MinMax algorithm to find the explore all possible moves and get the best move for the player
minmax(_, _, [],  (BestMove, _), BestMove).
minmax(Board, Player, [Move|Moves], CurrBest, BestMove) :-
	playMove(Move, Player, Board, NewBoard), 				% Plays a 'test' move
    evalBoard(NewBoard, Player, 0, BoardScore, 0),			% Evaluates the board after the move
	changePlayer(Player, Opponent),
	getPossibleMoves(NewBoard, [], OppMoves, 0),			% Repeats procedure for opponent
	maxmin(NewBoard, Opponent, OppMoves, (nil, -1000), OppBestScore, _),
    Difference is BoardScore - OppBestScore,
	compareMove(Move, Difference, CurrBest, UpdatedBest),	% Compares to the current best move
    minmax(Board, Player, Moves, UpdatedBest, BestMove),
    !.

maxmin(_, _, [],  (BestMove, BestScore),BestScore, BestMove).
maxmin(Board, Player, [Move|Moves], CurrBest, BestScore, BestMove) :-
	playMove(Move, Player, Board, NewBoard), 				% Plays a 'test' move
    evalBoard(NewBoard, Player, 0, BoardScore, 0),			% Evaluates the board after the move
	compareMove(Move, BoardScore, CurrBest, UpdatedBest),	% Compares to the current best move
    maxmin(Board, Player, Moves, UpdatedBest, BestScore, BestMove),
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
