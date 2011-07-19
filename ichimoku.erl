-module(ichimoku).
-export([cloud/2, tenkan/2, kijun/2, senkou_A/2, senkou_B/2, kumo/2]).

cloud(Highs, Lows) ->
    Tenkan = tenkan(Highs, Lows),
    Kijun = kijun(Highs, Lows),
    Senkou_A = (Tenkan + Kijun) / 2,
    Senkou_B = senkou_B(Highs, Lows),
    Kumo = Senkou_B - Senkou_A,
    [Tenkan, Kijun, Senkou_A, Senkou_B, Kumo].
tenkan(Highs, Lows) ->
	conversionLine(Highs, Lows, 9).
kijun(Highs, Lows) ->
	conversionLine(Highs, Lows, 26).
senkou_A(Highs, Lows) ->
	(tenkan(Highs, Lows) + kijun(Highs, Lows))/2.
senkou_B(Highs, Lows) ->
	conversionLine(Highs, Lows, 52).
kumo(Highs, Lows) ->
	senkou_B(Highs, Lows) - senkou_A(Highs, Lows).

conversionLine(Highs, Lows, Period) ->
	(lists:max(lists:sublist(Period,Highs)) + lists:min(lists:sublist(Period,Lows)))/2.
