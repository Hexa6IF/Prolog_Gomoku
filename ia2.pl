%%%% Artificial intelligence 2 - Tree Traversal
%%%% This AI always travels the tree of possible moves and picks the move that allows it to align the most player markers in a row
ia2(Board, Index, Player) :-
    parcours(Board, Index, Player).
ia2(Board, Index, _) :-
    ia1(Board, Index, _).

%%%%% Recursively traverse the tree of possible moves and pick the move that aligns the most in a row
parcours(Board, Index, Player) :-
    CurrentFloor=Board,
    parcours([CurrentFloor], 0, Index, Player, 5).
parcours([CurrentFloor|_], X, Index, Player, Size) :-
    nth0(X, CurrentFloor, Elem),
    var(Elem),
    nth0(X, CurrentFloor, Player),
    length(CurrentFloor, BoardLength),
    BoardDimension is round(sqrt(BoardLength)),
    aligned(CurrentFloor, CurrentFloor, Player, 0, Size, BoardLength, BoardDimension),
    Index is X,
    !.
parcours([CurrentFloor|Q], X, Index, Player, Size) :-
    length(CurrentFloor, Length),
    NewX is X+1,
    NewX<Length,
    parcours([CurrentFloor|Q], NewX, Index, Player, Size).
parcours([CurrentFloor|Q], 120, Index, Player, Size) :-
    Size>2,
    NewSize is Size-1,
    !,
    parcours([CurrentFloor|Q], 0, Index, Player, NewSize).
