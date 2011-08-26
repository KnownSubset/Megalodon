-module(stock_manager).
-export([start/1]).
-define(STOCKS, "stocks").
-define(PERIOD, "period").

start(File) ->
	application:start(mongodb),
    inets:start(),
	Stocks = properties:getProperty(?STOCKS),
	Period = properties:getSingleProperty(?PERIOD),
	manage(spawnStocksWatchers(Stocks,Period, dict:new()), Period).

%need to find the index of Pid in Pids, then find the Stock name that correlates to, respawn that process, and replace the Pid @ index
manage(Map, Period) ->
    receive
		{'DOWN', MonitorReference, process, Pid, Reason} ->
            erlang:demonitor(MonitorReference, [flush]),
            case dict:find(Pid, Map) of
                error -> false ;
                {ok, Name} ->
                    manage(spawnStocksWatchers([Name],Period,Map),Period)
            end,
            manage(Map,Period)
	end.
	
spawnStocksWatchers([],_, Map) ->
	Map;
spawnStocksWatchers([H|T],Period, Map) ->
	Pid = spawn_monitor(stock_watcher, start, [H, Period]),
	NewMap = spawnStocksWatchers(T,Period, Map),
    dict:store(Pid, H, NewMap).
