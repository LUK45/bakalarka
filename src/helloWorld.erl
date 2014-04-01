-module(helloWorld).

-compile([{parse_transform, lager_transform}]).

-export([init/0,generatePage/1]).
%% gen_server callbacks

init() ->
	lager:info("helloWorld: init ~p~n", [self()]),
	process_flag(trap_exit, true),
	State = dict:store(parent, ?MODULE, dict:new()),
	{ok, MyServer} = serviceServer:start_link(State),
	lager:info("helloWorld: initialized ~p~n", [self()]),
	{ok,MyServer}.


generatePage(Req) ->
			{ok, Req2} = cowboy_req:reply(200, [
			{<<"content-type">>, <<"text/plain">>}
			], <<"Hello world!\n">>, Req),
		{ok,Req2}.

