
the following content started as a copy of https://github.com/LodgeiT/labs-accounts-assessor/wiki/research-grant-proposal and will be extended here. 

https://github.com/LodgeiT/labs-accounts-assessor/wiki/Architectural-ponderings will contain less refined data and should be periodically updated with chat logs.

```
fixme: this page has content partly overlapping with 

see also docs/prolog/ and misc/ for recent advancements in formula solving

Abstract
Thesis statement

proposed research areas:
    

    Our Proposed Microservices architecture

    If the project goal is an open source framework, then the promise of extensibility offered by a microservice architecture can be a selling point. Otoh, "using a microservice architecture" is not research or something that any government organization should fund.


    openness:

    since we will already have to write quite a bit of code to serialize/deserialize data, we can bite the bullet and embrace semantic-web formats. 

    advantages:

    possibility to use generic data exploration and manipulation tools, employ different reasoning engines, or use ACE.

    disadvantages:

    added complexity, performance concerns

    flexibility

    can use any language to create a microservice

    can create a generic communication layer between microservices

    scalability

    spin up/down more microservice instances as necessary to meet demands

    host anywhere

    correctness

    simple self-contained microservices are easier to manage, develop, and analyze than a large and tightly-integrated monolithic system

    can force things to be filtered through specific microservices dedicated to ensuring certain correctness properties

    ex. calculations can be handled by a generic calculation / equation solving engine

    ex. privacy, security and general data-management issues can be handled by a dedicated engine

    etc...

    ideal, matching with declarativeness: no microservice should really be directly aware of other microservices



    formulas with proofs/explanations

    applicability:

    simple problems: livestock calculator

    ledger processing:

    financial sw interoperability, basic consistency checking

    this probably doesnt concern us directly, as its the area of xbrl processors. 

    or at least as far as i can see, we'll only be producing proofs for formulas in non-xbrl reports.

    XBRL GL - a financial report can contain all information, down to individual transactions recorded in the subject's ledger


    otoh, maybe we could elaborate on some formulas describing ledgers, or something


    something along the lines:

    """What I'm hoping we can aim for is ability to leverage the logic in controlled natural language interactions on both input & output. So we can easily build/expose queries from some chat services like Alexa or Dialogflow. And so the system can ultimately express controlled natural language output as the levels of logical complexity increase i.e. the system can generate an easy to follow description of how a result from a query was derived i.e. Net Assets = $10. How? Assets $20 less liabilities $10 equals $10."""


    quantity calculus

    dimensional analysis? yea apparently quantity calculus is the proper term for it, dimensional analysis is a specific kind ofapplication of it, which we aren't doing and don't have a need for here

    "Any physically meaningful equation (and any inequality) will have the same dimensions on its left and right sides, a propertyknown as dimensional homogeneity. Checking for dimensional homogeneity is a common application of dimensional analysi"

    idk, seems that fits? yea, that's about all we're doing w/ it though, a lot of the applications are to do w/ determining how quantities scale in relation to scalings of the underlying units, for ex. predicting things about a full-scale thing from properties of a scaled-down model; we basically just need to incorporate the basic arithmetic

    also, https://en.wikipedia.org/wiki/Dimensional_analysis#Finance,_economics,_and_accounting

    * note: probably should include a reference about that spaceship blowing up because of mismatched units

    Mars Climate Orbiter

    https://www.latimes.com/archives/la-xpm-1999-oct-01-mn-17288-story.html

    generic equation solver

    1) implementation of the expressed formulas more likely to be correct due to using generic equation solving code; pre-existingsolver libraries can be used; don't need to write ad hoc code for each set of formulas

    2) expressed formulas themselves are more likely to be correct by being expressed in higher level mathematical language that can be more readily checked by accountants and mathematicians.


    okay here we can elaborate

    1) what we got in my solver: produces proofs and finds solutions if the formulas dependencies are a DAG

    2) if they would not be a dag:

    3) if they would be more complex than linear:

    4) is CLP equal to some set of sympy solvers?

    5) outlooks on sympy's solveset and on hacking sympy to do the above more generically

    6) architecture - we're gonna expose this hack built on sympy as a django service, as an internal general purpose solver-with-proofs service

    7) extending the formula language:

    1) optional() values, for example if stock is bought in report currency then all the forex columns should be empty, and this should probably be "invoked" by omitting some values from the solver input, and all the formulas that depend on them should fail silently


    2) expressing sums: should sums be, at the level of feeding formulas to the solver, be expressed simply as (nested) addition experessions?

    ie. "sum of profits on livestock trading"

    could elaborate on how that is a nice example of a syntax definable in gf, but idk yet how to go on from that, except maybe that it would express a formula, which could be evaluable in the context of some livestock data

    so, do we generate parts of equations on the fly?

    for the purpose of the proposal it's enough to just outline that we are investigating that

    note that the formulas can in some cases come from xbrl, where there essentially is a concept of sum

    in the livestock calculator case, just hardcoding it is fine as a first step




    facilities that help in auditing:

    automated cross-checking:

    livestock calculator vs ledger livestock results

    formulas with proofs/explanations


    facilities that help users operate the sw correctly:

        reference: https://www.tandfonline.com/doi/abs/10.1080/00014788.1986.9729333 :

    allowed transaction forms, allowed account balances

    7. Accounting systems with finite transaction bases

    """This section introduces ideas that pertain to the auditability of accounting

    systems represented by this algebraic framework. The goal here is to be able to limit

    the set of allowable transactions and balances."""

    - from "An algebraic model for the representation of accounting systems"

    TODO: "improper" transaction types: 

    * "credit pension fund and debit equity account"

    * credit limits on customer accounts

    good use for ACE


    algorithm and data representation choices

    effectiveness of trial balance check

    use of difference transactions

    """the simple kind of transaction on the ledger could be called "instant". A set of these debits and credits some accounts, their sum total is zero, but the presence of those transactions change the balances of the accounts.

    a difference transaction, on the other hand, might have: coord(USD, 10, 0), coord(AUD, 0, 13).

    an income might be recorded on the ledger like so: assets CR 10USD income DR 13AUD

    10USD might correspond to 13AUD at the day of the transaction, but the as the exchange rate changes, the difference transaction amounts to the change."""

    this is still an overcomplicated syntax, each aspect only needs to be written once:

    [

     <-expended : ic @ pd>, 

     <+received : ic @ pd>

    ]

     + 

    [

     <-received : ic @ pd>

     <+received : ic @ sd>, 

    ]

     = [ 

     <-expended : ic @ pd)>, 

     <+received : ic @ sd>

    ]


    conversion of multi-unit vector into a particular unit/base is an instance of matrix multiplication

    given a vector of M values in these different units, it can be be dot-product'd with a vector of M conversion factors to yield a total converted value.

    a list of N of these multi-unit vectors is an N*M matrix, which can be multiplied by the conversion factors vector to yield a list of N total converted values.

    TB computable for any point in time

    adjacency list representation of transactions

    ledger always balances by construction;

    likely space-optimal representation

    concerns about correctness in terms of stuff like bit-flipping can be decoupled from the data representation (if desired)

    data structure choice should not be guided by bit-flipping concerns because there are many more bit-flipping concerns, which should be adressed systematically, probably by redundant computing

    shouldn't use "transaction matrices"; they are balanced by construction but extremely inefficient

    shouldn't use "balance matrix"; it's balanced by construction but inefficient, exactly like transaction matrices

    it's effectively just an aggregated/total'd transaction matrix

    at worst just use adjacency-list representation; probably optimal, just like w/ transactions

    but even this seems to lack utility; accountants generally just keep track of every account, not every pair of accounts



    controlled natural language

    GF, Attempto, PENG


    usability

    accessibility

    internationalization


    what seems like a probably viable plan to use gf for dsls + attempto for rules/queries/more-verbose-data language, and therearethree papers on integrations of attempto with different reasoners

    we can use ACE as an interface to OWL and SWRL

    * the main limitation in end-user-usability is that formal logics are hard

    * still it is useful for:

    * user-readable presentation of rules that the system uses

    * trained domain experts


    related but partly independent: 

    * dedicated tools for dealing with syntax (both concrete and abstract)

    * modular association of data-structures which abstract syntax structures to make them first-class accessible through user-interface(s)

    * still want to be able to employ this for standard syntaxes like XML, JSON, etc..


    depreciation calculator - use in inferring dep. rate from assets hierarchy


    matrix and graph based visualizations

    matrix

    GL matrix

    extensible to inter-entity accounting


    reasoning with hypotheticals

    what would be the ... if ... ?



WIP...

    accounting model considerations

    transaction matrix, balance matrix, etc.. can be interpreted as (weighted) adjacency matrices


    A collection of transactions can be interpreted as a directed, weighted, metadata-labelled multi-graph. Can represent a directed multi-graph as an adjacency matrix, but can't represent a weighted/labeled multi-graph as an adjacency matrix without losing information. Or at least, the information would have to be carried in the metadata labelings.

    * Follow up w/ that thought, maybe there's utility in representing in terms of the adjacency matrix if we do carry along info about each individual transaction in the metadata labelings.

    On the other hand, an adjacency list is perfectly equipped to represent a weighted/labeled multi-graph. This adjacency list is similar to a typical ledger, and in fact we can see the two as carrying the same information. T-accounts take a particular graph node and list the weights on its in-edges and out-edges. Then we only must take care to properly associate in/out-edges with debit/credit normal-sides appropriately for each account, and ensure that every inflow has a corresponding outflow. In this way we can regard the "check" enforced by double-entry accounting to simply be the requirement that the T-account structure properly reflects a weighted graph. This is the trial balance check.


    A transaction matrix can be interpreted as an adjacency matrix, but it is exceedingly sparse. However there may be something we can do with this idea mathematically even if it's not useful for storing actual transaction data for the ledger. When collapsed into either a balance matrix or a transactions subtotals matrix, it can still be interpreted as an adjacency matrix. 

    * Note that this equivalence beteen transaction matrix and weighted adjacency matrix is basically making an association between debits/credits and in-flows/out-flows. It seems to be converging on the conclusion that graphs are the appropriate model, rather than matrices; indeed the balance/transaction matrices seem to only be useful on the level that they are just a kind of representation of graphs (with a bit of pedagogical utility in that they make it relatively easy to see the trial-balance-correctness property directly, especially if you're more used to thinking about 2D tabular data, i.e. accountants, rather than properties of abstract network graphs, and indeed help to elucidate concepts of the latter w/ a concrete representation).


    Adjacency list will generally be the optimal representation of the ledger, for a computer, and ensures all entries are "correct by construction". This correctness property can be seen as being related to (essentially the same as) the correctness property for the balance matrix.


    Main thing that needs to be accounted for in this model is debits, credits and normal-sides. Normal-side of an account is determined entirely by its sign when the accounting equation is expressed with all accounts on the same side:

        Assets = Equity + Liabilities

        0 = Equity + Liabilities - Assets

        0 = (Capital + Revenue - Expenses) + Liabilities - Assets


    Capital:     + credit-normal

    Revenue:     + credit-normal

    Expenses:    - debit-normal

    Liabilities: + credit-normal

    Assets:      - debit-normal




    TODO: elaborate on the relationship between gains calculations and paths through the transactions graph.


    TODO: elaborate on intra-entity vs. inter-entity transaction graphs

    * would be cooler with matrix-based visualization

    * https://rady.ucsd.edu/docs/Liang%20Paper.pdf



    TODO: input-output matrices




    software construction correctness

    static analysis & verification

    can be used to prove correctness properties of algorithms employed in the accounting system

    model checking

    Hoare logic

    data-flow analysis

    dependent typing (and related machine-interpretable mathematical/logical foundations, ex. Isabelle/HOL etc...)

    can be used for static analysis but other methods should maybe be tried first;

    where these foundations have some interesting applications that are not very well covered by the other methods is that they can be used to prove properties about the accounting math & models abstractly

    * ex. prove the equivalence between adjacency list ledger representation and T-account ledger representation, and use the constructiveness of the proof as an algorithm to translate between the two representations

    in this way it can be employed in the role of ontology alignment (noting ofc that there are simpler approaches for basic ontology alignment applications which should probably be explored first)

    these systems are also more syntactically similar to standard mathematics, so that these formalizations of the concepts could be made potentially more accessible to "knowledge workers" reviewing the system

    all forms of static analysis are easier when performed on simple self-contained microservices

    having each microservice analyzed then makes it easier to perform whole-system analysis


    XSD/XBRL ?

    * running validations on inputs/outputs at least allows for some decent unit-testing

    * parsing-by-schema can eliminate a lot of code, replacing it with a generic system; allows extensions to be made by schema authors instead of programmers

    derivation of the algorithm from the accounting model

    * ex. in the algebraic representations paper they formulate the accounting system as a monoid and discuss "There is a standard procedure which associates with an automaton an algebraic structure called a monoid." they're going the opposite direction but for many kinds of monoids we should be able to derive automatons from them.



    hardware correctness - bit flipping:

        cosmic radiation, hardware error, or a combination


        can happen randomly or as an attack (eg rowhammer)

        can happen to data on storage media or "live" - in ram, on busses, in cpus..


        common practices:

            consumer devices: ignorance

            servers: ecc ram, hdd raid, checksumming filesystems

            high reliability systems: rendundancy, https://en.wikipedia.org/wiki/Fault-tolerant_computer_system


        references:

            https://static.googleusercontent.com/media/research.google.com/en//pubs/archive/35162.pdf

            https://en.wikipedia.org/wiki/Triple_modular_redundancy


        misc reading:

            https://www.johndcook.com/blog/2019/05/20/cosmic-rays-flipping-bits/

            http://lambda-diode.com/opinion/ecc-memory

            https://blogs.oracle.com/linux/attack-of-the-cosmic-rays-v2

            https://news.ycombinator.com/item?id=10029211

            https://www.reddit.com/r/programming/comments/ayleb/got_4gb_ram_no_ecc_then_you_have_95_probability/


        data redundancy in accounting sw:

            matrix vs dual representation


        HMAC, "triple-entry accounting", authenticated data-structures; merkle-trees; lambda-auth...

        basically just a more sophisticated elaboration on the concept of checksumming, etc..


    ...


    """And as best I can tell, if the agent is equipped with ability to reason over trans-action doing verb & trans-actiongraph relations (where the graph is directed acrylic) with primitive, primary terminals (BS - net assets, equity,PL - gain/(loss) + special extensions - currencies, inventory methods (livestock average cost),..."



    this project is not only an exploration into doing accounting better, but also doing sw dev better


    investigate use of matrices for visualization.... (could build a prototype fairly quickly)



    standards

    * can we elaborate on the utility of XBRL in producing a better accounting system?

    * RDF?



References:
[1] Charles Hoffman, "Accounting Matrix-based Model Prototype in XBRL" http://xbrl.squarespace.com/journal/2019/9/9/accounting-matrix-based-model-prototype-in-xbrl.html

[2] Stewart A. Leech, "The Theory and Development of a Matrix-Based Accounting System"
https://www.tandfonline.com/doi/abs/10.1080/00014788.1986.9729333

[3] Robert A. Nehmer, Derek Robinson, "An algebraic model for the representation of accounting systems"

[4] David Ellerman, "On Double-Entry Bookkeeping: The Mathematical Treatment"
```
