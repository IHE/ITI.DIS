<a name="3pxx17-reversible-lookup-table"> </a>

<a name="3pxx5-reversible-lookup-table"> </a>

<a name="protected-lookup-tables"> </a>

<a name="3pxx6-protected-lookup-tables"> </a>

This section defines the protected lookup table used to supply or retain patient identifier mappings. See [Patient Identifier Pseudonymization](volume-3-policy.html#3pxx123-patient-identifier-pseudonymization) for the rules that assign pseudonyms.

<a name="3pxx51-lookup-table-structure-and-handling"> </a>

## 3:PXX.6.1 Lookup Table Structure and Handling

[DIS-LookupTable](StructureDefinition-DIS-LookupTable.html) is a protected, identified R4 DocumentReference. The `lookupTable` input to ITI-x1 or ITI-x3 is a reference to a supplied table. The `generatedLookupTable` output in ITI-x3 or ITI-x7 is a task-generated instance carried inline as a resource in `Parameters`. Both use the [DIS patient lookup table JSON Schema](schemas/dis-lookup-table.schema.json) for patient identifier mappings. The generated table carries its JSON inline. A supplied table may carry JSON inline or reference a protected [DIS-LookupTableContent](StructureDefinition-DIS-LookupTableContent.html) Binary.

| DocumentReference element | DIS requirement |
|---|---|
| `identifier` | Stable business identifiers. At least one value SHALL equal the decoded JSON `tableId`. |
| `masterIdentifier` | A system and value identifying this immutable content version. A change to the JSON bytes requires a new `masterIdentifier`. |
| `status` | `current` when used for a new job or returned as generated output. |
| `type` | DIS document-type code `lookup-table`. |
| `extension[dis-identity-linkage-scope]` | Resolved scope type and identifier. Both SHALL match the authorized job scope and decoded JSON. |
| `content` | Exactly one `application/json` attachment. It carries either inline Base64 data or a protected Binary URL. |

The decoded JSON contains `tableId`, format `version` of `1`, a resolved `identity-linkage-scope`, and a nonempty `entries` array. A patient mapping has exactly four fields. `sourceSystem` and `sourceValue` are the original `Identifier.system` and `Identifier.value`. `targetSystem` and `targetValue` are the pseudonym identifier pair. See [lookup-backed assignment](volume-3-policy.html#lookup-backed-assignment) for how the De-Identifier applies supplied mappings.

Source identifier pairs SHALL be unique within a table.

**Supplied tables.** A task-scoped subset has its own business identifier and `masterIdentifier`, retains the authorized scope, and links to the pinned source with `relatesTo` code `transforms`. A reference may use a literal, version-specific history URL or an identifier that resolves unambiguously to an exact version. Repository provisioning and table lifecycle remain deployment concerns. ITI-x1 defines admission and pinning, and ITI-x3 defines restricted dispatch and cleanup.

**Generated tables.** When a reversible Manager-managed task generates patient identifier pseudonyms through salted hashing, the De-Identifier SHALL return one `generatedLookupTable` containing the resulting patient mappings and the resolved scope. Disclosure of the generated table to the Manager SHALL be authorized for the assigned task. The Manager SHALL validate the table against the task and retain the mappings before job release. Repeated identical pairs across tasks or retries are idempotent. If a source pair maps to conflicting targets in the same job or a target is assigned to distinct patients, the Manager SHALL fail the job without partial release. A task applying supplied patient mappings or executing an irreversible policy SHALL NOT return a generated patient lookup table.

Generated and supplied tables are protected operational material and SHALL be excluded from recipient-facing output, evidence, logs and errors.

<a name="3pxx18-worked-mapping-examples"> </a>

<a name="3pxx51-worked-mapping-examples"> </a>

<a name="3pxx52-worked-mapping-examples"> </a>

<a name="lookup-table-examples"> </a>

## 3:PXX.6.2 Worked Mapping Examples

These synthetic, informative FHIR R4 examples accompany the [lookup table binding](#protected-lookup-tables). They also appear in the [artifact index](artifacts.html) and the [FHIR example downloads](download.html).

| Published example | What it shows |
|---|---|
| [Lookup table with Binary content](DocumentReference-lookup-document-example.html) | A persistent DocumentReference with a business identifier, a content version identifier, and a reference to the JSON attachment. |
| [Lookup table JSON content](Binary-lookup-content-example.html) | The Binary carrying the lookup table JSON for the DocumentReference above. |
| [Lookup table with inline content](DocumentReference-lookup-inline-example.html) | The same lookup table content carried directly in a DocumentReference attachment. |
| [Task-scoped lookup table](DocumentReference-lookup-task-s1.html) | A supplied table subset with its own identifiers and a `transforms` relationship to the version of the source DocumentReference. |
| [Generated lookup table](DocumentReference-generated-lookup-uc3.html) | The patient identifier mapping generated by the clinical pathology salted hash example and returned to the Manager. |
{: .grid}
