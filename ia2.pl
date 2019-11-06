%%%% Artificial intelligence 2 - Tree Traversal
%%%% This AI always travels the tree of possible moves and picks the move that allows it to align the most player markers in a row
ia2(Board, Move, Player) :-
    parcours(Board, Move, Player),
	!.
ia2(Board, Move, Player) :-
    ia1(Board, Move, Player).

%%%%% Recursively traverse the tree of possible moves and pick the move that aligns the most in a row
parcours(Board, Move, Player) :-
    length(Board, BoardLength),
	LastIndex is BoardLength - 1,
	aligned(Board, Player, 2, Twos),
	aligned(Board, Player, 3, Threes),
	aligned(Board, Player, 4, Fours),
	aligned(Board, Player, 5, Fives),
    parcours(Board, 0, Move, Player, LastIndex, [Fives, Fours, Threes, Twos]),
	!.

parcours(Board, Index, Move, Player, _, [H|T]) :-
    isPosEmpty(Board, Index),
	playMove(Index, Player, Board, NewBoard),
	length([H|T], TailLength),
	Size is TailLength + 1,
	aligned(NewBoard, Player, Size, Count),
	Count > H,
	Move = Index,
	!.
parcours(Board, Index, Move, Player, LastIndex, Counts) :-
    NewIndex is Index+1,
    NewIndex =< LastIndex,
    parcours(Board, NewIndex, Move, Player, LastIndex, Counts).
parcours(Board, LastIndex, Move, Player, LastIndex, [_|T]) :-
    parcours(Board, 0, Move, Player, LastIndex, T).
