%%%% Declare board as dynamic predicate
:- (dynamic board/1).

%%%% Load other files
:- [helpers]. %% Generic predicates
:- [ia2]. %% IA 2 - Tree traversal
:- [ia3]. %% IA 3 - MinMax
:- [display]. %% Display board
:- [game]. %% Game predicates

%%%% Gomoku

%%%%% Start the game
init :-
    length(Board, 121),
    assert(board(Board)),
    playHuman.

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
	playMove(Move, x, Board, NewBoard),
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
    playMove(Move, o, Board, NewBoard),
    applyIt(Board, NewBoard),
    playHuman. % next turn!
