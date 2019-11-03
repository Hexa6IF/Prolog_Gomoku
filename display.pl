%%%%% Displaying the board

%%%%% Print all rows
printRows(BoardDimension, BoardDimension).
printRows(BoardDimension, Row) :-
    integer(Row),
    Row < 10,
    atom_number(RowToAtom, Row),
    atom_concat(' ', RowToAtom, RowHeader),
    atom_concat(RowHeader, ' |', CompletedRowHeader),
    write(CompletedRowHeader),
    printRow(Row, 0, BoardDimension),
    writeln('|'),
    NewRow is Row+1,
    printRows(BoardDimension, NewRow).
printRows(BoardDimension, Row) :-
    integer(Row),
    atom_number(RowToAtom, Row),
    atom_concat(' ', RowToAtom, RowHeader),
    atom_concat(RowHeader, '|', CompletedRowHeader),
    write(CompletedRowHeader),
    printRow(Row, 0, BoardDimension),
    writeln('|'),
    NewRow is Row+1,
    printRows(BoardDimension, NewRow).

%%%%% Print a row
printRow(_, BoardDimension, BoardDimension).
printRow(Row, Acc, BoardDimension) :-
    integer(Row),
    Val is Row*BoardDimension+Acc,
    printVal(Val),
    NewAcc is Acc+1,
    printRow(Row, NewAcc, BoardDimension).

%%%%% Print a value of the board at index N
printVal(N) :-
    board(B),
    nth0(N, B, Val),
    var(Val),
    write('_ '),
    !.
printVal(N) :-
    board(B),
    nth0(N, B, Val),
    write(Val),
    write(' ').

%%%%% Display the board
displayBoard :-
    board(Board),
    length(Board, BoardLength),
    BoardDimension is round(sqrt(BoardLength)),
    getColumnHeader('  C', BoardDimension, 0),
    getBoundaries(' R *', BoardDimension, 0),
    printRows(BoardDimension, 0),
    getBoundaries('   *', BoardDimension, 0).

%%%%% Display the number of the columns
getColumnHeader(CompletedColumnHeader, BoardDimension, BoardDimension) :-
    writeln(CompletedColumnHeader).
getColumnHeader(ColumnHeader, BoardDimension, Index) :-
    integer(Index),
    NewIndex is Index+1,
    atom_number(IndexToAtom, Index),
    atom_concat(ColumnHeader, ' ', ColumnHeaderSpace),
    atom_concat(ColumnHeaderSpace, IndexToAtom, NewColumnHeader),
    getColumnHeader(NewColumnHeader, BoardDimension, NewIndex).

%%%%% Display the board's borders
getBoundaries(Boundary, BoardDimension, BoardDimension) :-
    atom_concat(Boundary, '*', CompletedBoundary),
    writeln(CompletedBoundary).
getBoundaries(Boundary, BoardDimension, Index) :-
    integer(Index),
    NewIndex is Index+1,
    atom_concat(Boundary, '--', NewBoundary),
    getBoundaries(NewBoundary, BoardDimension, NewIndex).
    