-module(stock_watcher).
-export([watch/5]).

watch(NAME, PERIOD, HIGHS, LOWS, CLOSES) ->
	receive
        {From, {start}} ->
            RealTimeInfo = real_time_stock:price(NAME),
            High = lists:nth(1,RealTimeInfo),
            Low = lists:nth(2,RealTimeInfo),
            Close = lists:nth(3,RealTimeInfo),
            Volume = lists:nth(4,RealTimeInfo),
			Highs = [High|HIGHS],
            Lows = [Low|LOWS],
            Closes = [Close|CLOSES],
            IchimokuCloud = ichimoku:cloud(Highs, Lows),
            Macd = macd:calculate(PERIOD, Closes),
            BollingerBands = bollinger_bands:calculate(Closes),
			%timer:sleep(12000),
            %                                                     lists:foldl(fun(X, Sum) ->  math:pow(X - Mean,2) + Sum end, 0, Closes)
            file_writer:write(NAME, lists:foldl(fun(X, Text) ->  Text++ ","++ float_to_list(X) end, "", [High,Low,Close,IchimokuCloud,Macd,BollingerBands])),
            historical_data:write(NAME, High, Low, Close, Volume, erlang:now()),
            %
			watch(NAME, PERIOD, Highs, Lows, Closes);
    terminate ->
            ok
    end.
	
