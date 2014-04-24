-module(wtimer).



-behaviour(gen_server).
-compile([{parse_transform, lager_transform}]).
-export([start_link/1,checkTime/1]).
%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
terminate/2, code_change/3]).
start_link(State) -> gen_server:start_link( ?MODULE, State, []).

init(State) -> 
	
	lager:info("timer: initialized ~p state ~p~n", [self(),State]),
	{ok, State}.

checkTime(Pid) -> gen_server:cast(Pid, time).

handle_call(_Request, _From, State) -> {reply, reply, State}.

handle_cast(time, State) ->
	Time = dict:fetch(time, State),
	receive
		Any -> Any
	after Time -> 
			%io:format("TIMER: stop~n"),
				gen_server:call(dict:fetch(parent,State),terminate)
	end,
	{noreply,State};	
handle_cast(_Msg, State) -> {noreply, State}.
handle_info(_Info, State) -> {noreply, State}.
terminate(_Reason, _State) -> ok.
code_change(_OldVsn, State, _Extra) -> {ok, State}.




