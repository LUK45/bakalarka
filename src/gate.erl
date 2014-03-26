-module(gate).
-behaviour(gen_server).
-compile([{parse_transform, lager_transform}]).
-export([init/1,handle_call/3, handle_cast/2, handle_info/2, terminate/2, 
		code_change/3]).

-export([start_link/0]).


start_link() -> 
	gen_server:start_link(?MODULE, [], []).


init([]) ->
	register(gate, self()),
	process_flag(trap_exit, true),
	St = dict:store(name, ws1, dict:new()),
	{ok,Pid} = worker_spawner:start_link(St),
	worker_spawner:spawnWorker(Pid, w1),

	St2 = dict:store(name, ws2, dict:new()),
	{ok,Pid2} = worker_spawner:start_link(St2),
	worker_spawner:spawnWorker(Pid2, w2),

	St3 = dict:store(name, ws3, dict:new()),
	{ok,Pid3} = worker_spawner:start_link(St3),
	worker_spawner:spawnWorker(Pid3, w3),

 	lager:info("gate~p: initialization",[self()]),
 	State = dict:new(),
 	{ok,State}.

handle_call(_Request, _From, State) -> {reply, reply, State}.


handle_cast(_Msg, State) -> {noreply, State}.

handle_info(Msg, State) -> 
	lager:warning("gate: unknown message ~p som ~p~n",[Msg,self()]),		
	{noreply, State}.

terminate(Reason, _State) -> 
 lager:error("lbsr~p: stopping reason ~p~n",[self(),Reason]),
 case inets:stop() of 
	{error,{not_started,inets}} -> not_running;
	ok -> ok
 end.

code_change(_OldVsn, State, _Extra) -> {ok, State}.



