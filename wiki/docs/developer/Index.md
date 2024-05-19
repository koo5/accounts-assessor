
## architecture
there are 4 main components:

### services
various helper functions that prolog invokes over http/rpc

### workers
a remoulade worker that:
* wraps prolog and spawns prolog on request
* talks to the triplestore

### frontend
lets users upload request files and triggers workers.

### apache
serves static files and proxies requests to frontend


`

## directory structure

* source/lib - prolog source code
* tests
** plunit - contains queries that test the functionality of the main Prolog program
** endpoint_tests - contains test requests for the web endpoint as well as expected reponses
* misc - contains the stuff that does not yet clearly fit into a category
* server_root - this directory is served by the prolog server
** tmp - each request gets its own directory here
** taxonomy - contains all xbrl taxonomy files.
** schemas - xsd schemas



## version 2.0

A new version is planned, using a constrained logic programming language, aiming for these features:

Derives, validates, and corrects the financial information that it is given. The program uses redundancy to carry out its validations and corrections. By this it is meant that knowledge of parts of a company's financial data imposes certain constraints on the company's other financial data. If the program is given a company's ledger, then it knows what the balance sheet should look like. If the program is given a company's balance sheet, then it has a rough idea of what the ledger should look like.

* Given a hire purchase arrangement and ledger, it can guess what the erroneous transactions are
* Given a hire purchase arrangement and ledger, it can generate correction transactions to fix the erroneous transactions
...

