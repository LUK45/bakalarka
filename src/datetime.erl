-module(datetime).

-compile([{parse_transform, lager_transform}]).

-export([init/0,generatePage/0]).
%% gen_server callbacks

init() ->
	lager:info("datetime: init ~p~n", [self()]),
	process_flag(trap_exit, true),
	State = dict:store(parent, ?MODULE, dict:new()),
	
	{ok, MyServer} = serviceServer:start_link(State),
	lager:info("datetime: initialized ~p~n", [self()]),
	{ok,MyServer}.


generatePage() ->
			{_Date={Year,Month,Day},_Time={Hour,Minutes,Seconds}} = erlang:localtime(),
			Line = string:join(["Date: ",erlang:integer_to_list(Day),".",erlang:integer_to_list(Month),".",erlang:integer_to_list(Year),"\n"],""),
			Line2 = string:join(["Time: ",erlang:integer_to_list(Hour),":",erlang:integer_to_list(Minutes),":",erlang:integer_to_list(Seconds),"\n"],""),
			Page = string:concat(Line, Line2),
			{ok,Page}.

