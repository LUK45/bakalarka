-module(helloWorld).

-behaviour(serviceBehaviour).
-export([init/1,generatePage/0]).
%% gen_server callbacks

init(State) ->
	process_flag(trap_exit, true),
	serviceServer:start_link(State),
	ok.


generatePage() ->
			Page = "Hello world!\n",
			{ok,Page}.

