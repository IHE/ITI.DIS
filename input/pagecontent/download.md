
You can also download:

- [this entire guide](full-ig.zip),
- the definition resources in [json](definitions.json.zip), [xml](definitions.xml.zip), or [ttl](definitions.ttl.zip)
- the example resources in [json](examples.json.zip), [xml](examples.xml.zip) or [ttl](examples.ttl.zip) format.

The [IHE ITI.DIS repository](https://github.com/IHE/ITI.DIS) contains the source for this guide.

#### FHIR Semantic Group Binding

Volume 3 publishes the [authoritative R4 and R5 selector table](volume-3.html#3pxx3213-semantic-group-bindings). The following informative resources support policy authoring.

- [R4/R5 PII path catalog CSV](bindings/dis-fhir-pii-path-catalog-0.2.0.csv)
- [FHIR PII classification and semantic group guide](fhir-semantic-group-guide.html)

#### ODRL and JSON Schema Artifacts

The [DIS ODRL binding](odrl-content.html) defines the Agreement, De-Identification Policy, and Execution Plan. Download the [version 1 RDF vocabulary](schemas/dis-odrl-v1.ttl) and [version 1 JSON-LD context](schemas/dis-odrl-v1.jsonld).

These schemas describe the structure of the decoded JSON payloads used by DIS. Volume 3 defines the additional content and semantic requirements for each payload.

| JSON Schema | Purpose | Volume 3 binding |
|---|---|---|
| [Patient lookup table](schemas/dis-lookup-table.schema.json) | Defines supplied and generated patient identifier mappings and their table metadata. | [Reversible Lookup Table](volume-3.html#3pxx5-reversible-lookup-table) |
{: .grid}

#### Cross Version Analysis

{% include cross-version-analysis.xhtml %}

#### Dependency Table

{% include dependency-table.xhtml %}

#### Globals Table

{% include globals-table.xhtml %}

#### IP Statements

{% include ip-statements.xhtml %}
