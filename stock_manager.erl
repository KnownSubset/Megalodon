-module(stock_manager).
-export([start/1, spawnStocksWatchers/2]).
-define(STOCKS, "stocks").

start(File) ->
	application:start(mongodb),
    inets:start(),
	Stocks = properties:get(?STOCKS),
	manage(spawnStocksWatchers(Stocks, dict:new())).

%need to find the index of Pid in Pids, then find the Stock name that correlates to, respawn that process, and replace the Pid @ index
manage(Map) ->
    receive
		{'DOWN', MonitorReference, process, Pid, Reason} ->
            erlang:demonitor(MonitorReference, [flush]),
            case dict:find(Pid, Map) of
                error -> false ;
                {ok, Name} ->
                    manage(spawnStocksWatchers([Name],Map))
            end,
            manage(Map)
	end.
	
spawnStocksWatchers([], Map) ->
	Map;
spawnStocksWatchers([H|T], Map) ->
	Pid = spawn_monitor(stock_watcher, start, [H]),
	NewMap = spawnStocksWatchers(T, Map),
    dict:store(Pid, H, NewMap).
