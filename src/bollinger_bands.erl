-module(bollinger_bands).
-export([calculate/1, calculate/2, simpleMovingAverage/1, simpleMovingAverage/2]).

calculate() ->
    receive
        {From, {Period, Closes}} ->
			Middle = simpleMovingAverage(Closes, Period),
            Delta =  2 * standardDeviation(simpleMovingAverage(Closes, 20), Closes, 20),
            Upper = Middle + Delta,
            Lower = Middle - Delta;
    terminate ->
            ok
    end.
	
calculate(Closes) ->
	calculate(20, Closes).
calculate(Period, Closes) ->
	Middle = simpleMovingAverage(Closes, Period),
    Delta =  2 * standardDeviation(simpleMovingAverage(Closes, Period), Closes, Period),
    Upper = Middle + Delta,
    Lower = Middle - Delta.

simpleMovingAverage(Closes) ->
    simpleMovingAverage(Closes, 10).
simpleMovingAverage(Closes, Period)  ->
    lists:foldl(fun(X, Sum) -> X/Period + Sum end, 0, lists:sublist(Closes, Period)).

average(Closes) ->
    simpleMovingAverage(Closes, length(Closes)).

standardDeviation(Mean, Closes) ->
    math:sqrt(lists:foldl(fun(X, Sum) ->  math:pow(X - Mean,2) + Sum end, 0, Closes)/length(Closes)).
standardDeviation(Mean, Closes, Period) ->
    standardDeviation(Mean, lists:sublist(Closes, 20)).
