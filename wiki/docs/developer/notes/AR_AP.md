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