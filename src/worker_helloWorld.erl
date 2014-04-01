-module(worker_helloWorld).

-compile([{parse_transform, lager_transform}]).

-export([start_link/1, buildResponse/2]).


start_link(State) -> 
	lager:info("worker_helloWorld0~p: ~p~n",[self(),State]),
	%wtimer:start_link(self()),
	Dict = dict:store(request, State, dict:new()),
	{ok,WorkerPid} = worker:start_link(Dict),
	buildResponse(State,WorkerPid),
	{ok, State}.





buildResponse(_State, WorkerPid) ->
	%_Req = dict:fetch(request, State),

	worker:generatePage(WorkerPid,helloWorld).	



