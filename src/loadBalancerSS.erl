-module(loadBalancerSS).
%% gen_server_mini_template
-behaviour(gen_server).
-compile([{parse_transform, lager_transform}]).
-export([start_link/1, giveSS/1, changeLBmethod/2, addServer/2, removeServer/2]).
%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
terminate/2, code_change/3]).


start_link(State) -> gen_server:start_link(?MODULE, State, []).

init(State) -> 
	process_flag(trap_exit, true),
	lager:info("loadBalancerSS~p: lbss for ~p~n",[self(),dict:fetch(serviceId,State)]),
	register(erlang:list_to_atom(dict:fetch(name, State)), self()),
	ServiceId = dict:fetch(serviceId, State),
	Number  = dict:fetch(servers, State),
	Queue = serversInit(Number, queue:new(), ServiceId),
	State2 = dict:store(ssList, Queue, State),
	State3 = dict:store(lbMethod, roundRobin, State2),
	{ok, State3}.

serversInit(Number, Queue, ServiceId) ->
	while_loop(Number, 0, Queue, ServiceId).

serversStop(Number, Queue, ServiceId) ->
	stop_loop(Number, 0, Queue, ServiceId).


while_loop(Number, Number, Queue, _ServiceId)-> Queue;
while_loop(Number, Var, Queue, ServiceId)->
	{ok, Pid} = ServiceId:init(),
	Queue2 = queue:in(Pid, Queue),
	while_loop(Number, Var+1, Queue2, ServiceId).


stop_loop(Number, Number, Queue, _ServiceId)-> Queue;
stop_loop(Number, Var, Queue, ServiceId)->
	{{value, Item},Queue2} = queue:out(Queue),
	exit(Item,ok),
	stop_loop(Number, Var+1, Queue2, ServiceId).



addServer(Pid, Number) -> gen_server:cast(Pid, {addServer, Number}).		
removeServer(Pid, Number) -> gen_server:cast(Pid, {removeServer, Number}).		

giveSS(Pid) ->
	gen_server:call(Pid,{giveSS}).


changeLBmethod(Pid, LBmethod) -> gen_server:cast(Pid, {changeLBmethod, LBmethod}).




handle_call({giveSS}, _From, State) ->
		
	SSList = dict:fetch(ssList, State),	
	LBmethod = dict:fetch(lbMethod, State),
	case LBmethod:selectServer(SSList) of
				{SSpid, SSList2} ->
					lager:info("lbss~p: selected ss is ~p~n",[self(), SSpid]),
					Reply = SSpid;
					
				{noServer} ->
					Reply = noServiceServer,
					SSList2 = SSList	
	end,
	St = dict:erase(ssList, State),
	State2 = dict:store(ssList, SSList2, St),
	{reply,Reply,State2};


handle_call(_Request, _From, State) -> {reply, reply, State}.

handle_cast({addServer, Number}, State) ->
	ServiceId = dict:fetch(serviceId, State),
	Queue = dict:fetch(ssList, State),
	Queue2 = serversInit(Number, Queue, ServiceId),
	State2 = dict:erase(ssList, State),
	State3 = dict:store(ssList, Queue2, State2),
	{noreply, State3};

handle_cast({removeServer, Number}, State) ->
	ServiceId = dict:fetch(serviceId, State),
	Queue = dict:fetch(ssList, State),
	Queue2 = serversStop(Number, Queue, ServiceId),
	State2 = dict:erase(ssList, State),
	State3 = dict:store(ssList, Queue2, State2),
	{noreply, State3};	

handle_cast({changeLBmethod, LBmethod}, State) ->
	State1 = dict:erase(lbMethod, State),
	State2 = dict:store(lbMethod, LBmethod, State1),
	lager:info("lbss~p: LB method changed to ~p",[self(), LBmethod]),
	{noreply, State2};


handle_cast(_Msg, State) -> {noreply, State}.
handle_info(_Info, State) -> {noreply, State}.
terminate(_Reason, _State) -> ok.
code_change(_OldVsn, State, _Extra) -> {ok, State}.




%% alt -> gate ako gen server tak ako mam teraz, alebo ako master app loop teda druhy uzol -> vetdy ale by nanho neboli nalinkovany WS
%% alt -> service servre bez sup? alebo s monitorom alebo urobit SSRoot -> vtedy by sa ale aspon ejden SS musel startovat uz pri zapnusti prvom