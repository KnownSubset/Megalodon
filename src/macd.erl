-module(macd).
-export([calculate/0, calculate/1, exponentialMovingAverage/2, signalLine/2, calculateAll/1]).

calculate() ->
    receive
        {From, {Period, Closes}} ->
            Macd = calculate(Closes),
			From ! {self(), ok},
            Macd;
    terminate ->
            ok
    end.
	
calculate(Closes) ->
	Length = length(Closes),
	Ema12 = exponentialMovingAverage(Closes, 12, Length),
	Ema26 = exponentialMovingAverage(Closes, 26, Length),
	Ema12 - Ema26.

calculateAll([], _) -> [];
calculateAll( _ , Length) when Length < 26 -> [];
calculateAll(Closes, Length) when Length == 26 ->
    [calculate(Closes)];
calculateAll([H|T], Length) ->
    [calculate([H|T]) | calculateAll(T, Length - 1)].
calculateAll(Closes) ->
    calculateAll(Closes, length(Closes)).

exponentialMovingAverage(Closes, Period, Iteration) when Period >= Iteration->
    lists:sum(lists:sublist(Closes, Period))/Period;
exponentialMovingAverage([H|Tail], Period, Iteration)  ->
    (H + exponentialMovingAverage(Tail, Period, Iteration - 1) * (Period - 1)) / Period.
exponentialMovingAverage(Closes, Period)  ->
    exponentialMovingAverage(Closes, Period, length(Closes)).

signalLine(_, Period, Iteration) when Iteration < Period ->  [];
signalLine(Macds, Period, Iteration) when Iteration == Period ->
    [lists:sum(Macds)/Period];
signalLine([H|T], Period, Iteration) ->
    Signals = signalLine(T, Period, Iteration -1 ),
    Signal = hd(Signals),
    [(H + Signal * (Period - 1)) / Period | Signals].
signalLine(Closes, Period) ->
    Macds = calculateAll(Closes),
    signalLine(Macds, Period, length(Macds)).

