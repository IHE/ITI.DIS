
You can also download:

- [this entire guide](full-ig.zip),
- the definition resources in [json](definitions.json.zip), [xml](definitions.xml.zip), or [ttl](definitions.ttl.zip)
- the example resources in [json](examples.json.zip), [xml](examples.xml.zip) or [ttl](examples.ttl.zip) format.

The [IHE ITI.DIS repository](https://github.com/IHE/ITI.DIS) contains the source for this guide.

#### FHIR Semantic Group Binding

Volume 3 publishes the [authoritative R4 and R5 selector table](volume-3.html#3pxx3213-semantic-group-bindings). The following informative resources support policy authoring.

- [R4/R5 PII path catalog CSV](bindings/dis-fhir-pii-path-catalog-0.2.0.csv)
- [FHIR PII classification and semantic group guide](fhir-semantic-group-guide.html)

#### JSON Schema Artifacts

These schemas describe the structure of the decoded JSON payloads used by DIS. Volume 3 defines the additional content and semantic requirements for each payload.

| JSON Schema | Purpose | Volume 3 binding |
|---|---|---|
| [De-identification policy rules](schemas/dis-policy.schema.json) | Defines policy version, representation, ordered ruleSets, optional stages, and action parameters. | [Policy Rules JSON Structure](volume-3.html#3pxx13-policy-rules-json-structure) |
| [Patient lookup table](schemas/dis-lookup-table.schema.json) | Defines supplied and generated patient identifier mappings and their table metadata. | [Reversible Lookup Table](volume-3.html#3pxx5-reversible-lookup-table) |
| [Execution plan](schemas/dis-execution-plan.schema.json) | Defines resolved, ordered rules for one task. | [Execution Plan JSON Structure](volume-3.html#3pxx212-execution-plan-json-structure-and-rule-evaluation) |
{: .grid}

#### Cross Version Analysis

{% include cross-version-analysis.xhtml %}

#### Dependency Table

{% include dependency-table.xhtml %}

#### Globals Table

{% include globals-table.xhtml %}

#### IP Statements

{% include ip-statements.xhtml %}
