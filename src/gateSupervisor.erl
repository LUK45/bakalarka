-module(gateSupervisor).
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->
    supervisor:start_link(?MODULE, []).

init([]) ->
	register(gateSup, self()),
    {ok, {{one_for_one, 1, 60},
         [{gate,
           {gate, start_link, [[trans,req]]},
           permanent, 1000, worker, [gate]}
         ]}}.
