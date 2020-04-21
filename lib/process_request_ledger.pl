:- rdet(taxonomy_url_base/0).
:- rdet(create_instance/10).
:- rdet(other_reports/10).
:- rdet(add_xml_report/3).
:- rdet(create_reports/2).




process_request_ledger(File_Path, Dom) :-
	inner_xml(Dom, //reports/balanceSheetRequest, _),
	validate_xml2(File_Path, 'bases/Reports.xsd'),
	extract_s_transactions0(Dom, S_Transactions),
	/*profile*/(process_request_ledger2(Dom, S_Transactions, _, _Transactions)).
	%process_request_ledger_debug(Dom, S_Transactions).


	/*
	how we could test inference of s_transactions from gl transactions:
	gl_doc_eq_json(Transactions, Transactions_Json),
	doc_init,
	gl_doc_eq_json(Transactions2, Transactions_Json),
	process_request_ledger2(Dom, S_Transactions2, _, Transactions2),
	assertion(eq(S_Transactions, S_Transactions2)).
	*/

/*
gl_json :-
	maplist(transaction_to_dict, Transactions, T0),
*/

/*

	a little debugging facitliy that tries processing s_transactions one by one until it runs into an error

*/

process_request_ledger_debug(Data, S_Transactions0) :-
	findall(Count, ggg(Data, S_Transactions0, Count), Counts), writeq(Counts).

ggg(Data, S_Transactions0, Count) :-
	Count = 20000,
	%between(100, $>length(S_Transactions0), Count),
	take(S_Transactions0, Count, STs),
	format(user_error, 'total s_transactions: ~q~n', [$>length(S_Transactions0)]),
	format(user_error, '~q: ~q ~n ~n', [$>length(STs), $>last(STs)]),
	profile(once(process_request_ledger2(Data, STs, _Structured_Reports, _))).
	/*length(Structured_Reports.crosschecks.errors, L),
	(	L \= 2
	->	true
	;	(gtrace,format(user_error, '~q: ~q ~n', [Count, Structured_Reports.crosschecks.errors]))).*/



process_request_ledger2(Dom, S_Transactions, Structured_Reports, Transactions) :-
	%request(Request),
	%doc_add(Request, l:kind, l:ledger_request),
	extract_request_details(Dom),
	extract_start_and_end_date(Dom, Start_Date, End_Date),
	extract_output_dimensional_facts(Dom, Output_Dimensional_Facts),
	extract_cost_or_market(Dom, Cost_Or_Market),
	extract_report_currency(Dom, Report_Currency),
	extract_action_verbs_from_bs_request(Dom),
	extract_account_hierarchy_from_request_dom(Dom, Accounts0),
	extract_livestock_data_from_ledger_request(Dom),
	extract_exchange_rates(Cost_Or_Market, Dom, S_Transactions, Start_Date, End_Date, Report_Currency, Exchange_Rates),
	extract_invoices_payable(Dom),
	extract_initial_gl(Initial_Txs),

	process_ledger(
		Cost_Or_Market,
		Initial_Txs,
		S_Transactions,
		Start_Date,
		End_Date,
		Exchange_Rates,
		Report_Currency,
		Accounts0,
		Accounts,
		Transactions,
		Transactions_By_Account,
		Outstanding,
		Processed_Until_Date,
		Gl),

	/* if some s_transaction failed to process, there should be an alert created by now. Now we just compile a report up until that transaction. It would maybe be cleaner to do this by calling process_ledger a second time */
	dict_from_vars(Static_Data0,
		[Cost_Or_Market,
		Output_Dimensional_Facts,
		Start_Date,
		Exchange_Rates,
		Accounts,
		Transactions,
		Report_Currency,
		Gl,
		Transactions_By_Account,
		Outstanding
	]),
	Static_Data1 = Static_Data0.put([
		end_date=Processed_Until_Date,
		exchange_date=Processed_Until_Date
	]),

	once(create_reports(Static_Data1, Structured_Reports)).




create_reports(
	Static_Data,				% Static Data
	Structured_Reports			% ...
) :-
	once(static_data_historical(Static_Data, Static_Data_Historical)),

	once(balance_entries(Static_Data, Static_Data_Historical, Entries)),

	dict_vars(Entries, [Balance_Sheet, ProfitAndLoss, Balance_Sheet2_Historical, ProfitAndLoss2_Historical, Trial_Balance, Cf]),

	once(taxonomy_url_base),
	%gtrace,
	format(user_error, '.......', []),

	once(create_instance(Xbrl, Static_Data, Static_Data.start_date, Static_Data.end_date, Static_Data.accounts, Static_Data.report_currency, Balance_Sheet, ProfitAndLoss, ProfitAndLoss2_Historical, Trial_Balance)),

	once(other_reports(Static_Data, Static_Data_Historical, Static_Data.outstanding, Balance_Sheet, ProfitAndLoss, Balance_Sheet2_Historical, ProfitAndLoss2_Historical, Trial_Balance, Cf, Structured_Reports)),
	once(add_xml_report(xbrl_instance, xbrl_instance, [Xbrl])).



balance_entries(
	Static_Data,				% Static Data
	Static_Data_Historical,		% Static Data
	Entries						% Dict Entry
) :-
	/* sum up the coords of all transactions for each account and apply unit conversions */
	trial_balance_between(Static_Data.exchange_rates, Static_Data.accounts, Static_Data.transactions_by_account, Static_Data.report_currency, Static_Data.end_date, Static_Data.start_date, Static_Data.end_date, Trial_Balance),
	balance_sheet_at(Static_Data, Balance_Sheet),
	profitandloss_between(Static_Data, ProfitAndLoss),
	balance_sheet_at(Static_Data_Historical, Balance_Sheet2_Historical),
	cashflow(Static_Data, Cf),
	profitandloss_between(Static_Data_Historical, ProfitAndLoss2_Historical),
	assertion(ground((Balance_Sheet, ProfitAndLoss, ProfitAndLoss2_Historical, Trial_Balance))),
	dict_from_vars(Entries, [Balance_Sheet, ProfitAndLoss, Balance_Sheet2_Historical, ProfitAndLoss2_Historical, Trial_Balance, Cf]).


static_data_historical(Static_Data, Static_Data_Historical) :-
	add_days(Static_Data.start_date, -1, Before_Start),
	Static_Data_Historical = Static_Data.put(
		start_date, date(1,1,1)).put(
		end_date, Before_Start).put(
		exchange_date, Static_Data.start_date).


other_reports(
	Static_Data,
	Static_Data_Historical,
	Outstanding,
	Balance_Sheet,
	ProfitAndLoss,
	Balance_Sheet2_Historical,
	ProfitAndLoss2_Historical,
	Trial_Balance,
	Cf,
	Structured_Reports				% Dict <Report Abbr : _>
) :-

	investment_reports(Static_Data.put(outstanding, Outstanding), Investment_Report_Info),
	bs_page(Static_Data, Balance_Sheet),
	pl_page(Static_Data, ProfitAndLoss, ''),
	pl_page(Static_Data_Historical, ProfitAndLoss2_Historical, '_historical'),
	cf_page(Static_Data, Cf),
	make_json_report(Static_Data.gl, general_ledger_json),

	make_gl_viewer_report,

	Structured_Reports0 = _{
		pl: _{
			current: ProfitAndLoss,
			historical: ProfitAndLoss2_Historical
		},
		ir: Investment_Report_Info,
		bs: _{
			current: Balance_Sheet,
			historical: Balance_Sheet2_Historical
		},
		tb: Trial_Balance,
		cf: Cf
	},

	crosschecks_report0(Static_Data.put(reports, Structured_Reports0), Crosschecks_Report_Json),

	Structured_Reports = Structured_Reports0.put(crosschecks, Crosschecks_Report_Json),

	make_json_report(Structured_Reports, reports_json).

make_gl_viewer_report :-
	%format(user_error, 'make_gl_viewer_report..~n',[]),
	Viewer_Dir = 'general_ledger_viewer',
	absolute_file_name(my_static(Viewer_Dir), Src, [file_type(directory)]),
	report_file_path(loc(file_name, Viewer_Dir), loc(absolute_url, Dir_Url), loc(absolute_path, Dst)),

	/* symlink or copy, which one is more convenient depends on what we're working on */
	Cmd = ['ln', '-s', '-n', '-f', Src, Dst],
	%Cmd = ['cp', '-r', Src, Dst],

	%format(user_error, 'shell..~q ~n',[Cmd]),
	shell4(Cmd, _),
	%format(user_error, 'shell.~n',[]),
	atomic_list_concat([Dir_Url, '/link.html'], Full_Url),
	add_report_file(0,'gl_html', 'GL viewer', loc(absolute_url, Full_Url)),
	%format(user_error, 'make_gl_viewer_report done.~n',[]),
	true.

investment_reports(Static_Data, Ir) :-
	Data =
	[
		(current,'',Static_Data),
		(since_beginning,'_since_beginning',Static_Data.put(start_date, date(1,1,1)))
	],
	maplist(
		(
			[
				(Structured_Report_Key, Suffix, Sd),
				(Structured_Report_Key-Semantic_Json)
			]
			>>
				investment_report_2_0(Sd, Suffix, Semantic_Json)
		),
		Data,
		Structured_Json_Pairs
	),
	dict_pairs(Ir, _, Structured_Json_Pairs).

/*
To ensure that each response references the shared taxonomy via a unique url,
a flag can be used when running the server, for example like this:
```swipl -s prolog_server.pl  -g "set_flag(prepare_unique_taxonomy_url, true),run_simple_server"```
This is done with a symlink. This allows to bypass cache, for example in pesseract.
*/
taxonomy_url_base :-
	symlink_tmp_taxonomy_to_static_taxonomy(Unique_Taxonomy_Dir_Url),
	(	get_flag(prepare_unique_taxonomy_url, true)
	->	Taxonomy_Dir_Url = Unique_Taxonomy_Dir_Url
	;	Taxonomy_Dir_Url = 'taxonomy/'),
	request_add_property(l:taxonomy_url_base, Taxonomy_Dir_Url).

symlink_tmp_taxonomy_to_static_taxonomy(Unique_Taxonomy_Dir_Url) :-
	my_request_tmp_dir(loc(tmp_directory_name,Tmp_Dir)),
	server_public_url(Server_Public_Url),
	atomic_list_concat([Server_Public_Url, '/tmp/', Tmp_Dir, '/taxonomy/'], Unique_Taxonomy_Dir_Url),
	absolute_tmp_path(loc(file_name, 'taxonomy'), loc(absolute_path, Tmp_Taxonomy)),
	resolve_specifier(loc(specifier, my_static('taxonomy')), loc(absolute_path,Static_Taxonomy)),
	Cmd = ['ln', '-s', '-n', '-f', Static_Taxonomy, Tmp_Taxonomy],
	%format(user_error, 'shell..~q ~n',[Cmd]),
	shell4(Cmd, _).
	%format(user_error, 'shell.~n',[]).

	
/*

	extraction of input data from request xml
	
*/	
   
extract_report_currency(Dom, Report_Currency) :-
	request_data(Request_Data),
	(	doc(Request_Data, ic_ui:report_details, D)
	->	(
			doc_value(D, ic:currency, C),
			atom_string(Ca, C),
			Report_Currency = [Ca]
		)
	;	inner_xml_throw(Dom, //reports/balanceSheetRequest/reportCurrency/unitType, Report_Currency)).


/*
*If an investment was held prior to the from date then it MUST have an opening market value if the reports are expressed in market rather than cost.You can't mix market valu
e and cost in one set of reports. One or the other.
+       Market or Cost. M or C.
+       Cost value per unit will always be there if there are units of anything i.e. sheep for livestock trading or shares for Investments. But I suppose if you do not find any marke
t values then assume cost basis.*/

extract_cost_or_market(Dom, Cost_Or_Market) :-
	request_data(Request_Data),
	(	doc(Request_Data, ic_ui:report_details, D)
	->	(
			doc_value(D, ic:cost_or_market, C),
			(	rdf_equal(C, ic:cost)
			->	Cost_Or_Market = cost
			;	Cost_Or_Market = market)
		)
	;
	(
		inner_xml(Dom, //reports/balanceSheetRequest/costOrMarket, [Cost_Or_Market])
	->
		(
			member(Cost_Or_Market, [cost, market])
		->
			true
		;
			throw_string('//reports/balanceSheetRequest/costOrMarket tag\'s content must be "cost" or "market"')
		)
	;
		Cost_Or_Market = market
	)
	).
	
extract_output_dimensional_facts(Dom, Output_Dimensional_Facts) :-
	(
		inner_xml(Dom, //reports/balanceSheetRequest/outputDimensionalFacts, [Output_Dimensional_Facts])
	->
		(
			member(Output_Dimensional_Facts, [on, off])
		->
			true
		;
			throw_string('//reports/balanceSheetRequest/outputDimensionalFacts tag\'s content must be "on" or "off"')
		)
	;
		Output_Dimensional_Facts = on
	).
	
extract_start_and_end_date(Dom, Start_Date, End_Date) :-
	request_data(Request_Data),
	(	doc(Request_Data, ic_ui:report_details, D)
	->	(
			doc_value(D, ic:from, Start_Date),
			doc_value(D, ic:to, End_Date)
		)
	;
	(
		inner_xml(Dom, //reports/balanceSheetRequest/startDate, [Start_Date_Atom]),
		parse_date(Start_Date_Atom, Start_Date),
		inner_xml(Dom, //reports/balanceSheetRequest/endDate, [End_Date_Atom]),
		parse_date(End_Date_Atom, End_Date)
	)),
	result(R),
	doc_add(R, l:start_date, Start_Date),
	doc_add(R, l:end_date, End_Date),

	(	Start_Date = date(1,1,1)
	->	throw_string(['start date missing?'])
	;	true),
	(	End_Date = date(1,1,1)
	->	throw_string(['end date missing?'])
	;	true)
	.

	
%:- tspy(process_xml_ledger_request2/2).

extract_bank_accounts(Dom) :-
	findall(Account, xpath(Dom, //reports/balanceSheetRequest/bankStatement/accountDetails, Account), Accounts),
	maplist(extract_bank_account, Accounts).

extract_bank_account(Account) :-
	fields(Account, [
		accountName, Account_Name,
		currency, Account_Currency]),
	numeric_fields(Account, [
		openingBalance, (Opening_Balance_Number, 0)]),
	Opening_Balance = coord(Account_Currency, Opening_Balance_Number),
	doc_new_uri(Uri, bank_account),
	request_add_property(l:bank_account, Uri),
	doc_add(Uri, l:name, Account_Name),
	(	Opening_Balance_Number \= 0
	->	doc_add_value(Uri, l:opening_balance, Opening_Balance)
	;	true).

generate_bank_opening_balances_sts(Txs) :-
	result(R),
	findall(Bank_Account, docm(R, l:bank_account, Bank_Account), Bank_Accounts),
	maplist(generate_bank_opening_balances_sts2, Bank_Accounts, Txs0),
	exclude(var, Txs0, Txs).

generate_bank_opening_balances_sts2(Bank_Account, Tx) :-
	(	doc_value(Bank_Account, l:opening_balance, Opening_Balance)
	->	(
			request_has_property(l:start_date, Start_Date),
			add_days(Start_Date, -1, Opening_Date),
			doc(Bank_Account, l:name, Bank_Account_Name),
			doc_add_s_transaction(
				Opening_Date,
				'Bank_Opening_Balance',
				[Opening_Balance],
				Bank_Account_Name,
				vector([]),
				misc{desc2:'Bank_Opening_Balance'},
				Tx)
		)
	).

generate_bank_opening_balances_sts2(Bank_Account, _Tx) :-
	\+doc_value(Bank_Account, l:opening_balance, _Opening_Balance).

extract_initial_gl(Txs) :-
	request_data(Request_Data),
	(	doc(Request_Data, ic_ui:gl, Gl)
	->	(
			doc_value(Gl, ic:default_currency, Default_Currency0),
			atom_string(Default_Currency, Default_Currency0),
			doc_value(Gl, ic:items, List),
			doc_list_items(List, Items),
			maplist(extract_initial_gl_tx(Default_Currency), Items, Txs)
		)
	;	Txs = []).

extract_initial_gl_tx(Default_Currency, Item, Tx) :-
	doc_value(Item, ic:date, Date),
	doc_value(Item, ic:account, Account_String),
	/*fixme, support multiple description fields in transaction */
	(	doc_value(Item, ic:description, Description)
	->	true
	;	Description = 'initial_GL'),
	atom_string(Account, Account_String),
	(	doc_value(Item, ic:debit, Debit_String)
	->	vector_string(Default_Currency, debit, Debit_String, Debit_Vector)
	;	Debit_Vector = []),
	(	doc_value(Item, ic:credit, Credit_String)
	->	vector_string(Default_Currency, credit, Credit_String, Credit_Vector)
	;	Credit_Vector = []),
	append(Debit_Vector, Credit_Vector, Vector),
	make_transaction(initial_GL, Date, Description, Account, Vector, Tx).

extract_s_transactions0(Dom, S_Transactions) :-
	extract_bank_accounts(Dom),
	generate_bank_opening_balances_sts(Bank_Lump_STs),
	handle_additional_files(S_Transactions0),
	extract_s_transactions(Dom, S_Transactions1),
	flatten([Bank_Lump_STs, S_Transactions0, S_Transactions1], S_Transactions2),
	sort_s_transactions(S_Transactions2, S_Transactions).

extract_request_details(Dom) :-
	request(Request),
	result(Result),
	(	xpath(Dom, //reports/balanceSheetRequest/company/clientcode, element(_, [], [Client_code_atom]))
	->	(
			atom_string(Client_code_atom, Client_code_string),
			doc_add(Request, l:client_code, Client_code_string)
		)
	;	true),
	get_time(TimeStamp),
	stamp_date_time(TimeStamp, DateTime, 'UTC'),
	doc_add(Result, l:timestamp, DateTime).

/*
:- comment(Structured_Reports:
	the idea is that the dicts containing the high-level, semantic information of all reports would be passed all the way up, and we'd have some test runner making use of that / generating a lot of permutations of requests and checking the results computationally, in addition to endpoint_tests checking report files against saved versions.
Not sure if/when we want to work on that.
*/
