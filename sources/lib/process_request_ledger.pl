
 extract_data(Data) :-
	cf(extract_start_and_end_date),
	doc_add($>result, l:type, l:ledger),
	!cf(extract_request_details),
	!cf('extract "output_dimensional_facts"'),
	!cf('extract "cost_or_market"'),
	!cf(extract_report_currency),
	!cf('extract action verbs'),
	!cf('extract bank accounts'),
	!cf('extract GL accounts'),
	!cf(make_gl_viewer_report),
	!cf(write_accounts_json_report),
	!cf(extract_exchange_rates(Exchange_Rates)).


/*
phases:
	automated: post bank opening balances
	phase: opening balance
	automated: rollover

each phase depends on posted results of previous phase.
*/

 process_request_ledger :-
	extract_data(Sd0),
	!cf(generate_bank_opening_balances_sts(Bank_Lump_STs)),
	handle_sts(Sd0, Bank_Lump_STs, Bank_Lump_Ts),



	Exchange_Date = End_Date,

	dict_from_vars(
		Static_Data0,
		[
			Cost_Or_Market,
			Output_Dimensional_Facts,
			Start_Date,
			Exchange_Rates,
			Transactions,
			Report_Currency,
			Outstanding,
			End_Date
			Exchange_Date
		]
	),





 handle_sts(State0, S_Transactions, Outstanding_In, Outstanding_Out, Processed_Until) :-
 	doc(State0, l:has_transactions, Transactions_in),
 	doc(State0, l:end_date, End_Date),

	!s_transactions_up_to(End_Date, S_Transactions, S_Transactions2),
	!sort_s_transactions(S_Transactions2, S_Transactions4),

	dict_from_vars(Static_Data0, [Report_Currency, Start_Date, End_Date, Exchange_Rates, Cost_Or_Market]),

	!cf('pre-preprocess source transactions'(S_Transactions4, Prepreprocessed_S_Transactions)),

	!cf(preprocess_until_error(Static_Data0, Prepreprocessed_S_Transactions, Preprocessed_S_Transactions, Transactions, Outstanding_Out, End_Date, Processed_Until)),

	Processed_Until always == End_Date!

	(	(($>length(Processed_S_Transactions)) == ($>length(Prepreprocessed_S_Transactions)))
	->	true
	;	add_alert('warning', 'not all source transactions processed, proceeding with reports anyway..')),

	!transactions_by_account(Static_Data0b, Transactions_By_Account1),
	Static_Data1 = Static_Data0b.put([transactions_by_account=Transactions_By_Account1]).






	!cf(handle_additional_files(S_Transactions0)),
	!cf('extract bank statement transactions'(S_Transactions1b)),
	!cf(extract_action_inputs(Action_input_sts)),
	!flatten([Bank_Lump_STs, S_Transactions0,S_Transactions1b, Action_input_sts], S_Transactions2),


	Data = (Start_Date, End_Date, Output_Dimensional_Facts, Cost_Or_Market, Report_Currency),   S_Transactions, Structured_Reports, Transactions)

	%!cf(extract_livestock_data_from_ledger_request(Dom)),
	%!cf(extract_invoices_payable(Dom)),

	!process_ledger(
		Cost_Or_Market,
		S_Transactions,
		Start_Date,
		End_Date,
		Exchange_Rates,
		Report_Currency,
		Transactions,
		Outstanding,
		Processed_Until_Date),

	/* if some s_transaction failed to process, there should be an alert created by now. Now we just compile a report up until that transaction. It would maybe be cleaner to do this by calling 'process_ledger' a second time */
	dict_from_vars(Static_Data0,
		[Cost_Or_Market,
		Output_Dimensional_Facts,
		Start_Date,
		Exchange_Rates,
		Transactions,
		Report_Currency,
		Outstanding
	]),
	Static_Data0b = Static_Data0.put([
		end_date=Processed_Until_Date,
		exchange_date=Processed_Until_Date
	]),
	!transactions_by_account(Static_Data0b, Transactions_By_Account1),
	Static_Data1 = Static_Data0b.put([transactions_by_account=Transactions_By_Account1]),
	(	account_by_role(rl(smsf_equity), _)
	->	(
			cf(smsf_distributions_reports(_)),
			update_static_data_with_transactions(
				Static_Data1,
				$>!cf(smsf_income_tax_stuff(Static_Data1)),
				Static_Data2)
		)
	;	Static_Data2 = Static_Data1),
	cf(check_trial_balance2(Exchange_Rates, Static_Data2.transactions_by_account, Report_Currency, Static_Data2.end_date, Start_Date, Static_Data2.end_date)),
	once(!cf(create_reports(Static_Data2, Structured_Reports))).


update_static_data_with_transactions(In, Txs, Out) :-
	append(In.transactions,$>flatten(Txs),Transactions2),
	Static_Data1b = In.put([transactions=Transactions2]),
	!transactions_by_account(Static_Data1b, Transactions_By_Account),
	Out = Static_Data1b.put([transactions_by_account=Transactions_By_Account]).



check_trial_balance2(Exchange_Rates, Transactions_By_Account, Report_Currency, End_Date, Start_Date, End_Date) :-
	!trial_balance_between(Exchange_Rates, Transactions_By_Account, Report_Currency, End_Date, Start_Date, End_Date, [Trial_Balance_Section]),
	(
		(
			trial_balance_ok(Trial_Balance_Section)
		;
			Report_Currency = []
		)
	->
		true
	;
		(	term_string(trial_balance(Trial_Balance_Section), Tb_Str),
			add_alert('SYSTEM_WARNING', Tb_Str))
	).



create_reports(
	Static_Data,				% Static Data
	Sr2							% Structured Reports (dict)
) :-
	!balance_entries(Static_Data, Sr),
	!other_reports2('final_', Static_Data, Sr),
	!other_reports(Static_Data, Static_Data.outstanding, Sr, Sr2),
	!taxonomy_url_base,
	!cf('create XBRL instance'(Xbrl, Static_Data, Static_Data.start_date, Static_Data.end_date, Static_Data.report_currency, Sr.bs.current, Sr.pl.current, Sr.pl.historical, Sr.tb)),
	!add_xml_report(xbrl_instance, xbrl_instance, [Xbrl]).


balance_entries(
	Static_Data,				% Static Data
	Structured_Reports
) :-
	static_data_historical(Static_Data, Static_Data_Historical),
	maplist(!(check_transaction_account), Static_Data.transactions),
	!cf(trial_balance_between(Static_Data.exchange_rates, Static_Data.transactions_by_account, Static_Data.report_currency, Static_Data.end_date, Static_Data.start_date, Static_Data.end_date, Trial_Balance)),
	!cf(balance_sheet_at(Static_Data, Balance_Sheet)),
	!cf(balance_sheet_delta(Static_Data, Balance_Sheet_delta)),
	!cf(balance_sheet_at(Static_Data_Historical, Balance_Sheet2_Historical)),
	!cf(profitandloss_between(Static_Data, ProfitAndLoss)),
	!cf(profitandloss_between(Static_Data_Historical, ProfitAndLoss2_Historical)),
	!cf(cashflow(Static_Data, Cf)),

	Structured_Reports = _{
		pl: _{
			current: ProfitAndLoss,
			historical: ProfitAndLoss2_Historical
		},
		bs: _{
			current: Balance_Sheet,
			historical: Balance_Sheet2_Historical,
			delta: Balance_Sheet_delta /*todo crosscheck*/
		},
		tb: Trial_Balance,
		cf: Cf
	}.


static_data_historical(Static_Data, Static_Data_Historical) :-
	add_days(Static_Data.start_date, -1, Before_Start),
	Static_Data_Historical = Static_Data.put(
		start_date, date(1,1,1)).put(
		end_date, Before_Start).put(
		exchange_date, Static_Data.start_date).


 other_reports(
	Static_Data,
	Outstanding,
	Sr0,
	Sr5				% Structured Reports - Dict <Report Abbr : _>
) :-
	!cf(cf_page(Static_Data, Sr0.cf)),
	!cf('export GL'(Static_Data, Static_Data.transactions, Gl)),
	!cf(make_json_report(Gl, general_ledger_json)),
	!cf(make_gl_viewer_report),

	!cf(investment_reports(Static_Data.put(outstanding, Outstanding), Investment_Report_Info)),
	Sr1 = Sr0.put(ir, Investment_Report_Info),

	!cf(crosschecks_report0(Static_Data.put(reports, Sr1), Crosschecks_Report_Json)),
	Sr5 = Sr1.put(crosschecks, Crosschecks_Report_Json),
	!make_json_report(Sr1, reports_json).


 other_reports2(Report_prefix, Static_Data, Sr0) :-
	!static_data_historical(Static_Data, Static_Data_Historical),
	(	account_by_role(rl(smsf_equity), _)
	->	cf(smsf_member_reports(Report_prefix, Sr0))
	;	true),
	!report_entry_tree_html_page(Report_prefix, Static_Data, Sr0.bs.current, 'balance sheet', 'balance_sheet.html'),
	!report_entry_tree_html_page(Report_prefix, Static_Data, Sr0.bs.delta, 'balance sheet delta', 'balance_sheet_delta.html'),
	!report_entry_tree_html_page(Report_prefix, Static_Data_Historical, Sr0.bs.historical, 'balance sheet - historical', 'balance_sheet_historical.html'),
	!report_entry_tree_html_page(Report_prefix, Static_Data, Sr0.pl.current, 'profit and loss', 'profit_and_loss.html'),
	!report_entry_tree_html_page(Report_prefix, Static_Data_Historical, Sr0.pl.historical, 'profit and loss - historical', 'profit_and_loss_historical.html').



make_gl_viewer_report :-
	%format(user_error, 'make_gl_viewer_report..~n',[]),
	Viewer_Dir = 'general_ledger_viewer',
	!absolute_file_name(my_static(Viewer_Dir), Src, [file_type(directory)]),
	!report_file_path(loc(file_name, Viewer_Dir), loc(absolute_url, Dir_Url), loc(absolute_path, Dst)),

	/* symlink or copy, which one is more convenient depends on what we're working on */
	Cmd = ['ln', '-s', '-n', '-f', Src, Dst],
	%Cmd = ['cp', '-r', Src, Dst],

	%format(user_error, 'shell..~q ~n',[Cmd]),
	!shell4(Cmd, _),
	%format(user_error, 'shell.~n',[]),
	!atomic_list_concat([Dir_Url, '/link.html'], Full_Url),
	!add_report_file(0,'gl_html', 'GL viewer', loc(absolute_url, Full_Url)),
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
				(!investment_report_2_0(Sd, Suffix, Semantic_Json))
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
	!symlink_tmp_taxonomy_to_static_taxonomy(Unique_Taxonomy_Dir_Url),
	(	get_flag(prepare_unique_taxonomy_url, true)
	->	Taxonomy_Dir_Url = Unique_Taxonomy_Dir_Url
	;	Taxonomy_Dir_Url = 'taxonomy/'),
	!result_add_property(l:taxonomy_url_base, Taxonomy_Dir_Url).

 symlink_tmp_taxonomy_to_static_taxonomy(Unique_Taxonomy_Dir_Url) :-
	!my_request_tmp_dir(loc(tmp_directory_name,Tmp_Dir)),
	!server_public_url(Server_Public_Url),
	!atomic_list_concat([Server_Public_Url, '/tmp/', Tmp_Dir, '/taxonomy/'], Unique_Taxonomy_Dir_Url),
	!absolute_tmp_path(loc(file_name, 'taxonomy'), loc(absolute_path, Tmp_Taxonomy)),
	!resolve_specifier(loc(specifier, my_static('taxonomy')), loc(absolute_path,Static_Taxonomy)),
	Cmd = ['ln', '-s', '-n', '-f', Static_Taxonomy, Tmp_Taxonomy],
	%format(user_error, 'shell..~q ~n',[Cmd]),
	!shell4(Cmd, _).
	%format(user_error, 'shell.~n',[]).

	
/*

	extraction of input data from request xml
	
*/	
   
 extract_report_currency(Report_Currency) :-
	!request_data(Request_Data),
	doc(Request_Data, ic_ui:report_details, D),
	doc_value(D, ic:currency, C),
	atom_string(Ca, C),
	Report_Currency = [Ca],
	!result_add_property(l:report_currency, Report_Currency).

/*
 If an investment was held prior to the from date then it MUST have an opening market value if the reports are expressed in market rather than cost. You can't mix market value and cost in one set of reports. One or the other.
 Market or Cost. M or C.
 Cost value per unit will always be there if there are units of anything i.e. sheep for livestock trading or shares for Investments. But I suppose if you do not find any market values then assume cost basis.
*/

 'extract "cost_or_market"' :-
	!request_data(Request_Data),
	doc(Request_Data, ic_ui:report_details, D),
	doc_value(D, ic:cost_or_market, C),
	(	rdf_equal2(C, ic:cost)
	->	Cost_Or_Market = cost
	;	Cost_Or_Market = market),
	!doc_add($>result, l:cost_or_market, Cost_Or_Market).
	
 'extract "output_dimensional_facts"'(Output_Dimensional_Facts) :-
	!doc_add($>result, l:output_dimensional_facts, on).
	
 extract_start_and_end_date :-
	!request_data(Request_Data),
	!doc(Request_Data, ic_ui:report_details, D),
	!read_date(D, ic:from, Start_Date),
	!read_date(D, ic:to, End_Date),
	!result(R),
	!doc_add(R, l:start_date, Start_Date),
	!doc_add(R, l:end_date, End_Date).

 extract_request_details :-
	!result(Result),
	!get_time(TimeStamp),
	!stamp_date_time(TimeStamp, DateTime, 'UTC'),
	!doc_add(Result, l:timestamp, DateTime).

/*
:- comment(Structured_Reports:
	the idea is that the dicts containing the high-level, semantic information of all reports would be passed all the way up, and we'd have some test runner making use of that / generating a lot of permutations of requests and checking the results computationally, in addition to endpoint_tests checking report files against saved versions.
update: instead of passing json around, we should focus on doc-izing everything.
*/



/* a little debugging facitliy that tries processing s_transactions one by one until it runs into an error */
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
	;	(g trace,format(user_error, '~q: ~q ~n', [Count, Structured_Reports.crosschecks.errors]))).*/
