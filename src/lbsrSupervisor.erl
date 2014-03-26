-module(lbsrSupervisor).
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->
    supervisor:start_link(?MODULE, []).

init([]) ->
	register(erlang:list_to_atom( "lbsrSup"), self()),
    {ok, {{one_for_one, 3, 60},
         [{loadBalancerSR,
           {loadBalancerSR, start_link, []},
           permanent, 1000, worker, [loadBalancerSR]}
         ]}}.
