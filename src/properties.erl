-module(properties).
-export([getProperty/1, getSingleProperty/1]).

getProperty(Property) ->
    Properties = file_reader:read("./properties/megalodon.properties"),
    findLine(Properties,Property).

getSingleProperty(Property) ->
    hd(getProperty(Property)).

findLine([],_) ->
    [];
findLine([H|T],Property)->
    Start = string:substr(H,1,length(Property)),
    if Start =:= Property -> string:tokens(string:substr(H,length(Property)+2),",\n");
       true -> findLine(T,Property)
    end.
