%% @author author <author@example.com>
%% @copyright YYYY author.
%% @doc Example webmachine_resource.

-module(megalodon_resource).
-export([init/1,
         allowed_methods/2,
         content_types_provided/2,
         retrieve_data_for/2,
         to_json/2]).
-include_lib("webmachine/include/webmachine.hrl").
-record(ichimoki, {tenkan, kijun, senkou_a, senkou_b, kumo}).
-record(indicators, {name, highs=[], lows=[], closes=[], ichimoki=#ichimoki{}, macd=[], bollinger=[]}).


init(_) -> {ok, undefined}.

allowed_methods(ReqData, State) ->
    {['GET', 'HEAD', 'POST'], ReqData, State}.

%content_types_accepted(ReqData, State) ->
%    {[{"application/json", from_json}], ReqData, State}.

content_types_provided(ReqData, State) ->
    {[{"application/json", to_json}], ReqData, State}.

to_json(ReqData, State) ->
    Period = list_to_atom(wrq:path_info(period, ReqData)),
    Stock = wrq:path_info(stock, ReqData),
    Indicators = retrieve_data_for(Stock,Period),
    JsonDoc = mochijson2:encode({struct, Indicators}),
    {JsonDoc, ReqData, State}.

retrieve_data_for(Stock, Period) ->
    application:start(mongodb),
    {ok, HighsLowsCloses}= historical_data:fetch(Stock, 60, Period),
    {Highs, Lows, Closes} = extract_to_lists(HighsLowsCloses),
    {Tenkan, Kijun, Senkou_A, Senkou_B, Kumo} = ichimoku:cloud(Highs, Lows),
    Macd = macd:calculate(Closes),
    BollingerBands = bollinger_bands:calculate(60,Closes),
    Ichimoki = [{"tenkan",Tenkan}, {"kijun",Kijun}, {"senkou_a",Senkou_A}, {"senkou_b",Senkou_B}, {"kumo",Kumo}],
    [{"name",bson:utf8(Stock)}, {"highs",Highs}, {"lows",Lows}, {"closes",Closes}, {"ichimoki",Ichimoki}, {"macd",Macd}, {"bollinger",BollingerBands}].
    %{Highs, Lows, Closes, BollingerBands, {Tenkan, Kijun, Senkou_A, Senkou_B, Kumo}, Macd}. 

%to_html(ReqData, State) ->
%    {"<html><body>Hello, new world</body></html>", ReqData, State}. 
%	megalodon_resource:retrieve_data_for("MSFT", minutes)
extract_to_lists([]) ->
    {[],[],[]};	
extract_to_lists([H | T]) ->
    {High, Low, Close} = H,
    {Highs, Lows, Closes} = extract_to_lists(T),
    {[High | Highs], [Low | Lows], [Close | Closes]}.

