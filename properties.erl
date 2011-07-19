-module(properties).
-export([get/1]).

get(Property) ->
    Properties = readFromPropertiesFile("e:\\temp\\megalodon.properties"),
    findLine(Properties,Property).

readFromPropertiesFile(FileName) ->
    case file:open(FileName, [read]) of
        {ok, Device} ->
            get_all_lines(Device, []);
        {error, enoent} ->
            donothing
    end.

get_all_lines(Device, Accum) ->
    case io:get_line(Device, "") of
        eof  -> file:close(Device), Accum;
        Line -> get_all_lines(Device, Accum ++ [Line])
    end.

findLine([],_) ->
    [];
findLine([H|T],Property)->
    Start = string:substr(H,1,length(Property)),
    if Start =:= Property -> string:tokens(string:substr(H,length(Property)+2),",\n");
       true -> findLine(T,Property)
    end.
