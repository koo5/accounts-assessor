:- if(\+getenv('SWIPL_NODEBUG', true)).
	:- format(user_error, 'SWIPL_NODEBUG off~n', []).
	:- debug.
:- else.
	:- format(user_error, 'SWIPL_NODEBUG on~n', []).
:- endif.


:- initialization(init_guitracer).

 init_guitracer :-
	(	env_bool('GTRACE_ON_OWN_EXCEPTIONS', true)
	->	guitracer
	;	true).


:- use_module(library(http/json)).
:- use_module('chat', []).
:- use_module(library(prolog_stack)).

:- ['lib'].

:- misc_check(env_bool('PYTHONUNBUFFERED', true)).


/* read command from stdin */
process_request_rpc_cmdline :-
	json_read_dict(user_input, Dict),
	process_request_rpc_cmdline1(Dict).

/* or get command as a parameter of goal */
process_request_rpc_cmdline_json_text(String) :-
	string_to_json_dict(String, Dict),
	process_request_rpc_cmdline2(Dict).

/* process request, print error to stdout, reraise */
process_request_rpc_cmdline1(Dict) :-
	catch_with_backtrace(
		(
			process_request_rpc_cmdline2(Dict)
		),
		E,
		(nl,nl,writeq(E),nl,nl,throw(E))
	).



process_request_rpc_cmdline2(Dict) :-
	%profile(
	process_request_rpc_cmdline3(Dict.method, Dict.params),
	%[]),gtrace,
	flush_output.





process_request_rpc_cmdline3("calculator", Dict) :-
	!,
	!process_request_rpc_calculator(Dict).

process_request_rpc_cmdline3("chat", Dict) :-
	!,
	!(chat:do_chat(Dict, Response)),
	json_write(current_output, Response).



process_request_rpc_cmdline3(_,_) :-
	json_write(current_output, response{status:error, message:unknown_method}).

