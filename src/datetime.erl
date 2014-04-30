-module(datetime).

-behaviour(serviceBehaviour).
-export([init/1,generatePage/0]).
%% gen_server callbacks

init(State) ->
	process_flag(trap_exit, true),
	serviceServer:start_link(State),
	ok.


generatePage() ->


			while_loop(100, 0),

			{_Date={Year,Month,Day},_Time={Hour,Minutes,Seconds}} = erlang:localtime(),
			Line = string:join(["Date: ",erlang:integer_to_list(Day),".",erlang:integer_to_list(Month),".",erlang:integer_to_list(Year),"\n"],""),
			Line2 = string:join(["Time: ",erlang:integer_to_list(Hour),":",erlang:integer_to_list(Minutes),":",erlang:integer_to_list(Seconds),"\n"],""),
			Page = string:concat(Line, Line2),
			{ok,Page}.




while_loop(Number, Number)-> ok;
while_loop(Number, Var)->
	timer:sleep(2),
	while_loop(Number, Var+1).


