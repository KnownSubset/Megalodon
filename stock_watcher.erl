-module(stock_watcher).
-export([stock/1,stock/2,watch/3]).


stock(NAME) ->
    stock(NAME, 9).
stock(NAME, PERIOD) ->
    Pid = spawn(macd, calculate, []),
    Pid ! {self(), {macd, PERIOD}}.

watch(NAME, PERIOD, HIGHS, LOWS, CLOSES) ->
	receive
        {From, {start}} ->
            RealTimeInfo = real_time_stock:price(NAME),
            High = lists:nth(1,RealTimeInfo),
            Low = lists:nth(2,RealTimeInfo),
            Close = lists:nth(3,RealTimeInfo),
			Highs = [High|HIGHS],
            Lows = [Low|LOWS],
            Closes = [Close|CLOSES],
            IchimokuCloud = ichimoku:cloud(Highs, Lows),
            Macd = macd:calculate(PERIOD, Closes),
            BollingerBands = bollinger_bands:calculate(Closes),
			%timer:sleep(12000),
            %                                                     lists:foldl(fun(X, Sum) ->  math:pow(X - Mean,2) + Sum end, 0, Closes)
            file_writer:write(NAME, lists:foldl(fun(X, Text) ->  Text++ ","++ float_to_lists(X) end, "", [High,Low,Close,IchimokuCloud,Macd,BollingerBands])),
            %
			watch(NAME, PERIOD, Highs, Lows, Closes);
    terminate ->
            ok
    end.
	
    
