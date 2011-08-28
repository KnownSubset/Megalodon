-module(file_writer).
-export([write/2, writeFormattedText/2]).

writeFormattedText(Name, {Format, Args})->
    write(Name, prepareTextForWriting(Format, Args)).

write(Name, Text) ->
    case file:open(Name, [append]) of
        {ok, FileDescriptor} ->
            file:write(FileDescriptor, Text),
            file:close(FileDescriptor);
        {error, enoent} ->
            donothing
    end.

prepareTextForWriting("", _) ->
    "";
prepareTextForWriting(Text, []) ->
    Text;
prepareTextForWriting(Text, Args) ->
    lists:flatten(io_lib:format(Text, Args )).
