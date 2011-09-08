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
-record(ichimoki, {tenkan, kijun, senkou_a, senkou_b, kumo}).
-record(indicators, {name, highs=[], lows=[], closes=[], ichimoki=#ichimoki{}, macd=[], bollinger=[]}).

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
    Indicators = retrieve_data_for(Stock,Period),
    JsonDoc = mochijson2:encode({struct, [{indicators, Indicators}]}),
    {JsonDoc, ReqData, State}.

retrieve_data_for(Stock, Period) ->
    {Highs, Lows, Closes}= historical_data:fetch(Stock, 60, days),
    {Tenkan, Kijun, Senkou_A, Senkou_B, Kumo} = ichimoku:cloud(Highs, Lows),
    Macd = macd:calculate(Closes),
    BollingerBands = bollinger_bands:calculate(Period,Closes),
    Ichimoki = #ichimoki{tenkan=Tenkan, kijun=Kijun, senkou_a=Senkou_A, senkou_b=Senkou_B, kumo=Kumo},
    #indicators{name=Stock, highs=Highs, lows=Lows, closes=Closes, ichimoki=Ichimoki, macd=Macd, bollinger=BollingerBands}.
    %{Highs, Lows, Closes, BollingerBands, {Tenkan, Kijun, Senkou_A, Senkou_B, Kumo}, Macd}.  


