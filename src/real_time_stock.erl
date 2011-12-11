-module(real_time_stock).
-export([price/0,price/1]).
-include("../include/xmerl.hrl").

price() ->
price("YHOO").

price(Name) ->
    log:log("Retrieving "++Name++" stock price"),
    {ok, {{_, 200, _}, _, Body}} = httpc:request("http://www.google.com/ig/api?stock="++Name),
    {Doc, _}=xmerl_scan:string(Body),
    [#xmlAttribute{value=High}]=xmerl_xpath:string("//high/@data", Doc),
    [#xmlAttribute{value=Low}]=xmerl_xpath:string("//low/@data", Doc),
    [#xmlAttribute{value=Last}]=xmerl_xpath:string("//last/@data", Doc),
    [#xmlAttribute{value=Volume}]=xmerl_xpath:string("//volume/@data", Doc),
    lists:map(fun (X) -> list_to_number(X) end, [High,Low,Last,Volume]).


list_to_number([]) ->
    -1.0;
list_to_number(L) ->
    try list_to_float(L)
    catch
        error:badarg ->
            list_to_integer(L)
    end.
