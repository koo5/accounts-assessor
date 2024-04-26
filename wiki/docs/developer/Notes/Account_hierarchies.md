
```
basic usecases:
1) a request specifying taxonomies explicitly
2) a request without any account information, using the default taxonomy. This is just a case of the default investment calculator template containing a sheet referencing the default taxonomy.

referencing multiple taxonomies:
	some things we will have to specify in an additional taxonomy:
		some accounts need to specify where they attach in the hierarchy
		if there are account id's that the system would not expect by default:
			specify if account id's are to be takes as roles
			specify what account id's are not to be taken as roles, selectively
			specify what account id's are to be taken as roles, selectively
			remap id's
			specify normal_side

eventually we would deal with:
	specifying dependencies between taxonomies
	loading taxonomies in correct order
and orthogonal concerns:
	making all this interactive, possibly including system-account generation
	doing this on xbrl taxonomies
	doing this on an easily-editable xml tree structure?


architectually, i'd keep the system-accounts-generating code in prolog (ie accounts for banks, livestock types..), because we'll probably want to switch to generating them on the fly, rather that up front. But any logic dealing with any DSL for assembling account hierarchies should be standalone, probably in python, and prolog should simply load one file with everything worked out.


```

/*
The root account has id 'root' and role 'root'.
our logic does not seem to ever need to care about the structure of the tree, only about identifying appropriate accounts - but there are cases when relying on a certain structure would make things easier, for example in crosschecks.

the program can also create sub-accounts from the specified account at runtime as needed, for example for livestock types
*/
