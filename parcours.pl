%%%% MISC

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

%%%% Tell who is the next player

nextPlayer('o','x').
nextPlayer('x','o').

%%%% Swap strategy

changeStrategy('min','max').
changeStrategy('max','min').

%%%% EXPLORATEUR 

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

%%%% [[],[CoupN1|[CoupN2],[CoupN2]],[CoupN1|[CoupN2]]]

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


heuristic(Player,Move,BoardScore) :- 
            currentlyEvaluatedBoard(Board),
            playMove(Board,Move,NewBoard,Player),
            evalBoard(NewBoard, Player, BoardScore).  %%%% HEURISTIQUE A AJOUTER ICI
heuristic(_,_,0).
