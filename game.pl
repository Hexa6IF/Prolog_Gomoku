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