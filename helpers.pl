%%%% Helper predicates
%%%%% Recursive predicate that makes a copy of specified list but changes one element
partialCopy(_, _, [], []).
partialCopy(RvIndex, Elem, [_|T1], [Elem|T2]) :-
	length(T1, RvIndex),
	partialCopy(RvIndex, Elem, T1, T2),
	!.
partialCopy(RvIndex, Elem, [H|T1], [H|T2]) :-
    partialCopy(RvIndex, Elem, T1, T2).
%%%%% Checks if a given position in the list has not been instanciated
isPosEmpty(Board, Index) :-
    nth0(Index, Board, Elem),
    var(Elem).

%%%%% Recursive predicate that checks if all the elements of the board are instanciated
isBoardFull([]).
isBoardFull([H|T]) :-
    nonvar(H),
    isBoardFull(T).

%%%%% Play a Move, the new Board will be the same, but one value will be instanciated with the Move
playMove(Move, Player, Board, NewBoard) :-
	length(Board, BoardSize),
	ReverseIndex is BoardSize - 1 - Move,
	partialCopy(ReverseIndex, Player, Board, NewBoard).

%%%%% Remove old board save new on in the knowledge base
applyIt(Board, NewBoard) :-
    retract(board(Board)),
    assert(board(NewBoard)).
