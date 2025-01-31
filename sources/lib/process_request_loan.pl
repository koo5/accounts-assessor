
 process_request_loan_rdf :-
	ct(
		"is this a Div7A Calculator query?",
		?get_optional_singleton_sheet_data(div7a_ui:sheet, Loan)
	),

	!doc(Loan, div7a:income_year_of_loan_creation, CreationIncomeYearNumber),
	absolute_day(date(CreationIncomeYearNumber, 7, 1), NCreationIncomeYear),

    !doc(Loan, div7a:full_term_of_loan_in_years, Term),

	/* exactly one of PrincipalAmount or OpeningBalance must be provided */
	/* or we can loosen this requirement, and ignore principal if both are provided */
	(	doc(Loan, div7a:principal_amount_of_loan, Amount)
	->	(	doc(Loan, div7a:opening_balance, OB)
		->	throw_string('both principal amount and opening balance provided')
		;	OB = false)
	;	(	doc(Loan, div7a:opening_balance, OB)
		->	Amount = false
		;	throw_string('no principal amount and no opening balance provided'))),

	absolute_days($>!doc(Loan, div7a:lodgement_day_of_private_company), NLodgementDate),

    !doc(Loan, div7a:income_year_of_computation, ComputationYearNumber),
    calculate_computation_year2(ComputationYearNumber, CreationIncomeYearNumber, NComputationYearIdx),
    maplist(convert_loan_rdf_repayments, $>!doc_list_items($>!doc(Loan, div7a:repayments)), Repayments),

	loan_agr_summary(loan_agreement(
		% loan_agr_contract_number:
		0,
		% loan_agr_principal_amount:
		Amount,
		% loan_agr_lodgement_day:
		NLodgementDate,
		% loan_agr_begin_day:
		NCreationIncomeYear,
		% loan_agr_term (length in years):
		Term,
		% loan_agr_computation_year
		NComputationYearIdx,

		OB,
		% loan_agr_repayments (list):
		Repayments),
		% output:
		Summary),

	div7a_rdf_result(ComputationYearNumber, Summary).


div7a_rdf_result(ComputationYearNumber, Summary) :-

    Summary = loan_summary(_Number, OpeningBalance, InterestRate, MinYearlyRepayment, TotalRepayment,RepaymentShortfall, TotalInterest, TotalPrincipal, ClosingBalance),

	Row = _{
		income_year: ComputationYearNumber,
		opening_balance: OpeningBalance,
		interest_rate: InterestRate,
		min_yearly_repayment: MinYearlyRepayment,
		total_repayment: TotalRepayment,
		repayment_shortfall: RepaymentShortfall,
		total_interest: TotalInterest,
		total_principal: TotalPrincipal,
		closing_balance: ClosingBalance
	},

	Cols = [
		column{id:income_year, title:"income year", options:_{}},
		column{id:opening_balance, title:"opening balance", options:_{}},
		column{id:interest_rate, title:"interest rate", options:_{}},
		column{id:min_yearly_repayment, title:"min yearly repayment", options:_{}},
		column{id:total_repayment, title:"total repayment", options:_{}},
		column{id:repayment_shortfall, title:"repayment shortfall", options:_{}},
		column{id:total_interest, title:"total interest", options:_{}},
		column{id:total_principal, title:"total principal", options:_{}},
		column{id:closing_balance, title:"closing balance", options:_{}}
	],

	Table_Json = _{title_short: "Div7A", title: "Division 7A", rows: [Row], columns: Cols},
	!table_html([], Table_Json, Table_Html),
   	!page_with_table_html('Div7A', Table_Html, Html),
   	!add_report_page(0, 'Div7A', Html, loc(file_name,'summary.html'), 'summary.html').
	%!add_result_sheets_report($>doc_default_graph)... this will require an on-the-fly conversion from table json to rdf templates + data.



 convert_loan_rdf_repayments(I, loan_repayment(Days,  Value)) :-
 	absolute_days($>!doc_value(I, div7a_repayment:date), Days),
 	$>!doc_value(I, div7a_repayment:value, Value).



 process_request_loan(Request_File, DOM) :-

	% startDate and endDate in the request xml are ignored.
	% they are not used in the computation.

	/* for example 2014 */
	xpath(DOM, //reports/loanDetails/loanAgreement/field(@name='Income year of loan creation', @value=CreationIncomeYear), _E1),

	% yep, seems to be a loan request xml.
	validate_xml2(Request_File, 'bases/Reports.xsd'),

	/* for example 5 */
	xpath(DOM, //reports/loanDetails/loanAgreement/field(@name='Full term of loan in years', @value=Term), _E2),

	/* for example 100000, or left undefined if opening balance is specified */
	(xpath(DOM, //reports/loanDetails/loanAgreement/field(@name='Principal amount of loan', @value=PrincipalAmount), _E3)->true;true),

	/* for example 2014-07-01 */
	(	xpath(DOM, //reports/loanDetails/loanAgreement/field(@name='Lodgement day of private company', @value=LodgementDateStr), _E4)
	->	true
	;	true),

	/* for example 2018 */
	xpath(DOM, //reports/loanDetails/loanAgreement/field(@name='Income year of computation', @value=ComputationYear), _E5),

	/* opening balance is understood to be for the year of computation. Therefore, if term is 2 or more years, lodgement date can be ignored, which should be equivalent to setting it to 1 July of the year of after loan creation. */
	(	xpath(DOM, //reports/loanDetails/loanAgreement/field(@name='Opening balance of computation', @value=OB), _E6)
	->	OpeningBalance = OB
	;	OpeningBalance = -1),

	% need to handle empty repayments/repayment, needs to be tested
	findall(loan_repayment(Date, Value), xpath(DOM, //reports/loanDetails/repayments/repayment(@date=Date, @value=Value), _E7), LoanRepayments),
	atom_number(ComputationYear, NIncomeYear),

	(	(
%			(	ground(LodgementDateStr)
%			->	parse_date(LodgementDateStr, LodgementDate)
%			;	(
%					LodgementDateYear is CreationIncomeYear,
%					LodgementDate = date(LodgementDateYear, 7, 1)
%				)
%			),
%			convert_loan_inputs(
%				% inputs
%				CreationIncomeYear,  Term,  PrincipalAmount,  LodgementDate,  ComputationYear,  OpeningBalance,  LoanRepayments,
%				% converted inputs
%				NCreationIncomeYear, NTerm, NPrincipalAmount, NLodgementDate, NComputationYear, NOpeningBalance, NLoanRepayments),
%			loan_agr_summary(
%				loan_agreement(
%					% loan_agr_contract_number:
%					0,
%					% loan_agr_principal_amount:
%					NPrincipalAmount,
%					% loan_agr_lodgement_day:
%					NLodgementDate,
%					% loan_agr_begin_day:
%					NCreationIncomeYear,
%					% loan_agr_term (length in years):
%					NTerm,
%					% loan_agr_computation_year
%					NComputationYear,
%
%					NOpeningBalance,
%					% loan_agr_repayments (list):
%					NLoanRepayments
%				),
%				Summary
%			),
%
% ✀--------------------------------------------
			(var(PrincipalAmount) -> PrincipalAmount = -1; true),
			(var(LodgementDateStr) -> LodgementDateStr = -1; true),
			!loan_agr_summary_python(div7a{
				term: Term,
				principal_amount: PrincipalAmount,
				lodgement_date: LodgementDateStr,
				creation_income_year: CreationIncomeYear,
				computation_income_year: ComputationYear,
				opening_balance: OpeningBalance,
				repayments: $>repayments_to_json(LoanRepayments)
			}, Summary)
		)
	->	display_xml_loan_response(NIncomeYear, Summary)
	;	(
			LoanResponseXML = "<error>calculation failed</error>\n",
			report_file_path(loc(file_name, 'response.xml'), Url, Path, _),
			loc(absolute_path, Raw) = Path,
			open(Raw, write, XMLStream),
			write(XMLStream, LoanResponseXML),
			close(XMLStream),
			add_report_file(0,'result', 'result', Url)
		)
	)
	.


loan_agr_summary_python(LA, Summary) :-
	!ground(LA),
	my_request_tmp_dir_path(Tmp_Dir_Path),
	services_rpc('div7a', _{tmp_dir_path:Tmp_Dir_Path,data:LA}, R),
	(	_{
			opening_balance: OpeningBalance,
			interest_rate: InterestRate,
			min_yearly_repayment: MinYearlyRepayment,
			total_repayment: TotalRepayment,
			repayment_shortfall: RepaymentShortfall,
			total_interest: TotalInterest,
			total_principal: TotalPrincipal,
			closing_balance: ClosingBalance
		} :< R
	->	true
	;	throw_string(R)),
    Summary = loan_summary(_Number, OpeningBalance, InterestRate, MinYearlyRepayment, TotalRepayment, RepaymentShortfall, TotalInterest, TotalPrincipal, ClosingBalance).
    

repayments_to_json(LoanRepayments, Json) :-
	maplist(repayment_to_json, LoanRepayments, Json).


repayment_to_json(Repayment, Json) :-
	Repayment = loan_repayment(Date, Value),
	Json = repayment{date:Date, value:Value}.


 display_xml_loan_response(IncomeYear, LoanSummary) :-
	xml_loan_response(IncomeYear, LoanSummary, LoanResponseXML),

	report_file_path(loc(file_name, 'response.xml'), Url, Path, _),
	loc(absolute_path, Raw) = Path,

	% create a temporary loan xml file to validate the response against the schema
	open(Raw, write, XMLStream),
	write(XMLStream, LoanResponseXML),
	close(XMLStream),

	% read the schema file
	resolve_specifier(loc(specifier, my_schemas('responses/LoanResponse.xsd')), LoanResponseXSD),
	!validate_xml(Path, LoanResponseXSD, []),
	add_report_file(0,'result', 'result', Url).



xml_loan_response(
	IncomeYear,
	loan_summary(_Number, OpeningBalance, InterestRate, MinYearlyRepayment, TotalRepayment,RepaymentShortfall, TotalInterest, TotalPrincipal, ClosingBalance),
	LoanResponseXML
) :-

	ground(x(IncomeYear, OpeningBalance, InterestRate, MinYearlyRepayment, TotalRepayment,RepaymentShortfall, TotalInterest, TotalPrincipal, ClosingBalance)),
	var(LoanResponseXML),

	format(string(LoanResponseXML),
'<?xml version="1.0" ?>\n<LoanSummary xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="loan_response.xsd">\n\c
   <IncomeYear>~q</IncomeYear>\n\c
   <OpeningBalance>~f8</OpeningBalance>\n\c
   <InterestRate>~f8</InterestRate>\n\c
   <MinYearlyRepayment>~f8</MinYearlyRepayment>\n\c
   <TotalRepayment>~f8</TotalRepayment>\n\c
   <RepaymentShortfall>~f8</RepaymentShortfall>\n\c
   <TotalInterest>~f8</TotalInterest>\n\c
   <TotalPrincipal>~f8</TotalPrincipal>\n\c
   <ClosingBalance>~f8</ClosingBalance>\n\c
</LoanSummary>\n',

   [IncomeYear,
	OpeningBalance,
	InterestRate,
	MinYearlyRepayment,
	TotalRepayment,
	RepaymentShortfall,
	TotalInterest,
	TotalPrincipal,
	ClosingBalance]).



% ===================================================================
% Various helper predicates
% ===================================================================

% -------------------------------------------------------------------
% convert_loan_inputs/14
% -------------------------------------------------------------------

 convert_loan_inputs(CreationIncomeYear,  Term,  PrincipalAmount,  LodgementDate,  ComputationYear,  OpeningBalance,  LoanRepayments,
		      NCreationIncomeYear, NTerm, NPrincipalAmount, NLodgementDate, NComputationYear, NOpeningBalance, NLoanRepayments
) :-
	generate_absolute_days(CreationIncomeYear, LodgementDate, LoanRepayments, NCreationIncomeYear, NLodgementDate, NLoanRepayments),
	compute_opening_balance(OpeningBalance, NOpeningBalance),
	calculate_computation_year(ComputationYear, CreationIncomeYear, NComputationYear),
	(	nonvar(PrincipalAmount)
	->	atom_number(PrincipalAmount, NPrincipalAmount)
	;	NPrincipalAmount = -1),
	atom_number(Term, NTerm).



 generate_absolute_days(CreationIncomeYear, LodgementDate, LoanRepayments, NCreationIncomeYear, NLodgementDay, NLoanRepayments) :-
	generate_absolute_day(creation_income_year, CreationIncomeYear, NCreationIncomeYear),
	absolute_day(LodgementDate, NLodgementDay),
	generate_absolute_day(loan_repayments, LoanRepayments, NLoanRepayments).

 generate_absolute_day(creation_income_year, CreationIncomeYear, NCreationIncomeYear) :-
	atom_number(CreationIncomeYear, CreationIncomeYearNumber),
	absolute_day(date(CreationIncomeYearNumber, 7, 1), NCreationIncomeYear).



 % convert a list of loan_repayment terms with textual dates and values into a list of loan_repayment terms with absolute days and numeric values

 generate_absolute_day(loan_repayments, [], []).

 generate_absolute_day(loan_repayments, [loan_repayment(Date, Value)|Rest1], [loan_repayment(NDate, NValue)|Rest2]) :-
	parse_date_into_absolute_days(Date, NDate),
	atom_number(Value, NValue),
	generate_absolute_day(loan_repayments, Rest1, Rest2).


% ----------------------------------------------------------------------
% compute_opening_balance/2
% ----------------------------------------------------------------------

 compute_opening_balance(OpeningBalance, NOpeningBalance) :-
	(	OpeningBalance = -1
	->	NOpeningBalance = false
	;	atom_number(OpeningBalance, NOpeningBalance)).

% ----------------------------------------------------------------------
% calculate_computation_year/3
%
% Computation year is calculated as it is done in:
%	- ConstructLoanAgreement function (PrologEngpoint/LoanController.cs)
% ----------------------------------------------------------------------

 calculate_computation_year(ComputationYear, CreationIncomeYear, NComputationYear) :-
	atom_number(ComputationYear, NCY),
	atom_number(CreationIncomeYear, NCIY),
	calculate_computation_year2(NCY, NCIY, NComputationYear).

calculate_computation_year2(NCY, NCIY, NComputationYear) :-
	NComputationYear is NCY - NCIY - 1.
