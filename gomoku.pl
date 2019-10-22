

%%%% Print a row
printRow(Row):-nonvar(Row), printVal(Val), Val is Row*11+0. 
% printVal(Row*11+1), printVal(Row*11+2), printVal(Row*11+3), printVal(Row*11+4), printVal(Row*11+5), printVal(Row*11+6), printVal(Row*11+7), printVal(Row*11+8), printVal(Row*11+9), printVal(Row*11+10).

%%%%% Print a value of the board at index N 
printVal(N) :- board(B), nth0(N,B,Val), var(Val), write('?'), !.
printVal(N) :- board(B), nth0(N,B,Val), write(Val). 

%%%% Display board
displayBoard :-
	writeln('*----------*'),    
	printRow(0), writeln(''),
	printRow(1), writeln(''),
	printRow(2), writeln(''),
	printRow(3), writeln(''),
	printRow(4), writeln(''),
	printRow(5), writeln(''),
	printRow(6), writeln(''),
	printRow(7), writeln(''),
	printRow(8), writeln(''),
	printRow(9), writeln(''),
	printRow(10), writeln(''),
	writeln('*----------*').
	
%%%%% Start the game! 
init :- length(Board,121), assert(board(Board)).