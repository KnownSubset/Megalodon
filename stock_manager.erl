-module(stock_manager).
-export([start/1, spawnStocksWatchers/2]).

start(File) ->
	application:start(mongodb),
    inets:start(),
	odbc:start(),
	Stocks = readStocksToManageFromPropertiesFile(File),
	manage(spawnStocksWatchers(Stocks, dict:new())).

%need to find the index of Pid in Pids, then find the Stock name that correlates to, respawn that process, and replace the Pid @ index
manage(Map) ->
    receive
		{'DOWN', MonitorReference, process, Pid, Reason} ->
            erlang:demonitor(MonitorReference, [flush, info]),
            case dict:find(Pid, Map) of
                error -> false ;
                {ok, Name} ->
                    manage(spawnStocksWatchers([Name],Map))
            end,
            manage(Map);
	end.
	
spawnStocksWatchers([], Map) ->
	Map;
spawnStocksWatchers([H|T], Map) ->
	Pid = spawn_monitor(stock_watcher, watch, [H]),
	NewMap = spawnStocksWatchers(T, Map),
    dict:store(Pid, H, NewMap).

readStocksToManageFromPropertiesFile(FileName) ->
    case file:open(FileName, [read]) of
        {ok, Device} ->
            get_all_lines(Device, []);
        {error, Reason} ->
            ["APPL", "GOOG", "MSFT", "YHOO"];
    end.

get_all_lines(Device, Accum) ->
    case io:get_line(Device, "") of
        eof  -> file:close(Device), Accum;
        Line -> get_all_lines(Device, Accum ++ [Line])
    end.
