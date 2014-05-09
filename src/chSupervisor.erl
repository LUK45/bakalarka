-module(chSupervisor).
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->
    supervisor:start_link(?MODULE, []).

init([]) ->
	register(chSup, self()),
    {ok, {{one_for_one, 3, 60},
         [{cache_handler,
           {cache_handler, start_link, [[trans,req]]},
           permanent, 1000, worker, [cache_handler]}
         ]}}.
