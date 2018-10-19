% ------------------------------------------------------------------------
% Emysql: sample for accessing rows as records
% H. Diedrich <hd2010@eonblast.com> - Eonblast http://www.eonblast.com
% 12 Jun 2010
% ------------------------------------------------------------------------
%
% This sample does the same as the previous samples but uses a record
% to access the result row.
%
% ------------------------------------------------------------------------
%
% Create local mysql database (or re-use the one made for a_hello):
%
% $ mysql ...
% mysql> create database hello_database;
% mysql> use hello_database;
% mysql> create table hello_table (hello_text char(20));
% mysql> grant all privileges on hello_database.* to hello_username@localhost identified by 'hello_password';
% mysql> quit
%
% On *nix build and run using the batch a_hello in folder samples/:
%
% $ ./c_rows_as_records
%
% - or - 
%
% Make emysql and start this sample directly, along these lines:
%
% $ cd Emysql
% $ make
% $ cd samples
% $ erlc c_rows_as_records.erl
% $ erl -pa ../ebin -s c_rows_as_records run -s init stop -noshell
%
% ------------------------------------------------------------------------
%
% Expected Output:
%
% ...
% ... many PROGRESS REPORT lines ...
% ...
%
% Record: <<"Hello World!">>
%
% ------------------------------------------------------------------------

-module(c_rows_as_records).
-export([run/0]).

%% -----------------------------------------------------------------------
%% Record Definition:                                                    1
%% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

-record(hello_record, {hello_text}).

%% -----------------------------------------------------------------------


run() ->

	application:start(sasl),
	crypto:start(),
	application:start(emysql),

	emysql:add_pool(hello_pool, [{size,1},
				     {user,"hello_username"},
				     {password,"hello_password"},
				     {database,"hello_database"},
				     {encoding,utf8}]),

	emysql:execute(hello_pool,
		<<"INSERT INTO hello_table SET hello_text = 'Hello World!'">>),

	Result = emysql:execute(hello_pool, <<"SELECT * from hello_table">>),

	%% ------------------------------------------------------------------- 
	%% Records Fetch:                                                    2
	%% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

	Recs = emysql_util:as_record(
		Result, hello_record, record_info(fields, hello_record)),

	%% -------------------------------------------------------------------

	log4erl:debug("~n~s~n", [string:chars($-,72)]),

	%% -------------------------------------------------------------------
	%% Records Use:                                                      3
	%% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

	[begin
      log4erl:debug("Record: ~p~n", [Rec#hello_record.hello_text])
    end || Rec <- Recs],
    
	%% -------------------------------------------------------------------

    ok.

