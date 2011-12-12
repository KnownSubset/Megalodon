-module(price_acceleration).
-export([calculate/2]).

calculate(Closings, Period) ->
    calculate_for_sublists(Closings, Period, length(Closings)).

calculate_for_sublists([H|T], Period, Length) when Length > Period ->
    SubList = lists:sublist([H|T],Period),
    Difference = (lists:nth(Period, SubList)-lists:nth(1,SubList))  / Period,
    [Difference | calculate_for_sublists(T, Period, Length - 1)];
calculate_for_sublists(_,_,_) ->
    [].
