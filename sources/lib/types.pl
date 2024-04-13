
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
 	
