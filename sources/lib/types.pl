
 t(X,Y) :-
	doc(X, 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type', Y).


 doc_new_uri(Uri) :-
	doc_new_uri('', Uri).

 doc_new_uri(Postfix, Uri) :-
	result_data_uri_base(Result_data_uri_base),
	/* fixme, use something deterministic */
	gensym('x', Uri0),
	(	Postfix = ''
	->	atomic_list_concat([Result_data_uri_base, Uri0], Uri)
	;	atomic_list_concat([Result_data_uri_base, Uri0, '_', Postfix], Uri)).

% note: uniqueness is not checked, we rely on having control of the namespace
 bn(Postfix, Uri) :-
	doc_new_uri(Postfix, Uri).



 doc_new_(Type, Uri) :-
	doc_new_uri(Uri),
	doc_add(Uri, rdf:type, Type).

 doc_new_theory(T) :-
	doc_new_uri(T),
	doc_add(T, rdf:type, l:theory).




 doc_new_vec(List, Uri) :-
 	doc_new_uri(vec, Uri),
 	doc_add(Uri, rdf:type, 'https://rdf.lodgeit.net.au/v1/request#vec'),
 	assertion(is_list(List)),
 	assertion(maplist(coord_or_value_unit, List, _)),
 	doc_add(Uri, rdf:value, List).
 	



 result_accounts(As) :-
	result(D),
	!doc(D, l:account_hierarchy, As).

 request_data_property(P, O) :-
	request_data(Request_Data),
	doc(Request_Data, P, O).

 report_details_property_value(P, V) :-
	!report_details(Details),
	doc_value(Details, P, V).

 rp(P, O) :-
 	result_property(P, O).

 result_property(P, O) :-
	result(R),
	doc(R, P, O).

 result_add_property(P, O) :-
	doc_default_graph(G),
	result_add_property(P, O, G).

 result_add_property(P, O, G) :-
	result(R),
	doc_add(R, P, O, G).

 result_assert_property(P, O) :-
	doc_default_graph(G),
	result_assert_property(P, O, G).

 result_assert_property(P, O, G) :-
	result(R),
	doc_assert(R, P, O, G).




:- table request/1.
 request(R) :-
	doc(R, rdf:type, l:'Request').

:- table result/1.
 result(R) :-
	!doc(R, rdf:type, l:'Result').
 	%format(user_error, 'result(R): ~q~n', [R]).

:- table request_data/1.
 request_data(D) :-
	!request(Request),
	!doc(Request, l:has_request_data, D).

:- table result_data_uri_base/1.
 result_data_uri_base(B) :-
 	rp(l:result_data_uri_base, B).




 add_result_sheets_report(Graph) :-
	save_doc_graph_as_report(Graph, result_sheets).


