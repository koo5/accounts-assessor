```
Understanding the Differences Between Consolidated and Combined Financial Statements
	https://blog.embarkwithus.com/understanding-the-differences-between-consolidated-and-combined-financial-statements

https://www.google.com/search?channel=fs&client=ubuntu&q=intercompany+elimination
	- Intercompany elimination is the process that a parent company goes through in order to remove transactions between subsidiary companies in a group. Parent companies complete intercompany eliminations when they're preparing consolidated financial statements.

	https://www.softwaretestinghelp.com/financial-consolidation-software/


	https://www.youtube.com/watch?v=-aEDyuNwVB0
	https://www.youtube.com/watch?v=FJC_M2I7T7M
	https://www.youtube.com/watch?v=HRtWSfMpwQY
	https://blogs.sap.com/2020/09/09/group-reporting-intercompany-elimination-accounting-entries/
	https://blog.trginternational.com/trg-in-the-board-room/bid/182177/Financial-consolidation-Dealing-with-minority-interest?
	https://docs.oracle.com/en/cloud/saas/financial-consolidation-cloud/agfcc/intercompany_eliminations.html


let's say we simply run multiple requests as is coming from user. Each point of data naturally belongs (at least through its context) to an l:Request that will have l:entity <something>.

I.e. where entity a sold goods to entity b

Dr revenue in a and credit cost of goods in b.

Nullifies the inter entity activity



"""
1) sale of goods between the subsidiaries of a parent company, this intercompany sale must be eliminated from the consolidated financial statements. 

2) Another common intercompany elimination is when the parent company pays interest income to the subsidiaries whose cash it is using to make investments; this interest income must be eliminated from the consolidated financial statements."""
- https://www.accountingtools.com/articles/what-are-consolidated-financial-statements.html (modified)

https://www.accountingtools.com/articles/intercompany-accounting.html



"intersubsidiary"?



"In consolidated income statements, eliminate intercompany revenue and cost of sales arising from the transaction. In the consolidated balance sheet, eliminate intercompany payable and receivable. Profits and losses are eliminated against noncontrolling and controlling interest proportionally."


" No intercompany receivables, payables, investments, capital, revenue, cost of sales, or profits and losses are recognised in consolidated financial statements "


"
The total amount of unrealised profits/loss to be eliminated in intercompany transactions does not vary regardless of whether the subsidiary is wholly-owned (non-controlling interest, NCI, does not exist) or partially owned. However, if the subsidiary is partially owned (i.e., NCI exists), the elimination of such profit/loss may be allocated between the majority and minority interests.
"



- https://blog.trginternational.com/financial-consolidation-dealing-with-intercompany-transactions


https://blog.trginternational.com/what-is-intercompany-accounting#intercompanyreconciliationwaystoovercomethechallenges


txs(just generally):
	buy_merchandise:
		acct: <bank> (cr)
		counteracct: <inventory> (dr)
		
	sell_merchandise:
		acct: <bank> (dr)
		inventory acct: <inventory> (cr)
		
		counteracct: <revenue> (cr)
		
		
		
```