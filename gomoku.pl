

%%%% Print a row
printRow(Row):-nonvar(Row), Val0 is Row*11+0, printVal(Val0), Val1 is Row*11+1, printVal(Val1), Val2 is Row*11+2, printVal(Val2), Val3 is Row*11+3, printVal(Val3), Val4 is Row*11+4, printVal(Val4), Val5 is Row*11+5, printVal(Val5), Val6 is Row*11+6, printVal(Val6), Val7 is Row*11+7, printVal(Val7), Val8 is Row*11+8, printVal(Val8), Val9 is Row*11+9, printVal(Val9), Val10 is Row*11+10, printVal(Val10).

%%%%% Print a value of the board at index N 
printVal(N) :- board(B), nth0(N,B,Val), var(Val), write('? '), !.
printVal(N) :- board(B), nth0(N,B,Val), write(Val), write(' '). 

%%%% Display board
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
init :- length(Board,121), assert(board(Board)),displayBoard.