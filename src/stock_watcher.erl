-module(stock_watcher).
-export([start/2, startForDays/2]).
-define(START_TIME, 30600). %calendar:time_seconds({8,30,0})
-define(END_TIME, 61260).   %calendar:time_seconds({17,1,0})
-define(TIME_FORMAT, "~w/~w/~w@~w:~w:~w ").
-define(VALUES_FORMAT, "~f, ~f, ~f, ~f, ~f, ~f, ~f, ~f, ~f, ~f~n").
-define(ERROR, "Error Retrieving stock prices!!").

start(Name, Period) ->
    receive
        {From, start} ->
            log:log("starting"),
            From ! "starting",
            case historical_data:fetch(Name, Period, days) of
                {ok,StockHistory} ->
                    {Highs, Lows, Closes} = seperateHistorySegments(StockHistory),
                    watchDuringTradingSession(Name, Period, Highs,Lows,Closes, currentSeconds());
                {error,[]} ->
                    log:log(?ERROR),
                    From ! ?ERROR
            end;
        terminate ->
            ok
    end.

startForDays(Name, Period) ->
    case historical_data:fetch(Name, Period, days) of
        {ok,StockHistory} ->
            {Highs, Lows, Closes} = seperateHistorySegments(StockHistory),
            watchDuringTradingSession(Name, Period, Highs,Lows,Closes, currentSeconds());
        {error,[]} ->
            log:log(?ERROR)
    end.

watchDuringTradingSession(Name, Period, Highs, Lows, Closes, Seconds)  when ?START_TIME >= Seconds; Seconds >= ?END_TIME ->
    timer:sleep(110000),
    watchDuringTradingSession(Name, Period, Highs, Lows, Closes, currentSeconds());
watchDuringTradingSession(Name, Period, Highs, Lows, Closes, _) ->
    {HIGHS, LOWS, CLOSES} = watch(Name, Period, Highs, Lows, Closes),
    timer:sleep(110000),
    watchDuringTradingSession(Name, Period, HIGHS, LOWS, CLOSES, currentSeconds()).

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
    file_writer:writeFormattedText(Name++".log", {?TIME_FORMAT,[Year, Month, Day, Hour, Minute, Second]}),
    file_writer:writeFormattedText(Name++".log", {?VALUES_FORMAT, [High, Low, Close, Tenkan, Kijun, Senkou_A, Senkou_B, Kumo, Macd, BollingerBands]}),
    historical_data:write(Name, High, Low, Close, Volume, erlang:now(), calendar:time_to_seconds(erlang:time())),
    {[High|Highs], [Low|Lows], [Close|Closes]}.

seperateHistorySegments([]) ->
    {[], [], []};
seperateHistorySegments([H|T]) ->
    {High, Low, Close} = H,
    {Highs, Lows, Closes} = seperateHistorySegments(T),
    {[High | Highs], [Low | Lows], [Close | Closes]}.

currentSeconds() ->
    calendar:time_to_seconds(erlang:time()).
