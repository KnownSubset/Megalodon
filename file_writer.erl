-module(file_writer).
-export([start/1, write/2]).

start(Name) ->
    Name.
%Todo: Need to test out file paths and ensure that is working or decide where the location of the files will be stored

write(Name, Text) ->
    case file:open(Name, [append]) of
        {ok, FileDescriptor} ->
            io:format(FileDescriptor, Text),
            file:close(FileDescriptor);
        {error, enoent} ->
            donothing
    end.
