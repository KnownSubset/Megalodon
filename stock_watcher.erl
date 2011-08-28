-module(stock_watcher).
-export([start/2, startForDays/2]).

start(Name, Period) ->
    receive
        {From, start} ->
            log:log("starting"),
            From ! "starting",
            case historical_data:fetch(Name, Period, days) of
                {ok,StockHistory} ->
                    {Highs, Lows, Closes} = seperateHistorySegments(StockHistory),
                    watchDuringTradingSession(Name, Period, Highs,Lows,Closes, erlang:time());
                {error,[]} ->
                    log:log("Error Retrieving stock prices!!"),
                    From ! "Error Retrieving stock prices!!"
            end;
        terminate ->
            ok
    end.

startForDays(Name, Period) ->
    case historical_data:fetch(Name, Period, days) of
        {ok,StockHistory} ->
            {Highs, Lows, Closes} = seperateHistorySegments(StockHistory),
            watchDuringTradingSession(Name, Period, Highs,Lows,Closes, erlang:time());
        {error,[]} ->
            log:log("Error Retrieving stock prices!!")
    end.

watchDuringTradingSession(Name, Period, Highs, Lows, Closes, {Hour, Minute, _})  when Hour =< 8, Minute < 30; Hour >= 17, Minute > 1  ->
    timer:sleep(110000),
    watchDuringTradingSession(Name, Period, Highs, Lows, Closes, erlang:time());
watchDuringTradingSession(Name, Period, Highs, Lows, Closes, _) ->
    {HIGHS, LOWS, CLOSES} = watch(Name, Period, Highs, Lows, Closes),
    timer:sleep(110000),
    watchDuringTradingSession(Name, Period, HIGHS, LOWS, CLOSES, erlang:time()).

watch(Name, Period, Highs, Lows, Closes) ->
    RealTimeInfo = real_time_stock:price(Name),
    High = lists:nth(1,RealTimeInfo),
    Low = lists:nth(2,RealTimeInfo),
    Close = lists:nth(3,RealTimeInfo),
    Volume = lists:nth(4,RealTimeInfo),
    {Tenkan, Kijun, Senkou_A, Senkou_B, Kumo} = ichimoku:cloud([High|Highs], [Low|Lows]),
    Macd = macd:calculate([Close|Closes]),
    BollingerBands = bollinger_bands:calculate(Period,[Close|Closes]),
    {{Year, Month, Day}, {Hour, Minute, Second}} = erlang:localtime(),
    file_writer:writeFormattedText(Name, {"~w/~w/~w@~w:~w:~w ",[Year, Month, Day, Hour, Minute, Second]}),
    file_writer:writeFormattedText(Name, {"~f, ~f, ~f, ~f, ~f, ~f, ~f, ~f, ~f, ~f~n", [High, Low, Close, Tenkan, Kijun, Senkou_A, Senkou_B, Kumo, Macd, BollingerBands]}),
    historical_data:write(Name, High, Low, Close, Volume, erlang:now(), erlang:time()),
    {[High|Highs], [Low|Lows], [Close|Closes]}.

seperateHistorySegments([]) ->
    {[], [], []};
seperateHistorySegments([H|T]) ->
    {High, Low, Close} = H,
    {Highs, Lows, Closes} = seperateHistorySegments(T),
    {[High | Highs], [Low | Lows], [Close | Closes]}.
