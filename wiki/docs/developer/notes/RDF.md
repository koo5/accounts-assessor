see also https://github.com/koo5/hackery2/blob/master/notes2/rdf.md 
and https://github.com/koo5/hackery2/blob/master/notes2/graph_visualization


# how to edit RdfTemplates.n3

LodgeITSmart is where the master version of `RdfTemplates.n3` is. It is sometimes copied over to `labs-accounts-assessor`, so that `Update RDF Templates` may work correctly. This currently isn't automated.








#======
namespaces:
-	l: <https://rdf.lodgeit.net.au>
	-	can be made resolvable without messing with the organization's webservers
	-	is reasonably short
	-	https is probably a justified security measure
-	do we want a special path for each concept, for example l/hp_contract# ?
	-	different uris for otherwise same properties used with multiple different classes
	-	schema.org uses domainIncludes and rangeIncludes, this is useless for UI generation.
	-		and flat namespace, for example: https://schema.org/height.nt 

i think the principially sanest default is:
-	data is extracted from ui by walking rdfs classes / properties and template info
-	data is presented by walking the instances / looking up their classes, looking for templates specified for the classess
	-	one problem is lists, x rdfs:range List doesn't say much, 
		-	so let's have a new property, let's say l:properties:range, that can specify a parametrized type




#=======

#:section a rdfs:Class.
#:title a rdf:Property; rdfs:domain :section; rdfs:range rdfs:Literal.









