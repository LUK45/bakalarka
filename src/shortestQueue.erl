-module(shortestQueue).

-behaviour(loadBalancerBehaviour).
-compile([{parse_transform, lager_transform}]).
-export([selectServer/1]).

%%%%% shortest message queue
selectServer(Q) ->
			
			L = queue:to_list(Q),
			Members1 = lists:map(fun(Pid) ->
      			[{message_queue_len, Messages}] = erlang:process_info(Pid, [message_queue_len]),
      			{Pid, Messages} 
      		end, L),
  			case lists:keysort(2, Members1) of
    			[{Pid, _} | _] -> {Pid,Q};
    			[] -> noServer	

		end.

