-module(dfa).
-author('Nathan Dauber <nathan.dauber@gmail.com>').
-export([calculate/1]).

calculate(Prices) ->
    M = length(Prices),
    L = 4, %Sample Size
    Samples = divide_into_samples(Prices, L, M),
    Scales = ceiling(math:log(L)/math:log(2)), % round or ceiling?
    Y_n = lists:sum(Prices) * length(Prices),
    LocalTrend = 0,
    [].

divide_into_samples([H|T], Count, Length) when Length >= Count ->
    List = [H|T],
    Length = length(List),
    SubList = lists:sublist(Count, List),
    [SubList | divide_into_samples(T, Count)];
divide_into_samples([], _, _) ->
    [];
divide_into_samples(_, _, _) ->
    [].


