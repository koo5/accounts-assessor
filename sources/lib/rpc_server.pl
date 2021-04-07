:- use_module(library(http/json)).
:- use_module('residency', []).
:- use_module('sbe', []).
%:- use_module(library(prolog_stack)).

:- ['lib'].

:-set_prolog_flag(stack_limit, 20 000 000 000).
:- (have_display -> guitracer ; true).


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

/* dispatch request on method */
process_request_rpc_cmdline2(Dict) :-
	(	Dict.method == "calculator"
	->	process_request_rpc_calculator(Dict.params)
	;	(
			(	Dict.method == "chat"
			->	(
					do_chat(Dict, Response),
					json_write(current_output, Response)
				)
			;	json_write(current_output, e{error:m{message:unknown_method}})
			)
		)
	),
	flush_output.

do_chat(Dict, Response) :-
	(	Type = Dict.params.get(type)
	->
		(	Type == "sbe"
		->	sbe:sbe_step(Dict.params, Result)
		;
			(	Type == "residency"
			->	residency:residency_step(Dict.params, Result)
			;	Response = e{error: m{message:"unknown chat type"}})
		)
	;	Response = e{error: m{message:'specify type: "sbe" or "residency"'}}
	),
	(	var(Response)
	->	Response = r{result:Result}
	;	true).

/*

python-prolog interop:

	"vec_add(Old, Vector, New)" could be invoked through python<->prolog rpc like this: "['!','vec_add', 'uri', 'uri', 'uri']",
	prolog would then =.. and call it in a findall. Python side would only have to check if number of results isn't 0, then take the first result. It would then do more calls, ie doc_list_member, coord_unit etc. Everything would live in prolog doc db.

*/
