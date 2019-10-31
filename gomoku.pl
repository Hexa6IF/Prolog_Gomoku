
% The game state will be represented by a list of 9 elements
% board(_,_,_,_,_,_,_,_,_) at the beginning
% eg board(_,_,'x',_,_,_,_,_,_) after the first round
% eg board(_,_,'x',_,_,_,'o',_,_) after the second round
% ...
% until someone wins or the board is fully instanciated

:- dynamic board/1.

%%%% Test is the game is finished %%%
gameover(Winner) :- board(Board), aligned(Board, Board, Winner, 0, 5), !.  % There exists a winning configuration: We cut!
gameover('Draw') :- board(Board), isBoardFull(Board). % the Board is fully instanciated (no free variable): Draw.

%%%% Test if a Board is a winning configuration for the player P.

aligned(Board, [T|_], Player, A, C) :- div(A,11)=<6, nonvar(T),vertWinner(Board, A, Player, 0, C).
aligned(Board, [T|_], Player, A, C) :- mod(A, 11)=<6, nonvar(T),horiWinner(Board, A, Player, 0, C).
aligned(Board, [T|_], Player, A, C) :- div(A,11)=<6, mod(A, 11)>=4, nonvar(T),leftDiagWinner(Board, A, Player, 0, C).
aligned(Board, [T|_], Player, A, C) :- div(A,11)=<6, mod(A, 11)=<6, nonvar(T),rightDiagWinner(Board, A, Player, 0, C).
aligned(Board, [_|Q], Player, A, C) :- NewA is A+1, aligned(Board, Q, Player, NewA, C).

vertWinner(_ , _ , _, Y, Y).
vertWinner(Board, X, Winner, A, Y) :- not(nth0(X, Board, 'var')),nth0(X, Board, Winner),  NewA is A+1, NewX is X+11, vertWinner(Board, NewX, Winner, NewA, Y).

horiWinner(_ ,_ ,_ , Y, Y).
horiWinner(Board, X, Winner, A, Y) :- not(nth0(X, Board, 'var')),nth0(X, Board, Winner),  NewA is A+1, NewX is X+1, horiWinner(Board, NewX, Winner, NewA, Y).

leftDiagWinner(_ ,_ ,_ , Y, Y).
leftDiagWinner(Board, X, Winner, A, Y) :- not(nth0(X, Board, 'var')),nth0(X, Board, Winner),  NewA is A+1, NewX is X+10, leftDiagWinner(Board, NewX, Winner, NewA, Y).

rightDiagWinner(_ ,_ ,_ , Y, Y).
rightDiagWinner(Board, X, Winner, A, Y) :- not(nth0(X, Board, 'var')),nth0(X, Board, Winner),  NewA is A+1, NewX is X+12, rightDiagWinner(Board, NewX, Winner, NewA, Y).

%%%% Recursive predicate that checks if all the elements of the List (a board) %%%% are instanciated: true e.g. for [x,x,o,o,x,o,x,x,o] false for [x,x,o,o,_G125,o,x,x,o]
isBoardFull([]).
isBoardFull([H|T]):- nonvar(H), isBoardFull(T).

%%%% Artificial intelligence: choose in a Board the index to play for Player (_)
%%%% This AI plays randomly and does not care who is playing: it chooses a free position
%%%% in the Board (an element which is an free variable).


ia(Board, Index,_) :- repeat, Index is random(121), nth0(Index, Board, Elem), var(Elem), !.

%%%% Old
%parcours(Board,Index,Player) :- CurrentFloor=Board, parcours([CurrentFloor],0, Index,Player).
%parcours([CurrentFloor|_],X, Index,Player):- nth0(X, CurrentFloor, Elem), var(Elem), nth0(X,CurrentFloor,Player), aligned(CurrentFloor, CurrentFloor, Player, 0, 5), Index is X, !.
%parcours([CurrentFloor|Q],X, Index, Player):- length(CurrentFloor, Length), NewX is X+1,NewX<Length, parcours([CurrentFloor|Q],NewX, Index, Player).

winningMove(Board,Index,Player):- CurrentFloor=Board, winningMove([CurrentFloor],0, Index,Player,5).
winningMove([CurrentFloor|_],X, Index,Player,Size):- nth0(X, CurrentFloor, Elem), var(Elem), nth0(X,CurrentFloor,Player), aligned(CurrentFloor, CurrentFloor, Player, 0, Size), Index is X, !.
winningMove([CurrentFloor|Q],X, Index, Player,Size):- length(CurrentFloor, Length), NewX is X+1,NewX<Length, winningMove([CurrentFloor|Q],NewX, Index, Player,Size).
winningMove([CurrentFloor|Q],120, Index, Player,Size):- Size>2,NewSize is Size-1,!, winningMove([CurrentFloor|Q],0, Index, Player,NewSize).

%parcours(Floors,X,Index,Player):- boardFloors(Board),length(Board, Length),Length<2,retract(boardFloors([Board]).

ia2(Board,Index,Player) :- winningMove(Board,Index,Player).
ia2(Board,Index,_) :-ia(Board,Index,_). 

%%%% ia qui évalue les gains de chaque position

% ia3(Board,Index,Player) :- gainStep(Player,1,_,Board).

%%%% /!\ Chercher les possibilités d'utiliser les prédicats INCLUDE, MAPLIST, etc.. https://www.swi-prolog.org/pldoc/man?section=apply 

%%%% Selectionne tous les indices d'une liste qui correspondent au min ou au max, selon la stratégie.
selectBest(Indices,List,Max,max) :- selectMax(Indices,List,Max).
selectBest(Indices,List,Min,min) :- selectMin(Indices,List,Min).

%%%% Selectionne tous les indices d'une liste qui correspondent au min.
selectMin(Indices,List,Min) :- min_list(List, Min), selectMin(Indices,List, Min,0).
selectMin([],[],_,_).
selectMin([X|Indices],[Min|List],Min,X) :- incr1(X,NewX), selectMin(Indices,List,Min,NewX).
selectMin(Indices,[_|List],Min,X) :- incr1(X,NewX), selectMin(Indices,List,Min,NewX).

%%%% Selectionne tous les indices d'une liste qui correspondent au max.
selectMax(Indices,List,Max) :- max_list(List, Max), selectMax(Indices,List, Max,0).
selectMax([],[],_,_).
selectMax([X|Indices],[Max|List],Max,X) :- incr1(X,NewX), selectMax(Indices,List,Max,NewX).
selectMax(Indices,[_|List],Max,X) :- incr1(X,NewX), selectMax(Indices,List,Max,NewX).

%%%% retourne une liste de tous les index de List qui sont des variables.
selectVar(List,Vars) :- selectVar(List,Vars,0).
selectVar(List,[],A) :-  length(List,A).
selectVar(List,[X|Vars],A) :-  nth0(A,List,Elem), var(Elem), X=A, incr1(A,NewA), selectVar(List,Vars,NewA).
selectVar(List,Vars,A) :-  incr1(A,NewA), selectVar(List,Vars,NewA).

%%%% incremente X en NewX et l'initialise si dans le cas où X et NewX sont des variable, permet aussi de décrementer.
incr1(X,NewX) :- nonvar(X),NewX is X+1.
incr1(X,NewX) :- nonvar(NewX),X is NewX-1.
incr1(0,1).

%%%% Predicats dont on remplace l'ordre des arguments
fakenth0(List,Index,Elem) :- nth0(Index,List,Elem).

%%%% Joue plusieurs coups d'affiler
playMoves(Board,_,[],Board).
playMoves(Board,Player,[[]|Moves],FinalBoard) :-			% Si le coup à jouer est une liste vide, on passe
			playMoves(Board,Player,Moves,FinalBoard).
playMoves(Board,Player,[Move|Moves],FinalBoard) :-
			playMove(Board,Move,NewBoard,Player),
			nextPlayer(Player,Opponent),
			playMoves(NewBoard,Opponent,Moves,FinalBoard).

%%%% Transforme une liste en liste de liste
encapsuler([],[]).
encapsuler([X|Liste],[[X]|Reste]) :- encapsuler(Liste,Reste).

%%%% EXPLORATEUR 
%%%% [[],[CoupN1|[CoupN2],[CoupN2]],[CoupN1|[CoupN2]]]

explore(Player,0,'max',CoupsPrecedent,[CoupExplore],[CoupExplore|CapsuleCoups],Max) :-
            board(Board),                                                       % On récupère le plateau initial
			playMoves(Board,Player,[CoupExplore|CoupsPrecedent],FinalBoard),    % Note : les coups sont joues dans l'ordre inverse mais ça ne pose pas de problèmes
			calculMeilleurMoves(Player,FinalBoard,Max,ListeCoups),
            encapsuler(ListeCoups,CapsuleCoups), !.

explore(Player,Height,Strategy,CoupsPrecedent,[CoupExplore|ResteAJouer],[CoupExplore|ListMoves],Best) :- 
            incr1(NewHeight,Height),
            nextPlayer(Player,Opponent),
			maplist(explore(Opponent,NewHeight,NewStrategy,[CoupExplore|CoupsPrecedent]),ResteAJouer,ListeCoupsN1,ListMax),
            changeStrategy(NewStrategy,Strategy),
			selectBest(Indices,ListMax,Best,Strategy), 								% On selectionne les meilleurs coups
			maplist(fakenth0(ListeCoupsN1),Indices,ListMoves).

%%%% Fonction pour tester le fonctionnement sur une profondeur de 3, à mettre dans un autre fonction récursive

exploreTest :- assert(board([_,_,_,_,_,_,_,_,_])), Player = 'o', ResteAJouer = [], 
			explore(Player,0,_,[],[[]|ResteAJouer],ListeCoups,Max), writeln(ListeCoups),writeln(Max),
			explore(Player,1,_,[],ListeCoups,ListeCoups2,Max2), writeln(ListeCoups2),writeln(Max2),
			explore(Player,2,_,[],ListeCoups2,ListeCoups3,Max3), writeln(ListeCoups3),writeln(Max3),
			explore(Player,3,_,[],ListeCoups3,ListeCoups4,Max4), writeln(ListeCoups4),writeln(Max4),
			explore(Player,4,_,[],ListeCoups4,ListeCoups5,Max5), writeln(ListeCoups5),writeln(Max5),
			explore(Player,5,_,[],ListeCoups5,ListeCoups6,Max6), writeln(ListeCoups6),writeln(Max6),
			explore(Player,6,_,[],ListeCoups6,ListeCoups7,Max7), writeln(ListeCoups7),writeln(Max7),
			explore(Player,7,_,[],ListeCoups7,ListeCoups8,Max8), writeln(ListeCoups8),writeln(Max8),
			explore(Player,8,_,[],ListeCoups8,ListeCoups9,Max9), writeln(ListeCoups9),writeln(Max9).

%%%%  Pour une position de plateau donnee, retourne le gain maximum et la liste des coups associés.

calculMeilleurMoves(Player,Board,Max,ListMoves) :- 
			selectVar(Board,PossibleMoves),
			length(PossibleMoves,NumberOfMoves),
			length(Gain,NumberOfMoves),
			maplist(heuristic(Board,Player),PossibleMoves,Gain), % On teste les gains pour chaque coup. Note : Maplist ajoute les arguments à la fin et dans l'ordre 
			selectMax(Indices,Gain,Max), 								% On selectionne les meilleurs coups
			maplist(fakenth0(PossibleMoves),Indices,ListMoves).

%%%% heuristique de test pour un jeu de morpion : valeur de 1 si il y a une config gagnate, 0 sinon

winner(Board, P) :- Board = [P,Q,R,_,_,_,_,_,_], P==Q, Q==R, nonvar(P). % first row
winner(Board, P) :- Board = [_,_,_,P,Q,R,_,_,_], P==Q, Q==R, nonvar(P). % second row
winner(Board, P) :- Board = [_,_,_,_,_,_,P,Q,R], P==Q, Q==R, nonvar(P). % third row
winner(Board, P) :- Board = [P,_,_,Q,_,_,R,_,_], P==Q, Q==R, nonvar(P). % first column
winner(Board, P) :- Board = [_,P,_,_,Q,_,_,R,_], P==Q, Q==R, nonvar(P). % second column
winner(Board, P) :- Board = [_,_,P,_,_,Q,_,_,R], P==Q, Q==R, nonvar(P). % third column
winner(Board, P) :- Board = [P,_,_,_,Q,_,_,_,R], P==Q, Q==R, nonvar(P). % first diagonal
winner(Board, P) :- Board = [_,_,P,_,Q,_,R,_,_], P==Q, Q==R, nonvar(P). % second diagonal

heuristic(Board,Player,Move,1) :- playMove(Board,Move,NewBoard,Player),winner(NewBoard,Player).
heuristic(_,_,_,0).

%%%% Tell who is the next player

nextPlayer('o','x').
nextPlayer('x','o').

%%%% Swap strategy

changeStrategy('min','max').
changeStrategy('max','min').

human(Board, Index,_) :- repeat, 
						 write('C: '), 
						 read(MoveC),
						 write('R: '),
						 read(MoveR),
						 Index is MoveC + 11 * MoveR,
						 nth0(Index, Board, Elem),
						 var(Elem),
						 !.


%%%% Recursive predicate for playing the game. % The game is over, we use a cut to stop the proof search, and display the winner board. 
playHuman:- gameover(Winner), !, write('Game is Over. Winner: '), writeln(Winner), displayBoard, board(Board), retract(board(Board)). % The game is not over, we play the next turn
playHuman:- write('New turn for:'), writeln('HOOMAN'),board(Board), % instanciate the board from the knowledge base     
            displayBoard, % print it
			%human(Board, Move, 'x'),
			ia2(Board, Move, 'x'),
            playMove(Board,Move,NewBoard,'x'), % Play the move and get the result in a new Board
            applyIt(Board, NewBoard), % Remove the old board from the KB and store the new one
			playAI. % next turn!


playAI:- gameover(Winner), !, write('Game is Over. Winner: '), writeln(Winner), displayBoard, board(Board), retract(board(Board)). % The game is not over, we play the next turn
playAI:- write('New turn for:'), writeln('AI'),board(Board), % instanciate the board from the knowledge base     
            displayBoard, % print it 
            human(Board, Move, 'o'),
            playMove(Board, Move,NewBoard,'o'), % Play the move and get the result in a new Board
            applyIt(Board, NewBoard), % Remove the old board from the KB and store the new one
			playHuman. % next turn!

%%%% Play a Move, the new Board will be the same, but one value will be instanciated with the Move
playMove(Board,Move,NewBoard,Player) :- Board=NewBoard,  nth0(Move,NewBoard,Player).

%%%% Remove old board save new on in the knowledge base
applyIt(Board,NewBoard) :- retract(board(Board)), assert(board(NewBoard)).

%%%% Predicate to get the next player

%%%% Print a row
printRow(Row):-nonvar(Row), Val0 is Row*11+0, printVal(Val0), Val1 is Row*11+1, printVal(Val1), Val2 is Row*11+2, printVal(Val2), Val3 is Row*11+3, printVal(Val3), Val4 is Row*11+4, printVal(Val4), Val5 is Row*11+5, printVal(Val5), Val6 is Row*11+6, printVal(Val6), Val7 is Row*11+7, printVal(Val7), Val8 is Row*11+8, printVal(Val8), Val9 is Row*11+9, printVal(Val9), Val10 is Row*11+10, printVal(Val10).

%%%%% Print a value of the board at index N
printVal(N) :- board(B), nth0(N,B,Val), var(Val), write('_ '), !.
printVal(N) :- board(B), nth0(N,B,Val), write(Val), write(' ').

%%%% Display the board
displayBoard :-
	writeln('  C 0 1 2 3 4 5 6 7 8 9 10'),
	writeln(' R *----------------------*'),
	write(' 0 |'), printRow(0), writeln('|'),
	write(' 1 |'),printRow(1), writeln('|'),
	write(' 2 |'),printRow(2), writeln('|'),
	write(' 3 |'),printRow(3), writeln('|'),
	write(' 4 |'),printRow(4), writeln('|'),
	write(' 5 |'),printRow(5), writeln('|'),
	write(' 6 |'),printRow(6), writeln('|'),
	write(' 7 |'),printRow(7), writeln('|'),
	write(' 8 |'),printRow(8), writeln('|'),
	write(' 9 |'),printRow(9), writeln('|'),
	write('10 |'), printRow(10), writeln('|'),
	writeln('   *----------------------*').

%%%%% Start the game!
init :- length(Board,121), assert(board(Board)), playHuman.