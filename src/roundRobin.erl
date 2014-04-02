-module(roundRobin).
-behaviour(loadBalancerBehaviour).
-compile([{parse_transform, lager_transform}]).
-export([selectServer/1]).

%%%%% round robin -> pride list moznych serverov ktore sa tocia do kruhu
selectServer(Q) ->
	%	io:format("loadBalancerRoundRobin: selectServer~n"),
		case queue:is_empty(Q) of
			false ->
				Result = queue:get(Q),
				NewQ = queue:in(Result,queue:drop(Q)),
				{Result,NewQ};
			true ->
				%io:format("loadBalancerRoundRobin: selectServer -> no server ~n"),
				lager:error("loadBalancerRoundRobin~p: no server to select",[self()]),
				noServer	

		end.

