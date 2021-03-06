-module(worker).
-behaviour(gen_server).
-compile([{parse_transform, lager_transform}]).
-export([init/1,handle_call/3, handle_cast/2, handle_info/2, terminate/2, 
		code_change/3]).

-export([start_link/1,find_LbSs/2, generatePage/2, stop/1]).


start_link(Dict) -> 
	gen_server:start_link(?MODULE, Dict, []).




init(Req) -> 
	lager:info("worker~p: ~p~n",[self(),Req]),
	%Dict = dict:store(parent, self(), dict:new()),
	%Dict2 = dict:store(time, dict:fetch(time,State), Dict),
	%{ok, Timer} = wtimer:start_link(Dict2),
	%wtimer:checkTime(Timer),
	State = dict:store(request, Req, dict:new()),
	State2 = dict:store(done, no, State),

	{ok, State2}.



find_LbSs(Pid,ServiceId) -> 
	%io:format("worker ~p~n",[self()]),
	gen_server:cast(Pid, {find_LbSs, ServiceId}).

generatePage(Pid, ServiceId) -> gen_server:call(Pid, {generatePage, ServiceId}).	

stop(Pid) -> gen_server:cast(Pid, terminate).

handle_call({generatePage, ServiceId}, _From,  State) ->
	%Req= dict:fetch(request, State),
	%io:format("WORKER: ~p~n",[Req]),
	Lbsr = whereis(lbsr),
	if
		 Lbsr =:= undefined->
			State3 = State,
			Response = noLbSr;
		 true ->
			LbSs = loadBalancerSR:find_LbSs(lbsr,ServiceId,self()),
			if
				LbSs =:= noServiceRegister ->
					State3 = State,
					Response = noServiceRegister;
				true ->
					ServiceServer = loadBalancerSS:giveSS(LbSs),
					%io:format("WORKER: gouing build repsone~n"),
					if
						ServiceServer =:= noServiceServer ->
							State3 = State,
							Response = noServiceServer;
						true ->
							Response = serviceServer:generatePage(ServiceServer),
							State2 = dict:erase(done,State),
							State3 = dict:store(done, yes, State2)
			
					end
			end
	end,		
	
	{reply, Response, State3};

handle_call(_Request, _From, State) -> {reply, reply, State}.


handle_cast({find_LbSs, ServiceId},  State) -> 
	%io:format("worker~p: vyziadam si od sr cez lbsr lbss pre service id ~p f**~p~n", [self(),ServiceId,State]),
	
	Reply = loadBalancerSR:find_LbSs(lbsr,ServiceId,self()),
	lager:info("worker~p: reply = ~p~n",[self(),Reply]),
	{noreply,   State};	

handle_cast(terminate, State) ->
	{stop, normal, State};

handle_cast(_Msg, State) -> {noreply, State}.

handle_info(Msg, State) -> 
	lager:warning("worker: unknown message ~p som ~p~n",[Msg,self()]),		
	{noreply, State}.

terminate(normal, _State) -> ok;

terminate(Reason, State) -> 
	lager:info("Worker~p: terminating for reason ~p~n",[self(),Reason]),
	Req= dict:fetch(request, State),
	{ok, _Req2} = cowboy_req:reply(404, [
		{<<"content-type">>, <<"text/plain">>}
		], <<"Unexpected error Worker, try again\n">>, Req).


code_change(_OldVsn, State, _Extra) -> {ok, State}.