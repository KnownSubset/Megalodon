-module(properties).
-export([get/1]).

get(Property) ->
    Properties = file_reader:read("e:\\temp\\megalodon.properties"),
    findLine(Properties,Property).

findLine([],_) ->
    [];
findLine([H|T],Property)->
    Start = string:substr(H,1,length(Property)),
    if Start =:= Property -> string:tokens(string:substr(H,length(Property)+2),",\n");
       true -> findLine(T,Property)
    end.
