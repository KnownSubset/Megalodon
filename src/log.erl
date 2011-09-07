-module(log).
-export([log/1, log/2]).
-define(NAME, "megalodon.log").

log(Format, Args)->
    file_writer:writeFormattedText(?NAME, {string:concat(Format," @ ~w~n"), lists:append([Args,[erlang:localtime()]])}).

log(Text) ->
    log(Text,[]).
