-module(historical_data_fetcher).
-export([fetch/1,fetch/2]).

fetch(Name) ->
	fetch(Name, 60).

%Todo - change out the database name so that is it read in from a file
%     - handle for a non-existent stock in the database

fetch(Name, Range) ->
    Host = {localhost, 27017},
    {ok, Conn} = mongo:connect (Host),
    {ok, Prices} = mongo:do(safe, master, Conn, test, fun () ->
        Stock = hd(mongo:rest(mongo:find(stock, {name, bson:utf8(Name)}))),
		Closings = bson:at(closings, Stock),
        lists:map (fun (Closing) -> bson:at (price, Closing) end, Closings) end),
    mongo:disconnect (Conn),
	Prices.
	
	