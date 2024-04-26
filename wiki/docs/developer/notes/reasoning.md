# CNLS and reasoning

"and the event is a transfer of an asset by a transferor to a transferee"
"the event"
 - anaphoric reference
"a transfer of an asset by a transferor to a transferee"
 - i think this has to be (or is best) defined as a rigid syntax for something like a compound term or an existential variable in bwd chaining: "a transfer of <something> by <transferor> to <transferee>"
 
 
 now, the main problem with current CNLs is that syntax is actually used to convey meaning. This is different from programming languages, where syntax is only something simple and superficial, and all action is actually in choices of names that are used and referenced.
 Therefore, a programming language IDE doesn't bother autocompleting syntax in the sense of users wanting to know "what are all the syntactic structures that i could use here (here = at caret position). But with CNLs, this is crucial.
 
 




presumably, at some point of development, we'll be able to have a named graph where we'll keep up-to-date financial information of a bunch of companies, + exchange rates..
Each with a different timestamp and trust, though...


"what is the current value of MSFT?"
	such query has to deal with the issue of what data is the latest, and how old it really is, by itself, so, there has to be no opaque one-size-fits-all layer doing this decision.












backward:
	
	
	
	
	
	
	
	
	
forward:
	you may want to have destructive semantics:
		if
			X is a l:transaction,
			and X has action_verb V,
			and L is a rdf:value of V,
			and C is a rdfs:subclass of LBO:Cattle
			and C has rdf:label L
			(in other words, if a transaction has action_verb string that is also a label of a LBO:Cattle subclass)
		then
			the X ...
			
			
			
	====
	
	fwd chaining could/should be equivalent with querying for ?s ?p ?o ?g. The result is a new kb with all that could be inferred.




# how to make the reasoning process, and, the processed and generated data more accessible?

the reasoner can have "plug-in" points, kind of like AOP, poossibly trigerred by a matcher on a context trace item:
	user has a sheet that says: after "extract_bank_accounts", execute rules: ...
	this effectively augments the hardcoded bwd chaining query process, not in a way that allows overriding the hardcoded rules, but at least allows users to influence the data. Or do we actually allow arbitrary manipulation of the hardcoded rules? 
		"""Instead of "make_transaction2", use rule xxxxx...."""
		"""make_transaction2 is also: ......"""
	
	
	rules could be triggered after request is loaded, after it's processed, and in join points in-between.
	
	





# cattle unit inference
https://dbpedia.org/page/Beef
https://dbpedia.org/page/List_of_cattle_breeds
https://dbpedia.org/page/Ankole_(cattle)
https://github.com/AnimalGenome/livestock-breed-ontology
https://www.ebi.ac.uk/ols/ontologies/lbo



# code editing
http://attempto.ifi.uzh.ch/race/
https://blockyquery.toolforge.org/










# Some declarative approaches in tackling hard combinatorial problems
http://users.dimi.uniud.it/~agostino.dovier/CLPASP/
