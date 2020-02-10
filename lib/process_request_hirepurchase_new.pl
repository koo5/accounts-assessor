chase_kb(N/*, Done*/) :-
	format(user_error, "Starting chase(~w)~n", [N]),
	findall(
		Fact,
		'$enumerate_constraints'(Fact),
		Facts
	),
	format("Facts: ~w~n", [Facts]),
	start(N, _).
	

doc_get_attribute(S, P, O) :- (doc_value(S, P, O) -> true ; true).

hp_doc_to_chr_basic :-
	format(user_error,"hp_doc_to_chr_basic:~n",[]),
	docm(l:request,hp_ui:hp_calculator_query,HP_Calculator_Query),
	docm(HP_Calculator_Query,rdf:type,hp:hp_calculator_query),
	doc_get_attribute(HP_Calculator_Query,hp:begin_date, HP_Begin_Date),
	docm(HP_Calculator_Query,hp:hp_contract, HP_Contract),
	docm(HP_Contract, rdf:type, hp:hp_contract),
	doc_get_attribute(HP_Contract, hp:cash_price, HP_Cash_Price),
	doc_get_attribute(HP_Contract, hp:contract_number, HP_Contract_Number),
	doc_get_attribute(HP_Contract, hp:currency, HP_Currency),
	doc_get_attribute(HP_Contract, hp:hp_contract_has_payment_type, HP_Contract_Has_Payment_Type),
	doc_get_attribute(HP_Contract, hp:hp_installments, HP_Installments),
	doc_get_attribute(HP_Contract, hp:interest_rate, HP_Interest_Rate),
	doc_get_attribute(HP_Contract, hp:number_of_installments, HP_Number_of_Installments),
	doc_get_attribute(HP_Contract, hp:repayment_amount, HP_Repayment_Amount),
	hp_installments_to_chr_basic(HP_Installments, CHR_HP_Installments, Installments_Facts),



	fact(CHR_HP_Contract, a, hp_arrangement),

	fact(CHR_HP_Contract, begin_date, CHR_HP_Begin_Date),
	doc_date_to_chr_facts(CHR_HP_Begin_Date, HP_Begin_Date),

	fact(CHR_HP_Contract, cash_price, HP_Cash_Price),

	fact(CHR_HP_Contract, contract_number, HP_Contract_Number),

	fact(CHR_HP_Contract, currency, HP_Currency),

	fact(CHR_HP_Contract, payment_type, HP_Contract_Has_Payment_Type),

	fact(CHR_HP_Contract, installments, CHR_HP_Installments),
	maplist([fact(S,P,O)]>>fact(S,P,O), Installments_Facts),

	fact(CHR_HP_Contract, interest_rate, HP_Interest_Rate),

	fact(CHR_HP_Contract, number_of_installments, HP_Number_of_Installments),

	fact(CHR_HP_Contract, repayment_amount, HP_Repayment_Amount),

	dump_chr.

hp_installments_to_chr_basic(rdf:nil, _, []) :- !.
hp_installments_to_chr_basic(HP_Installments, _, []) :-
	\+doc(HP_Installments, rdf:first, _).
hp_installments_to_chr_basic(HP_Installments, CHR_HP_Installments, [fact(CHR_HP_Installments, first, HP_Installments) | Installment_Facts]) :-
	doc(HP_Installments, rdf:first, _),
	hp_installments_to_chr_basic_helper(HP_Installments, Installment_Facts).

hp_installments_to_chr_basic_helper(rdf:nil, []).
hp_installments_to_chr_basic_helper(Current_Item, Facts) :-
	(
		doc(Current_Item, rdf:first, Value)
	->	Facts = [fact(Current_Item, value, Value) | Rest_Facts]
	;	Facts = Rest_Facts
	),
	(
		doc(Current_Item, rdf:rest, Rest_List)
	->	Rest_Facts = [fact(Current_Item, next, Rest_List) | Rest_Rest_Facts],
		hp_installments_to_chr_basic_helper(Rest_List, Rest_Rest_Facts)
	;	Rest_Facts = []
	).

doc_date_to_chr_facts(_CHR_Date, Doc_Date) :-
	format(user_error, "doc date: ~w~n", [Doc_Date]),
	Doc_Date = Date_Part^^Type_Part,
	format(user_error, "date part: ~w~n", [Date_Part]),
	format(user_error, "type part: ~w~n", [Type_Part]),
	(
		Date_Part = date_time(Year, Month, Day, Hour, Minute, Second)
	->	fact(CHR_Date, year, Year),
		fact(CHR_Date, month, Month),
		fact(CHR_Date, day, Day),
		fact(CHR_Date, hour, Hour),
		fact(CHR_Date, minute, Minute),
		fact(CHR_Date, second, Second)
	;	% unknown date format, don't translate.
		true
	).


dump_chr :-
	format(user_error,"dump_chr:~n",[]),
	findall(
		_,
		(
			'$enumerate_constraints'(fact(S,P,O)),
			format(user_error,"~w ~w ~w~n", [S,P,O])
		),
		_
	),
	nl.

hp_doc_from_chr_basic :-
	find_fact3(CHR_HP_Contract1, a, hp_arrangement, [], Subs0),
	get_sub(CHR_HP_Contract1, Subs0, HP_Contract),

	find_fact3(CHR_HP_Contract1, begin_date, CHR_HP_Begin_Date1, Subs0, Subs1),
	get_sub(CHR_HP_Begin_Date1, Subs1, CHR_HP_Begin_Date),

	find_fact3(CHR_HP_Contract1, cash_price, HP_Cash_Price1, Subs1, Subs2),
	get_sub(HP_Cash_Price1, Subs2, HP_Cash_Price),

	find_fact3(CHR_HP_Contract1, contract_number, HP_Contract_Number1, Subs2, Subs3),
	get_sub(HP_Contract_Number1, Subs3, HP_Contract_Number),

	find_fact3(CHR_HP_Contract1, currency, HP_Currency1, Subs3, Subs4),
	get_sub(HP_Currency1, Subs4, HP_Currency),

	find_fact3(CHR_HP_Contract1, payment_type, HP_Contract_Has_Payment_Type1, Subs4, Subs5),
	get_sub(HP_Contract_Has_Payment_Type1, Subs5, HP_Contract_Has_Payment_Type),

	find_fact3(CHR_HP_Contract1, installments, CHR_HP_Installments1, Subs5, Subs6),
	get_sub(CHR_HP_Installments1, Subs6, CHR_HP_Installments),

	find_fact3(CHR_HP_Contract1, interest_rate, HP_Interest_Rate1, Subs6, Subs7),
	get_sub(HP_Interest_Rate1, Subs7, HP_Interest_Rate),

	find_fact3(CHR_HP_Contract1, number_of_installments, HP_Number_of_Installments1, Subs7, Subs8),
	get_sub(HP_Number_of_Installments1, Subs8, HP_Number_of_Installments),

	find_fact3(CHR_HP_Contract1, repayment_amount, HP_Repayment_Amount1, Subs8, Subs9),
	get_sub(HP_Repayment_Amount1, Subs9, HP_Repayment_Amount),

	doc_add_safe(l:request,hp_ui:hp_calculator_query,HP_Calculator_Query),
	doc_add_safe(HP_Calculator_Query,rdf:type,hp:hp_calculator_query),
	doc_add_safe(HP_Calculator_Query,hp:begin_date, HP_Begin_Date),
	chr_date_to_doc_facts(CHR_HP_Begin_Date, HP_Begin_Date),
	doc_add_safe(HP_Calculator_Query,hp:hp_contract, HP_Contract),
	doc_add_safe(HP_Contract, rdf:type, hp:hp_contract),
	doc_add_value_safe(HP_Contract, hp:cash_price, HP_Cash_Price),
	doc_add_value_safe(HP_Contract, hp:contract_number, HP_Contract_Number),
	doc_add_value_safe(HP_Contract, hp:currency, HP_Currency),
	doc_add_value_safe(HP_Contract, hp:hp_contract_has_payment_type, HP_Contract_Has_Payment_Type),
	doc_add_value_safe(HP_Contract, hp:interest_rate, HP_Interest_Rate),
	doc_add_value_safe(HP_Contract, hp:number_of_installments, HP_Number_of_Installments),
	doc_add_value_safe(HP_Contract, hp:repayment_amount, HP_Repayment_Amount),

	doc_add_value_safe(HP_Contract, hp:hp_installments, HP_Installments),
	hp_chr_installments_to_doc_basic(CHR_HP_Installments, HP_Installments).

chr_date_to_doc_facts(CHR_Date, Doc_Date) :-
	chr_get_attribute(CHR_Date, year, Year),
	chr_get_attribute(CHR_Date, month, Month),
	chr_get_attribute(CHR_Date, day, Day),
	chr_get_attribute(CHR_Date, hour, Hour),
	chr_get_attribute(CHR_Date, minute, Minute),
	chr_get_attribute(CHR_Date, second, Second),
	doc_add_safe(Doc_Date, rdf:value, date_time(Year, Month, Day, Hour, Minute, Second)^^'http://www.w3.org/2001/XMLSchema#dateTime').

doc_add_safe(S1,P1,O1) :-
	maplist(chr_term_to_doc_term, [S1,P1,O1], [S2,P2,O2]),
	(
		\+docm(S2,P2,O2)
	->	maplist(chr_var_to_doc_bnode, [S2,P2,O2], [S,P,O]),
		doc_add(S,P,O)
	;	doc(S2,P2,O2)
	).

doc_add_value_safe(S1,P1,O1) :-
	maplist(chr_term_to_doc_term, [S1,P1,O1], [S,P,O]),
	(
		\+docm(S,P,_)
	->	doc_new_uri(URI),
		doc_add_safe(S,P,URI),
		doc_add_safe(URI, rdf:value, O)
	;	doc(S,P,X),
		doc_add_safe(X, rdf:value, O)
	).
	
chr_term_to_doc_term(Term, Term) :- 
	nonvar(Term),
	Term \= _:_.

chr_term_to_doc_term(Term, Doc_Term) :-
	nonvar(Term),
	Term = Prefix:Suffix,
	doc_prefix(Prefix,RDF_Prefix),
	atom_concat(RDF_Prefix,Suffix, Doc_Term).

chr_term_to_doc_term(Term, Term) :- 
	var(Term).

chr_var_to_doc_bnode(Term, Term) :- nonvar(Term).
chr_var_to_doc_bnode(Var, Bnode) :- var(Var), doc_new_uri(Bnode), Var = Bnode.

hp_chr_installments_to_doc_basic(CHR_HP_Installments, _) :-
	\+find_fact2(CHR_HP_Installments1, first, _, [CHR_HP_Installments1:CHR_HP_Installments]), !.

hp_chr_installments_to_doc_basic(CHR_HP_Installments, HP_Installments) :-
	find_fact2(CHR_HP_Installments1, first, HP_Installments, [CHR_HP_Installments1:CHR_HP_Installments]),
	hp_chr_installments_to_doc_basic_helper(HP_Installments).

hp_chr_installments_to_doc_basic_helper(Current_Item) :-
	(
		find_fact2(Current_Item1, value, Value, [Current_Item1:Current_Item])
	->	doc_add(Current_Item, rdf:first, Value)
	;	true
	),
	(
		find_fact2(Current_Item1, next, Next_Item, [Current_Item1:Current_Item])
	->	doc_add(Current_Item, rdf:rest, Next_Item),
		hp_chr_installments_to_doc_basic_helper(Next_Item)
	;	true
	).

chr_get_attribute(S,P,O) :- (fact(S,P,O) -> true ; true).

dump_doc(Label) :-
	format(user_error, "dump_doc: ~w~n", [Label]),
	findall(
		_,
		(
			docm(S,P,O),
			format(user_error, "~w ~w ~w~n", [S,P,O])
		),
		_
	),
	nl.

get_sub(Var, [K:V | Rest], Sub) :-
	(
		Var == K
	->	Sub = V
	;	get_sub(Var, Rest, Sub)
	).

doc_prefix(code, 'https://rdf.lodgeit.net.au/v1/code#').
doc_prefix(l, 'https://rdf.lodgeit.net.au/v1/request#').
doc_prefix(livestock, 'https://rdf.lodgeit.net.au/v1/livestock#').
doc_prefix(excel, 'https://rdf.lodgeit.net.au/v1/excel#').
doc_prefix(depr, 'https://rdf.lodgeit.net.au/v1/calcs/depr#').
doc_prefix(ic, 'https://rdf.lodgeit.net.au/v1/calcs/ic#').
doc_prefix(hp, 'https://rdf.lodgeit.net.au/v1/calcs/hp#').
doc_prefix(depr_ui, 'https://rdf.lodgeit.net.au/v1/calcs/depr/ui#').
doc_prefix(ic_ui, 'https://rdf.lodgeit.net.au/v1/calcs/ic/ui#').
doc_prefix(hp_ui, 'https://rdf.lodgeit.net.au/v1/calcs/hp/ui#').
doc_prefix(transactions, 'https://rdf.lodgeit.net.au/v1/transactions#').
doc_prefix(s_transactions, 'https://rdf.lodgeit.net.au/v1/s_transactions#').
doc_prefix(rdf, 'http://www.w3.org/1999/02/22-rdf-syntax-ns#').
doc_prefix(rdfs, 'http://www.w3.org/2000/01/rdf-schema#').
doc_prefix(xml, 'http://www.w3.org/XML/1998/namespace#').
doc_prefix(xsd, 'http://www.w3.org/2001/XMLSchema#').




process_request_hirepurchase_new :-
	%dump_doc("Before"),
	hp_doc_to_chr_basic,
	chase_kb(20),
	hp_doc_from_chr_basic,
	dump_doc("After").
