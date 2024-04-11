% -------------------------------------------------------------------
% Exchanges the given coordinate, Amount, into the first unit from Bases for which an
% exchange on the day Day is possible. If the source unit is not found in Bases, then Amount is left as is.
% in practice, we never pass multiple items in Bases, so this mechanism could be simplified away.

% - no bases to use, leave as it is
 exchange_amount(_, _, [], Amount, Amount) :- !.

 exchange_amount(Exchange_Rates, Day, [Bases_Hd | _], coord(Unit, Debit), Amount_Exchanged) :-
	exchange_rate(Exchange_Rates, Day, Unit, Bases_Hd, Exchange_Rate),
	Debit_Exchanged is Debit * Exchange_Rate,
	Amount_Exchanged = coord(Bases_Hd, Debit_Exchanged),
	!.

 exchange_amount(Exchange_Rates, Day, [_ | Bases_Tl], Coord, Amount_Exchanged) :-
	exchange_amount(Exchange_Rates, Day, Bases_Tl, Coord, Amount_Exchanged).


% Using the exchange rates from the day Day, change the given vector into
% units in Bases.

% Where two different coordinates have been mapped to the same basis,
% combine them. If a coordinate cannot be exchanged into a unit from Bases, then it is
% put into the result as is.

 vec_change_bases_(_, _, _, [], []) :- !.


 vec_change_bases_(Exchange_Rates, Day, Bases, As, Bs) :-
 	assertion(flatten(Bases, Bases)),
	maplist(exchange_amount(Exchange_Rates, Day, Bases), As, As_Exchanged),
	vec_reduce_(As_Exchanged, Bs).


 vec_change_bases(Exchange_Rates, Day, Bases, As, Bs) :-
 	##push_format('convert ~q to ~q at ~q', [$>round_term(As), Bases, Day]),
	assertion(flatten(Bases, Bases)),
	val(As, AsV),
	maplist(exchange_amount(Exchange_Rates, Day, Bases), AsV, As_ExchangedV),
	vec_reduce_(As_ExchangedV, BsV),
	doc_new_vec(BsV, Bs),
	doc_add(Bs, l:origin, As),
	doc_add(Bs, l:conversion_day, Day),
	##pop_context.

 exchange_amount_throw(Exchange_Rates, Day, [Base], coord(Unit, Debit), Amount_Exchanged) :-
	exchange_rate_throw(Exchange_Rates, Day, Unit, Base, Exchange_Rate),
	Debit_Exchanged is Debit * Exchange_Rate,
	Amount_Exchanged = coord(Base, Debit_Exchanged).

 vec_change_bases_throw(Exchange_Rates, Day, Bases, As, Bs) :-
 	##push_format('convert ~q to ~q at ~q', [$>round_term(As), Bases, Day]),
	assertion(flatten(Bases, Bases)),
	val(As, AsV),
	maplist(exchange_amount_throw(Exchange_Rates, Day, Bases), AsV, As_Exchanged),
	vec_reduce_(As_Exchanged, BsV),
	doc_new_vec(BsV, Bs),
	doc_add(Bs, l:origin, As),
	##pop_context.

