<a name="de-identification-policy"> </a>

<a name="policy-content-module"> </a>

<a name="3pxx2-dis-policy-content-module"> </a>

<a name="3pxx1-de-identification-policy"> </a>

<a name="3pxx2-de-identification-policy"> </a>

This section defines the structure, delivery, and validation of de-identification policies. A policy is a reusable knowledge artifact that governs what de-identification transformations are applied. Policies can use DPV categories, Semantic-Level group references, or Syntax-Level element selectors. All policies use the same Contract carrier, delivery modes, and validation procedures. The De-ID Manager validates the policy, and when required, compiles it into one or more [payload-specific execution plans](volume-3-execution-plan.html#policy-compilation) before dispatching tasks.

The policy artifact is an HL7 FHIR R4 Contract resource, part of the protocol layer. It is fixed to HL7 FHIR R4 regardless of the payload version being de-identified.

The [HL7 FHIR R4 Contract]({{site.data.fhir.path}}contract.html) carries the policy. The [DIS Policy profile](StructureDefinition-DIS-Policy.html) defines its FHIR constraints. [ITI-x1](volume-2.html#23x1-submit-de-identification-job-iti-x1) defines the policy submission and admission behavior.

The [normative DPV–ODRL policy profile](volume-3-policy.html#dpv-odrl-policy-profile) defines reusable targets by personal data category, the person's role, and the location of the information. During compilation, the Manager applies the versioned mapping for the assigned payload binding and release. The [normative FHIR R4 mapping](volume-3-fhir-addressing.html#fhir-r4-dpv-mapping) supplies the corresponding selectors for FHIR R4.

<a name="3pxx21-policy-library-resource-structure"> </a>

<a name="3pxx11-policy-library-resource-structure"> </a>

<a name="3pxx11-policy-contract-resource-structure"> </a>

<a name="policy-contract-structure"> </a>

## 3:PXX.2.1 Policy Contract Resource Structure

A DIS policy is carried in a profiled FHIR R4 `Contract`. An authorization permission incorporates the approved policy revision by its exact `Contract.url|Contract.version`. The Manager verifies that the Set revision `uid` matches `Contract.identifier.value`. The full [ODRL Policy Set](odrl-content.html#de-identification-policy-set) is carried inline. The same policy revision can be approved by multiple Agreements.

| Contract element | Cardinality | Description |
|---|---|---|
| `id`, `meta.versionId` | 1..1 each | Identify the exact resource revision in a version-specific FHIR reference. |
| `url`, `version` | 1..1 each | Policy URL and business version. |
| `identifier` | 1..1 | Set revision `uid`, with system `urn:ietf:rfc:3986`. |
| `name`, `issued` | 1..1 each | Machine-readable name and issuance timestamp. |
| `authority` | 1..1 | Organization responsible for issuing the policy. |
| `status`, `applies` | 1..1 each | Policy lifecycle state and validity period. |
| `rule.contentAttachment` | 1..1 | Base64-encoded UTF-8 JSON-LD with content type `application/ld+json`. |
{: .grid}

<a name="transformation-actions"> </a>

<a name="3pxx13-transformation-actions"> </a>

<a name="3pxx22-transformation-actions"> </a>

<a name="3pxx12-transformation-actions"> </a>

## 3:PXX.2.2 Transformation Actions

Policy rules select transformation actions. The compiled execution plan applies the same action definitions to concrete targets. This section defines the core action family (`core`) for DIS-FHIR-Payload. The [processing capability requirements](volume-3-fhir-addressing.html#fhir-processing-capabilities) define how a De-Identifier or Integrated actor supports and declares the core actions.

<a name="3pxx131-action-catalog"> </a>

<a name="3pxx221-action-catalog"> </a>

<a name="3pxx121-action-catalog"> </a>

### 3:PXX.2.2.1 Action Catalog

Table 3:PXX.2.2-1 lists the core transformation actions.

<p id="tPXX.1.2-1" class="tableTitle"><strong>Table 3:PXX.2.2-1: Core Transformation Actions</strong></p>

| Action Code | Description | Applicable HL7 FHIR Datatypes | Deterministic | Parameters |
|-------------|-------------|-------------------------------|---------------|------------|
| `remove` | Remove the element entirely from the resource | Any element | Yes | None |
| `replace` | Fixed-value or reversible lookup-backed replacement | Fixed mode: `string`, `HumanName`, `Address`, `ContactPoint`, `Identifier`, `uri`; lookup mode: patient business identifiers (`Patient.identifier`) | Yes | Fixed mode: `value`; lookup mode: `source: lookupTable` (mutually exclusive) |
| `keep` | Preserve the element unchanged in the de-identified output | Any element | Yes | None |
| `hash` | Replace the value with a cryptographic hash digest | `Identifier`, `HumanName`, `string` | Yes | `mode` (`salted` or `unsalted`), `algorithm` (`SHA-256`), and output namespace when required. |
| `truncate-date` | Reduce date precision by truncating to the specified level | `date`, `dateTime` | Yes | `precision` (`year` or `year-month`) |
| `date-shift` | Shift all dates by a consistent per-patient offset | `date`, `dateTime`, `instant`, `Period` | Yes (given same scope and patient) | `scope` (consistency scope identifier), `maxOffsetDays` (maximum magnitude of the shift in days) |
| `round` | Bin a numeric value to the nearest multiple of the step | `Quantity`, `Age`, `integer`, `decimal` | Yes | `step` (rounding interval; e.g., `10` bins 57 → 60) |
| `truncate` | Keep the first N characters of a string value | `string`, `Address.postalCode`, `Identifier.value` | Yes | `length` (number of characters to retain) |
| `redact` | Remove the narrative content from a resource | `Narrative` (`DomainResource.text`) | Yes | None |
{: .grid}

Each DIS action code carries a `technique` property that identifies its ISO/IEC 20889:2018 classification. The classifications describe the techniques behind the executable DIS actions. The action design draws on RSNA CTP DICOM Anonymizer function patterns.

<p id="tPXX.1.2-2" class="tableTitle"><strong>Table 3:PXX.2.2-2: Core Transformation Actions — ISO/IEC 20889 Classification</strong></p>

| ISO/IEC 20889 §9 Category | ISO Technique | DIS Action | Function |
|---|---|---|---|
| §9.3 Suppression | Local suppression (§9.3.3) | `remove` | `(element) → ∅` |
| §9.3 Suppression | Local suppression (§9.3.3) | `redact` | `(narrative) → ∅` |
| §9.3 Suppression / §9.4 Pseudonymization | Masking (§9.3.2) / lookup-table pseudonymization (§9.4.3.2) | `replace` | Fixed replacement or authoritative lookup-backed replacement |
| §9.4 Pseudonymization | Hashing (§9.4.3.3) | `hash` | `(value, mode, algorithm, scope?) → digest` |
| §9.6 Generalization | Rounding (§9.6.2) | `truncate-date` | `(date, precision) → truncated` |
| §9.6 Generalization | Rounding (§9.6.2) | `round` | `(value, step) → binned` |
| §9.6 Generalization | Generalization (§9.6) | `truncate` | `(value, length) → shortened` |
| §9.7 Randomization | Noise addition (§9.7.2) | `date-shift` | `(date, scope, maxDays) → shifted` |
| — | — | `keep` | `(element) → element` |
{: .grid}

ISO/IEC 20889 categories outside the scope of this supplement include statistical tools (§9.1 — sampling, aggregation), anatomization (§9.5), randomization techniques beyond noise addition (§9.7.3 — permutation, §9.7.4 — microaggregation), synthetic data (§9.8), and the formal privacy measurement models (§10 — k-anonymity, l-diversity, t-closeness, differential privacy). Lookup-table-based pseudonymization (ISO §9.4.3.2 — pseudonyms independent of identifying attributes) is supported through lookup-backed `replace` under DIS-REVERSIBLE. The optional [encryption method](#encryption-based-patient-pseudonymization) uses AES-FF1 format-preserving encryption under DIS-REVERSIBLE.

<a name="3pxx132-action-definitions"> </a>

<a name="3pxx222-action-definitions"> </a>

<a name="3pxx122-action-definitions"> </a>

### 3:PXX.2.2.2 Action Definitions

#### remove

The `remove` action removes the targeted element and all its children from the resource. After removal, the element SHALL NOT be present in the de-identified output. If the targeted element is required by the HL7 FHIR base resource definition (cardinality 1..1 or 1..*), the De-Identifier SHALL reject the task with an OperationOutcome. Execution plans SHALL NOT target required elements with the `remove` action.

#### replace

With the `dis:source` action refinement set to `lookupTable`, `replace` replaces patient business identifiers in `Patient.identifier` using the [lookup-backed assignment rules](#lookup-backed-assignment). This mode is mutually exclusive with a fixed `value`. It SHALL preserve identifier/reference consistency and SHALL NOT fall back to fixed replacement or hashing when an entry is absent. The following fixed-value behavior applies only when lookup mode is not selected.

The `replace` action replaces the targeted element's displayable content with the nonempty string specified by the `value` parameter.

For a fixed replacement of an `Identifier`, replace `Identifier.value` and preserve its system unless another authorized action changes it. For `HumanName`, each sub-element (`family`, `given`, `text`) is replaced with the specified value. For `Address`, each sub-element (`text`, `line`, `city`, `district`, `state`, `postalCode`) is replaced with the specified value; `Address.country` is preserved. For `ContactPoint`, `ContactPoint.value` is replaced with the specified value; `ContactPoint.system` and `ContactPoint.use` are preserved.

#### keep

The `keep` action preserves the targeted element unchanged in the de-identified output. In first-match-wins evaluation, `keep` enables execution plans to express exceptions before general rules — for example, preserving a specific identifier before removing all identifiers:

```
R01: target Patient.identifier.where(system = 'https://example.org/approved-id')    action keep
R02: target Patient.identifier         action remove
```

#### hash

The `hash` action computes a SHA-256 digest. The `algorithm` parameter uses the `SHA-256` code from HL7's [IntegrityCheckAlgorithm CodeSystem](https://terminology.hl7.org/CodeSystem-v3-IntegrityCheckAlgorithm.html). The `mode` parameter selects `salted` or `unsalted`.

For patient business identifiers, the rule SHALL use `salted` and declare `pseudonymSystem`. Apply the patient identifier recipe in [patient identifier pseudonymization](#3pxx123-patient-identifier-pseudonymization). Generic value rules hash the exact original string, including a selected displayable string sub-element where applicable. The unsalted message is the UTF-8 serialization of `["DIS-value-digest-v1", value]`. The salted message is the UTF-8 serialization of `["DIS-value-digest-v1", scope.type, scope.identifier.system, scope.identifier.value, value]` followed by the raw scope salt. Both modes use the serialization and output rules in §3:PXX.1.2.3. An unsalted rule is unsuitable for patient business identifiers because an observer can test guesses against the digest.

For `HumanName`, hash `family`, `given`, `prefix`, `suffix` and `text` individually. Preserve `use` and remove `period`. For an `Identifier` governed by a generic hash rule, replace `value` with the digest and set `system` to the rule's required `pseudonymSystem`. Preserve `type`, `use` and `period`, and remove `assigner`.

Unsalted test vector. The exact UTF-8 message is `["DIS-value-digest-v1","example"]` and the digest is `7a5d5b43b1725c76debaedcb17ccfb99d6bd99299593c8b18eab0b4d0e4643b9`.

#### truncate-date

The `truncate-date` action reduces the precision of the targeted date value to the level specified by the `precision` parameter.

- `precision: year` — retain only the year (e.g., `1985-03-15` → `1985`)
- `precision: year-month` — retain year and month (e.g., `1985-03-15` → `1985-03`)

#### date-shift

Date shifting requires purpose-specific derivation under the [declared processing capability](volume-3-fhir-addressing.html#fhir-processing-capabilities). The De-Identifier SHALL use patient hashing salts only for the authorized hash rules. The `date-shift` action shifts the targeted date or time value by a per-patient offset. The offset is deterministically derived from the scope-derived seed material and the patient identifier, ensuring that all dates for the same patient within the same consistency scope are shifted by the same offset. The offset magnitude SHALL NOT exceed the `maxOffsetDays` parameter. The direction (forward or backward) is determined by the derivation.

Date shifting preserves temporal ordering and intervals between events for the same patient. The De-Identifier SHALL apply the same offset to all `date`, `dateTime`, `instant`, and `Period` elements for a given patient within a single task.

For `Period` elements, shift each present bound by the same offset. If a date or dateTime has insufficient precision to determine a day, the De-Identifier SHALL fail the task when a date-shift rule selects it.

Date-shift reference dates and offsets are protected transformation parameters. The linkage scope identifies where consistency is authorized. Support for derivation is required for core conformance and applies to every processing entry that advertises `date-shift`. Accepting precomputed parameters is an optional De-Identifier capability. If a generated parameter must be reused, an explicit capability contract SHALL define how it is returned to the Manager through a protected channel, retained as authorized, and reused in later tasks. See [reversibility material custody](volume-1.html#1pxx54-reversibility-material-custody).

#### round

The `round` action bins a numeric value to the nearest multiple of the `step` parameter. The rounding centers at zero. When a value is exactly halfway between two multiples, select the multiple farther from zero.

- `round(57, step: 10)` → `60`
- `round(23, step: 5)` → `25`
- `round(82, step: 10)` → `80`

#### truncate

The `truncate` action retains only the first `length` characters of a string value, discarding the remainder.

- `truncate("02139", length: 3)` → `"021"`
- `truncate("SW1A 2AA", length: 4)` → `"SW1A"`

#### redact

The `redact` action removes the narrative content (`DomainResource.text`) from a resource. The De-Identifier SHALL replace the entire narrative with a fixed placeholder using `Narrative.status = empty` and `Narrative.div = <div xmlns="http://www.w3.org/1999/xhtml">Narrative redacted</div>`. The placeholder preserves valid XHTML without carrying any source text, attributes, images, or links.

<a name="3pxx133-baseline-patient-pseudonym-derivation"> </a>

<a name="3pxx223-baseline-patient-pseudonym-derivation"> </a>

<a name="3pxx123-baseline-patient-pseudonym-derivation"> </a>

<a name="3pxx123-patient-identifier-pseudonymization"> </a>

### 3:PXX.2.2.3 Patient Identifier Pseudonymization

Salted `hash` derives a pseudonym from the source identifier and linkage scope. In Manager-managed reversible processing, the Manager retains the generated mapping for authorized reversal. Lookup-backed `replace` assigns a pseudonym from a Requester-supplied mapping. Optional [AES-FF1 encryption](#encryption-based-patient-pseudonymization) lets the Manager recover the resolved identifier when authorized.

**Salted hash derivation.**

The Manager SHALL copy the resolved policy `identity-linkage-scope` into each compiled salted `hash` rule. The De-Identifier SHALL obtain the confidential salt for the resolved scope through its deployment. The deployment SHALL generate or derive a distinct effective salt of exactly **16 bytes** for each scope and salt version using cryptographically secure material. Authorized workers that need matching pseudonyms SHALL use the same effective salt and version. The deployment SHALL keep the selected version consistent across all tasks and retries of a job. For example, a deployment can coordinate rotation after the jobs using a version finish. Rotating the salt changes the pseudonym derivation context. The De-Identifier SHALL fail the task if it cannot obtain the applicable salt or if the decoded salt length differs from 16 bytes.

For each `Patient.identifier` targeted by the rule, require a nonempty source `system` and `value`. Construct this ordered array of strings using the exact scope and source identifier values:

```text
["DIS-patient-identifier-v1", scope.type, scope.identifier.system, scope.identifier.value, source.system, source.value]
```

Serialize the array without whitespace, escape quotation marks, backslashes and control characters as required by JSON, emit other Unicode characters directly, preserve forward slashes, use the short JSON escapes for backspace, tab, newline, form feed and carriage return, and use lowercase Unicode escapes for the remaining control characters U+0000–U+001F. Perform no Unicode normalization and reject unpaired surrogates. Encode the resulting text as UTF-8 without a byte-order mark. Append the 16 raw salt bytes to the UTF-8 bytes, then compute SHA-256 over the concatenation. Set `Identifier.system` to the rule's `pseudonymSystem` and `Identifier.value` to the complete 32-byte digest as 64 lowercase hexadecimal characters. Scope and identifier values use exact string matching. Cross-community identity resolution and salt coordination remain deployment prerequisites. On detecting a digest collision between distinct source identifier pairs within the job, fail the job without partial output.

Matching pseudonyms require the same source identifier pair, resolved scope, and effective salt. Deployments claiming cross-community consistency SHALL establish cross-community identity resolution, scope authorization, and coordination of the effective salt, version, and lifecycle.

Salted test vector. The exact UTF-8 message is `["DIS-patient-identifier-v1","source-institution","https://hospital.example.org/identifiers/linkage-scope","lab-project-2026","https://hospital.example.org/identifiers/mrn","A123"]`. Append the 16 public test bytes `000102030405060708090a0b0c0d0e0f` (hexadecimal). The expected digest is `8162610a149e7b6700513fa3f0ceff46328e2b584fd3d351e4d5c2775a42ff0c`. Deployments generate their own confidential salts.

<a name="lookup-backed-assignment"> </a>

**Lookup-backed assignment.**

The De-Identifier uses the supplied [lookup table](volume-3-lookup-tables.html#protected-lookup-tables) to replace `Patient.identifier`. `sourceSystem` and `sourceValue` are the original `Identifier.system` and `Identifier.value`. `targetSystem` and `targetValue` are the pseudonym identifier pair. The De-Identifier SHALL match both source fields exactly, without implicit normalization, and replace both target fields. A supplied table may map multiple approved source identifiers to one assigned pseudonym for the same patient. The table authority and Manager SHALL ensure that a shared target pair is authorized for the same patient. A missing or conflicting source mapping SHALL fail the job without partial output.

<a name="encryption-based-patient-pseudonymization"> </a>

#### Encryption-based derivation

A reversible policy MAY use the optional `encrypt` action to pseudonymize a selected `Patient.identifier`. The Manager SHALL apply the [optional normative AES-FF1 binding](draft-encryption-based-pseudonymization.html). The De-Identifier SHALL use the approved FF1 configuration and the scoped key version pinned in the compiled [ODRL action](odrl-content.html#action-parameters). A payload set that uses the encryption action SHALL NOT include a supplied lookup table. DIS does not require an implementation declaring DIS-REVERSIBLE to support the optional action.

<a name="3pxx22-policy-rules-json-structure"> </a>

<a name="3pxx12-policy-rules-json-structure"> </a>

<a name="3pxx13-policy-rules-json-structure"> </a>

<a name="3pxx13-policy-rules-and-ordering"> </a>

## 3:PXX.2.3 Policy Rules and Ordering

The decoded policy attachment SHALL conform to the [DIS ODRL Policy Set](odrl-content.html#de-identification-policy-set). DPV–ODRL policies SHALL use the [DPV–ODRL target rules](volume-3-policy.html#policy-rules). Semantic-Level policies use semantic groups, such as `@subject-identifiers`. Syntax-Level policies use concrete element selectors and declare the applicable payload family and version. The Manager SHALL preserve first-match precedence within each rule set.

A `job` linkage scope is limited to that job, including its tasks and retries. A `source-institution` scope permits authorized reuse across jobs of one source institution. A `cross-community` scope permits authorized reuse across participating communities. A policy SHALL declare a linkage scope when it selects lookup-backed replacement, encryption, salted hashing, or date shifting without an explicit consistency scope. See the [ODRL action parameters](odrl-content.html#action-parameters). Lookup-backed replacement requires reversible mode. The Manager SHALL resolve a `job` scope to a stable scope identifier for the job and retries. For other scope types the Manager SHALL preserve the approved identifier. The Manager SHALL include the resolved scope in each compiled salted hash rule. For other actions that require protected input or a lookup assignment, apply the applicable action and transaction rules.

The ODRL Policy Set declares ruleSet order and any stage sequence. The Manager applies this order under the [staged job execution rules](volume-2.html#staged-job-execution).

<a name="dpv-odrl-policy-profile"> </a>

### DPV–ODRL policy profile

DPV–ODRL defines format-independent policy targets and a corresponding compiled Execution Plan. The Policy and Execution Plan use the DIS FHIR R4 Contract carriers and signature rules. The [ODRL Agreement binding](odrl-content.html#odrl-authorization) governs authorization for the approved scope and recipient.

#### Common personal information model

Each ODRL target describes a class of occurrences using exactly one value from each dimension.

| Dimension | ODRL constraint operand | Values |
| --- | --- | --- |
| Personal data category | `disdpv:category` | The DPV v2.3 concept IRI. The FHIR R4 mapping covers `pd:Name`, `pd:Identifier`, and `pd:BirthDate`. |
| Role in the record | `disdpv:personRole` | `disdpv:patient`, `disdpv:patient-contact`, `disdpv:care-provider`, or `disdpv:all-person-roles`. The FHIR R4 mapping defines additional role use. |
| Location | `disdpv:location` | `disdpv:structured` for structured elements, `disdpv:narrative` for names or other information within free text, and `disdpv:pixel` for information in image pixels. The FHIR R4 mapping supports only `disdpv:structured`. |
{: .grid}

Category matching uses the exact IRI defined in [DPV Personal Data Categories v2.3](https://w3c-cg.github.io/dpv/2.3/pd/). A binding declares the categories it can evaluate. The Manager SHALL reject an unsupported category and SHALL use no implicit expansion to related, broader, or narrower categories. For example, selecting `pd:BirthDate` does not select a recorded age. The [DPV Health Sector Concepts v2.3 draft](https://w3c-cg.github.io/dpv/2.3/sector/health/) provides context for interpreting health sector roles. The DIS role codes below have their own matching rules.

- **Patient** applies to information about a person in the role of receiving care represented by the assigned record.
- **Patient contact** applies to information about a person represented as a patient's contact.
- **Care provider** applies to information about a person represented as participating in the patient's care in the assigned record. A person can have another role elsewhere in the same payload. A name in a patient record remains in the patient role even if the same person is also named as a care provider.
- **All person roles** matches every occurrence with the selected category and location within the supported assignment scope. It also matches occurrences where the person's precise role is unnecessary to determine the action.

Other FHIR R4 roles include a related person, the person described by a `Person` record, a family member, a named contact, a subscriber, and a research participant. Their occurrence-level bindings are defined in the [FHIR R4 mapping](volume-3-fhir-addressing.html#fhir-r4-dpv-mapping).

Location values are exact. To cover several locations, author a rule for each location. Where an action requires complete coverage of a location, a binding SHALL establish that coverage for the governed assignment. For example, a mapping for a person's structured name does not cover the same name in a narrative or image. The policy's coverage statement applies to the selected locations and the input scope admitted under the Agreement.

#### ODRL representation

Use the [DPV–ODRL JSON-LD context](schemas/dis-dpv-odrl-draft-1.jsonld) as the sole context for the Policy and Execution Plan. The [DPV–ODRL vocabulary (RDF Turtle)](schemas/dis-dpv-odrl-draft-1.ttl) identifies the profiles and terms. The `dis:` prefix identifies the [DIS actions and shared terms](odrl-content.html#dis-odrl-vocabulary). Apply the [common JSON-LD requirements](odrl-content.html#common-json-ld-requirements). The context URL and `disdpv:` term IRIs retain their published identifiers for policies, plans, and FHIR R4 mapping revision 1.

| Artifact | ODRL type | Profile identifier |
| --- | --- | --- |
| Policy | `Set` | `disdpv:Policy` |
| Execution Plan | `Set` | `disdpv:ExecutionPlan` |
{: .grid}

##### Policy rules

Use the `uid`, `obligation`, `dis:reversibilityMode`, `dis:ruleSets`, and optional staging and linkage scope fields of the [DIS Policy Set](odrl-content.html#de-identification-policy-set). The Policy Set SHALL omit `dis:representationLevel`, `dis:payloadFamily`, and `dis:payloadVersion`.

Each obligation SHALL have a unique `uid`, an `action`, and one `target`. The target is an ODRL `AssetCollection` with `source` equal to `disdpv:personal-information`. Its `refinement` is an array of three constraints, one for each dimension. Each constraint uses `eq` and an explicit `{"@id":"…"}` right operand. All three constraints SHALL match. Reject unknown or duplicate operands, unsupported values, and additional target properties. See the [ODRL Information Model, §2.5.5](https://www.w3.org/TR/odrl-model/).

Use the nine DIS actions and their [existing definitions and parameters](#transformation-actions), including the [ODRL action encoding](odrl-content.html#action-parameters). The allowed actions are `remove`, `replace`, `keep`, `hash`, `truncate-date`, `date-shift`, `round`, `truncate`, and `redact`. Reversibility is declared independently of action support. The applicable option, assignment capabilities, and action-specific requirements still govern each selected action.

Within a plan, the first matching rule controls each concrete occurrence. Put a role-specific `keep` rule before an all-roles `remove` rule to preserve an exception. The serialized obligation array carries no precedence. Apply the existing [rule evaluation and overlap checks](volume-3-execution-plan.html#3pxx212-execution-plan-json-structure-and-rule-evaluation) to same-element matches and to incompatible ancestor and descendant actions.

<a name="3pxx221-policy-rules-examples"> </a>

<a name="3pxx121-policy-rules-examples"> </a>

<a name="3pxx131-policy-rules-examples"> </a>

See the [DPV–ODRL worked policies](examples-odrl.html#dpv-odrl-worked-examples) for a category-based policy and care-provider exception. See the [decoded ODRL Policy Set](examples-odrl.html#decoded-policy-example) for the Semantic-Level policy used in UC-2. It selects `@subject-names`, which the Manager resolves to `Patient.name` in the R4 execution plan. See also the [UC-1 staged Bulk FHIR policy](examples-bulk-fhir-cohort.html#approved-policy), [UC-3 reversible Semantic-Level policy](examples-reversible-pathology.html#approved-reversible-policy), and [UC-4 signed Syntax-Level policy](examples-cloud-decision-support.html#approved-policy-and-delivery) in their respective use-case examples.

<a name="3pxx23-policy-delivery-and-validation"> </a>

<a name="3pxx13-policy-delivery-and-validation"> </a>

<a name="3pxx14-policy-delivery-and-validation"> </a>

## 3:PXX.2.4 Policy Delivery and Validation

A de-identification policy is a reusable knowledge artifact. The same policy may be approved for multiple independent data requests. Each payload-set input in the ITI-x1 request declares the approved policy as a versioned canonical in the `policy` subextension. The `authorization` input provides evidence that the data governance authority approved the data request and that specific policy. The De-ID Manager validates that the declared policy matches the policy approved in the authorization.

<a name="3pxx231-policy-content-resolution"> </a>

<a name="3pxx131-policy-content-resolution"> </a>

<a name="3pxx141-policy-content-resolution"> </a>

### 3:PXX.2.4.1 Policy Content Resolution

<a name="approved-policy-access"> </a>

DIS assumes that the De-Identification Requester can read the exact approved policy Contract and its rules. The Requester obtains access by implementation-defined means and SHALL declare the canonical URL and version approved for each set. The De-ID Manager SHALL verify that the approved canonical URL and version identify one immutable rules payload, including the linkage scope, rule parameters and stage order. A change to the approved rules requires a new Contract version and approval for the data request.

The optional `policyContent` subextension determines how the De-ID Manager obtains the policy Contract:

**When `policyContent` is present (inline delivery):** The subextension SHALL reference a contained [DIS Policy Content Binary](StructureDefinition-DIS-PolicyContent.html) by its local fragment identifier. `Binary.data` SHALL carry the UTF-8 JSON serialization of the complete FHIR R4 Policy Contract with `Binary.contentType = application/fhir+json`. The Manager SHALL reject an unresolved reference or invalid carrier and SHALL verify the decoded Contract's canonical URL and version against the declaration.

**When `policyContent` is absent (Manager-resolved):** The Manager SHALL resolve the exact declared Policy Contract by implementation-defined trusted means and verify its canonical URL and version. Both delivery modes use the [shared Contract signature requirements](volume-3-contract-rules.html#contract-signatures).

<a name="3pxx232-policy-validation"> </a>

<a name="3pxx132-policy-validation"> </a>

<a name="3pxx142-policy-validation"> </a>

### 3:PXX.2.4.2 Policy Validation

The De-ID Manager SHALL perform the following validation on the resolved policy Contract.

1. **Authorization consistency** — verify that the canonical and version declared for each set in the job submission identify the policy bound by the selected permission in the [Data Request Authorization Agreement](volume-3-authorization.html#data-request-authorization).
2. **Integrity** — confirm that the obtained Contract's canonical URL and version match the declaration and that its rules are the exact content bound to the approved version. Apply the [deployment signature requirements](volume-3-contract-rules.html#contract-signatures) and establish trust in the exact policy revision. Both modes require an unambiguous binding to the approved content, for example through an authoritative immutable version or an integrity value bound to the approval. Reject altered or ambiguous content even if its canonical URL and version match the declaration.
3. **Schema** — verify the Contract conforms to the [DIS Policy profile](StructureDefinition-DIS-Policy.html) and the decoded policy rules conform to the [DIS ODRL Policy Set](odrl-content.html#de-identification-policy-set). Also verify unique ruleSet, rule, and stage IDs in their applicable scopes, resolve all stage references, and check that each ruleSet appears exactly once when stages are declared. Validate target paths or semantic groups, action applicability, and parameter values that depend on the target, approved scope, or declared capabilities.
4. **Currency** — verify the current date falls within `Contract.applies` and that the policy has not been revoked. Revocation checking uses the deployment's implementation-defined policy trust and lifecycle mechanisms.

<a name="3pxx25-policy-lifecycle"> </a>

<a name="3pxx15-policy-lifecycle"> </a>

<a name="3pxx16-policy-lifecycle"> </a>

## 3:PXX.2.5 Policy Lifecycle

DIS does not standardize policy lifecycle management (authoring, approval, distribution, revocation, versioning workflows). Implementations obtain policies through implementation-defined mechanisms, including local configuration, administrative provisioning, bilateral agreement, or integration with an external policy management system.

The De-ID Manager SHALL admit an issued policy with `Contract.status = policy` only while `Contract.applies` covers the current time and the Manager can establish that the policy revision has not been revoked. An authorized, immutable policy version can be reused across jobs.
