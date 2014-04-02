-module(gate).

-behaviour(gen_server).
-compile([{parse_transform, lager_transform}]).
-export([start_link/1]).
%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
terminate/2, code_change/3]).

 

start_link(State) -> gen_server:start_link( ?MODULE, State, []).

init(State) -> 
	register(gate, self()),
	process_flag(trap_exit, true),
	io:format("GATE gen serve init~n"),
		Dispatch = cowboy_router:compile([
		{'_', [
			{"/", worker_spawner, []}
		]}
	]),
	{ok, _} = cowboy:start_http(http, 100, [{port, 8080}], [
		{env, [{dispatch, Dispatch}]}
	]),
	lager:info("gate: initiaized"),
	{ok,State}.



handle_call(_Request, _From, State) -> {reply, reply, State}.
handle_cast(_Msg, State) -> {noreply, State}.
handle_info(_Info, State) -> {noreply, State}.
terminate(_Reason, _State) -> ok.
code_change(_OldVsn, State, _Extra) -> {ok, State}.


