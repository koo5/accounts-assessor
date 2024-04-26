## Difference transactions


the simple kind of transaction on the ledger could be called "instant". A set of these debits and credits some accounts, their sum total is zero, but the presence of those transactions change the balances of the accounts.

a difference transaction, on the other hand, might have: coord(USD, 10, 0), coord(AUD, 0, 13).

an income might be recorded on the ledger like so:
assets CR 10USD
income DR 13AUD

10USD might correspond to 13AUD at the day of the transaction, but the as the exchange rate changes, the difference transaction amounts to the change. 

