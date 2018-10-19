%% Test setup for issue 7. See https://github.com/Eonblast/Emysql/issues/7 
%% Use it to kill and restart the mysql server underneath and see what happens. 
%% To use this script, move this file to Emysql root, build Emysql, and do:
%% $ erlc issue7.erl && erl -pa ./ebin -s issue7 run -s init stop -noshell

-module(issue7).
-export([run/0,do/0]).

run() ->

		crypto:start(),
		application:start(emysql),

		emysql:add_pool(hello_pool, 1,
			"hello_username", "hello_password", "localhost", 3306,
			"hello_database", utf8),

		Pid = spawn(?MODULE, do, []),
		
		Mref = erlang:monitor(process, Pid),
		wait(Pid, Mref).
		
do() ->
		log4erl:debug("enter do~n"),

		log4erl:debug("delete do~n"),

		emysql:execute(hello_pool,
    		<<"delete from hello_table">>),

		log4erl:debug("insert do~n"),
    		
		emysql:execute(hello_pool,
			<<"INSERT INTO hello_table SET hello_text = 'Hello World!'">>),

	    Result = emysql:execute(hello_pool,
    		<<"select hello_text from hello_table">>),

		log4erl:debug("Result ~n~p~n", [Result]),

		receive after 10000 -> nil end,
		
		do().
		
wait(Pid, Mref) ->

		case is_process_alive(Pid) of
			true ->
				log4erl:debug("~p is alive~n", [Pid]),
				receive after 1000 -> nil end,
				wait(Pid, Mref);
			_ ->
				log4erl:debug("~p is gone, new spawn: ", [Pid]),
				NewPid = spawn(?MODULE, do, []),
				NewMref = erlang:monitor(process, NewPid),
				log4erl:debug("~p~n", [NewPid]),
				wait(NewPid, NewMref)
		end.