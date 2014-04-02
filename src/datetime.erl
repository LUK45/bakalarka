-module(datetime).

-compile([{parse_transform, lager_transform}]).

-export([init/0,generatePage/1]).
%% gen_server callbacks

init() ->
	lager:info("datetime: init ~p~n", [self()]),
	process_flag(trap_exit, true),
	State = dict:store(parent, ?MODULE, dict:new()),
	
	{ok, MyServer} = serviceServer:start_link(State),
	lager:info("datetime: initialized ~p~n", [self()]),
	{ok,MyServer}.


generatePage(_Req) ->
			{_Date={Year,Month,Day},_Time={_Hour,_Minutes,_Seconds}} = erlang:localtime(),
			Page = string:join(["Date: ",erlang:integer_to_list(Day),".",erlang:integer_to_list(Month),".",erlang:integer_to_list(Year),"\n"],""),
			Page.

