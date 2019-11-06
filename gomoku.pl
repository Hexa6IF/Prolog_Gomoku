
% The game state will be represented by a list of 9 elements
% board(_,_,_,_,_,_,_,_,_) at the beginning
% eg board(_,_,'x',_,_,_,_,_,_) after the first round
% eg board(_,_,'x',_,_,_,'o',_,_) after the second round
% ...
% until someone wins or the board is fully instanciated

:- dynamic board/1.
:- dynamic currentlyEvaluatedBoard/1.

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

ia3(_,Index,Player) :- explorateur(Player,Index).

%%%% /!\ Chercher les possibilités d'utiliser les prédicats INCLUDE, MAPLIST, etc.. https://www.swi-prolog.org/pldoc/man?section=apply 

%%%% Selectionne tous les indices d'une liste qui correspondent au min ou au max, selon la stratégie.
selectBest(Indices,List,Max,max) :- selectMax(Indices,List,Max).
selectBest(Indices,List,Min,min) :- selectMin(Indices,List,Min).

%%%% Selectionne tous les indices d'une liste qui correspondent au min.
selectMin(Indices,List,Min) :- min_list(List, Min), selectMin(Indices,List, Min,0).
selectMin([],[],_).
selectMin([],[],_,_).
selectMin([X|Indices],[Min|List],Min,X) :- incr1(X,NewX), selectMin(Indices,List,Min,NewX).
selectMin(Indices,[_|List],Min,X) :- incr1(X,NewX), selectMin(Indices,List,Min,NewX).

%%%% Selectionne tous les indices d'une liste qui correspondent au max.
selectMax(Indices,List,Max) :- max_list(List, Max), selectMax(Indices,List, Max,0).
selectMax([],[],_,_).
selectMax([X|Indices],[Max|List],Max,X) :- incr1(X,NewX), selectMax(Indices,List,Max,NewX).
selectMax(Indices,[_|List],Max,X) :- incr1(X,NewX), selectMax(Indices,List,Max,NewX).

%%%% retourne une liste de tous les index de List qui sont des variables.
selectVar(List,Vars) :- selectVar(List,Vars,0),!.
selectVar(List,[],A) :-  length(List,A),!.
selectVar(List,[X|Vars],A) :-  nth0(A,List,Elem), var(Elem), X=A, incr1(A,NewA), selectVar(List,Vars,NewA).
selectVar(List,Vars,A) :-  incr1(A,NewA), selectVar(List,Vars,NewA).
 
%%%%
isPosEmpty(Board, Index) :-
    nth0(Index, Board, Elem),
    var(Elem).

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
			playMoves(NewBoard,Opponent,Moves,FinalBoard),!.

%%%% Transforme une liste en liste de liste
encapsuler([],[]).
encapsuler([X|Liste],[[X]|Reste]) :- encapsuler(Liste,Reste).

%%%% EXPLORATEUR 
%%%% [[],[CoupN1|[CoupN2],[CoupN2]],[CoupN1|[CoupN2]]]

%prettyWriteListe(Liste) :- length(Liste,L),maplist(prettyWriteListe(L),Liste).
prettyWriteListe([]).
prettyWriteListe([Element|Liste]) :- 
			maplist(prettyWriteListe,Liste),
			write(Element),write(' '),
			nextLineIfEmpty(Liste).

nextLineIfEmpty([]) :- 
			writeln('').
nextLineIfEmpty(_).

writeSpaces(0).
writeSpaces(A) :- write('| '),incr1(NewA,A),writeSpaces(NewA).

%%%% Parcours

explorateur(Player,Index) :- 
			explore(Player,0,_,[],[[]],ListeCoups,Max),
			explorateur(Player,1,ListeCoups,Max,ListeFinale),
			selectionneur(ListeFinale,Index).
explorateur(_,_,ListeCoups,_,ListeCoups) :- length(ListeCoups,2).
explorateur(_,Depth,ListeCoups,_,ListeCoups) :- length(ListeCoups,Length),(121*(Length^Depth))>15000.
explorateur(_,_,ListeCoups,-1,ListeCoups).
explorateur(Player,Depth,ListeCoups,_,ListeFinale) :- 
			explore(Player,Depth,_,[],ListeCoups,NewListeCoups,Max),
			incr1(Depth,NewDepth),
			explorateur(Player,NewDepth,NewListeCoups,Max,ListeFinale).

explore(_,_,_,_,[],[[]],_).

explore(Player,0,'max',CoupsPrecedent,[CoupExplore],[CoupExplore|CapsuleCoups],Max) :-
            board(Board),
			nextPlayer(Player,Opponent),                                                       % On récupère le plateau initial
			reverse([CoupExplore|CoupsPrecedent],CoupsAJouer),
			playMoves(Board,Opponent,CoupsAJouer,FinalBoard), % Note : les coups sont joues dans l'ordre inverse mais ça ne pose pas de problèmes
			asserta(currentlyEvaluatedBoard(FinalBoard)),
			calculMeilleurMoves(Player,FinalBoard,Max,ListeCoups),	% Fail si la liste est vide
			retractall(currentlyEvaluatedBoard(_)),
            encapsuler(ListeCoups,CapsuleCoups), !.

explore(_,0,'max',_,[CoupExplore],[CoupExplore],-1).

explore(Player,Height,Strategy,CoupsPrecedent,[CoupExplore|ResteAJouer],[CoupExplore|ListMoves],Best) :- 
            incr1(NewHeight,Height),
            nextPlayer(Player,Opponent),
			maplist(explore(Opponent,NewHeight,NewStrategy,[CoupExplore|CoupsPrecedent]),ResteAJouer,ListeCoupsN1,ListMax),
			writeln(ListMax),
            changeStrategy(NewStrategy,Strategy),
			selectBest(Indices,ListMax,Best,Strategy), 								% On selectionne les meilleurs coups
			maplist(fakenth0(ListeCoupsN1),Indices,ListMoves).

selectionneur([[],[Index|_]],Index).
selectionneur([[]|ListeMove],Index) :- 
			maplist(length,ListeMove,ListLength),
			selectMin(Indices,ListLength,_),
			maplist(fakenth0(ListeMove),Indices,NewListMove),
			selectionneur(NewListMove,Index).
selectionneur([Index|_]|[],Index).
selectionneur(ListeMove,Index) :- 
			length(ListeMove,Length),
			Numero is random(Length),
			nth0(Numero,ListeMove,[Index|_]).

%%%% Fonction pour tester le fonctionnement de l'explorateur

exploreTest :-  asserta(board([_,_,_,_,_,_,_,_,_])), Player = 'o', explorateur(Player,Index),write('| '), writeln(Index).

%%%%  Pour une position de plateau donnee, retourne le gain maximum et la liste des coups associés.

calculMeilleurMoves(Player,Board,Max,ListMoves) :- 
			selectVar(Board,PossibleMoves),
			length(PossibleMoves,NumberOfMoves),
			length(Gain,NumberOfMoves),
			maplist(heuristic(Player),PossibleMoves,Gain), % On teste les gains pour chaque coup. Note : Maplist ajoute les arguments à la fin et dans l'ordre 
			selectMax(Indices,Gain,Max), 								% On selectionne les meilleurs coups
			maplist(fakenth0(PossibleMoves),Indices,ListMoves).

%%%% heuristique de test pour un jeu de morpion : valeur de 1 si il y a une config gagnate, 0 sinon

%%%%% Attribute a score to each consecutive sets of player marker alignements
	
	getScore(5, 0, 100) :-
		!.
	getScore(_, _, 0) :-
		!.

%%%%% Increment the count of player/oppent markers in a row
	incrementCount(Player, Elem, PlyCount, OppCount, NewPlyCount, NewOppCount) :-
		Elem==Player,
		NewPlyCount is PlyCount+1,
		NewOppCount is OppCount.
	incrementCount(_, _, PlyCount, OppCount, NewPlyCount, NewOppCount) :-
		NewPlyCount is PlyCount,
		NewOppCount is OppCount+1.

%%%%% Recursively calculate the total value of a given state of the board to the player
	evalBoard(Board, Player, BoardScore) :-
		evalBoardHori(Board, Player, 0, TotalHScore, 0),
		evalBoardVert(Board, Player, 0, TotalVScore, 0),
		evalBoardLeftDiag(Board, Player, 0, TotalLDScore, 0),
		evalBoardRightDiag(Board, Player, 0, TotalRDScore, 0),
		BoardScore is TotalHScore+TotalVScore+TotalLDScore+TotalRDScore,
		!.

	evalBoardHori(_, _, TotalScore, TotalScore, 121).
	evalBoardHori(Board, Player, AccScore, TotalHScore, Acc) :-
		Acc mod 11=<6,
		evalHori(Board, Player, HScore, Acc, 0, 0, 0),
		NewAccScore is AccScore + HScore,
		NewAcc is Acc + 1,
		evalBoardHori(Board, Player, NewAccScore, TotalHScore, NewAcc),
		!.
	evalBoardHori(Board, Player, AccScore, TotalHScore, Acc) :-
		NewAcc is Acc + 1,
		evalBoardHori(Board, Player, AccScore, TotalHScore, NewAcc),
		!.

	evalBoardVert(_, _, TotalScore, TotalScore, 121).
	evalBoardVert(Board, Player, AccScore, TotalVScore, Acc) :-
		Acc=<76,
		evalVert(Board, Player, VScore, Acc, 0, 0, 0),
		NewAccScore is AccScore + VScore,
		NewAcc is Acc + 1,
		evalBoardVert(Board, Player, NewAccScore, TotalVScore, NewAcc),
		!.
	evalBoardVert(Board, Player, AccScore, TotalVScore, Acc) :-
		NewAcc is Acc + 1,
		evalBoardVert(Board, Player, AccScore, TotalVScore, NewAcc),
		!.

	evalBoardLeftDiag(_, _, TotalScore, TotalScore, 121).
	evalBoardLeftDiag(Board, Player, AccScore, TotalLDScore, Acc) :-
		Acc=<76,
		Acc mod 11>=4,
		evalLeftDiag(Board, Player, LDScore, Acc, 0, 0, 0),
		NewAccScore is AccScore + LDScore,
		NewAcc is Acc + 1,
		evalBoardLeftDiag(Board, Player, NewAccScore, TotalLDScore, NewAcc),
		!.
	evalBoardLeftDiag(Board, Player, AccScore, TotalLDScore, Acc) :-
		NewAcc is Acc + 1,
		evalBoardLeftDiag(Board, Player, AccScore, TotalLDScore, NewAcc),
		!.

	evalBoardRightDiag(_, _, TotalScore, TotalScore, 121).
	evalBoardRightDiag(Board, Player, AccScore, TotalRDScore, Acc) :-
		Acc=<76,
		Acc mod 11=<6,
		evalRightDiag(Board, Player, RDScore, Acc, 0, 0, 0),
		NewAccScore is AccScore + RDScore,
		NewAcc is Acc + 1,
		evalBoardRightDiag(Board, Player, NewAccScore, TotalRDScore, NewAcc),
		!.
	evalBoardRightDiag(Board, Player, AccScore, TotalRDScore, Acc) :-
		NewAcc is Acc + 1,
		evalBoardRightDiag(Board, Player, AccScore, TotalRDScore, NewAcc),
		!.

%%%%% Recursively calculate the total value of a given state of the board to the player - horizontal alignements
	evalHori(_, _, HScore, _, 5, PlyCount, OppCount) :-
		getScore(PlyCount, OppCount, HScore),
		!.
	evalHori(Board, Player, HScore, Index, Acc, PlyCount, OppCount) :-
		Acc=<5,
		not(isPosEmpty(Board, Index)),
		nth0(Index, Board, Elem),
		NewAcc is Acc+1,
		NewIndex is Index+1,
		incrementCount(Player,
					Elem,
					PlyCount,
					OppCount,
					NewPlyCount,
					NewOppCount),
		evalHori(Board,
				Player,
				HScore,
				NewIndex,
				NewAcc,
				NewPlyCount,
				NewOppCount).
	evalHori(Board, Player, VScore, Index, Acc, PlyCount, OppCount) :-
		Acc=<5,
		NewIndex is Index+1,
		NewAcc is Acc+1,
		evalHori(Board,
				Player,
				VScore,
				NewIndex,
				NewAcc,
				PlyCount,
				OppCount).

%%%%% Recursively calculate the total value of a given state of the board to the player - verical alignements
	evalVert(_, _, VScore, _, 5, PlyCount, OppCount) :-
		getScore(PlyCount, OppCount, VScore),
		!.
	evalVert(Board, Player, VScore, Index, Acc, PlyCount, OppCount) :-
		Acc=<5,
		not(isPosEmpty(Board, Index)),
		nth0(Index, Board, Elem),
		NewAcc is Acc+1,
		NewIndex is Index+11,
		incrementCount(Player,
					Elem,
					PlyCount,
					OppCount,
					NewPlyCount,
					NewOppCount),
		evalVert(Board,
				Player,
				VScore,
				NewIndex,
				NewAcc,
				NewPlyCount,
				NewOppCount),
		!.
	evalVert(Board, Player, VScore, Index, Acc, PlyCount, OppCount) :-
		Acc=<5,
		NewIndex is Index+11,
		NewAcc is Acc+1,
		evalVert(Board,
				Player,
				VScore,
				NewIndex,
				NewAcc,
				PlyCount,
				OppCount).

%%%%% Recursively calculate the total value of a given state of the board to the player - left-diagonal alignements
	evalLeftDiag(_, _, LDScore, _, 5, PlyCount, OppCount) :-
		getScore(PlyCount, OppCount, LDScore),
		!.
	evalLeftDiag(Board, Player, LDScore, Index, Acc, PlyCount, OppCount) :-
		not(isPosEmpty(Board, Index)),
		nth0(Index, Board, Elem),
		NewAcc is Acc+1,
		NewIndex is Index+10,
		incrementCount(Player,
					Elem,
					PlyCount,
					OppCount,
					NewPlyCount,
					NewOppCount),
		evalLeftDiag(Board,
					Player,
					LDScore,
					NewIndex,
					NewAcc,
					NewPlyCount,
					NewOppCount).
	evalLeftDiag(Board, Player, LDScore, Index, Acc, PlyCount, OppCount) :-
		Acc=<5,
		NewIndex is Index+10,
		NewAcc is Acc+1,
		evalLeftDiag(Board,
					Player,
					LDScore,
					NewIndex,
					NewAcc,
					PlyCount,
					OppCount).

%%%%% Recursively calculate the total value of a given state of the board to the player - right-diagonal alignements
	evalRightDiag(_, _, RDScore, _, 5, PlyCount, OppCount) :-
		getScore(PlyCount, OppCount, RDScore),
		!.
	evalRightDiag(Board, Player, RDScore, Index, Acc, PlyCount, OppCount) :-
		not(isPosEmpty(Board, Index)),
		nth0(Index, Board, Elem),
		NewAcc is Acc+1,
		NewIndex is Index+12,
		incrementCount(Player,
					Elem,
					PlyCount,
					OppCount,
					NewPlyCount,
					NewOppCount),
		evalRightDiag(Board,
					Player,
					RDScore,
					NewIndex,
					NewAcc,
					NewPlyCount,
					NewOppCount).
	evalRightDiag(Board, Player, RDScore, Index, Acc, PlyCount, OppCount) :-
		Acc=<5,
		NewIndex is Index+12,
		NewAcc is Acc+1,
		evalRightDiag(Board,
					Player,
					RDScore,
					NewIndex,
					NewAcc,
					PlyCount,
					OppCount).


heuristic(Player,Move,BoardScore) :- currentlyEvaluatedBoard(Board),playMove(Board,Move,NewBoard,Player) ,evalBoard(NewBoard, Player, BoardScore).
heuristic(_,_,0).

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
			human(Board, Move, 'x'),
            playMove(Board,Move,NewBoard,'x'), % Play the move and get the result in a new Board
            applyIt(Board, NewBoard), % Remove the old board from the KB and store the new one
			playAI. % next turn!


playAI:- gameover(Winner), !, write('Game is Over. Winner: '), writeln(Winner), displayBoard, board(Board), retract(board(Board)). % The game is not over, we play the next turn
playAI:- write('New turn for:'), writeln('AI'),board(Board), % instanciate the board from the knowledge base     
            displayBoard, % print it 
            ia3(Board, Move, 'o'),
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