-module(serviceBehaviour).

-export([behaviour_info/1]).

behaviour_info(callbacks) ->
	[{init,1},{ generatePage,0}].