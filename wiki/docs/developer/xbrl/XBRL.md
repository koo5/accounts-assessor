## formats
https://www.xbrl.org/tag/xbrl-csv/

"simplifying the standard in several important respects and opening it up to being used with a range of different formats. These include xBRL-JSON,"
XBRL-XML is definitely awfully overcomplicated. XML is a format that concerns itself with form instead of content.


## gui softwares

ubmatrix - outdated, discontinued, but Waqas uses it to edit the taxonomy

pesseract: XBRL creator's current project. But typed dimensional units aren't supported. This seems to be an intention. 

interesting: http://asreported.com/

todo: https://www.microsoft.com/cs-cz/p/rosetta-sie-xbrl-gl-viewer/9pp9f5k2jv3j?cid=msft_web_chart&activetab=pivot:overviewtab#

xmlspy?

there's lots more, search "xbrl taxonomy editor"

## libraries

arelle  - we use this to extract data from taxonomies
	python

https://github.com/greedo/python-xbrl/
	simple parser + some GAAP stuff

https://github.com/bseddon/XBRL
	PHP

gepsio:
	C#, no formulas, but useful to corroborate basic XBRL taxonomy (Locator, Label)..

???:
	prolog, auditchain
	

# xsd
	https://link.springer.com/chapter/10.1007/978-3-030-00801-7_12
	


## resources
http://xbrlsite.azurewebsites.net/2020/introduction/

## useful xbrl resources:
```
	ok(?)
		http://what-when-how.com/xbrl/finding-tools-and-services-to-make-xbrl-work/
		https://en.wikipedia.org/wiki/XBRL#XBRL_Taxonomy
		http://files.xbrl.us/documents/TDH-public-exposure.pdf
		http://www.batavia-xbrl.com/downloads/XBRLinPlainEnglishv1.1.pdf
		https://xbrl.us/xbrl-reference/style-guide/		
		https://www.xbrl.org/guidance/xbrl-formula-rules-tutorial/
			(paywalled but looks good)
		
			
	
	not sure:
		this directory.
		http://xbrlsite.azurewebsites.net/2019/SBRM/NarrativeConceptualization.pdf
		http://www.eurofiling.info/201405/presentations/20140507IntroductionToXBRLBartoszOchocki.pdf
		
		
		http://www.datypic.com/sc/xbrl21/e-xbrli_context.html
		http://28msec.github.io/xbrl-tutorial/gitbook/chap-BizQLTutorial-Networks.html
		http://pesseract.azurewebsites.net/PuttingTheExpertiseIntoKnowledgeBasedSystem.pdf
		http://www.xbrlsite.com/mastering/Contents.html
		
	misc:
		https://xbrl.us/xbrl-taxonomy/2020-loan-app/
		https://www.taxonomy-collaboration.sbr.gov.au/yeti/resources/yeti-gwt/Yeti.jsp#tax~(id~47*v~3966)!con~(id~56564)!net~(a~785*l~191)!lang~(code~en)!path~(g~8342*p~0_0)!rg~(rg~21*p~1)

```

## useful xbrl sw:
```
	taxonomy editing:
		altova

			https://www.altova.com/xbrl-tools
			https://www.altova.com/xmlspy-xml-editor/xule-editor-validator

			XMLSpy enterprise edition - about €799.00 + VAT for a perpetual license
				taxonomy
			StyleVision enterprise edition - €499.00 + VAT for a perpetual license
				presentation
			MissionKit enterprise edition - €1,390.00 + VAT for a perpetual license

			free trial

			https://www.altova.com/blog/three-way-file-comparison-and-difference-merging/
				https://www.cs.hut.fi/~ctl/3dm/

			https://www.sw.cz/vyvojove-nastroje/ostatni/altova-xmlspy-2020-professional-installed-edition/


		arelle
			Arelle offers validation, instance creation, and taxonomy generation, among other capabilities. Once the concepts and structures have been prepared in the spreadsheet, Arelle can transform this information into a taxonomy.


	https://www.reportingstandard.com/xbrl-tools/xbrl-taxonomy-builder/?lang=en
	https://www.corefiling.com/infrastructure/xbrltaxonomy/
	https://www.fujitsu.com/global/products/software/middleware/application-infrastructure/interstage/xbrltools/



```

## the data model

```
possibly a promising direction:
some projects revolving around https://www.w3.org/TR/vocab-data-cube/
which is a data schema similar to xbrl, and we should be able to automatically generate conforming data.




dead a couple of years:
	https://github.com/AKSW/cubeviz.ontowiki
		demo docker running, not sure how to use. but i'm curious about ontowiki itself too.
	JS rewrite, only a few features:
		https://github.com/AKSW/cubevizjs
	and it leads us to:
		http://opencube-toolkit.eu/
		also dead.




https://zazuko.com/
	https://github.com/zazuko
	https://github.com/zazuko/data-cube-frontend-example
		no visualization, just shows how to work with the datacube lib
	https://editor.zazuko.com/
		collaborative ontology editing




https://github.com/lorenae/qb4olap-tools
	extensions to the data cube ontology
	" we propose a high level OLAP language, called QL, which consists on a set of well-known operators: rollup, drilldown, slice, and dice. Using the cube metadata, also written using QB4OLAP, we automatically generate SPARQL queries to implement sequences of QL operations."
	broken demo, build with node 6 or 8, and try to find a dataset.
	





other:
	simple data model (backend) library:
		https://github.com/feonit/olap-cube-js
		
		
		
		
		
or back to "standard BI" tools:
	https://github.com/d4software/QueryTree
	
	
	
	
```








```



/*
xbrl notes
https://www.xbrl.org/guidance/xbrl-formula-rules-tutorial/#fn:assertions
https://www.xbrl.org/guidance/xbrl-glossary/#taxonomy-defined-dimension



 the test expression will be evaluated for each occurrence of a fact using the concept "Revenue". This may include facts reported with different periods, units or taxonomy-defined dimensions. The characteristics (concept, period, unit, taxonomy-defined dimension and entity) used to uniquely identify a fact are known as "Aspects".



Built-in dimension
    Dimensions that are defined by the XBRL specification, and which are required for all facts (depending on their datatype). For example, the "period" built-in dimension defines the date or period in time to which a fact relates, and the "unit" built-in dimension defines the units, such as a monetary currency, in which a numeric fact is reported. Taxonomies may add additional dimensions, referred to as taxonomy-defined dimensions.


Which of "segment" or "scenario" should be used as the dimension container?
For historical reasons, XBRL provides two alternative containers in which XBRL dimensions can be included, known as "segment" and "scenario". These container elements pre-dates the introduction of XBRL Dimensions, and the split is now redundant.
The choice of which to use is arbitrary, as it does not affect the semantic meaning of the dimensions.
In the absence of other factors, it is suggested that the scenario element is used.



Calculation tree
    Relationships between concepts in a taxonomy for the purpose of describing and validating simple totals and subtotals. [At a technical level, these relationships are defined using the summation-item arcrole in the XBRL specification]



Concept
    A taxonomy element that provides the meaning for a fact. For example, "Profit", "Turnover", and "Assets" would be typical concepts. [approximate technical term: concept (XBRL v2.1) or primary item (XBRL Dimensions)




Cube
    A multi-dimensional definition of related data synonymous with a business intelligence or data warehousing "cube". A cube is defined by combining a set of dimensions with a set of concepts. Cubes are often referred to as "hypercubes", as unlike a physical, 3-dimensional cube, a hypercube may have any number of dimensions. [Approximate technical term: "hypercube". Cube here is used to mean the combination of hypercubes in a single base set]


Data point
    Definition of an item that can be reported in an XBRL report. In technical terms, this is the combination a concept and a number of dimension values. A value may be reported against a data point to give a fact.


Dimension
    A qualifying characteristic that is used to uniquely define a data point. For example, a fact reporting revenue may be qualified by a "geography" dimension, to indicate the region to which the revenue relates. A dimension may be either a taxonomy-defined dimension or a built-in dimension. [Technical term: "Aspect"]


Dimension value
    A value taken by a particular dimension when defining a data point. For example, the dimension value for the period built-in dimension would be a specific date or date range, the dimension value for an explicit taxonomy-defined dimension is a dimension member and the dimension value for a typed taxonomy-defined dimension is a value that is valid against the format that has been specified in the taxonomy.



Fact
    A fact is an individual piece of information in an XBRL report. A fact is represented by reporting a value against a concept (e.g., profit, assets), and associating it with a number of dimension values (e.g., units, entity, period, other dimensions) that together uniquely define a data point.






---




iXBRL report
    A single document that combines structured, computer-readable data with the preparer's presentation using the iXBRL (or Inline XBRL) standard. An iXBRL report provides the same XBRL data as an XBRL report, but embeds it into an HTML document that can be viewed in a web browser. By linking structured data and human-readable presentation into a single document, iXBRL provides the benefits of computer-readable structured data whilst enabling preparers to retain full control over the presentation of their reports.

Label
    A human readable description of a taxonomy component. XBRL labels can be defined in multiple languages and can be of multiple types, such as a "standard label", which provides a concise name for the component, or a "documentation label" which provides a more complete definition of the component.

Preparer's presentation
    The human-readable presentation of a business report. The term is used to refer to the report as it would be presented on paper, PDF or HTML.
    This term is of particular relevance in open reporting environments, where preparers typically have significant control over the layout and presentation of a report. An iXBRL report embeds XBRL data into an HTML document, allowing a single document to provide both the preparer's presentation and structured data from an XBRL report.

Presentation tree
    The organisation of taxonomy elements into a hierarchical structure with the aim of providing a means of visualising or navigating the taxonomy. [At a technical level, the presentation tree is defined using the parent-child arcrole in the XBRL specification]

Open reporting
    An environment where a preparer must make their own decisions about exactly which data points are to be reported. This is commonly found in financial reporting where the reporting requirements are expressed as a set of principles that must be followed, rather than a specific set of data points that must be reported. Open reporting environments may allow preparers to provide an extension taxonomy that defines any additional data points needed, although there are other approaches to implementing open reporting with XBRL.

Closed reporting
    A reporting system in which the set of data points that is to be reported is prescribed completely by the collector of the reports. The process to be followed by a preparer in a closed reporting system is analogous to completing a paper form, as the boxes that may be completed are prescribed completely by the creator of the form (although as with paper forms, closed reporting systems may include specific points of flexibility, such as where rows in a table may be repeated as many times as required).

Table structure
    A view of a taxonomy or report that is designed to replicate tables for presentation or data entry purposes. Table structures are typically used to cope with the complex, dimensional reports often seen in prudential reporting. [At a technical level, the table structure is defined using the Table Linkbase specification]


(United States Dollars) for monetary values or “meters” for length. The units are expressed as a list of
numerator units with an optional list of denominator units. This allows for compound units, such as
dollars/share or miles/hour. It also allows for units such as meters 2 by specifying multiple “meter” units in
the numerator.


Other types of concepts may be used as organizational containers for concept core dimensions that are
semantically related. These are called grouping concepts, and they define structures within a taxonomy,
such as an XBRL table structure or a domain of possible values.


This new XBRL dimension is defined by a concept that represents the nature of an axis in the
data set. In the example, a concept named Person would be added to the taxonomy. Good practice would
also dictate that a suffix is appended to the name of this concept to indicate that this is a taxonomy-
defined dimension and should not itself be used as a concept core dimension. In other words, this new
concept should not be used directly with any one fact. For more information on suffixes, see the XBRL
Style Guide. This would make the final concept name PersonAxis.


Now that there is a concept to describe the taxonomy-defined dimension, the components, or members,
of this dimension must be described. In the example, this would be Jared and Allyson, the two people
who belong to the reporting entity, “Bob’s Household.” They therefore belong to the new PersonAxis.
XBRL offers numerous ways to express these components, but for this example, concepts named Jared
and Allyson will be used. Again, good style practice and clarity suggest adding a suffix to these concept
names to indicate they should not be used as concept core dimensions. Thus, they will be named
JaredMember and AllysonMember. For a more in-depth discussion on the other options to express the
components of a taxonomy-defined dimension, see Section 3.4.2.


Facts with a numeric data type must have a decimals or precision property that states how
mathematically precise the value of the fact is. Because all numeric facts must have precision, XBRL
software can maintain precision when performing mathematical calculations. Given this, when comparing
a computed value versus a fact value, XBRL software can automatically accommodate for rounding
errors.


For example, an XBRL date must be in ISO 8601 format but many
textual dates are written in descriptive language. An XBRL transformation describes how the descriptive
language can be converted to the appropriate format. For a list of rules and more information, see the
XBRL Transformation Registry.


Inline XBRL also offers a scaling property on individual facts, to indicate to XBRL software that the value
of the fact must be scaled before it is interpreted. For example, a table of facts may be expressed in
millions without the trailing zeros to aid in human readability but Inline XBRL has appropriate scaling so
the value of 123 is interpreted as 123000000.

Naming conventions should be employed
following certain style rules (check the XBRL US Style Guide for language and reference styles). Of note
in this case is the use of specific suffixes to indicate a concept’s role.

Concepts that do not actually intersect facts often have their
abstract property set to “true.” This specifically indicates that a concept is not a concept core dimension
but rather an organizational item.

Reporting data for “Income (Loss)” may be a
situation where a negative fact represents that loss, but that fact may be presented as positive for a
specific human-readable presentation. This would be accomplished with a negated label.

Within the XBRL definition, the closed property of the hypercube specifies that all taxonomy-defined
dimensions in this hypercube must intersect on a fact in order for that fact to be part of this hypercube. If
a taxonomy-defined dimension is omitted, the default value for that dimension is assumed to intersect on
the fact. If there is no default value, that taxonomy-defined dimension cannot intersect, which will prevent
the hypercube from including the fact. An open hypercube removes this constraint. In the widget example,
each fact must have the taxonomy-defined dimensions CustomerNameAxis, WidgetTypeAxis, and
OrderDateAxis intersecting upon it. For an explicit taxonomy-defined dimension, a dimension-default
arcrole allows for a concept to be the default value of the dimension, meaning facts that do not explicitly
intersect with that taxonomy-defined dimension are implied to intersect with the default value when
rendering the hypercube. If facts do not intersect with a concept member of the taxonomy-defined
dimension and that dimension has a dimension-default set, those facts will be considered to intersect with
the dimension-default. The dimension-default is usually set to the domain concept, which implies that
facts that do not intersect the dimension are a total of that dimension.




VARIABLES



Every XBRL variable implies an XPath expression. A variable is evaluated by evaluating the implied XPath in the context of an XBRL instance.

The XPath expressions implied by variables are evaluated using the <xbrli:xbrl> element of the input XBRL instance as the context item.

 For various reasons, the XBRL Specification [XBRL 2.1] makes minimal use of the normal hierarchical structure of XML, instead requiring relatively flat syntax for XBRL instances and for their supporting XML schemas and linkbases.

This design makes it cumbersome to use XPath or XQuery to select data from XBRL instances based on their content and their supporting discoverable taxonomy sets, at least without a library of custom functions.

This specification provides a framework for an alternative syntax for specifying the filters that are to be applied to an XBRL instance to select the required data from them, if it is available. The alternative syntax is extensible in the sense that additional filters can be defined as they are deemed useful.

For two facts, an aspect test can be used to test whether an aspect is not reported for both facts or is reported with an equivalent value for both facts.

Two facts are aspect-matched facts if they have exactly the same aspects and, for each of aspect that they both have, the value for that aspect matches for the two facts.

All formulae have a default accuracy rule. A formula MAY also have an accuracy rule specified by either a <formula:precision> child element or a <formula:decimals> child element on the formula.

An aspect rule is a rule for determining the value of an output aspect. Rules for determining the output concept, the output context and the output units of measurement (for numeric facts), are all different types of aspect rules.


http://www.xbrl.org/WGN/xf-grammar/WGN-2018-10-10/xf-grammar-WGN-2018-10-10.html

1.1 Example XF rule
namespace eg = "http://www.example.com/ns" ;
assertion RevenueNonNegative {
    unsatisfied-message (en) "Revenue must not be negative";
    variable $revenue {
        concept-name eg:Revenue ;
    };
    test { $revenue ge 0 };
};

http://www.xbrl.org/specification/dimensions/rec-2012-01-25/dimensions-rec-2006-09-18+corrected-errata-2012-01-25-clean.html

http://www.xbrl.org/WGN/dimensions-use/WGN-2015-03-25/dimensions-use-WGN-2015-03-25.html

https://www.xbrl.org/Specification/extensible-enumerations-2.0/REC-2020-02-12/extensible-enumerations-2.0-REC-2020-02-12.html

https://www.xbrl.org/REQ/calculation-requirements-2.0/REQ-2019-02-06/calculation-requirements-2.0-2019-02-06.html

XBRL 2.1 summation-item relationships have defined validation behaviour, with conformant processors being required to signal an "inconsistency" if the facts in an XBRL report do not conform to the prescribed relationships. The validation behaviour does not include any provision for inferring values which are not explicitly reported.

XBRL 2.1 summation-item relationships are restricted to describing summation relationships between numeric facts which are c-equal, that is, which share the same period, dimensions and other contextual information, among other restrictive conditions.


XBRL formula linkbase <-> XF language
https://github.com/Arelle/Arelle/blob/master/arelle/plugin/formulaSaver.py
https://github.com/Arelle/Arelle/blob/master/arelle/plugin/formulaLoader.py
now, what's the semantic model of XF and what's the semantic model of XULE?

namespace cdp-og = "http://www.cdp.net/xbrl/cdp/og/2016-08-30/";
assertion-set assertionSet {
assertion valueAssertion {
unsatisfied-message (en) "Emissions intensities (Scope1 + Scope 2) associated with current production
and operations, Year ending must be between 2010 and 2016. ";
variable $OperationsYearEnding {
nils
fallback {0}
concept-name cdp-og:EmissionsIntensitiesScope1Scope2ProductionOperationsYearEnding;
typed-dimension cdp-og:EmissionsIntensitiesScope1Scope2ProductionOperationsAxis;
};
test {fn:number(fn:string($OperationsYearEnding)) >= 2010 and
fn:number(fn:string($OperationsYearEnding)) <= 2016};
};
};


XULE, from “XBRL rule,” was created by XBRL.US to provide a way to query and check XBRL reports by validating business rules prior to filing.

The goal behind XULE was to create a modern alternative to XBRL Formula

The primary purpose of XULE is to provide a user friendly syntax to query and manipulate XBRL data. Unlike XBRL Formula, XULE does not have the ability to create facts or define new XBRL reports. XULE has been primarily used to validate SEC filings as part of the DQC rules. The DQC rules are published in a XULE format.

XULE is also used to query XBRL taxonomies and render them as open API schemas, or as iXBRL forms.

XULE is syntax independent and will operate on XBRL reports published in JSON, iXBRL, CSV and XML formats. The language operates on an XBRL data model and ignores the XBRL syntax. For example, XULE does not allow a user to query all the XML contexts in an XBRL report in an XML format.

In addition to its XULE processor and validator, XMLSpy includes the industry’s first XULE editor.

https://xbrl.us/xule/?doing_wp_cron=1593455136.4135539531707763671875

@concept = RevenueFromContractWithCustomerExcludingAssessedTax @ProductOrServiceAxis = IPhoneMember

The detailed options available within factset filtering are defined in detail in the XULE guide and the XULE examples page.

also supported in arelle: https://github.com/DataQualityCommittee/dqc_us_rules/releases




2 Segment and scenario

The XBRL v2.1 specification provided two containers for providing additional information about the nature of a reported fact: the <segment> and <scenario> elements contained within the context. Both of these containers can contain arbitrary XML content, with the XBRL v2.1 specification providing no mechanism for defining or constraining the information that appears within these elements.

The XBRL Dimensions specification provides a more structured way to define additional information about the nature of a reported fact. This is preferrable to using arbitrary XML elements within segment and scenario, as the meaning of XBRL Dimensions can be precisely defined and constrained using an XBRL taxonomy.

The syntactic constructs which appear in an XBRL instance document to represent such dimensional qualifications may appear within either the <segment> or <scenario> elements, depending on the definition of the relevant hypercube.

As the meaning of an XBRL Dimension can be defined precisely and completely within an XBRL taxonomy, separately grouping them into the broad categories of "segment" and "scenario" offers little additional value. As the decision as to whether an individual dimension appears within <segment> or <scenario> is attached to the hypercube as a whole rather than to individual dimensions, attempting to classify dimensions between the two introduces additional complexity as additional hypercubes must be introduced.

Common practice in taxonomy design is to select one or other out of the two options, and to use it for all hypercubes within a taxonomy. The choice between segment and scenario is arbitrary: in effect, the greater precision of dimension definition offered by the XBRL Dimensions specification renders the broad, binary classification offered by the XBRL v2.1 specification redundant from a technical perspective.


2.1 Recommendations
    The <segment> and <scenario> elements should only be used to contain XBRL Dimensions, and should not be used to contain other XML elements (this will be enforced where a <segment> or <scenario> element is constrained by a closed hypercube)
    A taxonomy should use one or other of <segment> and <scenario> for its hypercubes exclusively.
    In the absence of reasons to do otherwise (for example, compatibility with other taxonomies or consistency with prior versions), it is suggested that new taxonomies define hypercubes for use on <scenario> only.
    The container that is not used for dimensions should be empty. It is recommended that this is enforced by external validation rather than taxonomy constructs.


"units" which may sometimes be viewed as dimensional and at other times as properties of individual facts depending on the application.





.......

https://www.xbrl.org/guidance/esd-main/

*/

/*




----


reconcilliation of xbrl and our system wrt:
	our adjustment units:
		possibly this could be represented in a xbrl taxonomy, ie, "Assets" is not a single fact-point, or rather, it is a calculated fact, made up of 'assets in report currency' + ..



*/
/*

XPATH:



https://www.swi-prolog.org/pldoc/doc/_SWI_/library/xpath.pl?show=src
"inspired"
xpath3 is a strict superset of xpath2.




Match an element in a DOM structure. The syntax is inspired by XPath, using () rather than [] to select inside an element. First we can construct paths using / and //:

//Term
    Select any node in the DOM matching term.
/Term
    Match the root against Term.
Term
    Select the immediate children of the root matching Term.

XPath formalization:
http://typex.lri.fr/deliverables.html







A schema document may include other schema documents for the same namespace, and may import schema documents for a different namespace.




element(







# Explicit filtering

## a formula linkbase filter resource
## kinds
### boolean filters, which serve to build groups of filter terms

### For example, a group filter may restrict data to a specific period or dimension value,
### a fact variable filter may bind a fact variable to a certain concept element name, or relate it to a period
## evaluation contexts
### related to a variable set
#### group filtering behavior
### related to a fact variable
#### fact variable filtering behavior


# Implicit filtering
## can match the aspects not otherwise covered (e.g. excluding concept name, but matching dates, dimensions, entity and units as applicable).


# Each aspect has a specific matching test implied by the aspect.
## Concept aspects match by QName of the element,
## periods by their dates,
## entity identifiers by their scheme and value,
## units by their measures,
## dimensions (if dimensional) by their explicit members and typed contents,
### For the case of typed dimension aspects, a custom matching test can be supplied by user XPath expressions
## and segment and scenario by XML contents





# what to model
## taxonomy
### concept declarations
#### concept declaration
##### name
by XBRL standard, a QName. are non-namespaced taxonomies allowed? Ideally, the name will be just the uri, although this could sacrifice some flexibility, let's say some functionality for comparing taxonomies.




---

a little exploration into how values might be represented.
inspired by https://www.bkent.net/Doc/mdarchiv.pdf
we will assume and ensure that range(X,Y) has X and Y always ordered such that X <= Y.

op(add(
        value(dimension(fungible), unit(Unit), range(X1,X2)),
        value(dimension(fungible), unit(Unit), range(Y1,Y2))
    ),
    value(dimension(fungible), unit(Unit), range(Z1,Z2))
) :-
    {Z1 = X1 + Y1,
    Z2 = X2 + Y2}.

...

eval(Op, Result) :-
    op(Op,Result0),
    order_range(Result0, Result).

see also misc/equation_solving/ops/.

---


*/
```





/*

first class formulas:

	"Accounting Equation"
		assets - liabilities = equity

	smsf:
		'Benefits Accrued as a Result of Operations before Income Tax' = 'P&L' + 'Writeback_of_Deferred_Tax' + 'Income_Tax_Expenses'

	there is a choice between dealing with (normal-side) values vs dr/cr coords. A lot of what we need to express are not naturally coords, and dealing with them as coords would be confusing. Otoh, translating gl account coords to normal side values can make things confusing too, as seen above.

	'Benefits Accrued as a Result of Operations before Income Tax' = 'P&L', excluding: 'Writeback_of_Deferred_Tax', 'Income_Tax_Expenses'

*/

/*

a subset of these declarations could be translated into a proper xbrl taxonomy.

value_formula(equals(
	aspects([concept - smsf/income_tax/'Benefits Accrued as a Result of Operations before Income Tax']),
	aspects([
		report - pl/current,
		account_role - 'Comprehensive_Income']))),

value_formula(x_is_sum_of_y(
	aspects([concept - smsf/income_tax/'total subtractions from PL']),
	[
		aspects([
			report - pl/current,
			account_role - 'Distribution_Received'])
		aspects([
			report - pl/current,
			account_role - 'Trading_Accounts/Capital_Gain/(Loss)']),
		aspects([
			report - pl/current,
			account_role - 'Distribution_Received']),
		aspects([
			report - pl/current,
			account_role - 'Contribution_Received'])
	])).
*/
/*
	evaluate expressions:
		aspecses with report and account_role aspects are taken from reports. They are forced into a single value. This allows us to do clp on it without pyco. Previously unseen facts are asserted.

*/

/*
% Sr - structured reports
evaluate_value_formulas(Sr) :-
	findall(F, value_formula(F), Fs),
	evaluate_value_formulas(Sr, Fs).

evaluate_value_formulas(Sr, [F|Rest]) :-
	evaluate_value_formula(Sr, F),
	evaluate_value_formulas(Sr, Rest).

evaluate_value_formula(Sr, equals(X, Y)) :-
	evaluate_value(X, Xv)



evaluate_value(X, Xv) :-




asserted:
	aspects([concept - smsf/income_tax/'total subtractions from PL']),
equals(X,aspects([
	concept - smsf/income_tax/'total subtractions from PL'
	memeber - xxx
]),



xbrl:
	fact:
		concept
		context:
			period
			dimension1
*/
/*

fact1:
concept - contribution
taxation - taxable
phase - preserved
fact2:
concept - contribution
taxation - tax-free
phase - preserved
effect - addition

get(concept - contribution):
		get exact match
	or
		get the set of subdividing aspects:
			taxation, phase, effect
		pick first aspect present in all asserted facts
		get([concept - contribution, taxation - _]):
			get the set of subdividing aspects:
				phase, effect
			pick first aspect present in all asserted facts
			get([concept - contribution, taxation - _]):
*/

/*

open problems:
	unreliability of clp - run a sicstus clp service?
	vectors for fact values - would require pyco to solve
*/
















```
I have a ton of examples. The two best are the following: (just read the XBRL instance and
trace back to the XBRL formulas
Proof: http://xbrlsite.azurewebsites.net/2020/master/proof/index.html
http://xbrlsite.azurewebsites.net/2019/Prototype/conformance-suite/Production/1000-
ConceptArangementPatterns/99-Proof/99-TestCase-Proof.xml
XASB: http://xbrlsite.azurewebsites.net/2020/reporting-scheme/xasb/documentation
/Index.html
http://xbrlsite.azurewebsites.net/2019/Prototype/conformance-suite/Production/2000-
Valid/15-XASB/15-TestCase-XASB.xml
The biggest thing to understand is DO NOT just read the specification and implement that as
an interface to create the XBRL formulas. USE PATTERNS. Have different interfaces for
different formula patterns. You can see the primary interfaces here in this Microsoft Access
database of the Proof (above):
http://xbrlsite-app.azurewebsites.net/Proof/Download.aspx
Lots of opportunities to screw this up. Best to avoid those.
Charlie




	
XF features
Same functionality as XBRL Formula Linkbase
Arelle open source on GitHub
 Linkbase to xf: plugin formulaSaver.py
 GUI: load, Tools->Save Xbrl Formula File
 Cmd line: arelleCmdLine -f {dts} --plugins formulaSaver.py --save-xbrl-formula {file-name.xf}
 Xf to linkbase: plugin formulaLoader.py
 Stand-alone or integrated xf-to-linkbase converter
 python3.5 formulaLoader.py [--debug] {files}
 Linkbase outputs saved as {file}-formula.xml
 Interactive
 load in arelle GUI; Tools->Save Xbrl Formula File
 run in production with xf files instead of formula linkbase files


Paul Warren:
• Need to break the tie between XBRL Formula evaluation and XML documents
• XPath remains a reasonable choice for the expression language
• Restricted subset:
• No node navigation
• No context nodes




TDH-public-exposure.pdf :
	
Using Arelle ................................................................................................................................. 86








full-def:
	rhizomik or fnogatz/xsd
	








	
	
	







xule
	different semantics
	factsets, filtering, ..
	
	
	
```



https://www.holistics.io/blog/olap-is-not-olap-cube/
	"One of the biggest shifts in data analytics over the past decade is the move away from building ‘data cubes’, or ‘OLAP cubes’, to running OLAP* workloads directly on columnar databases."
	"Columnar databases have higher read efficiency. If you’re running a query like “give me the average price of all transactions over the past 5 years”, a relational database would have to load all the rows from the previous 5 years even though it merely wants to aggregate the price field; a columnar database would only have to examine one column — the price column. This means that a columnar database only has to sift through a fraction of the total dataset size."
	"Columnar databases also compress better than row-based relational databases. It turns out that when you’re storing similar pieces of data together, you can compress it far better than if you’re storing very different pieces of information. "
	" update performance in a columnar database is abysmal (you’ll have to go to every column in order to update one ‘row’)"
	
	







representing xbrl in something else:
	https://finregont.com/xbrl/
	
	
