-module(workerSpawnerSupervisor).

-behaviour(supervisor).

-export([start_link/1]).
-export([init/1]).

start_link(St) ->
    supervisor:start_link(?MODULE, St).

init(St) ->
	%register(rootWs, self()),
	WState = dict:store(myWorker, null,St),
	
	%%register(rootLB,self()),
    {ok, {{one_for_one, 3, 60},
         [{worker_spawner,
           {worker_spawner, start_link, [WState]},
           permanent, 1000, worker, [worker_spawner]}	
         ]}}.

