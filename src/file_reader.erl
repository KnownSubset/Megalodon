-module(file_reader).
-export([read/1]).

read(FileName) ->
    case file:open(FileName, [read]) of
        {ok, Device} ->
            get_all_lines(Device, []);
        {error, enoent} ->
            donothing
    end.

get_all_lines(Device, Accum) ->
    case io:get_line(Device, "") of
        eof  -> file:close(Device), Accum;
        Line -> get_all_lines(Device, Accum ++ [Line])
    end.
