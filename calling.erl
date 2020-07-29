-module(calling).
-export([fetchData/3]).

fetchData(ProcessID, Sender, Receivers) ->
	sendData(ProcessID, Sender, Receivers).

sendData(ProcessID, Sender, Receivers) ->
	ProcessID ! {self(), register, Sender},
	startSendingMessages(ProcessID, Sender, Receivers).

sleepNow() ->
	timer:sleep(50 + rand:uniform(50)).

startSendingMessages(ProcessID, Sender, Receivers) ->
	sleepNow(),
	[Head | Tail] = Receivers,
	ProcessID ! {self(), intro, Sender, Head, "intro"},
    startComm(ProcessID, Sender),
	if(length(Tail) == 0) -> startCommEmpty(ProcessID, Sender);
	  true -> startSendingMessages(ProcessID, Sender, Tail)
	end.
	

startComm(ProcessID, Sender) ->
	receive
        {intro, Name, _} -> ProcessID ! {self(), reply, Sender, Name, "reply"};
        {reply, _, _} ->  ok
    after 5000 -> ProcessID ! {self(), time, Sender},
            exit(time)
    end.

startCommEmpty(ProcessID, Sender) ->
	receive
        {intro, Name, _} -> ProcessID ! {self(), reply, Sender, Name, "reply"},
            startCommEmpty(ProcessID,Sender);
        {reply, _, _} -> startCommEmpty(ProcessID,Sender)
    after 5000 ->
            ProcessID ! {self(), time, Sender},
            exit(time)
    end.