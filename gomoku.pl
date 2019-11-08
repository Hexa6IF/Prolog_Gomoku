%%%% Declare board as dynamic predicate
:- (dynamic board/1).

%%%% Declare Heuristic choice as dynamic
:- (dynamic heuristic/1).

%%%% Load other files
:- [helpers]. %% Generic predicates
:- [ia1]. %% IA 1 - Random
:- [ia2]. %% IA 2 - Tree traversal
:- [ia3]. %% IA 3 - MiniMax / Alpha-Beta
:- [evalBoard1]. %% Heuristic 1 for IA3
:- [evalBoard2]. %% Heuristic 2 for IA3
:- [display]. %% Display board
:- [game]. %% Game predicates

%%%% Gomoku

%%%%% Start the game
init :-
    writeln('Board size?'),
    read(BoardSize),
    BoardLength is BoardSize*BoardSize,
    length(Board, BoardLength),
    assert(board(Board)),
    writeln('< o > or < x > for human?'),
    read(HumanMark),
    writeln('Which AI to play with?'),
    writeln('1 - Random'),
    writeln('2 - Tree traversal'),
    writeln('3 - Alpha-Beta with H1'),
    writeln('4 - Alpha-Beta with H2'),
	read(AISel),
	setHeuristic(AISel),
    play(x, HumanMark, AISel).

%%%% Set dynamic heuristic selector
setHeuristic(3) :-
    assert(heuristic(1)).
setHeuristic(4) :-
    assert(heuristic(2)).
setHeuristic(_).

%%%% Recursive predicate for playing the game. % The game is over, we use a cut to stop the proof search, and display the winner board.
play(_, _, _) :-
    checkGameover.
play(Player, Player, AISel) :-
    writeln('New turn for: HOOMAN'),
    board(Board),
    displayBoard,
    human(Board, Move, Player),
    playMove(Move, Player, Board, NewBoard),
    applyIt(Board, NewBoard),
    changePlayer(Player, NextPlayer),
    play(NextPlayer, Player, AISel).
play(Player, HumanMark, AISel) :-
    Player\==HumanMark,
    writeln('New turn for: AI'),
    board(Board),
    displayBoard,
    ia(Board, Move, Player, AISel),
    playMove(Move, Player, Board, NewBoard),
    applyIt(Board, NewBoard),
    changePlayer(Player, NextPlayer),
    play(NextPlayer, HumanMark, AISel).

%%%% Predicate to allow easy switching between AIs.
ia(Board, Move, Player, 1) :-
    ia1(Board, Move, Player).
ia(Board, Move, Player, 2) :-
    ia2(Board, Move, Player).
ia(Board, Move, Player, _) :-
    ia3(Board, Move, Player).