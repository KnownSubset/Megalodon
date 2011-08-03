-module(historical_data_fetcher).
-export([fetch/1,fetch/2, import/2]).
-define(DATABASE_URL, "databaseURL").
-define(DATABASE_PORT, "databasePort").
-define(TOKENS, ",\n").

fetch(Name) ->
	fetch(Name, 60).

%Todo - need to be able to specify if I want minutes or if I want day's values
%Todo - need to be able to pull back data in order of time
fetch(Name, Range) ->
    {ok, Conn} = mongo:connect (getHost()),
    {ok, Prices} = mongo:do(safe, master, Conn, test, fun () ->
        StockHistory = mongo:rest(mongo:find(stock, {'query',{name, bson:utf8(Name)}, 'orderby', {date,-1}},{'_id', 0, close, 1}, 0, -1*Range)),
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
    Elements = string:tokens(H,?TOKENS),
    DateParts = string:tokens(lists:nth(1,Elements),"/"),
    Year = list_to_number(lists:nth(3,DateParts)),
    Month = list_to_number(lists:nth(1,DateParts)),
    Day = list_to_number(lists:nth(2,DateParts)),
    mongo:do(safe, master, Conn, test, fun () ->
        mongo:insert(stock, {
            name, bson:utf8(Name),
            dayOfYear, calendar:date_to_gregorian_days(Year, Month, Day),
            secondOfDay, calendar:time_to_seconds({16,0,0}),
            date, {year, Year, month, Month, day, Day, hour, 16, minute, 0, second, 0},
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
