
### XBRL dimensions

#### resources

https://www.xbrl.org/specification/dimensions/rec-2012-01-25/dimensions-rec-2006-09-18+corrected-errata-2012-01-25-clean.html
http://www.xbrlsite.com/Examples/Dimensions/
https://docs.oracle.com/en/cloud/saas/enterprise-performance-reporting-cloud/udepr/about_dimensions_172x8e51bd9a.html


#### notes on the spec


explicit dimension = enumerated dimension

 
>this implies that the instance-rooted DTS MUST contain domain-member relationships in a linkbase that is not in the schema-rooted DTS of the primary taxonomy.


>By convention, a taxonomy that imports primary and domain member taxonomies and defines all the necessary dimensional information is called a template taxonomy. In particular, a template defines Hypercube. A Hypercube describes the Cartesian product of zero or more dimensions.

cartesian product:`Suppose, A = {dog, cat} B = {meat, milk} then, A×B = {(dog,meat), (cat,milk), (dog,milk), (cat,meat)}`

> Each dimension in turn is defined over zero or more domains and domains are composed of members


```
Dimensional Taxonomies Requirements
Aggregator
	A dimension member that represents the result of summing facts about other members of the same dimension.
Example: In the products dimension, the member “TotalProducts” is the aggregator of all possible products.
Measure
	A measure is an XBRL fact whose context contains dimensions.
```


>Instance authors must be able to create contexts with Dimensions. Taxonomy authors must be able to define the valid combinations of Dimensions that may or must occur in the contexts of the facts of any concept.  Instances with facts or contexts violating the validity constraints are invalid.


>Example: A taxonomy requires that the context of every Sales fact must have a product and region dimension and may have others.

>Example: A taxonomy requires that the context of every Asset fact must have a region dimension but no other dimensions.





`2.7 Default values for dimensions`:
Specifying a default value serves two purposes:
* A fact with a context that does not specify a value for the dimension, is understood to have the default value.
* They are also used in "summation-item or other relationships between some specific facts".





#### how to model this

##### link a primary item to a hypercube:
 
```
<link:definitionArc 
    xlink:type="arc" 
    xlink:arcrole="http://xbrl.org/int/dim/arcrole/hypercube-dimension" 
    xlink:from="basic_Banks" 
    xlink:to="Banks_hc" 
    order="1.0"
/>
```
##### declare a hypercube:
```
<xs:element name="Banks_hc" id="xbrldt_hypercubeItem_Banks_hc" abstract="true" substitutionGroup="xbrli:item" type="xbrli:stringItemType" xbrli:periodType="duration"/>
```
> The hypercube-dimension relationship has a hypercube declaration [Def, 4] as its source and a dimension declaration [Def, 7] as its target. 

```
<link:definitionArc xlink:type="arc" xlink:arcrole="http://xbrl.org/int/dim/arcrole/hypercube-dimension" xlink:from="DisclosureOfConsolidatedAndSeparateFinancialStatementsTable" xlink:to="ConsolidatedAndSeparateFinancialStatementsAxis" xlink:title="definition: DisclosureOfConsolidatedAndSeparateFinancialStatementsTable to ConsolidatedAndSeparateFinancialStatementsAxis" order="1.0"/>
```

##### declaration of a typed dimension:
```
<element 
    id="basic_Dimension_BankAccounts_Duration" 
    name="Dimension_BankAccounts_Duration" 
    type="xbrli:stringItemType" 
    substitutionGroup="xbrldt:dimensionItem" 
    xbrli:periodType="duration" 
    abstract="true" 
    xbrldt:typedDomainRef="basic.xsd#basic_Dimension_BankAccounts_Duration_DomainDeclaration" 
/>
```
`type` attribute is dummy.
xbrldt:typedDomainRef attribute is used in a Typed Dimension Element to locate the element in an XML Schema that defines the content of the typed dimension. 


##### declare an element type, that can be used in <scenario> to add a dimension value to a context:
```
<element id="basic_Dimension_BankAccounts_Duration_DomainDeclaration" name="BankAccount_Duration">
    <simpleType>
        <restriction base="string" /></simpleType></element>
```
