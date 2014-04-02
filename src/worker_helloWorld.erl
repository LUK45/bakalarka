-module(worker_helloWorld).

-compile([{parse_transform, lager_transform}]).

-export([start_link/1, buildResponse/2]).


start_link(State) -> 
	lager:info("worker_helloWorld0~p: ~p~n",[self(),State]),
	%wtimer:start_link(self()),
	Dict = dict:store(request, State, dict:new()),
	Dict2 = dict:store(time, 20000, Dict),
	{ok,WorkerPid} = worker:start_link(Dict2),
	buildResponse(State,WorkerPid),
	{ok, State}.





buildResponse(State, WorkerPid) ->
	%_Req = dict:fetch(request, State),

	Page = worker:generatePage(WorkerPid,helloWorld),
	Page2 = worker:generatePage(WorkerPid, datetime),
	Result = string:concat(Page,Page2),
	cowboy_req:reply(200,[
    {<<"content-type">>, <<"text/plain">>}
	],Result,State). 



