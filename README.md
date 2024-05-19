[](mrkev2query: "
the “Accounts Assessor” below corresponds to:
products:robust kb:project_name ?x. 
?x rdf:value ?y.
")

# Robust
## introduction

[](mrkev2entity: "
the “This repository” below corresponds to:
codebases:labs_accounts_assessor
")

Robust represents practical research into leveraging logic programming and RDF to solve accounting problems.
The core logic runs in SWI-Prolog, and is aided by several smaller python codebases.

We use it at http://www.nobleaccounting.com.au to automate reporting and auditing tasks.

Several services are available:

[](mrkev2extra: "
products:accounts_assessor kb:has_service kb:investment_calculator
")

[](mrkev2query: "
the “investment calculator” below corresponds to:
investment calculator kb:investment_calculator rdfs:label ?x.
")

* investment calculator
* hirepurchase agreement
* depreciation
* livestock (standalone)
* division 7A loan calculator


## investment calculator ("ledger")
The most complex endpoint is the investment calculator; it validates and processes financial data of a financial entity for a given period:
* bank statements
* general ledger transactions
* forex and investments
* Australian SMSF accounting
* livestock accounting

![screenshot](wiki/img/readme/ic-sheets.png?raw=true)

It automates some accounting procedures, like tax calculations, and generates balance sheets, trial balances, investment report and other types of reports.

![screenshot](wiki/img/readme/ic-result.png?raw=true)


## livestock calculator
![screenshot](wiki/img/readme/livestock-standalone-sheet.png?raw=true)
![screenshot](wiki/img/readme/livestock-standalone-result.png?raw=true)


## depreciation calculator
![screenshot](wiki/img/readme/depreciation-sheets.png?raw=true)
![screenshot](wiki/img/readme/depreciation-result.png?raw=true)


## hirepurchase calculator
![screenshot](wiki/img/readme/hp-sheet.png?raw=true)
(todo: UI)

Given a hire purchase arrangement, it can track the balance of a hire purchase account through time, the total payment and the total interest.

## Division 7A Loan calculator
![screenshot](wiki/img/readme/Div7A-sheet.png?raw=true)

![screenshot](wiki/img/readme/Div7A-result.png?raw=true)




## chatbot services
* determine tax residency by carrying out a dialog with the user
* determine small business entity status by carrying out a dialog with the user



# in detail

## running the server with docker

1) `git clone --recurse-submodules https://github.com/lodgeit-labs/accounts-assessor/`
2) `docker_scripts/up.sh`

## usage

#### with Excel and LSU plugin
[https://github.com/koo5/accounts-assessor-public-wiki/blob/master/excel_usage/README.md](https://github.com/koo5/accounts-assessor-public-wiki/blob/master/excel_usage/README.md)

#### with OneDrive explorer
navigate to https://robust1.ueueeu.eu/static/onedrive-explorer-js/ and log in. Log into OneDrive, the choose a file and click "run investment calculator".

#### through file upload form
1) Load http://localhost:8877/view/upload_form in your browser
2) upload one of the example input files

#### with curl
```
curl -F file1=@'tests2/endpoint_tests/loan/single_step/loan-0/request/request.xml' http://localhost:8877/upload
```

#### with test runner
see [tests2/runner/README.md](tests2/runner/README.md)

#### through a custom GPT
we have an experimental endpoint for [custom GPT](https://openai.com/blog/introducing-gpts), which you can register as an "action" - https://robust1.ueueeu.eu/ai3/openapi.json - see [/wiki/CustomGPT.md]


## example input files
excel_usage
* `tests/endpoint_tests/**/inputs/*`




## documentation
[wiki](wiki)

videos:
https://www.dropbox.com/sh/prgubjzoo9zpkhp/AACd6YmoWxf9IUi5CriihKlLa?dl=0

https://www.dropbox.com/sh/o5ck3qm79zwgpc5/AABD9jUcWiNpWMb2fxsmeVfia?dl=0

[Robust technical overview](https://www.youtube.com/playlist?list=PL1BSZVqCNKEu1tLZYSa_gAbbXpRV7KAa5)



## todo: comparisons to other projects
* https://github.com/johannesgerer/buchhaltung
* gnu cash
...

## Contributors ✨

<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-5-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="https://github.com/sto0pkid"><img src="https://avatars2.githubusercontent.com/u/9160425?v=4" width="100px;" alt=""/><br /><sub><b>stoopkid</b></sub></a><br /><a href="#infra-sto0pkid" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="https://github.com/lodgeit-labs/accounts-assessor/commits?author=sto0pkid" title="Tests">⚠️</a> <a href="https://github.com/lodgeit-labs/accounts-assessor/commits?author=sto0pkid" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/Schwitter"><img src="https://avatars3.githubusercontent.com/u/8089563?v=4" width="100px;" alt=""/><br /><sub><b>Schwitter</b></sub></a><br /><a href="#infra-Schwitter" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="https://github.com/lodgeit-labs/accounts-assessor/commits?author=Schwitter" title="Tests">⚠️</a> <a href="https://github.com/lodgeit-labs/accounts-assessor/commits?author=Schwitter" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/salamt2"><img src="https://avatars0.githubusercontent.com/u/2647629?v=4" width="100px;" alt=""/><br /><sub><b>salamt2</b></sub></a><br /><a href="#infra-salamt2" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="https://github.com/lodgeit-labs/accounts-assessor/commits?author=salamt2" title="Tests">⚠️</a> <a href="https://github.com/lodgeit-labs/accounts-assessor/commits?author=salamt2" title="Code">💻</a></td>
    <td align="center"><a href="http://github.com/murisi"><img src="https://avatars0.githubusercontent.com/u/6886764?v=4" width="100px;" alt=""/><br /><sub><b>Murisi Tarusenga</b></sub></a><br /><a href="#infra-murisi" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="https://github.com/lodgeit-labs/accounts-assessor/commits?author=murisi" title="Tests">⚠️</a> <a href="https://github.com/lodgeit-labs/accounts-assessor/commits?author=murisi" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/koo5"><img src="https://avatars1.githubusercontent.com/u/114276?v=4" width="100px;" alt=""/><br /><sub><b>koo5</b></sub></a><br /><a href="#infra-koo5" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="https://github.com/lodgeit-labs/accounts-assessor/commits?author=koo5" title="Tests">⚠️</a> <a href="https://github.com/lodgeit-labs/accounts-assessor/commits?author=koo5" title="Code">💻</a></td>
  </tr>
</table>

<!-- markdownlint-enable -->
<!-- prettier-ignore-end -->
<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!


[](mrkev2extra: "
products:robust kb:has_codebase codebases:labs_accounts_assessor.
products:robust kb:has_codebase codebases:LodgeITSmart.
")





