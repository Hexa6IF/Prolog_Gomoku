%%%% Artificial intelligence 1
%%%% This AI plays randomly and does not care who is playing: it chooses a free position in the Board (an element which is a free variable).
ia1(Board, Index, _) :-
    repeat,
    length(Board, BoardLength),
    Index is random(BoardLength),
    isPosEmpty(Board, Index),
    !.
