-module(worker_helloWorld).

-behaviour(workerBehaviour).
-compile([{parse_transform, lager_transform}]).

-export([start_link/1, buildResponse/2]).


start_link(Req) -> 
	lager:info("worker_helloWorld0~p: ~p~n",[self(),Req]),
	%wtimer:start_link(self()),
	{ok,WorkerPid} = worker:start_link(Req),
	buildResponse(Req,WorkerPid),
	ok.





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

		Value3 = worker:generatePage(WorkerPid, lorem),
		case Value3 of
			{ok,Page3} ->
				Fault3 = 0,
				Result3 = Page3;
			_Error3 ->
				Fault3  = 1,
				Result3	= ""
		end,
			worker:stop(WorkerPid),

		Fault = Fault1+Fault2+Fault3,
		case Fault of
			3 ->
				cowboy_req:reply(404, [
				{<<"content-type">>, <<"text/plain">>}
				], <<"Unexpected error, try again\n">>, Req),
				lager:error("Page: unexpected error");		
			
			_ ->
				Res = string:concat(Result1,Result2),
				Result = string:concat(Res, Result3),
				cowboy_req:reply(200,[
    				{<<"content-type">>, <<"text/plain">>}
					],Result,Req),
				lager:info("Page - OK")	 
				

		
		end.

		

