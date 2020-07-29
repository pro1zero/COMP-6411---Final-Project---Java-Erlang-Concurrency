-module(exchange).
-export([start/0]).

loadData() ->
	{ok, Data} = file:consult("calls.txt"),
	Data.

printMessage() ->
	io:fwrite("** Calls to be made **\n").

printData([]) -> ok;
printData(Data) ->
	[Head | Tail] = Data,
	{Sender, Receivers} = Head,
	io:fwrite("~s: ~p\n", [Sender, Receivers]),
	printData(Tail).

spawnProcesses([]) -> ok;
spawnProcesses(Data) ->
	[Head | Tail] = Data,
	{Sender, Receivers} = Head,
	spawn(calling, fetchData, [self(), Sender, Receivers]),
	spawnProcesses(Tail).

start() ->
	Data = loadData(),
	printMessage(),
	printData(Data),
	spawnProcesses(Data),
	CurrentQueue = [],
	mainTransfers(CurrentQueue).

mainTransfers(CurrentQueue) ->
		receive
        {ProcessIdentifier, register, Sender} ->
            case lists:keymember(Sender, 2, CurrentQueue) of
                true ->
                    mainTransfers(CurrentQueue);
                false ->
                    mainTransfers([{ProcessIdentifier, Sender} | CurrentQueue])
            end;
        {_, time, Sender} ->
            io:fwrite("\nProcess ~s has received no calls for 5 second, ending...\n", [Sender]),
            mainTransfers(CurrentQueue);
        {ProcessIdentifier, intro, SendingProcess, ReceivingProcess, Message} ->
            communication(intro, ProcessIdentifier, SendingProcess, ReceivingProcess, Message, CurrentQueue),
            TimeStamp = 700000 + rand:uniform(100000),
            io:fwrite("\n~s received intro message from ~s [~p]", [ReceivingProcess, SendingProcess, TimeStamp]),		
            mainTransfers(CurrentQueue);
        {ProcessIdentifier, reply, SendingProcess, ReceivingProcess, Message} ->
            communication(reply, ProcessIdentifier, SendingProcess, ReceivingProcess, Message, CurrentQueue),
            TimeStamp = 700000 + rand:uniform(100000),
            io:fwrite("\n~s received reply message from ~s [~p]", [ReceivingProcess, SendingProcess, TimeStamp]),
            mainTransfers(CurrentQueue)
    after 7000 ->
            io:fwrite("\nMaster has received no replies for 10 seconds, ending...\n", [])
    end.

communication(Operation, _, SendingProcess, ReceivingProcess, Message, CurrentQueue) ->
    case lists:keysearch(SendingProcess, 2, CurrentQueue) of
        false -> ok;
        {value, {ProcessIdentifier, Sender}} ->
            subCommunication(Operation, ProcessIdentifier, Sender, ReceivingProcess, Message, CurrentQueue, CurrentQueue)
    end.

subCommunication(Operation, _, Sender, ReceivingProcess, Message, CurrentQueue, CurrentQueue) ->
    case lists:keysearch(ReceivingProcess, 2, CurrentQueue) of
        false -> ok;
        {value, {ProcessID, ReceivingProcess}} ->
            ProcessID ! {Operation, Sender, Message}
    end.