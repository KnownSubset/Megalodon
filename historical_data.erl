-module(historical_data).
-export([fetch/1,fetch/2, import/2, write/6]).
-define(DATABASE_URL, "databaseURL").
-define(DATABASE_PORT, "databasePort").
-define(FILE_TOKENS, ",\n").
-define(DATE_TOKENS, "/").

fetch(Name) ->
	fetch(Name, 60).

%Todo - need to pull out the values that are eod closes, or by minutes out of the whole collection
fetch(Name, Range) ->
    {ok, Conn} = mongo:connect (getHost()),
    {ok, Prices} = mongo:do(safe, master, Conn, test, fun () ->
        StockHistory = mongo:rest(mongo:find(stock, {'query',{name, bson:utf8(Name)}, 'orderby', {time,-1}},{'_id', 0, close, 1}, 0, -1*Range)),
        lists:map (fun (Closing) -> bson:at (close, Closing) end, StockHistory) end),
    mongo:disconnect (Conn),
	Prices.

write(Name, High, Low, Close, Volume, Time) ->
    {ok, Conn} = mongo:connect(getHost()),
    mongo:do(safe, master, Conn, test, fun () ->
        mongo:delete(stock,  {name, bson:utf8(Name)}) end),
    insert(Conn, Name, High, Low, Close, Volume, Time),
    mongo:disconnect (Conn).

import(Name, FileName) ->
    Lines = file_reader:read(FileName),
    {ok, Conn} = mongo:connect(getHost()),
    insert(Name, Conn, Lines),
    mongo:disconnect (Conn).

getHost() ->
    {properties:getSingleProperty(?DATABASE_URL), list_to_number(properties:getSingleProperty(?DATABASE_PORT))}.

insert(_, _, []) ->  null;
insert(Name, Conn, [H|T])->
    Elements = string:tokens(H,?FILE_TOKENS),
    Time =  convertDateStringToSeconds(lists:nth(1,Elements)),
    High = list_to_number(lists:nth(3,Elements)),
    Low = list_to_number(lists:nth(4,Elements)),
    Close = list_to_number(lists:nth(5,Elements)),
    Volume = list_to_integer(lists:nth(6,Elements)),
    insert(Conn, Name, High, Low, Close, Volume, Time),
    insert(Name,Conn, T).

insert(Conn, Name, High, Low, Close, Volume, Time)->
    mongo:do(safe, master, Conn, test, fun () ->
        mongo:insert(stock,  {name, bson:utf8(Name), time, Time, high, High,
                              low, Low, close, Close, volume, Volume}) end).

convertDateStringToSeconds(DateString) ->
    DateParts = string:tokens(DateString,?DATE_TOKENS),
    Year = list_to_number(lists:nth(3,DateParts)),
    Month = list_to_number(lists:nth(1,DateParts)),
    Day = list_to_number(lists:nth(2,DateParts)),
    convertDateToSeconds(Year, Month, Day, 16, 0, 0).

convertDateToSeconds(Year, Month, Day, Hour, Minutes, Seconds) ->
    bson:secs_to_unixtime(86400 * calendar:date_to_gregorian_days(Year-1970, Month, Day) + calendar:time_to_seconds({Hour,Minutes,Seconds})).

list_to_number(L) ->
    try list_to_float(L)
    catch
        error:badarg ->
            list_to_integer(L)
    end.
