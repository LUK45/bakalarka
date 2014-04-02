-module(worker_helloWorld).

-compile([{parse_transform, lager_transform}]).

-export([start_link/1, buildResponse/2]).


start_link(Req) -> 
	lager:info("worker_helloWorld0~p: ~p~n",[self(),Req]),
	%wtimer:start_link(self()),
	Dict = dict:store(request, Req, dict:new()),
	Dict2 = dict:store(time, 1000, Dict),
	{ok,WorkerPid} = worker:start_link(Dict2),
	buildResponse(Req,WorkerPid),
	{ok, Req}.





buildResponse(Req, WorkerPid) ->
	%_Req = dict:fetch(request, State),

	
		Value = worker:generatePage(WorkerPid,helloWorld),
		case Value of
			{ok,Page} ->
				Fault1 = 0,
				Result1 = Page;
			_Error ->
				Fault1 = 1,
				Result1	= ""
		end,

		Value2 = worker:generatePage(WorkerPid, datetime),
		case Value2 of
			{ok,Page2} ->
				Fault2 = 0,
				Result2 = Page2;
			_Error2 ->
				Fault2  = 1,
				Result2	= ""
		end,

		Fault = Fault1+Fault2,
		case Fault of
			2 ->
				cowboy_req:reply(404, [
				{<<"content-type">>, <<"text/plain">>}
				], <<"Unexpected error, try again\n">>, Req);
			
			_ ->
				Result = string:concat(Result1,Result2),
				cowboy_req:reply(200,[
    				{<<"content-type">>, <<"text/plain">>}
					],Result,Req) 
				
		
		end.
		

