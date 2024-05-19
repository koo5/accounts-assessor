
## more resources:

https://businessecon.org/2016/03/14/bookkeeping-complex-entries-lesson-15/


https://beancount.github.io/docs/the_double_entry_counting_method.html

## nomenclature

from https://www.accountingtools.com/articles/what-is-a-journal-entry.html:
"""The structural rules of a journal entry are that there must be a minimum of two line items in the journal entry, and that the total amount you enter in the debit column equals the total amount entered in the credit column."""

"""A compound journal entry is an accounting entry in which there is more than one debit, more than one credit, or more than one of both debits and credits. It is essentially a combination of several simple journal entries;"""

Well, thats confusing. Better resources are welcome. Meanwhile, i am proposing this nomenclature, to be introduced on an occasion of a rewrite or similar:

A "Line": our current transaction() term. It only afects one account.
An "Entry": a list of lines. Arbitrarily many accounts involved.
a bst() term: current s_transaction, that is, statement transaction, that is, bank statement transaction


## examples of transaction types
https://businessecon.org/2016/03/14/bookkeeping-complex-entries-lesson-15/
https://www.accountingtools.com/articles/what-are-examples-of-key-journal-entries.html

todo explore the tagging systems mentioned here: https://news.ycombinator.com/item?id=20109545


## inventory
https://www.accountingcoach.com/blog/purchases-inventory


## Difference transactions


the simple kind of transaction on the ledger could be called "instant". A set of these debits and credits some accounts, their sum total is zero, but the presence of those transactions change the balances of the accounts.

a difference transaction, on the other hand, might have: coord(USD, 10, 0), coord(AUD, 0, 13).

an income might be recorded on the ledger like so:
assets CR 10USD
income DR 13AUD

10USD might correspond to 13AUD at the day of the transaction, but the as the exchange rate changes, the difference transaction amounts to the change. 



## AR / AP
```
new data types:
	sales statement (for methods A and B) has:
		method (A or B), implies transaction verbs
		entries 
			optional date
			item count
			item type
			total cost
				value
				currency

	invoices?


new transaction verbs:
	all verbs must have a numeric parameter "GST percent".
	
method A:
	sales statement is the source of the transactions.
	inventory (non-monetary account) is involved.
	transaction verb: purchase_method_A
		parameters:
			cr Liabilities->Accounts Payable
			dr Assets->Inventory (money account)
			dr GST Receivable

	transaction verb: sale_method_A
		parameters:
			dr Assets->Accounts Receivable
			cr Assets->Inventory (money account)
			cr GST Payable
			cr Revenue
			dr COGS

method B:
	sales statement is the source of the transactions.
	transaction verb: purchase_method_B
		parameters:
			cr Liabilities->Accounts Payable
			dr Expenses->Purchases
			dr GST Receivable
	transaction verb: sale_method_B
		parameters:
			dr Assets->Accounts Receivable
			cr Revenue
			cr GST Payable
	period-end adjustment transaction: dr Assets->Inventory, cr COGS

method C:
	same as method B, but bank is involved instead of AP/AR.
	bank statement is the source of the transactions.
	transaction verb: purchase_method_C
		parameters:
			cr bank
	transaction verb: sale_method_C
		parameters:
			dr bank

```


