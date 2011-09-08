%% @author author <author@example.com>
%% @copyright YYYY author.
%% @doc Example webmachine_resource.

-module(megalodon_resource).
-export([init/1,
         allowed_methods/2,
         content_types_provided/2,
         content_types_accepted/2,
         to_json/2]).
-include_lib("webmachine/include/webmachine.hrl").

init([]) -> {ok, undefined}.

allowed_methods(ReqData, State) ->
    {['GET'], ReqData, State}.

content_types_accepted(ReqData, State) ->
    {[{"application/json", from_json}], ReqData, State}.

content_types_provided(ReqData, State) ->
    {[{"application/json", to_json}], ReqData, State}.

to_json(ReqData, State) ->
    Period = wrq:path_info(period, ReqData),
    Stock = wrq:path_info(stock, ReqData),
    JsonDoc = mochijson2:encode({struct, [{period, list_to_binary(Period)}, 
					  {stock, list_to_binary(Stock)}
					 ]}),
    {JsonDoc, ReqData, State}.

