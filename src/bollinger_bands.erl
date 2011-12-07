-module(bollinger_bands).
-export([calculate/1, calculate/2, simple_moving_average/1, simple_moving_average/2]).

calculate() ->
    receive
        {From, {Period, Closes}} ->
			Middle = simple_moving_average(Closes, Period),
            Delta =  2 * standard_deviation(simple_moving_average(Closes, 20), Closes, 20),
            Upper = Middle + Delta,
            Lower = Middle - Delta;
    terminate ->
            ok
    end.
	
calculate(Closes) ->
	calculate(20, Closes).
calculate(Period, Closes) ->
	Middle = simple_moving_average(Closes, Period),
    Delta =  2 * standard_deviation(simple_moving_average(Closes, Period), Closes, Period),
    Upper = Middle + Delta,
    Lower = Middle - Delta.

simple_moving_average(Closes) ->
    simple_moving_average(Closes, 10).
simple_moving_average(Closes, Period)  ->
    lists:foldl(fun(X, Sum) -> X/Period + Sum end, 0, lists:sublist(Closes, Period)).

average(Closes) ->
    simple_moving_average(Closes, length(Closes)).

standard_deviation(Mean, Closes) ->
    math:sqrt(lists:foldl(fun(X, Sum) ->  math:pow(X - Mean,2) + Sum end, 0, Closes)/length(Closes)).
standard_deviation(Mean, Closes, Period) ->
    standard_deviation(Mean, lists:sublist(Closes, 20)).
