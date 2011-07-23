-module(historical_data_fetcher).
-export([fetch/1,fetch/2, import/2]).
-define(DATABASE_URL, "databaseURL").
-define(DATABASE_PORT, "databasePort").

fetch(Name) ->
	fetch(Name, 60).

%Todo - handle for a non-existent stock in the database

fetch(Name, Range) ->
    {ok, Conn} = mongo:connect (getHost()),
    {ok, Prices} = mongo:do(safe, master, Conn, test, fun () ->
        StockHistory = mongo:rest(mongo:find(stock, {name, bson:utf8(Name)})),
        lists:map (fun (Closing) -> bson:at (close, Closing) end, StockHistory) end),
    mongo:disconnect (Conn),
	Prices.

import(Name, FileName) ->
    Lines = file_reader:read(FileName),
    {ok, Conn} = mongo:connect(getHost()),
    insert(Name, Conn, Lines),
    mongo:disconnect (Conn).

getHost() ->
    {properties:getSingleProperty(?DATABASE_URL), list_to_number(properties:getSingleProperty(?DATABASE_PORT))}.

insert(_, _, []) ->  null;
insert(Name, Conn, [H|T])->
    Elements = string:tokens(H,",\n"),
    {ok, Prices} = mongo:do(safe, master, Conn, test, fun () ->
        mongo:insert(stock, {
            name, bson:utf8(Name),
            date, bson:utf8(lists:nth(1,Elements)),
            open, list_to_number(lists:nth(2,Elements)),
            high, list_to_number(lists:nth(3,Elements)),
            low, list_to_number(lists:nth(4,Elements)),
            close, list_to_number(lists:nth(5,Elements)),
            volume, list_to_integer(lists:nth(6,Elements))}) end),
    insert(Name,Conn, T).

list_to_number(L) ->
    try list_to_float(L)
    catch
        error:badarg ->
            list_to_integer(L)
    end.
