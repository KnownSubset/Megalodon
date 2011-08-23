-module(stock_watcher).
-export([start/2, startForDays/2]).

start(Name, Period) ->
    receive
        {From, {start}} ->
            StockHistory = historical_data:fetch(Name, Period, days),
            {Highs, Lows, Closes} = convert(StockHistory),
            watch(Name, Period, Highs,Lows,Closes);
    terminate ->
        ok
    end.

startForDays(Name, Period) ->
    StockHistory = historical_data:fetch(Name, Period, days),
    {Highs, Lows, Closes} = convert(StockHistory),
    watch(Name, Period, Highs,Lows,Closes).

watch(NAME, PERIOD, HIGHS, LOWS, CLOSES) ->
    RealTimeInfo = real_time_stock:price(NAME),
    High = lists:nth(1,RealTimeInfo),
    Low = lists:nth(2,RealTimeInfo),
    Close = lists:nth(3,RealTimeInfo),
    Volume = lists:nth(4,RealTimeInfo),
    Highs = [High|HIGHS],
    Lows = [Low|LOWS],
    Closes = [Close|CLOSES],
    {Tenkan, Kijun, Senkou_A, Senkou_B, Kumo} = ichimoku:cloud(Highs, Lows),
    Macd = macd:calculate(Closes),
    BollingerBands = bollinger_bands:calculate(Closes)+1,
    Items = [High ,Low , Close ,Tenkan, Kijun, Senkou_A, Senkou_B, Kumo , Macd , BollingerBands],
    Words = lists:map (fun (X) -> float_to_list(X) end, Items),
    file_writer:write(NAME, lists:foldl(fun(X, Text) ->  Text++ ","++ X end, "", Words)),
    historical_data:write(NAME, High, Low, Close, Volume, erlang:now(), erlang:time()).
    %timer:sleep(120000),
    %watch(NAME, PERIOD, Highs, Lows, Closes).

convert([]) ->
    {[], [], []};
convert([H|T]) ->
    {High, Low, Close} = H,
    {Highs, Lows, Closes} = convert(T),
    {[High | Highs], [Low | Lows], [Close | Closes]}.
