-module(properties_tests).
-export ([test/0]).

test() ->
    eunit:test ({
        setup,
        fun () -> io:format ("~n** Make sure mongod is running on 127.0.0.1:27017 **~n~n", []) end,
        fun (_) -> io:format ("~n** Make sure mongod is running on 127.0.0.1:27017 **~n~n", []) end,
        [fun properties_test/0]}).

properties_test() ->
    Stocks = ["MSFT","GOOG","YHOO","AAPL"],
    Stocks = properties:getProperty("stocks"),
    "localhost" = properties:getSingleProperty("databaseURL"),
    "27017" = properties:getSingleProperty("databasePort").

