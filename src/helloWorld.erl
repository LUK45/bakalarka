-module(helloWorld).

-compile([{parse_transform, lager_transform}]).

-export([init/0,generatePage/0]).
%% gen_server callbacks

init() ->
	lager:info("helloWorld: init ~p~n", [self()]),
	process_flag(trap_exit, true),
	State = dict:store(parent, ?MODULE, dict:new()),
	
	{ok, MyServer} = serviceServer:start_link(State),
	lager:info("helloWorld: initialized ~p~n", [self()]),
	{ok,MyServer}.


generatePage() ->
			Page = "Hello world!\n",
			{ok,Page}.

