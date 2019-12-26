:- use_module(library(http/html_write)).

%:- rdet(report_page/4).
%:- rdet(report_page_with_table/4).
%:- rdet(report_section/3).
%:- rdet(html_tokenlist_string/2).
%:- rdet(report_file_path/3).


html_tokenlist_string(Tokenlist, String) :-
	setup_call_cleanup(
		new_memory_file(X),
		(
			open_memory_file(X, write, Mem_Stream),
			print_html(Mem_Stream, Tokenlist),
			close(Mem_Stream),
			memory_file_to_string(X, String)
		),
		free_memory_file(X)).

/*TODO rename*/
report_item(File_Name, Text, Url) :-
	report_file_path(File_Name, Url, File_Path),
	write_file(File_Path, Text).

report_section(File_Name, Html_Tokenlist, Url) :-
	html_tokenlist_string(Html_Tokenlist, Html_String),
	report_item(File_Name, Html_String, Url).

report_page_with_table(Title_Text, Tbl, File_Name, Id) :-
	report_page(Title_Text, [Title_Text, ':', br([]), table([border="1"], Tbl)], File_Name, Id).
	
report_page(Title_Text, Body_Tags, File_Name, Id) :-
	Page = page(
		title([Title_Text]),
		link([
			type('text/css'),
			rel('stylesheet'),
			href('../../static/report_stylesheet.css')
		]),
		Body_Tags),
	phrase(Page, Page_Tokenlist),
	report_section(File_Name, Page_Tokenlist, Url),
	report_entry(Title_Text, Url, Id).
	
report_entry(Title_Text, Url, Id) :-
	add_report_file(Id, Title_Text, Url).


make_json_report(Dict, Fn) :-
	Title = Key, Fn = Key,
	dict_json_text(Dict, Json_Text),
	atomic_list_concat([Fn, '.json'], Fn2_Value),
	Fn2 = loc(file_name, Fn2_Value),
	report_item(Fn2, Json_Text, Report_File_URL),
	report_entry(Title, Report_File_URL, Key).
