-module(rootSrSupervisor).

-behaviour(supervisor).


-export([start_link/1,  init/1]).



start_link({Type,Name}) ->
	supervisor:start_link(?MODULE, {Type,Name}).




init({Type,Name}) ->
	Dict = dict:store(mode, Type, dict:new()),
	if
		Type =:= master ->
			register(rootSr, self()),
			Dict2 = dict:store(name, "sr", Dict);
		true ->
			Dict2 = Dict
	end,

	{ok, {{one_for_one, 3, 60},
         [{Name,
           {serviceRegisterSupervisor, start_link, [Dict2]},
           permanent, 1000, supervisor, [serviceRegisterSupervisor]}	
         ]}}.




