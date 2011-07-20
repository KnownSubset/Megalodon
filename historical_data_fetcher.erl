-module(historical_data_fetcher).
-export([fetch/1,fetch/2, import/1, format/1]).

fetch(Name) ->
	fetch(Name, 60).

%Todo - change out the database name so that is it read in from a file
%     - handle for a non-existent stock in the database

fetch(Name, Range) ->
    Host = {properties:get("databaseURL"), properties:get("databasePort")},
    {ok, Conn} = mongo:connect (Host),
    {ok, Prices} = mongo:do(safe, master, Conn, test, fun () ->
        Stock = hd(mongo:rest(mongo:find(stock, {name, bson:utf8(Name)}))),
		Closings = bson:at(closings, Stock),
        lists:map (fun (Closing) -> bson:at (price, Closing) end, Closings) end),
    mongo:disconnect (Conn),
	Prices.

import(FileName) ->
    Lines = file_reader:read(FileName),
    {ok, Conn} = mongo:connect ({localhost, 27017}),
    {ok, Prices} = mongo:do(safe, master, Conn, test, fun () ->
        mongo:insert(stock, {name, bson:utf8("MSFT"), closings, format(Lines)}) end),
    mongo:disconnect (Conn).

format([])->
    [];
format([H|T])->
    Elements = string:tokens(H,",\n"),
    [{date, bson:utf8(lists:nth(1,Elements)),
    open, list_to_float(lists:nth(2,Elements)),
    high, list_to_float(lists:nth(3,Elements)),
    low, list_to_float(lists:nth(4,Elements)),
    close, list_to_float(lists:nth(5,Elements)),
    volume, list_to_integer(lists:nth(6,Elements))} | format(T) ].
