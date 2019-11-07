%%%% Artificial intelligence 3 - Heuristic MinMax
%%%% This AI picks the best possible move for a given state that increases as much as possible its chances of winning whilst reducing the chances of its opponent winning
ia3(Board, Index, Player) :-
    findBestMove(Board, Player, Index).

%%%% MinMax - Based on MinMax theory at 2 level depth

%%%%% Get a list of all possible moves in a given state of the board
%getPossibleMoves(Board, Moves, AllMoves, BoardLength) :-
getPossibleMoves(Board, AllMoves, AllMoves, BoardLength) :-
    length(Board, BoardLength).
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

%%%% Alpha Beta Pruning
findBestMove(Board, Player, BestMove) :-
    alphabeta(Player, Board, 2, -inf, inf, BestMove, _).

evaluateAndChoose(_, _, _, Alpha, _, [], BestMove,  (BestMove, Alpha)).
evaluateAndChoose(Player, Board, Depth, Alpha, Beta, [Move|Moves], CurrBest, BestMove) :-
    playMove(Move, Player, Board, NewBoard),
    changePlayer(Player, NextPlayer),
    alphabeta(NextPlayer,
              NewBoard,
              Depth,
              Alpha,
              Beta,
              _,
              BestValue),
    NewValue is -BestValue,
    cutOff(Move,
           NewValue,
           Player,
           Board,
           Depth,
           Alpha,
           Beta,
           Moves,
           CurrBest,
           BestMove).

alphabeta(Player, Board, 0, _, _, _, Value) :-
	%% recover heuristic selection and call correct heuristic
    heuristic(Heuristic),
    alphabetaHeuristic(Player, Board, Value, Heuristic).
alphabeta(Player, Board, Depth, Alpha, Beta, Move, Value) :-
    getPossibleMoves(Board, [], AllMoves, 0),
    NewAlpha is -Beta,
    NewBeta is -Alpha,
    NewDepth is Depth-1,
    evaluateAndChoose(Player,
                      Board,
                      NewDepth,
                      NewAlpha,
                      NewBeta,
                      AllMoves,
                      nil,
                      (Move, Value)).

alphabetaHeuristic(Player, Board, Value, 1) :-
    evalBoard1(Board, Player, Value).
alphabetaHeuristic(Player, Board, Value, 2) :-
    evalBoard2(Board, Player, Value).

cutOff(BestMove, BestValue, _, _, _, _, Beta, _, _,  (BestMove, BestValue)) :-
    BestValue>=Beta,
    !.
cutOff(Move, Value, Player, Board, Depth, Alpha, Beta, Moves, _, BestMove) :-
    Alpha<Value,
    Value<Beta,
    !,
    evaluateAndChoose(Player,
                      Board,
                      Depth,
                      Value,
                      Beta,
                      Moves,
                      Move,
                      BestMove).
cutOff(_, Value, Player, Board, Depth, Alpha, Beta, Moves, CurrBest, BestMove) :-
    Value=<Alpha,
    !,
    evaluateAndChoose(Player,
                      Board,
                      Depth,
                      Alpha,
                      Beta,
                      Moves,
                      CurrBest,
                      BestMove).

%%%% Minimax refactored
findBestMove2(Board, Player, BestMove) :-
    getPossibleMoves(Board, [], AllMoves, 0),
    evaluateAndChoose(Player,
                      Board,
                      1,
                      1,
                      AllMoves,
                      (nil, -inf),
                      (BestMove, _)).

evaluateAndChoose(_, _, _, _, [], BestMove, BestMove).
evaluateAndChoose(Player, Board, Depth, Flag, [Move|Moves], Record, BestMove) :-
    playMove(Move, Player, Board, NewBoard),
    minimax(Player, NewBoard, Depth, Flag, _, BestValue),
    compareMove(Move, BestValue, Record, NewRecord),
    evaluateAndChoose(Player,
                      Board,
                      Depth,
                      Flag,
                      Moves,
                      NewRecord,
                      BestMove).

minimax(Player, Board, 0, Flag, _, Value) :-
    evalBoard2(Board, Player, BoardScore),
    Value is BoardScore*Flag.
minimax(Player, Board, Depth, Flag, Move, Value) :-
    Depth>0,
    changePlayer(Player, NextPlayer),
    getPossibleMoves(Board, [], AllMoves, 0),
    NewDepth is Depth-1,
    NewFlag is -Flag,
    evaluateAndChoose(NextPlayer,
                      Board,
                      NewDepth,
                      NewFlag,
                      AllMoves,
                      (nil, -inf),
                      (Move, Value)).

%%%%% Compare a given move to the current best move and swap if necessary
compareMove(CurrMove, CurrScore,  (_, BestScore),  (CurrMove, CurrScore)) :-
    CurrScore>=BestScore.
compareMove(_, CurrScore,  (BestMove, BestScore),  (BestMove, BestScore)) :-
    CurrScore<BestScore.