-module(historical_data_fetcher).
-export([fetch/1,fetch/2, import/1]).

fetch(Name) ->
	fetch(Name, 60).

%Todo - change out the database name so that is it read in from a file
%     - handle for a non-existent stock in the database

fetch(Name, Range) ->
    Host = {properties:getSingleProperty("databaseURL"), list_to_number(properties:getSingleProperty("databasePort"))},
    {ok, Conn} = mongo:connect (Host),
    {ok, Prices} = mongo:do(safe, master, Conn, test, fun () ->
        Stock = hd(mongo:rest(mongo:find(stock, {name, bson:utf8(Name)}))),
		Closings = bson:at(closings, Stock),
        lists:map (fun (Closing) -> bson:at (price, Closing) end, Closings) end),
    mongo:disconnect (Conn),
	Prices.

import(FileName) ->
    Lines = file_reader:read(FileName),
    Host = {properties:getSingleProperty("databaseURL"), list_to_number(properties:getSingleProperty("databasePort"))},
    {ok, Conn} = mongo:connect(Host),
    insert(Conn, Lines),
    mongo:disconnect (Conn).

insert(_, []) ->  null;
insert(Conn, [H|T])->
    Elements = string:tokens(H,",\n"),
    {ok, Prices} = mongo:do(safe, master, Conn, test, fun () ->
        mongo:insert(stock, {
            name, bson:utf8("MSFT"),
            date, bson:utf8(lists:nth(1,Elements)),
            open, list_to_number(lists:nth(2,Elements)),
            high, list_to_number(lists:nth(3,Elements)),
            low, list_to_number(lists:nth(4,Elements)),
            close, list_to_number(lists:nth(5,Elements)),
            volume, list_to_integer(lists:nth(6,Elements))}) end),
    insert(Conn, T).

list_to_number(L) ->
    try list_to_float(L)
    catch
        error:badarg ->
            list_to_integer(L)
    end.
