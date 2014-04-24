-module(serviceServer).
%% gen_server_mini_template
-behaviour(gen_server).
%-compile([{parse_transform, lager_transform}]).
-export([start_link/1,generatePage/1]).
%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
terminate/2, code_change/3]).
start_link(State) -> gen_server:start_link( ?MODULE, State, []).

init(State) -> 

%	lager:info("serviceServer: initialized ~p state ~p~n", [self(),State]),
	LbSs = dict:fetch(lbss, State),
	loadBalancerSS:serverToQueue(LbSs, self()),
	{ok, State}.

generatePage(Pid) -> gen_server:call(Pid, {generatePage}).


handle_call({generatePage}, _From, State) ->
%	lager:info("SS ~p: handling call ~p~n",[self(),State]),
	Parent = dict:fetch(parent,State),
	Reply = Parent:generatePage(),
	{reply, Reply, State};

handle_call(_Request, _From, State) -> {reply, reply, State}.
handle_cast(_Msg, State) -> {noreply, State}.
handle_info(_Info, State) -> {noreply, State}.
terminate(_Reason, _State) -> ok.
code_change(_OldVsn, State, _Extra) -> {ok, State}.
