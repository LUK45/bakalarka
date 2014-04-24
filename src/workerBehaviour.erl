-module(workerBehaviour).

-export([behaviour_info/1]).

behaviour_info(callbacks) ->
	[{start_link,1}].