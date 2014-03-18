-module(loadBalancerSRMonitor).

-compile(export_all).

%%% monitor pre lbsr

%% spawne monitor, referenciu vratim service registru
start(LbsrID) ->
	{MonitorPid, MonitorRef} = erlang:spawn_monitor(?MODULE, init, [LbsrID]),
	io:format("lbsrMonitor:  ref for lbsr: ~p monitorujem ~p ~n",[MonitorRef,MonitorPid]),
	MonitorRef.

init(LbsrID) -> 
	Ref = monitor(process,LbsrID),
	io:format("lbsrMonitor: my ref ~p monitorujem ~p moje id ~p~n",[Ref,LbsrID, self()]),
	loop(Ref).

loop(Ref) -> 
	receive

		%%padol lbsr
		{'DOWN',Ref, process, LbsrID, Why} ->
			io:format("lbsrMonitor: padol lbsr ~p dovod ~p , restartujem~n",[LbsrID,Why]),
			register(lbsr, spawn(fun() -> loadBalancerSR:start(null) end));

		Any -> Any	

	end.		 	