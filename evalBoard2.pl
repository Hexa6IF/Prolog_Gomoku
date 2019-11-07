%% EvalBoard 2 (Heuristic 2)
%% For a given board, check the number of player marker alignements (of 1, 2, 3, 4, 5 in a row)
%% Attribute a score to the board according to the number of alignements

%%%%% Calculate the total value of a given state of the board to the player
evalBoard2(Board, Player, BoardScore) :-
    aligned(Board, Player, 1, Ones, 1),
    aligned(Board, Player, 2, Twos, 1),
    aligned(Board, Player, 3, Threes, 1),
    aligned(Board, Player, 4, Fours, 1),
    % aligned(Board, Player, 5, Fives, 1),
    aligned(Board, Player, 5, AllFives, 0),
    %% change player to get scores of opponent
    changePlayer(Player, Opponent),
    aligned(Board, Opponent, 1, OnesOpp, 1),
    aligned(Board, Opponent, 2, TwosOpp, 1),
    aligned(Board, Opponent, 3, ThreesOpp, 1),
    aligned(Board, Opponent, 4, FoursOpp, 1),
    % aligned(Board, Opponent, 5, FivesOpp, 1),
    aligned(Board, Opponent, 5, AllFivesOpp, 0),
    BoardScorePlayer is 1*Ones+10*Twos+100*Threes+1000*Fours+100000*(AllFives),
    BoardScoreOpp is 1*OnesOpp+10*TwosOpp+100*ThreesOpp+1000*FoursOpp+100000*(AllFivesOpp),
    BoardScore is BoardScorePlayer-BoardScoreOpp,
    !.