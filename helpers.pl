%%%% Helper predicates
%%%%% Make true copy of a list
copy(OriList, CopyList) :-
    accCopy(OriList, CopyList).
accCopy([], []).
accCopy([H|T1], [H|T2]) :-
    accCopy(T1, T2).

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
playMove(Board, Move, NewBoard, Player) :-
    Board=NewBoard,
    nth0(Move, NewBoard, Player).

%%%%% Remove old board save new on in the knowledge base
applyIt(Board, NewBoard) :-
    retract(board(Board)),
    assert(board(NewBoard)).