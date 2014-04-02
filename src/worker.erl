-module(worker).
-behaviour(gen_server).
-compile([{parse_transform, lager_transform}]).
-export([init/1,handle_call/3, handle_cast/2, handle_info/2, terminate/2, 
		code_change/3]).

-export([start_link/1,find_LbSs/2, generatePage/2, timesout/1]).


start_link(Dict) -> 
	gen_server:start_link(?MODULE, Dict, []).




init(State) -> 
	lager:info("worker~p: ~p~n",[self(),State]),
	%wtimer:start(self(), dict:fetch(time,State)),

	%wtimer:start_link(self()),
	{ok, State}.



find_LbSs(Pid,ServiceId) -> 
	%io:format("worker ~p~n",[self()]),
	gen_server:cast(Pid, {find_LbSs, ServiceId}).

generatePage(Pid, ServiceId) -> gen_server:call(Pid, {generatePage, ServiceId}).	
timesout(Pid) -> gen_server:cast(Pid, terminate).

handle_call({generatePage, ServiceId}, _From,  State) ->
	Req= dict:fetch(request, State),
	%io:format("WORKER: ~p~n",[Req]),
	LbSs = loadBalancerSR:find_LbSs(lbsr,ServiceId,self()),
	ServiceServer = loadBalancerSS:giveSS(LbSs),
	io:format("WORKER: gouing build repsone~n"),
	Response = serviceServer:generatePage(ServiceServer,Req),
	io:format("WORKER: REsponse ~p~n",[Response]),
	{reply, Response, State};

handle_call(_Request, _From, State) -> {reply, reply, State}.


handle_cast(terminate, State)->
	lager:info("Worker~p: terminating~n",[self()]),
	Req= dict:fetch(request, State),
	{ok, _Req2} = cowboy_req:reply(404, [
			{<<"content-type">>, <<"text/plain">>}
			], <<"Unexpected error, try again\n">>, Req);


handle_cast({find_LbSs, ServiceId},  State) -> 
	%io:format("worker~p: vyziadam si od sr cez lbsr lbss pre service id ~p f**~p~n", [self(),ServiceId,State]),
	
	Reply = loadBalancerSR:find_LbSs(lbsr,ServiceId,self()),
	lager:info("worker~p: reply = ~p~n",[self(),Reply]),
	{noreply,   State};	


handle_cast(_Msg, State) -> {noreply, State}.

handle_info(Msg, State) -> 
	lager:warning("worker: unknown message ~p som ~p~n",[Msg,self()]),		
	{noreply, State}.

terminate(_Reason, _State) -> ok.
code_change(_OldVsn, State, _Extra) -> {ok, State}.