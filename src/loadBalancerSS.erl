-module(loadBalancerSS).
%% gen_server_mini_template
-behaviour(gen_server).
-compile([{parse_transform, lager_transform}]).
-export([start_link/1, giveSS/1]).
%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
terminate/2, code_change/3]).


start_link(State) -> gen_server:start_link(?MODULE, State, []).

init(State) -> 
	process_flag(trap_exit, true),
	lager:info("loadBalancerSS~p: lbss for ~p~n",[self(),dict:fetch(serviceId,State)]),
	register(erlang:list_to_atom(dict:fetch(name, State)), self()),
	ServiceId = dict:fetch(serviceId, State),
	{ok, Pid1} = ServiceId:init(),
	Q = queue:in(Pid1, queue:new()),
	{ok, Pid2} = ServiceId:init(),
	Queue = queue:in(Pid2, Q),
	State2 = dict:store(ssList, Queue, State),
	{ok, State2}.


giveSS(Pid) ->
	gen_server:call(Pid,{giveSS}).



handle_call({giveSS}, _From, State) ->
		
	SSList = dict:fetch(ssList, State),	
	case loadBalancerRoundRobin:selectServer(SSList) of
				{SSpid, SSList2} ->
					%io:format("lbsr~p: give dict ~p~n",[self(), SRpid]),
					%lager:info("lbsr~p: selected sr is ~p~n",[self(), SRpid]),
					lager:info("lbss~p: selected sr is ~p~n",[self(), SSpid]),
					Reply = SSpid;
					
				{noServer} ->
					Reply = noServiceServer,
					SSList2 = SSList	
	end,
	St = dict:erase(ssList, State),
	State2 = dict:store(ssList, SSList2, St),
	{reply,Reply,State2};


handle_call(_Request, _From, State) -> {reply, reply, State}.
handle_cast(_Msg, State) -> {noreply, State}.
handle_info(_Info, State) -> {noreply, State}.
terminate(_Reason, _State) -> ok.
code_change(_OldVsn, State, _Extra) -> {ok, State}.




%% alt -> gate ako gen server tak ako mam teraz, alebo ako master app loop teda druhy uzol -> vetdy ale by nanho neboli nalinkovany WS
%% alt -> service servre bez sup? alebo s monitorom alebo urobit SSRoot -> vtedy by sa ale aspon ejden SS musel startovat uz pri zapnusti prvom