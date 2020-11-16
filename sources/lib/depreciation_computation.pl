/*
ATO: Days held can be 366 for a leap year. (for both prime_cost and diminishing_value)
	https://www.ato.gov.au/business/depreciation-and-capital-expenses-and-allowances/general-depreciation-rules---capital-allowances/prime-cost-(straight-line)-and-diminishing-value-methods

diminishing_value:
The base value reduces each year by the decline in the value of the asset. This means the base value for the second year will be $48,000; that is, $80,000 minus the $32,000 decline in value in the first year.

note that when we calculato depreciation_between_two_dates, we calculate the depreciation up to the beginning date, calculate base value from that, then calculate the rest. This is different from calculating the total depreciation over the income year of beginning date, and perhaps calculating the depreciation from beginning date until the end of the income year proportionally
*/

:- module(depreciation_computation,[
	depreciation_between_start_date_and_other_date/11,
	depreciation_pool_from_start/4,
	depreciation_pool_between_two_dates/5,
	written_down_value/5,
	depreciation_between_two_dates/5,
	profit_and_loss/6]).

:- use_module(event_calculus, [depreciationAsset/12,asset/4]).
:- use_module(library(lists)).

begin_accounting_date(date(1990,1,1)).

% Calculates depreciation on a daily basis between the invest in date and any other date
% recurses for every income year, because depreciation rates may be different
/*
total depreciation at To_date is the sum of:
	depreciation until start of income year following start
	total depreciation from there until To_date
*/
depreciation_between_start_date_and_other_date(
		Initial_value, 							% value at start of year / Asset Base Value
		Method, 								% Diminishing Value / Prime Cost
		date(From_year, From_Month, From_day),
		To_date,								% date for which depreciation should be computed
		Asset_id,								% Asset
		[Life|RestOfLife],
		Depreciation_year, 						% 1,2,3...
		While_in_pool,
		What_pool,
		Initial_depreciation_value,
		Total_depreciation_value
) :-

	/* is To_date >= From_Date? if no, the whole calculation fails. */
	day_diff(date(From_year, From_Month, From_day), To_date, Request_period),
	check_day_difference_validity(Request_period),

	begin_accounting_date(Begin_accounting_date),
	day_diff(Begin_accounting_date, date(From_year, From_Month, 1), T1),

	absolute_day(Begin_accounting_date, Begin_accounting_days),
	T1_absolute is Begin_accounting_days + T1,
	gregorian_date(T1_absolute, T1_debug_date),


	(	/* compute Days_held since asset purchase or recursion, until start of new income year */
		From_Month < 7
	->
		day_diff(date(From_year, From_Month, From_day), date(From_year, 7, 1), Days_held),
		Next_from_year is From_year
	;
		day_diff(date(From_year, From_Month, From_day), date(From_year + 1, 7, 1), Days_held),
		Next_from_year is From_year + 1
	),

	(	/* done or recurse? */
		Request_period =< Days_held
	->	T2 is T1 + Request_period
	;	T2 is T1 + Days_held),

	T2_absolute is Begin_accounting_days + T2,
	gregorian_date(T2_absolute, T2_debug_date),

	depreciationAsset(Asset_id,T1,T2,Initial_value,End_value,Method,Depreciation_year,Life,While_in_pool,What_pool,/*Initial_depreciation_value*/0,Depreciation_value),

	format(user_error, '~n~q~n', [depreciationAsset(Asset_id,T1,T2,Initial_value,End_value,Method,Depreciation_year,Life,While_in_pool,What_pool,/*Initial_depreciation_value*/0,Depreciation_value)]),

	(	/* done or recurse? */
		Request_period =< Days_held
	->	Total_depreciation_value is Initial_depreciation_value + Depreciation_value
	;	Next_depreciation_year is Depreciation_year + 1,
		Next_initial_value is Initial_value - Depreciation_value,
		Next_depreciation_value is (Initial_depreciation_value + Depreciation_value),
		depreciation_between_start_date_and_other_date(
			Next_initial_value,
			Method,
			date(Next_from_year, 7, 1),
			To_date,
			Asset_id,
			RestOfLife,
			Next_depreciation_year,
			While_in_pool,
			What_pool,
			Next_depreciation_value,
			Total_depreciation_value
		)
	),

	format(user_error, '~nT1:~q~nT2:~q~n~q~n', [
		(T1, T1_debug_date),
		(T2, T2_debug_date),
		depreciation_between_start_date_and_other_date(
			Initial_value, 							% value at start of year / Asset Base Value
			Method, 								% Diminishing Value / Prime Cost
			date(From_year, From_Month, From_day),
			To_date,								% date for which depreciation should be computed
			Asset_id,								% Asset
			[Life|RestOfLife],
			Depreciation_year, 						% 1,2,3...
			While_in_pool,
			What_pool,
			Initial_depreciation_value,
			Total_depreciation_value)
		]).

%findall((Asset,Depreciation_value),depreciation_between_start_date_and_other_date(1000,prime_cost,date(2017,7,1),date(2021,6,30),Asset,_,1,false,_,0,Depreciation_value),Output).
%findall(Depreciation_value,depreciation_between_start_date_and_other_date(1000,prime_cost,date(2017,1,1),date(2018,2,2),_,_,1,false,Pool,0,Depreciation_value),Depreciation_values_lst)

%start(Total_depreciation):-findall(Depreciation_value,depreciation_between_start_date_and_other_date(1000,prime_cost,date(2017,7,1),date(2021,6,30),Asset,_,1,false,_,0,Depreciation_value),Output),
%	sum_list(Output,Total_depreciation).

%This can only be calculated in depreciation_computation because it needs begins values when using diminishing_value, and that depends always on previous years
depreciation_pool_from_start(Pool,To_date,Method,Total_depreciation):-

	format(user_error, '~n~q~n', [depreciation_pool_from_start(Pool,To_date,Method,Total_depreciation)]),

	%get begin value of all assets that are inside the pool any duration between T1 and T2, in T1
	% for each asset calculate depreciation while in the specified pool between T1 and T2
	findall(
		Depreciation_value,
		depreciation_pool_from_start2(To_date,Method,Pool,Depreciation_value),
		Depreciation_values_lst
	),
	sum_list(Depreciation_values_lst,Total_depreciation). 

depreciation_pool_from_start2(To_date,Method,Pool,Depreciation_value) :-
	%asset(car123,1000,date(2017,5,1),5).
	asset(Asset_id,Cost,Asset_Start_date,_),
	day_diff(Asset_Start_date,To_date,Days_diff),
	Days_diff>0,
	/* for every asset purchased before To_date */
	depreciation_between_start_date_and_other_date(
		/*Initial_value*/Cost,
		Method,
		/*From_Date*/Asset_Start_date,
		To_date,
		Asset_id,
		_Life,
		/*Depreciation_year*/1,
		/*While_in_pool*/true,
		Pool,
		/*Initial_depreciation_value*/0,
		Depreciation_value).

depreciation_pool_between_two_dates(Pool,From_date, To_date, Method, Total_depreciation):-
	depreciation_pool_from_start(Pool,From_date,Method,Before_depreciation),
	depreciation_pool_from_start(Pool,To_date,Method,All_depreciation),
	Total_depreciation is All_depreciation - Before_depreciation.

%start:-depreciationInInterval(corolla,76768,date(2019,7,1),0,32,76768,_,diminishing_value,1,5,_,0,Depreciation_value).
%start:- depreciation_between_start_date_and_other_date(1000,diminishing_value,date(2017,1,1),date(2019,10,2),car123,_,1,false,_,0,Result).
/*
start:- depreciation_between_start_date_and_other_date(1000,diminishing_value,date(2017,5,1),date(2019,10,2),car123,Life,1,false,_,0,_Total_depreciation_value),
	writeln(Life).
*/

% Calculates depreciation between any two dates on a daily basis equal or posterior to the invest in date
depreciation_between_two_dates(Asset_id, From_date, To_date, Method, Depreciation_value):-

	format(user_error, '~n~q~n', [depreciation_between_two_dates(Asset_id, From_date, To_date, Method, Depreciation_value)]),

	day_diff(From_date, To_date, Days_difference),
	check_day_difference_validity(Days_difference),
	written_down_value(Asset_id, To_date, Method, _, To_date_written_down_value),
	written_down_value(Asset_id, From_date, Method, _, From_date_written_down_value),
	Depreciation_value is From_date_written_down_value - To_date_written_down_value.

% Calculates written down value at a certain date equal or posterior to the invest in date using a daily basis
written_down_value(Asset_id, Written_down_date, Method, Life, Written_down_value):-

	format(user_error, '~n~q~n', [written_down_value(Asset_id, Written_down_date, Method, Life, Written_down_value)]),

	asset(Asset_id,Asset_cost,Start_date,_),
	depreciation_between_start_date_and_other_date(
		Asset_cost,
		Method,
		Start_date, 
		Written_down_date, 
		Asset_id,
		Life,
		1,/* this is in the sense of first year of ownership*/
		false, 
		_,
		0,
		Total_depreciation_value
	),
	Written_down_value is Asset_cost - Total_depreciation_value.

profit_and_loss(Asset_id, Asset_sell_price, Written_down_date, Method, Recup, Capital_gain):-

	format(user_error, '~n~q~n', [profit_and_loss(Asset_id, Asset_sell_price, Written_down_date, Method, Recup, Capital_gain)]),

	asset(Asset_id,Asset_cost,_,_),
	written_down_value(Asset_id, Written_down_date,Method,_,Written_down_value),

/*fixme:
 Concept of capital gain is as follows
Buy an asset for 10
Deprecate to a written down value of 8. I.e accumulated depreciation is 2.
Sell for 12.
I've a capital gain of 2 and a depreciation recoupment of 2.
Any proceeds over the cost base is a capital gain.
*/

	Capital_gain is Asset_sell_price - Asset_cost,
	Recup is Written_down_value - Asset_cost.


% if days difference is less than zero, it means that the requested date
% in the input value is earlier than the invest in date.
check_day_difference_validity(Days_difference) :-
	(
	Days_difference >= 0
	->
		true
	;
		false,/* todo,is failing ever desired? */throw_string('Request date is earlier than the invest in date.')
	).

% Predicates for asserting that the fields of given transactions have particular values
% duplicated from transactions.pl with the difference that transaction_date is used instead of transaction_day
% ok well transactions.pl transactions now use date too, just havent renamed it yet, so we can probably use it 
% The absolute day that the transaction happenned
% ok well transactions.pl uses dates, not days
% input and output xml should use dates too, so idk, best to convert it to days just inside the computation functions and convert it back after
transaction_date(transaction(Date, _, _, _), Date).
% A description of the transaction
transaction_description(transaction(_, Description, _, _), Description).
% The account that the transaction modifies
transaction_account(transaction(_, _, Account_Id, _), Account_Id).
% The amounts by which the account is being debited and credited
transaction_vector(transaction(_, _, _, Vector), Vector).
% Extract the cost of the buy from transaction data
transaction_cost(transaction(_, _, _, t_term(Cost, _)), Cost).
