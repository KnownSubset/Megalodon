-module(historical_data).
-export([fetch/1,fetch/3, import/2, write/7]).
-define(DATABASE_URL, "databaseURL").
-define(DATABASE_PORT, "databasePort").
-define(FILE_TOKENS, ",\n").
-define(DATE_TOKENS, "/").

fetch(Name) ->
	fetch(Name, 60, minutes).

fetch(Name, Range, minutes) ->
    fetchPricesAfterTime(Name, Range, 0);

fetch(Name, Range, days) ->
    MarketClosingTime = convertDateToSeconds(1970, 1, 1, 16, 0, 0),
    fetchPricesAfterTime(Name, Range, calendar:time_to_seconds({16,0,0})).

fetchPricesAfterTime(Name, Range, Time) ->
    case mongo:connect (getHost()) of
        {ok, Conn} ->
            {ok, Prices} = mongo:do(safe, master, Conn, test, fun () ->
                StockHistory = mongo:rest(mongo:find(stock, {'$query',{name, bson:utf8(Name), seconds, {'$gte', Time }}, '$orderby', {timestamp,-1}},{'_id', 0, high, 1, low, 1, close, 1}, 0, -1*Range)),
                lists:map (fun (Stock) -> {bson:at (high, Stock),bson:at (low, Stock),bson:at (close, Stock)} end, StockHistory) end),
            mongo:disconnect (Conn),
            {ok, lists:reverse(Prices)};
        {error,econnrefused} ->
            io:format("Database is not started! Failing process!!~n"),
            log:log("Database is not started! Failing process!!"),
            {error, []}
    end.


write(Name, High, Low, Close, Volume, Timestamp, Time) ->
    {ok, Conn} = mongo:connect(getHost()),
    insert(Conn, Name, High, Low, Close, Volume, [Timestamp|Time]),
    mongo:disconnect (Conn).

import(Name, FileName) ->
    Lines = file_reader:read(FileName),
    {ok, Conn} = mongo:connect(getHost()),
    mongo:do(safe, master, Conn, test, fun () ->
        mongo:delete(stock,  {name, bson:utf8(Name)}) end),
    insertRecords(Name, Conn, Lines, 1),
    mongo:disconnect (Conn).

getHost() ->
    {properties:getSingleProperty(?DATABASE_URL), list_to_number(properties:getSingleProperty(?DATABASE_PORT))}.

insertRecords(_, _, [], _) ->  null;
insertRecords(Name, Conn, [H|T], LineNumber)->
    io:format("~w ~n", [LineNumber]),
    Elements = string:tokens(H,?FILE_TOKENS),
    Time =  convertDateStringToSeconds(lists:nth(1,Elements)),
    High = list_to_number(lists:nth(3,Elements)),
    Low = list_to_number(lists:nth(4,Elements)),
    Close = list_to_number(lists:nth(5,Elements)),
    Volume = list_to_integer(lists:nth(6,Elements)),
    insert(Conn, Name, High, Low, Close, Volume, Time),
    insertRecords(Name,Conn, T, LineNumber + 1).

insert(Conn, Name, High, Low, Close, Volume, [Timestamp | Time])->
    mongo:do(safe, master, Conn, test, fun () ->
        mongo:insert(stock,  {name, bson:utf8(Name),timestamp, Timestamp, seconds, Time, high, High,
                              low, Low, close, Close, volume, Volume}) end).

convertDateStringToSeconds(DateString) ->
    DateParts = string:tokens(DateString,?DATE_TOKENS),
    Year = list_to_number(lists:nth(3,DateParts)),
    Month = list_to_number(lists:nth(1,DateParts)),
    Day = list_to_number(lists:nth(2,DateParts)),
    [convertDateToSeconds(Year, Month, Day, 16, 0, 0) | convertDateToSeconds(1970, 1, 1, 16, 0, 0) ].

convertDateToSeconds(Year, Month, Day, Hour, Minutes, Seconds) ->
    bson:secs_to_unixtime(86400 * calendar:date_to_gregorian_days(Year-1970, Month, Day) + calendar:time_to_seconds({Hour,Minutes,Seconds})).

list_to_number(L) ->
    try list_to_float(L)
    catch
        error:badarg ->
            list_to_integer(L)
    end.
