/*
mock_request :-
	doc_init.
*/
make_fact(Vec, Aspects, Uri) :-
	doc_new_uri(fact, Uri),
	doc_add(Uri, rdf:type, l:fact),
	doc_add(Uri, l:vec, $>flatten([Vec])),
	doc_add(Uri, l:aspects, Aspects).

make_fact(Vec, Aspects) :-
	make_fact(Vec, Aspects, _).

fact_vec(Uri, X) :-
	doc(Uri, l:vec, X).



/*
find all facts with matching aspects
for a fact to match, it has to have all the aspects present in Aspects, and they have to unify.
rest of aspects of the fact are ignored. All matching facts are returned. findall, unifications
are not preserved.
*/
 facts_by_aspects(aspects(Aspects), Facts) :-
	findall(
		Uri,
		(
			doc(Uri, rdf:type, l:fact),
			doc(Uri, l:aspects, aspects(Aspects2)),
			maplist(find_aspect(Aspects2), Aspects)
		),
		Facts).

find_aspect(Hay, Needle) :-
	member(Needle, Hay).



/*
given account role, get balance from corresponding report_entry, and assert a fact (with given aspects)
*/

 add_fact_by_account_role(Json_reports, aspects(Aspects)) :-
	!member(report - Report_path, Aspects),
	path_get_dict(Report_path, Json_reports, Report),
	!member(account_role - Role, Aspects),
	!report_entry_vec_by_role(Report, Role, Vec),
	!account_normal_side($>abrlt(Role), Side),
	maplist(!coord_normal_side_value2(Side), Vec, Values),
	!make_fact(Values, aspects(Aspects), _).

%add_sum_fact_from_report_entries_by_roles(Bs, Roles, New_fact_aspects) :-
%	!maplist(report_entry_vec_by_role(Bs), Roles, Vecs),
%	!vec_sum(Vecs, Sum),
%	!make_fact(Sum, New_fact_aspects, _).



/*
input: 2d matrix of aspect terms and other stuff.
extend aspect terms with additional aspect
*/

add_aspect_to_table(Aspect, In, Out) :-
	!maplist(add_aspect_to_row(Aspect), In, Out).
add_aspect_to_row(Aspect, In, Out) :-
	!maplist(add_aspect(Aspect), In, Out).
add_aspect(_, X, X) :-
	X \= aspects(_).
add_aspect(Aspect, aspects(Aspects), aspects(Aspects2)) :-
	append(Aspects, [Aspect], Aspects2).



/*
input: 2d matrix of aspect terms and other stuff.
replace aspect terms with strings
*/

evaluate_fact_table(Pres, Tbl) :-
	maplist(evaluate_fact_table3, Pres, Tbl).

evaluate_fact_table3(Row_in, Row_out) :-
	maplist(evaluate_fact, Row_in, Row_out).

evaluate_fact(X, X) :-
	X \= aspects(_).

evaluate_fact(In, with_metadata(Values,In)) :-
	evaluate_fact2(In, Values).

/*
this relies on there being no intermediate facts asserted.
*/
evaluate_fact2(In,Sum) :-
	In = aspects(_),
	facts_by_aspects(In, Facts),
	/*(	Facts \= []
	->	true
	;	throw_string(['fact missing:', In])),*/
	facts_vec_sum(Facts, Sum).

coord_normal_side_value2(Side, In, Out) :-
	coord_normal_side_value(In, Side, Out).

facts_vec_sum(Facts, Sum) :-
	maplist(fact_vec, Facts, Vecs),
	vec_sum(Vecs, Sum).

