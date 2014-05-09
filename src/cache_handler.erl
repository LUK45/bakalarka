-module(cache_handler).
-behaviour(gen_server).
-compile([{parse_transform, lager_transform}]).
-export([start_link/1, start/0, stop/0, store/4, find/3, delete/3, newTable/2, deleteTable/2]).
%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
terminate/2, code_change/3]).
start_link(State) -> gen_server:start_link( ?MODULE, State, []).

init(State) -> 

	lager:info("cache_handler: initialized ~p state ~p~n", [self(),State]),
	register(ch, self()),
	ets:new(cache, [set, named_table]),
	{ok, State}.



start() -> {ok, _Pid} = supervisor:start_child(root, {chSup,{chSupervisor, start_link, []}, permanent, 1000, supervisor, [chSupervisor]} ),
			ok.

stop() -> 	supervisor:terminate_child(root, chSup),
	    	supervisor:delete_child(root, chSup),
	    	ok.			

store(Pid, Key, Value, Table) -> gen_server:call(Pid, {store, Key, Value, Table}).
find(Pid, Key, Table) -> gen_server:call(Pid, {find, Key, Table}).
delete(Pid,Key, Table) -> gen_server:call(Pid, {delete, Key, Table}).			
newTable(Pid, TableName) -> gen_server:call(Pid, {newTable, TableName}).
deleteTable(Pid, TableName) -> 	gen_server:call(Pid, {deleteTable, TableName}).	




handle_call({store, Key, Value, Table}, _From, State) ->
	Info = ets:info(Table),
	case Info of
		undefined ->
			Reply = noSuchTable;
		_I  ->
			ets:insert(Table, {Key, Value}),
			Reply = ok
	end,
	
	{reply, Reply, State};

handle_call({delete, Key, Table},_From, State) ->
	Info = ets:info(Table),
	case Info of
		undefined ->
			Reply = noSuchTable;
		_I  ->
			ets:delete(Table, Key),
			Reply = ok
	end,
	
	
	{reply, Reply, State};
	
	

handle_call({newTable, Name} , _From,State) ->
	ets:new(Name, [set, named_table]),
	Reply = ok,
	
	{reply, Reply, State};
	


handle_call({deleteTable, Table},_From, State) ->
	Info = ets:info(Table),
	case Info of
		undefined ->
			Reply = noSuchTable;
		_I  ->
			ets:delete(Table),
			Reply = ok
	end,
	
	{reply, Reply, State};
	
handle_call({find, Key, Table}, _From, State) -> 
	Info = ets:info(Table),
	case Info of
		undefined ->
			Reply = noSuchTable;
		_I  ->
			Reply = ets:lookup(Table, Key)
	end,
	{reply, Reply, State};

handle_call(_Request, _From, State) -> {reply, reply, State}.



handle_cast(_Msg, State) -> {noreply, State}.
handle_info(_Info, State) -> {noreply, State}.
terminate(_Reason, _State) -> ok.
code_change(_OldVsn, State, _Extra) -> {ok, State}.
