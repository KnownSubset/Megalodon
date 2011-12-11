%% @author author <author@example.com>
%% @copyright YYYY author.

%% @doc Callbacks for the megalodon application.

-module(megalodon_app).
-author('author <author@example.com>').

-behaviour(application).
-export([start/2,stop/1]).


%% @spec start(_Type, _StartArgs) -> ServerRet
%% @doc application start callback for megalodon.
start(_Type, _StartArgs) ->
    megalodon_sup:start_link().

%% @spec stop(_State) -> ServerRet
%% @doc application stop callback for megalodon.
stop(_State) ->
    ok.
