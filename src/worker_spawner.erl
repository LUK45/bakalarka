-module(worker_spawner).
%% gen_server_mini_template

-compile([{parse_transform, lager_transform}]).
-export([ init/3, terminate/3, handle/2]).



init(_Transport, Req, []) ->
	%link(whereis(gate)),
	process_flag(trap_exit, true),
	%io:format("LAGER : INIT  ~p ~n~p~n",[self(),erlang:process_info(self())]),
	% For the random number generator:
	
	{ok, Req, undefined}.

			
handle(Req, State) ->
	worker_helloWorld:start_link(Req),
	{ok, Req, State}.


terminate(_Reason, _Req, _State) ->
ok.			
