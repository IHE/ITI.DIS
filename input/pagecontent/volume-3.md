Volume 3 defines the content used by the DIS workflow. [Volume 1](volume-1.html) describes the actors and their obligations. [Volume 2](volume-2.html) specifies the transactions that carry the content.

- The De-ID Manager turns an approved policy into an execution plan by resolving semantic groups or validating concrete selectors against the selected payload binding and release.
- DIS actors use that binding to package or locate source and de-identified data for exchange through the FHIR R4 protocol.

| Topic | Content defined here |
|---|---|
| [De-Identification Policy](#de-identification-policy) | Approved policy artifact, transformation actions, rule sets, validation, and compilation |
| [De-Identification Execution Plan](#execution-plan-content) | Resolved task rules and FHIR integrity constraints |
| [Payload Bindings](#payload-bindings) | Common manifest contract, FHIR payload releases, and links to proposed native-format bindings |
| [De-Identification Evidence](#evidence-baseline) | Minimum evidence and its FHIR R4 Provenance representation |
| [Reversible Lookup Table](#3pxx5-reversible-lookup-table) | Protected patient identifier mappings and examples |
{: .grid}

<a name="de-identification-policy"> </a>

<a name="policy-content-module"> </a>

<a name="3pxx2-dis-policy-content-module"> </a>

## 3:PXX.1 De-Identification Policy

This section defines the structure, delivery, validation, and compilation of de-identification policies. A policy is a reusable knowledge artifact that governs what de-identification transformations are applied. A policy may be authored at the Semantic-Level (using semantic group references, format-neutral) or at the Syntax-Level (using concrete element paths for a specific payload family and version). Both representation levels use the same Library carrier, delivery modes, and four-point validation. The De-ID Manager validates the policy, and when required, compiles it into one or more payload-specific execution plans (see [§3:PXX.2.1](#3pxx21-execution-plan-format)) before dispatching tasks.

The policy artifact is an HL7 FHIR R4 Library resource, part of the protocol layer. It is fixed to HL7 FHIR R4 regardless of the payload version being de-identified.

**Referenced standards and artifacts.** The [HL7 FHIR R4 Library]({{site.data.fhir.path}}library.html) carries the policy. The draft [DIS Policy profile](StructureDefinition-DIS-Policy.html) and [DIS Library Type CodeSystem](CodeSystem-dis-library-type.html) define its FHIR constraints. [ITI-x1](volume-2.html#23x1-submit-de-identification-job-iti-x1) defines the policy submission and admission behavior.

<a name="3pxx21-policy-library-resource-structure"> </a>

### 3:PXX.1.1 Policy Library Resource Structure

A DIS policy is carried as an HL7 FHIR R4 `Library` resource. The Library resource provides versioned metadata about the policy; the policy rules are carried as a DIS-specific JSON format within `Library.content`. Policies and execution plans both use Library but are distinguished by `Library.type` coding.

Table 3:PXX.1.1-1 lists the required Library resource elements for a DIS policy.

<p id="tPXX.1.1-1" class="tableTitle"><strong>Table 3:PXX.1.1-1: DIS-Policy Library Resource Elements</strong></p>

| Element | Cardinality | Description |
|---------|-------------|-------------|
| `Library.url` | 1..1 | Canonical URL identifying this policy |
| `Library.identifier` | 1..* | Business identifier(s) for the policy |
| `Library.version` | 1..1 | Version of the policy |
| `Library.name` | 1..1 | Machine-readable name |
| `Library.title` | 0..1 | Human-readable title |
| `Library.status` | 1..1 | `draft`, `active`, or `retired` |
| `Library.type` | 1..1 | SHALL use coding `https://profiles.ihe.net/ITI/DIS/CodeSystem/dis-library-type\|dis-policy` |
| `Library.date` | 1..1 | Date the policy was authored or last revised |
| `Library.publisher` | 1..1 | Policy authority that authored and signed the policy |
| `Library.description` | 0..1 | Human-readable description of the policy's purpose |
| `Library.purpose` | 0..1 | Stated purpose (e.g., research de-identification, clinical pseudonymization) |
| `Library.useContext` | 0..* | Context of use: purpose codes, applicable jurisdictions, applicable data categories |
| `Library.jurisdiction` | 0..* | Geographic jurisdictions where the policy is applicable |
| `Library.effectivePeriod` | 1..1 | Period during which the policy is valid; used for currency validation |
| `Library.relatedArtifact` | 0..* | References to related artifacts (e.g., related policies, derived execution plans) |
| `Library.content` | 1..1 | Attachment containing the policy rules JSON |
| `Library.content.contentType` | 1..1 | SHALL be `application/vnd.ihe.dis.policy+json` |
| `Library.content.data` | 1..1 | Base64-encoded policy rules JSON |
{: .grid}

Table 3:PXX.1.1-2 lists the `Library.type` codings used to distinguish DIS Library artifacts.

<p id="tPXX.1.1-2" class="tableTitle"><strong>Table 3:PXX.1.1-2: DIS Library Type Codings</strong></p>

| Coding | Artifact |
|--------|----------|
| `dis-policy` | De-identification policy (Semantic-Level or Syntax-Level rules) |
| `dis-execution-plan` | Execution plan (payload-specific compiled rules, see [§3:PXX.2.1](#3pxx21-execution-plan-format)) |
{: .grid}

<div markdown="1" class="stu-note">
The draft [DIS Policy](StructureDefinition-DIS-Policy.html) and [DIS Execution Plan](StructureDefinition-DIS-ExecutionPlan.html) profiles use the [DIS Library Type CodeSystem](CodeSystem-dis-library-type.html).
</div>

<a name="transformation-actions"> </a>

<a name="3pxx13-transformation-actions"> </a>

<a name="3pxx22-transformation-actions"> </a>

### 3:PXX.1.2 Transformation Actions

Policy rules select transformation actions. The compiled execution plan applies the same action definitions to concrete targets. This section defines the Phase 1 core action family (`core`) for DIS-FHIR-Payload. Every De-Identifier declaring DIS-FHIR-Payload SHALL support all actions in the `core` family.

<a name="3pxx131-action-catalog"> </a>

<a name="3pxx221-action-catalog"> </a>

#### 3:PXX.1.2.1 Action Catalog

Table 3:PXX.1.2-1 lists the Phase 1 core transformation actions.

<p id="tPXX.1.2-1" class="tableTitle"><strong>Table 3:PXX.1.2-1: Phase 1 Core Transformation Actions</strong></p>

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

<a name="3pxx132-action-definitions"> </a>

<a name="3pxx222-action-definitions"> </a>

#### 3:PXX.1.2.2 Action Definitions

##### remove

The `remove` action removes the targeted element and all its children from the resource. After removal, the element SHALL NOT be present in the de-identified output. If the targeted element is required by the HL7 FHIR base resource definition (cardinality 1..1 or 1..*), the De-Identifier SHALL reject the task with an OperationOutcome. Execution plans SHALL NOT target required elements with the `remove` action.

##### replace

With `parameters.source` set to `lookupTable`, `replace` replaces patient business identifiers in `Patient.identifier` using the [lookup-backed assignment rules](#lookup-backed-assignment). This mode is mutually exclusive with a fixed `value`. It SHALL preserve identifier/reference consistency and SHALL NOT fall back to fixed replacement or hashing when an entry is absent. The following fixed-value behavior applies only when lookup mode is not selected.

The `replace` action replaces the targeted element's displayable content with the nonempty string specified by the `value` parameter.

For a fixed replacement of an `Identifier`, replace `Identifier.value` and preserve its system unless another authorized action changes it. For `HumanName`, each sub-element (`family`, `given`, `text`) is replaced with the specified value. For `Address`, each sub-element (`text`, `line`, `city`, `district`, `state`, `postalCode`) is replaced with the specified value; `Address.country` is preserved. For `ContactPoint`, `ContactPoint.value` is replaced with the specified value; `ContactPoint.system` and `ContactPoint.use` are preserved.

##### keep

The `keep` action preserves the targeted element unchanged in the de-identified output. In first-match-wins evaluation, `keep` enables execution plans to express exceptions before general rules — for example, preserving a specific identifier before removing all identifiers:

```
R01: target Patient.identifier.where(system = 'https://example.org/approved-id')    action keep
R02: target Patient.identifier         action remove
```

##### hash

The `hash` action computes a SHA-256 digest. The `algorithm` parameter uses the `SHA-256` code from HL7's [IntegrityCheckAlgorithm CodeSystem](https://terminology.hl7.org/CodeSystem-v3-IntegrityCheckAlgorithm.html). The `mode` parameter selects `salted` or `unsalted`.

For patient business identifiers, the rule SHALL use `salted` and declare `pseudonymSystem`. Apply the patient identifier recipe in [§3:PXX.1.2.3](#3pxx123-patient-identifier-pseudonymization). Generic value rules hash the exact original string, including a selected displayable string sub-element where applicable. The unsalted message is the UTF-8 serialization of `["DIS-value-digest-v1", value]`. The salted message is the UTF-8 serialization of `["DIS-value-digest-v1", scope.type, scope.identifier.system, scope.identifier.value, value]` followed by the raw scope salt. Both modes use the serialization and output rules in §3:PXX.1.2.3. An unsalted rule is unsuitable for patient business identifiers because an observer can test guesses against the digest.

For `HumanName`, hash `family`, `given`, `prefix`, `suffix` and `text` individually. Preserve `use` and remove `period`. For an `Identifier` governed by a generic hash rule, replace `value` with the digest and set `system` to the rule's required `pseudonymSystem`. Preserve `type`, `use` and `period`, and remove `assigner`.

Unsalted test vector. The exact UTF-8 message is `["DIS-value-digest-v1","example"]` and the digest is `7a5d5b43b1725c76debaedcb17ccfb99d6bd99299593c8b18eab0b4d0e4643b9`.

##### truncate-date

The `truncate-date` action reduces the precision of the targeted date value to the level specified by the `precision` parameter.

- `precision: year` — retain only the year (e.g., `1985-03-15` → `1985`)
- `precision: year-month` — retain year and month (e.g., `1985-03-15` → `1985-03`)

##### date-shift

Date shifting requires a separately declared, purpose-specific derivation capability. The De-Identifier SHALL use patient hashing salts only for the authorized hash rules. The `date-shift` action shifts the targeted date or time value by a per-patient offset. The offset is deterministically derived from the scope-derived seed material and the patient identifier, ensuring that all dates for the same patient within the same consistency scope are shifted by the same offset. The offset magnitude SHALL NOT exceed the `maxOffsetDays` parameter. The direction (forward or backward) is determined by the derivation.

Date shifting preserves temporal ordering and intervals between events for the same patient. The De-Identifier SHALL apply the same offset to all `date`, `dateTime`, `instant`, and `Period` elements for a given patient within a single task.

For `Period` elements, shift each present bound by the same offset. If a date or dateTime has insufficient precision to determine a day, the De-Identifier SHALL fail the task when a date-shift rule selects it.

##### round

The `round` action bins a numeric value to the nearest multiple of the `step` parameter. The rounding centers at zero. When a value is exactly halfway between two multiples, select the multiple farther from zero.

- `round(57, step: 10)` → `60`
- `round(23, step: 5)` → `25`
- `round(82, step: 10)` → `80`

##### truncate

The `truncate` action retains only the first `length` characters of a string value, discarding the remainder.

- `truncate("02139", length: 3)` → `"021"`
- `truncate("SW1A 2AA", length: 4)` → `"SW1A"`

##### redact

The `redact` action removes the narrative content (`DomainResource.text`) from a resource. The De-Identifier SHALL replace the entire narrative with a fixed placeholder using `Narrative.status = empty` and `Narrative.div = <div xmlns="http://www.w3.org/1999/xhtml">Narrative redacted</div>`. The placeholder preserves valid XHTML without carrying any source text, attributes, images, or links.

<a name="3pxx133-baseline-patient-pseudonym-derivation"> </a>

<a name="3pxx223-baseline-patient-pseudonym-derivation"> </a>

<a name="3pxx123-baseline-patient-pseudonym-derivation"> </a>

#### 3:PXX.1.2.3 Patient Identifier Pseudonymization

Two actions can assign pseudonyms to patient business identifiers. Salted `hash` derives the pseudonym from the source identifier and linkage scope. Lookup-backed `replace` uses a mapping supplied for the authorized scope.

**Salted hash derivation.**

The Manager SHALL copy the resolved policy `identity-linkage-scope` into each compiled salted `hash` rule. The De-Identifier SHALL obtain the confidential salt for the resolved scope through its deployment. The deployment SHALL generate or derive a distinct effective salt of exactly **16 bytes** for each scope and salt version using cryptographically secure material. Authorized workers that need matching pseudonyms SHALL use the same effective salt and version. The deployment SHALL keep the selected version consistent across all tasks and retries of a job. For example, a deployment can coordinate rotation after the jobs using a version finish. Rotating the salt changes the pseudonym derivation context. The De-Identifier SHALL fail the task if it cannot obtain the applicable salt or if the decoded salt length differs from 16 bytes.

For each `Patient.identifier` targeted by the rule, require a nonempty source `system` and `value`. Construct this ordered array of strings using the exact scope and source identifier values:

```text
["DIS-patient-identifier-v1", scope.type, scope.identifier.system, scope.identifier.value, source.system, source.value]
```

Serialize the array without whitespace, escape quotation marks, backslashes and control characters as required by JSON, emit other Unicode characters directly, preserve forward slashes, use the short JSON escapes for backspace, tab, newline, form feed and carriage return, and use lowercase Unicode escapes for the remaining control characters U+0000–U+001F. Perform no Unicode normalization and reject unpaired surrogates. Encode the resulting text as UTF-8 without a byte-order mark. Append the 16 raw salt bytes to the UTF-8 bytes, then compute SHA-256 over the concatenation. Set `Identifier.system` to the rule's `pseudonymSystem` and `Identifier.value` to the complete 32-byte digest as 64 lowercase hexadecimal characters. Scope and identifier values use exact string matching. Cross-community identity resolution and salt coordination remain deployment prerequisites. On detecting a digest collision between distinct source identifier pairs within the job, fail the job without partial output.

Salted test vector. The exact UTF-8 message is `["DIS-patient-identifier-v1","source-institution","https://hospital.example.org/identifiers/linkage-scope","lab-project-2026","https://hospital.example.org/identifiers/mrn","A123"]`. Append the 16 public test bytes `000102030405060708090a0b0c0d0e0f` (hexadecimal). The expected digest is `8162610a149e7b6700513fa3f0ceff46328e2b584fd3d351e4d5c2775a42ff0c`. Deployments generate their own confidential salts.

<a name="lookup-backed-assignment"> </a>

**Lookup-backed assignment.**

The De-Identifier uses the supplied [lookup table](#3pxx5-reversible-lookup-table) to replace `Patient.identifier`. `sourceSystem` and `sourceValue` are the original `Identifier.system` and `Identifier.value`. `targetSystem` and `targetValue` are the pseudonym identifier pair. The De-Identifier SHALL match both source fields exactly, without implicit normalization, and replace both target fields. A supplied table may map multiple approved source identifiers to one assigned pseudonym for the same patient. The table authority and Manager SHALL ensure that a shared target pair is authorized for the same patient. A missing or conflicting source mapping SHALL fail the job without partial output.

<a name="3pxx22-policy-rules-json-structure"> </a>

<a name="3pxx12-policy-rules-json-structure"> </a>

### 3:PXX.1.3 Policy Rules JSON Structure

The [DIS policy JSON Schema](schemas/dis-policy.schema.json) defines the structure of the decoded JSON in `Library.content.data`. The [DIS Policy profile](StructureDefinition-DIS-Policy.html) defines the structure of the enclosing FHIR Library. The policy rules use one of two representation levels:

- **Semantic-Level** — rules use semantic group references (prefixed with `@`) and action codes. The policy is format-neutral and requires compilation into a payload-specific execution plan before dispatch. This is the default representation for reusable, cross-format policies.
- **Syntax-Level** — rules use concrete element paths (e.g., FHIRPath expressions for HL7 FHIR, DICOM tag paths for DICOM) and action codes. The policy is specific to a payload family and version, and is directly executable after validation. A Syntax-Level policy requires `payloadFamily` and `payloadVersion` declarations.

Both levels use the same JSON structure, delivery modes, and four-point validation. The `@` prefix on rule targets is the syntactic marker distinguishing Semantic-Level from Syntax-Level rules. A De-Identifier SHALL never receive rules containing unresolved `@` references — that would indicate a compilation failure.

Table 3:PXX.1.3-1 lists the top-level elements of the policy rules JSON.

<p id="tPXX.1.3-1" class="tableTitle"><strong>Table 3:PXX.1.3-1: Policy Rules JSON — Top-Level Elements</strong></p>

| Element | Cardinality | Type | Description |
|---------|-------------|------|-------------|
| `policyVersion` | 1..1 | string | Policy rules JSON format version. Use `1.0` for this schema. `Library.version` identifies the policy revision. |
| `representationLevel` | 1..1 | code | `semantic` or `syntax` |
| `reversibilityMode` | 1..1 | code | `irreversible` or `reversible` |
| `identity-linkage-scope` | 0..1 | object | Authorized scope for lookup-backed replacement or salted hashing. Required when either is used. A `job` scope declares only `type`. A `source-institution` or `cross-community` scope declares `type` and an `identifier` with `system` and `value`. |
| `payloadFamily` | 0..1 | string | Required for Syntax-Level policies. Phase 1 uses `fhir`. Semantic-Level policies omit this field. |
| `payloadVersion` | 0..1 | string | Required for Syntax-Level policies. Use `R4`, `R5`, or provisional `R6` under the payload version rules. Semantic-Level policies omit this field. |
| `ruleSets` | 1..* | array | Named groups of de-identification rules |
| `stages` | 0..* | array | Optional ordered list of execution stages referencing ruleSet IDs. If present, the list contains at least one stage. |
{: .grid}

Each ruleSet in the `ruleSets` array contains the elements listed in Table 3:PXX.1.3-2.

<p id="tPXX.1.3-2" class="tableTitle"><strong>Table 3:PXX.1.3-2: Policy Rules JSON — RuleSet Elements</strong></p>

| Element | Cardinality | Type | Description |
|---------|-------------|------|-------------|
| `ruleSetId` | 1..1 | string | Unique identifier for the ruleSet within the policy |
| `description` | 0..1 | string | Human-readable description of the ruleSet |
| `rules` | 1..* | array | Ordered list of rules for this ruleSet |
{: .grid}

Each rule in the `rules` array contains the elements listed in Table 3:PXX.1.3-3.

<p id="tPXX.1.3-3" class="tableTitle"><strong>Table 3:PXX.1.3-3: Policy Rules JSON — Rule Elements</strong></p>

| Element | Cardinality | Type | Description |
|---------|-------------|------|-------------|
| `ruleId` | 1..1 | string | Unique identifier for the rule within the policy |
| `target` | 1..1 | string | Semantic group reference (prefixed with `@`) for Semantic-Level policies, or a concrete element path (e.g., FHIRPath expression) for Syntax-Level policies |
| `action` | 1..1 | code | Action code from the core action family (see [§3:PXX.1.2](#transformation-actions)) |
| `parameters` | 0..1 | object | Action-specific parameters as key-value pairs |
{: .grid}

Semantic-Level policy rules use semantic group references (e.g., `@subject-identifiers`) rather than element paths. This keeps the policy format-neutral. The De-ID Manager expands semantic group references to payload-specific element paths during compilation (see [§3:PXX.1.5](#3pxx15-policy-compilation)).

Syntax-Level policy rules use concrete element paths appropriate to the declared `payloadFamily`. For HL7 FHIR payloads, these are FHIRPath expressions (e.g., `Patient.identifier`, `Patient.name`). The De-ID Manager validates that all rule targets are valid paths for the declared payload family and version.

Rules within a ruleSet are evaluated in order; first-match-wins evaluation applies, consistent with execution plan evaluation (see [§3:PXX.2.1.2](#3pxx212-execution-plan-json-structure-and-rule-evaluation)).

The schema checks which parameters an action accepts. Lookup-backed `replace` requires reversible mode and is mutually exclusive with fixed replacement. A salted `hash` rule uses the policy scope. For a patient business identifier target, the Manager SHALL require `mode` of `salted` and a `pseudonymSystem`, including when a target is expressed as a FHIRPath selector. The Manager SHALL validate its authorization and resolve a `job` scope to a stable scope identifier for the job and its retries. For other scope types, the Manager SHALL copy the authorized `system` and `value` as supplied in the approved policy. The scope level and identifier SHALL be copied into each applicable compiled rule. Date-shift derivation and its protected inputs remain a separate capability contract.

Each stage in the optional `stages` array contains the elements listed in Table 3:PXX.1.3-4.

<p id="tPXX.1.3-4" class="tableTitle"><strong>Table 3:PXX.1.3-4: Policy Rules JSON — Stage Elements</strong></p>

| Element | Cardinality | Type | Description |
|---------|-------------|------|-------------|
| `stageId` | 1..1 | string | Stage identifier (e.g., `preliminary`, `advanced`) |
| `description` | 0..1 | string | Human-readable description of the stage |
| `ruleSetRefs` | 1..* | array of string | Ordered list of ruleSet IDs assigned to this stage |
{: .grid}

The Manager SHALL dispatch each stage after validating all results from the preceding stage. A later stage SHALL receive the validated outputs from the preceding stage, together with any unchanged resources needed for its authorized input set. It SHALL NOT receive the original versions of transformed resources or the preceding stage's protected mappings unless separately required and authorized for its task. The last stage's validated output, including unchanged resources, is the basis for the released set.

Within a stage, the Manager SHALL process ruleSets in the listed order for any input resource governed by more than one ruleSet. Each subsequent ruleSet receives the latest validated version of that resource. The Manager MAY run tasks concurrently on disjoint inputs when their transformations cannot affect each other's references or results. If it cannot determine an unambiguous input or final result, it SHALL reject the plan before dispatch. When `stages` is absent, apply the same rules in one stage using the order of `ruleSets`.

<a name="3pxx221-policy-rules-examples"> </a>

<a name="3pxx121-policy-rules-examples"> </a>

<a name="3pxx131-policy-rules-examples"> </a>

The [Policy Rules Examples](examples-policy-rules.html) page illustrates Semantic-Level and Syntax-Level policies, including staged execution.

<a name="3pxx23-policy-delivery-and-validation"> </a>

<a name="3pxx13-policy-delivery-and-validation"> </a>

### 3:PXX.1.4 Policy Delivery and Validation

A de-identification policy is a reusable knowledge artifact. The same policy may be approved for multiple independent data requests. The ITI-x1 `policy` group, within each `payload` set, declares the approved policy by canonical URL (`policy.url`) and version (`policy.version`). The `authorization` parameter provides evidence that the data request — including approval of that specific policy — was authorized by the data governance authority. The De-ID Manager validates that the declared policy matches the policy approved in the authorization.

<a name="3pxx231-policy-content-resolution"> </a>

<a name="3pxx131-policy-content-resolution"> </a>

#### 3:PXX.1.4.1 Policy Content Resolution

The `policy.content` parameter is optional. It determines how the De-ID Manager obtains the policy Library:

**When `policy.content` is present (inline delivery):** The Requester carries the JWS-signed policy Library directly in the ITI-x1 request as a `Binary` resource with `Binary.contentType` of `application/jose`. The JWS protects the policy content from tampering by the Requester, who acts as an untrusted courier. The De-ID Manager SHALL verify the JWS signature against the trusted policy authority's public key. The JWS payload is the JSON serialization of the Library resource. The JWS header SHALL include:

- `alg` — the signing algorithm (e.g., `RS256`, `ES256`)
- `x5c` or `jwk` — the signing key or certificate chain, enabling the De-ID Manager to verify the signature against a trusted policy authority

The De-ID Manager SHALL confirm that `Library.url` and `Library.version` inside the JWS payload match the declared `policy.url` and `policy.version`. A mismatch indicates the Requester declared one policy but couriered different content; the Manager SHALL reject the job.

**When `policy.content` is absent (Manager-resolved):** The ITI-x1 request carries only `policy.url` and `policy.version`. No policy content appears in the ITI-x1 message. The De-ID Manager resolves the policy from the declared canonical URL through its own mechanisms and SHALL verify that the resolved Library URL and version match the declaration:

- When the URL matches a policy managed locally by the De-ID Manager (e.g., provisioned by administrative configuration), the Manager resolves it from its own store.
- When the URL identifies an externally hosted policy, the Manager retrieves the policy through its implementation-defined trust model (e.g., TLS-protected fetch, mutual TLS, or externally stored JWS artifacts).

Locally managed policies are trusted by virtue of their administrative provisioning; the Manager is not required to verify a JWS signature at each job submission.

<a name="3pxx232-policy-validation"> </a>

<a name="3pxx132-policy-validation"> </a>

#### 3:PXX.1.4.2 Policy Validation

The De-ID Manager SHALL perform the following validation on the resolved policy Library, as defined in [§1:PXX.4.1](volume-1.html#1pxx41-concepts):

1. **Authorization consistency** — verify that `policy.url` and `policy.version` declared in the ITI-x1 request identify the policy approved in the data request authorization. The mechanism for extracting the approved policy identity from the authorization is implementation-defined (it depends on the authorization format used in the deployment).
2. **Integrity** — when `policy.content` is present, verify the JWS signature and confirm that the Library's canonical URL and version match the declared values. When `policy.content` is absent, integrity is established by the Manager's resolution trust model.
3. **Schema** — verify the Library conforms to the [DIS Policy profile](StructureDefinition-DIS-Policy.html) and the decoded policy rules conform to the [DIS policy JSON Schema](schemas/dis-policy.schema.json). Also verify unique ruleSet, rule, and stage IDs in their applicable scopes, resolve all stage references, and check that each ruleSet appears exactly once when stages are declared. Validate target paths or semantic groups, action applicability, and parameter values that depend on the target, approved scope, or declared capabilities.
4. **Currency** — verify the current date falls within `Library.effectivePeriod` and that the policy has not been revoked. Revocation checking uses the deployment's implementation-defined policy trust and lifecycle mechanisms.

<a name="3pxx24-policy-compilation"> </a>

<a name="3pxx14-policy-compilation"> </a>

### 3:PXX.1.5 Policy Compilation

Before dispatching tasks via ITI-x3, the De-ID Manager resolves targets against the payload binding and assembles the execution plan from the validated policy Library.

<a name="3pxx241-semantic-level-compilation"> </a>

<a name="3pxx141-semantic-level-compilation"> </a>

<a name="3pxx242-syntax-level-validation"> </a>

<a name="3pxx142-syntax-level-validation"> </a>

<a name="3pxx152-syntax-level-validation"> </a>

<a name="3pxx151-semantic-level-compilation"> </a>

#### 3:PXX.1.5.1 Resolve Semantic Groups or Validate Concrete Selectors

**Semantic-Level policies.** The De-ID Manager SHALL resolve each `@` group reference using the [Semantic Group Binding](#3pxx3213-semantic-group-bindings) for the declared payload family and release. If a referenced group has no binding for that release, the Manager SHALL fail compilation before dispatch.

**Syntax-Level policies.** The De-ID Manager verifies that all rule targets are valid element paths for the declared `payloadFamily` and `payloadVersion`. For HL7 FHIR payloads, this means each target is a valid FHIRPath expression for the declared HL7 FHIR version. The Manager verifies that the policy's declared `payloadFamily` and `payloadVersion` are consistent with the `payloadBinding` and `payloadVersion` in the ITI-x1 request. The Manager preserves concrete paths without semantic group expansion or version-conditional path mapping.

#### 3:PXX.1.5.2 Assemble the Plan and Check Capabilities

**Execution plan assembly.** The Manager preserves rule order and source rule IDs and adds the resolved scope to salted rules. The Manager assembles the resolved or validated rules into execution plan JSON (see [§3:PXX.2.1.2](#3pxx212-execution-plan-json-structure-and-rule-evaluation)) and packages the plan in a Library resource with `Library.type` coding `dis-execution-plan`.

**Capability verification.** The De-ID Manager verifies that the target De-Identifier's declared capabilities support all action codes and the payload binding and version required by the execution plan. The Manager SHALL NOT dispatch a task with an incompatible execution plan.

For each applicable payload set, each ruleSet produces one execution plan Library, dispatched as one ITI-x3 task for that set. When stages are declared, the Manager dispatches in stage order. Before dispatch, the Manager SHALL populate the execution plan Library's [source policy identity](#execution-plan-source-policy) from the exact approved policy it validated.

<a name="3pxx25-policy-lifecycle"> </a>

<a name="3pxx15-policy-lifecycle"> </a>

### 3:PXX.1.6 Policy Lifecycle

Phase 1 does not standardize policy lifecycle management (authoring, approval, distribution, revocation, versioning workflows). Implementations obtain policies through implementation-defined mechanisms, including local configuration, administrative provisioning, bilateral agreement, or integration with an external policy management system.

The following lifecycle states are supported through `Library.status`:

- `draft` — the policy is under development and SHALL NOT be accepted by the De-ID Manager for job execution
- `active` — the policy is approved and valid for use within its `effectivePeriod`
- `retired` — the policy is no longer valid and SHALL NOT be accepted for new jobs

The De-ID Manager SHALL reject a policy with `Library.status` other than `active`. The De-ID Manager SHALL reject a policy whose `Library.effectivePeriod` does not include the current date.

<a name="execution-plan-content"> </a>

## 3:PXX.2 De-Identification Execution Plan

The execution plan is the task-specific artifact produced from a validated policy. The [policy compilation rules](#3pxx15-policy-compilation) define how policy rules become concrete payload selectors. The plan uses the [transformation actions](#transformation-actions) defined by the policy section. [ITI-x3](volume-2.html#23x3-submit-de-identification-task-iti-x3) defines how the Manager dispatches the plan.

<a name="execution-plan-format"> </a>

<a name="3pxx14-execution-plan-format"> </a>

### 3:PXX.2.1 Execution Plan Format

This section defines the structure of DIS-FHIR-Payload execution plans carried within HL7 FHIR R4 Library resources.

<a name="3pxx141-library-resource-structure"> </a>

#### 3:PXX.2.1.1 Library Resource Structure

A DIS-FHIR-Payload execution plan is carried as a content attachment in an HL7 FHIR R4 `Library` resource. The Library resource provides metadata about the plan; the plan content is a DIS-specific JSON format.

Table 3:PXX.2.1-1 lists the required Library resource elements.

<p id="tPXX.2.1-1" class="tableTitle"><strong>Table 3:PXX.2.1-1: Execution Plan Library Resource Elements</strong></p>

| Element | Cardinality | Description |
|---------|-------------|-------------|
| `Library.url` | 1..1 | Canonical URL identifying this execution plan |
| `Library.identifier` | 0..* | Business identifiers for the plan |
| `Library.version` | 1..1 | Version of the execution plan |
| `Library.name` | 1..1 | Machine-readable name |
| `Library.title` | 0..1 | Human-readable title |
| `Library.status` | 1..1 | `draft`, `active`, or `retired` |
| `Library.type` | 1..1 | SHALL use coding `https://profiles.ihe.net/ITI/DIS/CodeSystem/dis-library-type\|dis-execution-plan` |
| `Library.date` | 1..1 | Date the plan was compiled |
| `Library.description` | 0..1 | Human-readable description |
| `Library.content` | 1..1 | Attachment containing the execution plan JSON |
| `Library.content.contentType` | 1..1 | SHALL be `application/vnd.ihe.dis.execution-plan+json` |
| `Library.content.data` | 1..1 | Base64-encoded execution plan JSON |
{: .grid}

<a name="execution-plan-source-policy"> </a>

**Source policy identity for ITI-x3.** A dispatched DIS Execution Plan Library SHALL include exactly one `Library.relatedArtifact` of type `derived-from` identifying the policy Library that produced the plan. Its `resource` SHALL be the approved policy's canonical URL and nonempty Library version in `canonical|version` form. The same related artifact SHALL carry one [DIS Policy Evidence URI](StructureDefinition-dis-policy-evidence-uri.html) extension. Its `valueUri` SHALL be an absolute, version-specific URI identifying the same approved policy. A version-specific FHIR Library REST URL is one example. The Manager SHALL verify that both values identify the same validated policy version before dispatch.

The De-Identifier SHALL reject a plan before execution if the source policy entry, canonical version, or evidence URI is missing, malformed, or ambiguous. It SHALL copy the supplied evidence URI into `Provenance.policy` for the task. It does not need to retrieve the source policy to produce evidence. The Manager SHALL verify that the returned task evidence names the version-specific URI supplied with the plan before accepting or releasing the result. The evidence URI SHALL NOT contain credentials or temporary access tokens. The Integrated actor may use its local validated policy identity when no ITI-x3 dispatch occurs.

<a name="3pxx142-execution-plan-json-structure"> </a>

<a name="3pxx212-execution-plan-json-structure"> </a>

#### 3:PXX.2.1.2 Execution Plan JSON Structure and Rule Evaluation

The [DIS execution plan JSON Schema](schemas/dis-execution-plan.schema.json) defines the decoded attachment. It contains `planVersion`, `ruleSetId`, `payloadBinding`, `payloadVersion` and an ordered `rules` array. The `ruleSetId`, `payloadBinding` and `payloadVersion` SHALL match the ITI-x3 parameters. Each compiled rule identifies the source policy rule and specifies a target, an action, and action-specific parameters.

Table 3:PXX.2.1-2 lists the elements of each rule in the execution plan.

<p id="tPXX.2.1-2" class="tableTitle"><strong>Table 3:PXX.2.1-2: Execution Plan Rule Elements</strong></p>

| Element | Cardinality | Type | Description |
|---------|-------------|------|-------------|
| `ruleId` | 1..1 | string | Unique identifier for the compiled rule within the plan |
| `sourceRuleId` | 1..1 | string | Identifier of the approved policy rule from which this rule was compiled |
| `target` | 1..1 | string | FHIRPath expression identifying the target element(s). Semantic group references (`@`) SHALL have been expanded during compilation; they SHALL NOT appear in dispatched execution plans. |
| `action` | 1..1 | code | Action code from the core action family (see [§3:PXX.1.2](#transformation-actions)) |
| `parameters` | 0..1 | object | Action-specific parameters as key-value pairs |
{: .grid}

Within one plan, evaluate selectors on the input resource before applying mutations. When multiple rules select the same element instance, apply the first matching rule and skip later matches for that instance. Reject the plan for that resource when independently selected ancestor and descendant actions conflict, such as keeping a child while removing its parent. This first-match-wins evaluation enables execution plans to specify exceptions before general rules (e.g., keep a specific identifier before removing all identifiers).

Execution plans dispatched via ITI-x3 SHALL contain only concrete element paths. Semantic group references (`@` prefix) SHALL have been expanded by the De-ID Manager during policy compilation. The presence of an unresolved `@` reference in a dispatched execution plan is a conformance error.

<a name="3pxx143-execution-plan-example"> </a>

#### 3:PXX.2.1.3 Execution Plan Example

This decoded execution plan compiles the clinical pathology [policy example](examples-policy-rules.html#semantic-level-reversible-clinical-pathology-policy). The Manager copies the resolved institutional scope into the salted `hash` rule and expands the semantic targets to concrete paths. See the corresponding [evidence example](Provenance-dis-evidence-uc3-001.html) and [generated lookup table](DocumentReference-generated-lookup-uc3.html).

```json
{
  "planVersion": "1.0",
  "ruleSetId": "direct-identifiers",
  "payloadBinding": "DIS-FHIR-Payload",
  "payloadVersion": "R4",
  "rules": [
    {
      "ruleId": "R01",
      "sourceRuleId": "P01",
      "target": "Patient.identifier",
      "action": "hash",
      "parameters": {
        "mode": "salted",
        "algorithm": "SHA-256",
        "pseudonymSystem": "https://hospital.example.org/identifiers/pseudonym",
        "identity-linkage-scope": {
          "type": "source-institution",
          "identifier": {
            "system": "https://hospital.example.org/identifiers/linkage-scope",
            "value": "lab-project-2026"
          }
        }
      }
    },
    {
      "ruleId": "R02",
      "sourceRuleId": "P02",
      "target": "Patient.name",
      "action": "remove"
    }
  ]
}
```

<a name="3pxx224-fhir-reference-integrity"> </a>

<a name="3pxx134-fhir-reference-integrity"> </a>

### 3:PXX.2.2 FHIR Reference Integrity

The De-Identifier SHALL ensure that references between retained resources resolve correctly in the de-identified output. In a Bundle, this includes keeping `Bundle.entry.fullUrl` values and internal references consistent with the resource identities in the output. Handle references to removed resources and external references according to the approved policy. The De-Identifier SHALL fail the task without partial output if it cannot produce a valid result under the declared FHIR version and policy.

Patient pseudonymization transforms the business identifier pair in `Patient.identifier`. The lookup-table and hash bindings define that transformation. The output packaging rules govern FHIR resource identities and references.

<a name="payload-bindings"> </a>

## 3:PXX.3 Payload Bindings

DIS uses HL7 FHIR R4 protocol resources. The selected payload binding determines the native format and version and how content is carried or resolved through the protocol. The common delivery contract applies to every payload set. The FHIR binding specifies the Phase 1 payload content.

<a name="payload-set-delivery"> </a>

<a name="3pxx3-common-payload-set-delivery"> </a>

### 3:PXX.3.1 Common Payload Set Delivery

A job contains one or more payload sets. Each set uses one binding and version and carries one manifest at each exchange. Successful responses carry the manifest and evidence together in a result package. The manifest can select bundled and externally hosted content. A job can combine, for example, an inline R5 Patient and a set of separately hosted FHIR Observations. The FHIR R4 envelope carries the delivery description. The selected binding defines the native data, retrieval rules, execution plan, validation, and evidence mapping.

The [shared payload set parameters](volume-2.html#grouped-payload-parameters) define how the transactions carry a payload set.

<a name="3pxx31-manifest-formats"> </a>

<a name="3pxx311-manifest-formats"> </a>

#### 3:PXX.3.1.1 Manifest Formats and Packages

The `dis-resource-list` format carries an R4 DIS Resource Manifest as a standalone List or in an R4 [DIS Manifest Package](StructureDefinition-DIS-ManifestPackage.html). Serialize either as FHIR JSON or XML and declare the corresponding FHIR media type in the `manifest` attachment. These forms apply to inputs. Results carry the List inside the result package.

The `fhir-bulk-data` format uses the JSON [bulk file manifest](#3pxx3224-bulk-file-manifests-and-authorized-retrieval) of DIS-FHIR-Payload. It enumerates NDJSON files.

<a name="manifest-package"> </a>

Use an R4 `Bundle` of type `collection` when the manifest and its targets or indexes travel together. It SHALL contain exactly one List declaring the DIS Resource Manifest profile. Each entry in that List SHALL use either an absolute HTTPS FHIR REST reference to an R4 resource or a `urn:uuid` reference matching exactly one `Bundle.entry.fullUrl` in the same package. A standalone List SHALL use absolute HTTPS references. Only the List's selected entries determine the payload set. Other Bundle entries may support resolution under the selected binding.

A bundled R4 resource can be the target itself or a wrapper or index. The package SHALL carry non-R4 bytes inside the attachment of an R4 resource. It SHALL NOT embed a native R5 or R6 resource as a Bundle entry.

<a name="3pxx32-authorization-and-stable-retrieval"> </a>

#### 3:PXX.3.1.2 Authorization and Stable Retrieval

The Manager SHALL verify that the job authorization covers every set, including the indexes, native objects, or files reached through its references or manifests. The retrieving actor SHALL use HTTPS and obtain credentials accepted by each endpoint. For automated FHIR REST retrieval of manifests, indexes, or payloads, apply the [FHIR retrieval authorization rules](#referenced-input-authorization). Other bindings define the access mechanism for their endpoints. The job authorization and credentials for reading the source serve separate purposes.

The Manager SHALL establish the authorized target set before dispatch, including any expansion of references. Each retry SHALL use the same authorized inputs and compiled plan version. Use version-specific references or verify exact content against protected snapshots or digests. A changed input or plan that cannot be resolved to the pinned version SHALL cause task or job failure. When publishing results by reference or manifest, the producing actor SHALL ensure the locators resolve to the intended de-identified objects and are accessible only to authorized recipients. A failed or inaccessible required set SHALL cause job failure without release of any set to the Requester.

<a name="fhir-payload-binding"> </a>

<a name="fhir-payload-content-module"> </a>

<a name="3pxx1-dis-fhir-payload-content-module"> </a>

### 3:PXX.3.2 FHIR Payload Binding

The FHIR payload binding (`DIS-FHIR-Payload`) defines how actors identify, carry, retrieve, address, and validate FHIR processing payloads. The [execution plan](#execution-plan-content) and [evidence](#evidence-baseline) sections define the associated task and result artifacts.

DIS-FHIR-Payload is independent of the DIS HL7 FHIR R4 protocol binding version. It supports processing payloads in HL7 FHIR R4, R5, and R6 without requiring a corresponding version of the protocol binding. This independence is achieved through version identification, version-safe packaging, and version-neutral element addressing. As specified in Volume 1, R6 support is based on the ballot draft and will be confirmed upon final publication.

The [FHIRPath specification](https://hl7.org/fhirpath/) defines the addressing language. The [common delivery contract](#payload-set-delivery) defines the manifest and package used in each exchange.

<a name="3pxx11-cross-version-payload-support"> </a>

<a name="cross-version-payload"> </a>

<a name="content-model"> </a>

<a name="3pxx12-content-model"> </a>

<a name="3pxx322-content-model"> </a>

<a name="3pxx321-cross-version-payload-support"> </a>

#### 3:PXX.3.2.1 Addressing and Processing

The declared payload release determines the element selectors, traversal of the target resources, and validation of the result.

<a name="3pxx111-version-identification"> </a>

<a name="3pxx3211-version-identification"> </a>

##### 3:PXX.3.2.1.1 FHIR Release and Capability Matching

For a FHIR set, the `payloadVersion` field declares the FHIR release of the processing payload. The De-ID Manager SHALL reject a request that omits it and SHALL use the same declaration in ITI-x3. A De-Identifier declaring DIS-FHIR-Payload SHALL advertise the payload releases it supports. The Manager SHALL verify that the assigned De-Identifier supports the declared release before dispatch and SHALL reject the job when no available De-Identifier supports that release. Source server capabilities and attachment metadata are used to check the declaration. The retrieving actor SHALL fail processing when the retrieved content or its version metadata conflicts with the declaration.

<a name="3pxx121-element-addressing"> </a>

<a name="3pxx113-version-neutral-element-addressing"> </a>

<a name="3pxx3213-version-neutral-element-addressing"> </a>

<a name="3pxx3221-element-addressing"> </a>

##### 3:PXX.3.2.1.2 FHIRPath Element Addressing

DIS-FHIR-Payload uses FHIRPath expressions as the element addressing language. Execution plan rules and semantic group definitions reference HL7 FHIR elements using FHIRPath-compatible path expressions rooted at the resource type.

An element path SHALL be one of the following forms:

- **Resource-rooted path** -- a FHIRPath expression starting with a resource type (e.g., `Patient.name`, `Observation.value`). The path identifies one or more elements within a single resource instance.
- **Semantic group reference** -- a reference to a named semantic group (e.g., `@subject-identifiers`). The `@` prefix distinguishes a semantic group reference from a FHIRPath expression. The group expands to its member paths at policy compilation time (see [§3:PXX.1.5](#3pxx15-policy-compilation)).

When a path targets an element with child elements (e.g., `Patient.name` which contains `HumanName.family`, `HumanName.given`, `HumanName.prefix`, `HumanName.suffix`, `HumanName.text`, `HumanName.period`), the action applies to the targeted element and all its children unless the execution plan specifies a more specific child path.

Choice-type elements use the `[x]` notation (e.g., `Observation.value`). The De-Identifier SHALL apply the rule to whichever concrete type is present in the resource instance.

Semantic-Level policies use the same group codes across releases. The [Semantic Group Binding](#3pxx3213-semantic-group-bindings) supplies release-specific selectors during compilation. For example, `@dates` selects the encounter period through `Encounter.period` in R4 and `Encounter.actualPeriod` in R5.

<a name="3pxx122-semantic-groups"> </a>

<a name="3pxx3222-semantic-groups"> </a>

##### 3:PXX.3.2.1.3 Semantic Group Bindings

Semantic groups categorize HL7 FHIR elements by privacy sensitivity. Semantic-Level policies reference semantic groups instead of individual element paths. The De-ID Manager expands semantic group references to individual element paths during policy compilation (see [§3:PXX.1.5](#3pxx15-policy-compilation)).

The [DIS Semantic Group CodeSystem](CodeSystem-dis-semantic-group.html) defines the group codes and their meanings. Table 3:PXX.3.2.1-1 is the authoritative FHIR Semantic Group Binding for selector membership and order by payload release. The table defines binding version 0.2.0 independently of the FHIR payload version.

The [R4/R5 PII path catalog](bindings/dis-fhir-pii-path-catalog-0.2.0.csv) and [classification and semantic group guide](fhir-semantic-group-guide.html) are informative. They help policy authors identify candidate FHIRPath selectors for syntax-level policies. Catalog groups and paths do not extend the selector membership defined in the table.

Binding version 0.2.0 assigns `Patient.birthDate` to `birth-dates` in both R4 and R5. When migrating a policy from version 0.1.0, review rules targeting `@dates` or `@subject-demographics` and add an explicit `@birth-dates` rule if the policy still governs birth date. If both older groups targeted birth date, resolve the intended action during migration.

Policies may use the applicable date actions or remove the birth date. If the policy needs to preserve age relative to a shifted event, use the same date-shift scope for both. Deriving an age band is a separate transformation that requires a reference event or date, band boundaries, handling for partial birth dates, and an output destination. The Phase 1 core action family does not define age-band derivation.

<a name="tPXX.3.2.2-1"> </a>

<p id="tPXX.3.2.1-1" class="tableTitle"><strong>Table 3:PXX.3.2.1-1: DIS FHIR Semantic Group Binding</strong></p>

| Semantic group | FHIR R4 (4.0.1) | FHIR R5 (5.0.0) |
| --- | --- | --- |
| `subject-identifiers` | `Patient.identifier`, `Patient.name` | `Patient.identifier`, `Patient.name` |
| `subject-business-identifiers` | `Patient.identifier` | `Patient.identifier` |
| `subject-names` | `Patient.name` | `Patient.name` |
| `subject-demographics` | `Patient.gender`, `Patient.address`, `Patient.telecom`, `Patient.photo`, `Patient.maritalStatus`, `Patient.communication`, `Patient.multipleBirth`, `Patient.deceased` | `Patient.gender`, `Patient.address`, `Patient.telecom`, `Patient.photo`, `Patient.maritalStatus`, `Patient.communication`, `Patient.multipleBirth`, `Patient.deceased` |
| `contact-information` | `Patient.contact.name`, `Patient.contact.telecom`, `Patient.contact.address`, `Patient.contact.organization`, `RelatedPerson.identifier`, `RelatedPerson.name`, `RelatedPerson.telecom`, `RelatedPerson.address`, `RelatedPerson.photo` | `Patient.contact.name`, `Patient.contact.telecom`, `Patient.contact.address`, `Patient.contact.organization`, `RelatedPerson.identifier`, `RelatedPerson.name`, `RelatedPerson.telecom`, `RelatedPerson.address`, `RelatedPerson.photo` |
| `provider-identifiers` | `Practitioner.identifier`, `Practitioner.name`, `Practitioner.telecom`, `Practitioner.address`, `Practitioner.photo`, `PractitionerRole.identifier` | `Practitioner.identifier`, `Practitioner.name`, `Practitioner.telecom`, `Practitioner.address`, `Practitioner.photo`, `PractitionerRole.identifier` |
| `birth-dates` | `Patient.birthDate` | `Patient.birthDate` |
| `dates` | `Patient.deceased.ofType(dateTime)`, `Encounter.period`, `Condition.onset.ofType(dateTime)`, `Condition.onset.ofType(Period)`, `Condition.abatement.ofType(dateTime)`, `Condition.abatement.ofType(Period)`, `Procedure.performed.ofType(dateTime)`, `Procedure.performed.ofType(Period)`, `Observation.effective.ofType(dateTime)`, `Observation.effective.ofType(Period)`, `Observation.effective.ofType(instant)`, `MedicationRequest.authoredOn`, `DiagnosticReport.effective.ofType(dateTime)`, `DiagnosticReport.effective.ofType(Period)`, `DocumentReference.date` | `Patient.deceased.ofType(dateTime)`, `Encounter.actualPeriod`, `Condition.onset.ofType(dateTime)`, `Condition.onset.ofType(Period)`, `Condition.abatement.ofType(dateTime)`, `Condition.abatement.ofType(Period)`, `Procedure.occurrence.ofType(dateTime)`, `Procedure.occurrence.ofType(Period)`, `Observation.effective.ofType(dateTime)`, `Observation.effective.ofType(Period)`, `Observation.effective.ofType(instant)`, `MedicationRequest.authoredOn`, `DiagnosticReport.effective.ofType(dateTime)`, `DiagnosticReport.effective.ofType(Period)`, `DocumentReference.date` |
| `narrative` | `DomainResource.text` | `DomainResource.text` |
| `references` | `Observation.subject`, `Condition.subject`, `Encounter.subject`, `Procedure.subject`, `DiagnosticReport.subject`, `MedicationRequest.subject`, `Encounter.participant.individual`, `DocumentReference.subject`, `DocumentReference.author` | `Observation.subject`, `Condition.subject`, `Encounter.subject`, `Procedure.subject`, `DiagnosticReport.subject`, `MedicationRequest.subject`, `Encounter.participant.actor`, `DocumentReference.subject`, `DocumentReference.author` |
| `device-identifiers` | `Device.identifier`, `Device.serialNumber`, `Device.deviceName`, `Device.udiCarrier` | `Device.identifier`, `Device.serialNumber`, `Device.name`, `Device.udiCarrier` |
{: .grid}

For the declared FHIR payload release, the Manager SHALL expand each semantic group using the selectors in the corresponding release column of Table 3:PXX.3.2.1-1. The Manager SHALL preserve the listed selector order and the order of source policy rules. A selector with a concrete resource root applies to resources of that type. `DomainResource.text` applies to the narrative element on each governed resource derived from `DomainResource`.

The FHIR payload binding defines group membership. A policy selects groups and actions. It cannot change the group's selectors. The `subject-identifiers` group intentionally shares its two selectors with `subject-business-identifiers` and `subject-names`. Use the narrower groups when applying different actions to identifiers and names. A group containing a composite element selects the element as a whole. The separate action applicability rules still apply to every expanded target.

The `dates` group covers the listed structured temporal values. Its choice selectors constrain the selected FHIR types using `ofType()`. Free-text dates, ages, ranges, and schedules expressed as `Timing` are outside this binding. Other paths, including extensions and other references, require separate policy coverage as applicable. The binding does not establish that a policy covers all identifying content in a payload.

Implementations MAY define additional semantic groups beyond those listed in Table 3:PXX.3.2.1-1 for local governance requirements. Additional groups SHALL NOT conflict with the element assignments of the Phase 1 groups.

<div markdown="1" class="stu-note">
**Editorial Note:** This draft defines the proposed Phase 1 membership for R4 and R5. An R6 Semantic Group Binding remains pending.
</div>

<a name="3pxx123-resource-traversal"> </a>

<a name="3pxx3223-resource-traversal"> </a>

##### 3:PXX.3.2.1.4 Resource Traversal

An execution plan applies to a set of processing target resources. The De-Identifier SHALL traverse the processing target according to the following rules.

**Bundle traversal.** When the processing target is a Bundle, the De-Identifier SHALL apply execution plan rules to each entry resource in the Bundle. Rules are matched by the entry resource's resource type. Bundle metadata elements (`Bundle.id`, `Bundle.identifier`, `Bundle.timestamp`, `Bundle.link`) are not governed by resource-type-rooted rules; separate rules targeting `Bundle.*` paths are required to govern them.

**Contained resources.** When a processing target resource contains other resources via `Resource.contained`, the De-Identifier SHALL apply execution plan rules to each contained resource according to its resource type. References from the containing resource to contained resources (e.g., `#contained-id`) SHALL be updated if the contained resource's identifier is transformed.

**Reference chains.** In by-reference delivery mode, the processing target MAY include references to resources not included in the processing target set. The De-Identifier SHALL NOT follow references outside the processing target set. Only resources explicitly included in the processing target (directly or as Bundle entries) are governed by the execution plan. Reference elements pointing to resources outside the processing target set are governed by rules targeting the `references` semantic group.

<a name="3pxx115-validation-across-versions"> </a>

<a name="3pxx3215-validation-across-versions"> </a>

##### 3:PXX.3.2.1.5 Output Validation in the Declared Release

De-identified output SHALL be validated against the processing payload's declared HL7 FHIR version, not against the HL7 FHIR R4 protocol binding version.

The following minimum validation checks apply to all payload versions:

1. Well-formed HL7 FHIR JSON or XML conforming to the declared version.
2. Valid against the base resource definition for the declared version.
3. Valid against declared output StructureDefinition profiles when supplied. Output profiles SHALL be compatible with the payload version.
4. Each governed element matches its authorized action. A direct identifier may remain only where the approved policy explicitly permits its retention.
5. Internal references remain resolvable within the output graph or Bundle.
6. Remapped identifiers and references are consistent within the declared scope.
7. Narrative XHTML remains valid and contains no detected PHI for governed narrative targets.
8. Provenance evidence maps all required DIS evidence baseline elements (see [§3:PXX.4](#3pxx4-de-identification-evidence)).

A De-Identifier SHALL use an HL7 FHIR validation library or equivalent mechanism compatible with the declared payload version. Validation against the wrong HL7 FHIR version (e.g., validating HL7 FHIR R5 output against HL7 FHIR R4 definitions) is a conformance failure.

<a name="data-plane-access"> </a>
<a name="obtaining-processing-targets"> </a>

<a name="3pxx16-obtaining-processing-targets"> </a>

<a name="3pxx323-obtaining-processing-targets"> </a>

#### 3:PXX.3.2.2 Input and Result Delivery

The job request identifies the proposed processing targets. The task request identifies the data assigned to the De-Identifier. The De-Identifier returns task results in ITI-x3 or ITI-x7. The Manager returns job results in ITI-x1 or ITI-x4. Result resources retain the declared input release.

<a name="3pxx33-fhir-payload-delivery"> </a>

<a name="3pxx324-fhir-payload-delivery-summary"> </a>

##### 3:PXX.3.2.2.1 Payload Set Delivery

[Volume 2](volume-2.html#grouped-payload-parameters) defines the transaction parameters. Table 3:PXX.3.2.2-1 summarizes the delivery forms for a FHIR payload set.

<p id="fhir-input-result-delivery-table" class="tableTitle"><strong>Table 3:PXX.3.2.2-1: FHIR Input and Result Delivery</strong></p>

| Exchange | Delivery attachment |
|---|---|
| Input | `payload.manifest` |
| Result | `payloadResult.resultPackage` |
{: .grid}

For both exchanges, use `dis-resource-list` for bundled or hosted FHIR resources, or `fhir-bulk-data` for bulk files. A single inline R4 input uses an R4 manifest package containing the List and that resource. Its result uses a DIS Result Package. The Manager MAY repackage inline or hosted inputs at dispatch while preserving the authorized content and set identity.

<a name="resource-manifest"> </a>

<a name="resource-manifest-resolution"> </a>

<a name="fhir-resource-manifest-resolution"> </a>

##### 3:PXX.3.2.2.2 FHIR Resource Manifest and Wrapper Resolution

A [DIS Resource Manifest](StructureDefinition-DIS-ResourceManifest.html) is a profiled FHIR R4 [List](https://hl7.org/fhir/R4/list.html). A standalone List uses absolute HTTPS FHIR REST references. Within a package the List may also use bundle-local references under the [manifest package rules](#manifest-package). The manifest belongs to one payload set. The selected binding and version determine whether an entry identifies a payload resource, an R4 payload wrapper, or an R4 index.

The Manager SHALL establish the manifest's entry set before dispatch and verify that authorization covers every entry and the corresponding native content. It SHALL ensure the job and its retries resolve to the same target set. The Manager can use version-specific references or a protected snapshot of the manifest and any index resources used to resolve the targets. The Manager SHALL give the De-Identifier access only to the manifest, indexes, and payloads authorized for its task. The Integrated De-ID Manager/De-Identifier applies the same rules when processing directly.

Table 3:PXX.3.2.2-2 shows how a List entry identifies the payload.

<p id="tPXX.3.2.2-2" class="tableTitle"><strong>Table 3:PXX.3.2.2-2: FHIR Resource Manifest Resolution</strong></p>

| Binding and version | Resource selected by a List entry | Payload selected |
|---------------------|------------------------------------|------------------|
| DIS-FHIR-Payload R4 | An R4 resource, or an R4 [DIS Payload Wrapper](StructureDefinition-DIS-PayloadWrapper.html) | The resource itself or, for a wrapper, the R4 content carried or located by its attachment |
| DIS-FHIR-Payload R5 or R6 | R4 DIS Payload Wrapper | The serialized R5 or R6 resource carried or located by the wrapper's attachment |
{: .grid}

**Payload wrapper.** The wrapper is a profiled R4 DocumentReference with one attachment. Its `data` carries the payload bytes inline, or its `url` locates the payload at an authorized HTTPS endpoint. Exactly one SHALL be present. A FHIR wrapper SHALL use `application/fhir+json` or `application/fhir+xml`. The receiving actor SHALL retrieve or decode the payload and validate it against the containing set's binding and version. If the FHIR media-type release parameter is present, it SHALL agree with `payloadVersion`. Any HTTP negotiation for R5 or R6 occurs on retrieval of the attachment content. The manifest, package, and wrapper exchanges use R4.

The receiving actor SHALL follow the attachment only when the DocumentReference declares and conforms to the DIS Payload Wrapper profile. A DocumentReference claiming that profile but failing validation SHALL cause a set failure. To deliver a resource that itself declares the wrapper profile as a FHIR payload, serialize it inside a separate wrapper. An inline R5 DocumentReference is therefore carried as R5 bytes in the R4 wrapper, just like any other R5 resource.

**Results.** A result manifest SHALL reference only result resources or result indexes whose native targets resolve to the authorized de-identified output. The producing actor SHALL verify retrieval and identity of the referenced results before returning the manifest. Recipient-facing manifests, result indexes, and their referenced metadata SHALL exclude source identifiers and protected transformation material. Associated evidence follows the rules below.

<a name="result-evidence-placement"> </a>

**Result package and evidence placement.** Each successful job or task result SHALL carry one [DIS Result Package](StructureDefinition-DIS-ResultPackage.html) in `payloadResult.resultPackage`. This FHIR R4 collection Bundle SHALL contain the manifest and at least one DIS Evidence Provenance entry. The attachment's `data` contains the serialized Bundle, or its HTTPS `url` identifies that Bundle at an authorized endpoint. Use `application/fhir+json` or `application/fhir+xml`. The same packaging applies when the result is returned immediately or by polling. Each distributed job result set that uses multiple stages also carries [staged release evidence](#staged-release-evidence). The receiver SHALL identify the manifest and evidence by profile and validate their references.

| `manifestFormat` | Required package contents in addition to Provenance |
|---|---|
| `dis-resource-list` | Exactly one DIS Resource Manifest List. Its selected entries may be bundled resources or authorized HTTPS references. Apply the payload binding's wrapper or index rules. |
| `fhir-bulk-data` | Exactly one [DIS Bulk Result Manifest](StructureDefinition-DIS-BulkResultManifest.html) DocumentReference and one [DIS Bulk Result File](StructureDefinition-DIS-BulkResultFile.html) DocumentReference per listed file. The manifest carrier holds or links to the JSON file listing. File descriptors link to the listed NDJSON files. |

The List or bulk JSON manifest determines the selected output. Provenance and manifest carriers SHALL NOT be selected as clinical payload. The receiver SHALL verify that the package contents agree with the enclosing `manifestFormat`, binding and payload version, and validate evidence coverage before accepting or releasing the set. If the Manager changes how results are made available, it SHALL preserve the selected output and update the manifest and evidence targets to describe the same released set.

<a name="3pxx112-version-safe-packaging"> </a>

<a name="3pxx3212-version-safe-packaging"> </a>

##### 3:PXX.3.2.2.3 Version-Safe Packaging of Inline and Hosted Resources

The DIS transaction envelope and manifest package use HL7 FHIR R4. For R5 and provisional R6, carry the serialized resource in the attachment of a DIS Payload Wrapper selected by the manifest. For an inline R5 example, see [the manifest package below](#inline-r5-manifest-package).

<a name="protocol-resources-remain-hl7-fhir-r4"> </a>

**Protocol Resources Remain HL7 FHIR R4**

Table 3:PXX.3.2.2-3 lists the resources that are part of the HL7 FHIR R4 protocol layer and remain HL7 FHIR R4 regardless of the payload version.

<a name="tPXX.3.2.1-2"> </a>

<p id="tPXX.3.2.2-3" class="tableTitle"><strong>Table 3:PXX.3.2.2-3: HL7 FHIR R4 Protocol Resources</strong></p>

| HL7 FHIR R4 Protocol Resource | Role |
|-------------------------------|------|
| `Parameters` | ITI-x1 and ITI-x3 requests and success responses, and ITI-x4 and ITI-x7 success responses |
| `Provenance` | De-identification evidence |
| `OperationOutcome` | Error and validation reporting |
| `Bundle` | Workflow packaging (message, result collection) |
| `Library` | Policy artifact ([§3:PXX.1.1](#3pxx11-policy-library-resource-structure)) and execution plan carrier ([§3:PXX.2.1](#3pxx21-execution-plan-format)) |
| `CapabilityStatement` | Actor capability declaration |
{: .grid}

<a name="3pxx163-bulk-file-manifests"> </a>

<a name="3pxx3233-bulk-file-manifests"> </a>

##### 3:PXX.3.2.2.4 Bulk File Manifests and Authorized Retrieval

For an asynchronous cohort job, the Requester supplies an HTTPS URI identifying a JSON manifest that lists prepared input files. Each line of a listed NDJSON file contains one complete resource in the declared payload release. [Volume 1](volume-1.html) defines the Phase 1 boundary for bulk data input and output.

DIS uses the file listing conventions of the [HL7 Bulk Data Access IG STU 3](https://hl7.org/fhir/uv/bulkdata/STU3/en/export.html#response---output-manifest). For a manifest prepared for DIS, the required fields are `requiresAccessToken` (boolean) and `output` (array of file entries). Each entry SHALL identify the resource type in `type` and the file location in `url` as an absolute HTTPS URL. The manifest SHALL enumerate the complete dataset in one file listing. It may omit export-specific metadata such as `request` and `transactionTime`. The job's `payloadVersion` applies to all listed input files. A manifest with continuation links or reported export errors SHALL be rejected for processing under this binding.

For asynchronous cohort jobs, the Manager returns a bulk file manifest for the de-identified NDJSON files and supplies the associated evidence with the job result. The result package carries the manifest DocumentReference and file descriptors. The manifest carrier attachment SHALL use `application/json` and exactly one of inline `data` or an authorized HTTPS `url`. Each file descriptor attachment SHALL use `application/fhir+ndjson` and the exact HTTPS URL listed for that file in the manifest. The receiver SHALL match descriptors one to one with the manifest file URLs and reject missing, duplicate or unlisted descriptors. Extract the JSON manifest for ordinary Bulk Data file retrieval. The Manager SHALL ensure that manifest and file access expires within the authorized release window. Recipient-facing manifests and files SHALL NOT contain confidential salts or other protected transformation material. A failed job SHALL NOT release a partial dataset. The Manager SHALL report the failure through job status for an accepted asynchronous job.

<a name="bulk-result-content-identity"> </a>

**Bulk result content identity.** The producing actor is the De-Identifier for a task result and the De-ID Manager or Integrated De-ID Manager/De-Identifier for a job result. Before making a bulk result available to its receiver, the producing actor SHALL establish the exact output manifest and file versions covered by validation and evidence for that set. The manifest URL SHALL continue to resolve to that manifest version, and each file locator SHALL continue to resolve to its validated file version, for every successful retrieval of the released set. Content identity is based on the JSON and NDJSON bytes after HTTP decompression, when compression is used. A locator for a released result SHALL NOT serve substitute content, even when the replacement lists the same file URLs or contains the same FHIR resource type.

The producing actor SHALL withhold the result if it cannot establish or preserve the validated versions before release. If it detects after release that a manifest or file no longer resolves to the validated version, it SHALL prevent further access to the affected result set. It SHALL NOT renew access to a substitute version. A failed retrieval alone does not indicate that an accepted job or task has failed.

When a deployment supports renewal, the actor controlling access SHALL verify that the receiver is still authorized and that renewal is within the authorized release window. It MAY issue a new temporary download URL or credentials for the same version. The locators in the released manifest and the bytes of the manifest and files SHALL remain unchanged. The profile does not define a renewal transaction or prescribe how the deployment maintains object versions.

<a name="referenced-input-authorization"> </a>

<a name="3pxx164-authorization-for-referenced-inputs"> </a>

<a name="3pxx3234-authorization-for-referenced-inputs"> </a>

**Authorization for referenced inputs.**

The Manager SHALL verify that the approved data request covers the processing target set, including every resource identified by a resource manifest and the dataset described by a bulk file manifest. It SHALL dispatch only references within the authorized scope. Retrieval of a resource or manifest SHALL NOT expand that scope. The data request authorization governs the full target set.

The actor making the retrieval request SHALL use HTTPS and obtain credentials valid for the specific resource or file service. For automated FHIR REST reads, the retrieving actor SHOULD use [SMART Backend Services](https://hl7.org/fhir/smart-app-launch/STU2.2/backend-services.html) with its registered client identity to obtain an access token. The source service enforces the applicable resource access restrictions. The data request authorization in ITI-x1 is evidence of approval for the job. The retrieving actor obtains credentials through the source service's access mechanism.

Authorization SHALL cover retrieval of each manifest and each resource or file listed in it. If `requiresAccessToken` is true, the retrieving actor SHALL present an access token valid at the file endpoint. Use `requiresAccessToken = false` for files accessed with signed URLs. When the file endpoint uses a signed URL as the access credential, the retrieving actor SHALL use the URL without forwarding a bearer token. The signed URL SHALL be limited to the specific file and have a bounded lifetime. A signed URL SHALL be handled as a credential. The retrieving actor SHALL send credentials only to the service for which they are valid.

The Manager SHALL reject the job if it cannot establish that the identified dataset is authorized. If a required input is missing, inaccessible, invalid or outside the authorized scope, the Manager SHALL reject the job before acceptance or fail the accepted job and withhold all job output. A De-Identifier that detects such a failure SHALL report it to the Manager using the applicable task transaction.

<a name="inline-r5-manifest-package"></a>

<a name="3pxx34-inline-r5-manifest-package-example"> </a>

<a name="3pxx325-inline-r5-manifest-package-example"> </a>

##### 3:PXX.3.2.2.5 Inline R5 Manifest Package Example

For inline submission, carry the following R4 collection as the serialized `payload.manifest.valueAttachment.data` with `contentType` of `application/fhir+json`. The set declares `DIS-FHIR-Payload`, `R5`, and manifest format `dis-resource-list`. The inner attachment decodes to `{"resourceType":"Patient","id":"example"}` and is interpreted as R5.

```json
{
  "resourceType": "Bundle",
  "meta": {
    "profile": [
      "https://profiles.ihe.net/ITI/DIS/StructureDefinition/DIS-ManifestPackage"
    ]
  },
  "type": "collection",
  "entry": [
    {
      "fullUrl": "urn:uuid:64385609-ea68-4315-b178-b70ee276061c",
      "resource": {
        "resourceType": "List",
        "meta": {
          "profile": [
            "https://profiles.ihe.net/ITI/DIS/StructureDefinition/DIS-ResourceManifest"
          ]
        },
        "status": "current",
        "mode": "snapshot",
        "entry": [
          {
            "item": {
              "reference": "urn:uuid:5adb0ea3-d321-496b-8685-63529cbe90e1"
            }
          }
        ]
      }
    },
    {
      "fullUrl": "urn:uuid:5adb0ea3-d321-496b-8685-63529cbe90e1",
      "resource": {
        "resourceType": "DocumentReference",
        "meta": {
          "profile": [
            "https://profiles.ihe.net/ITI/DIS/StructureDefinition/DIS-PayloadWrapper"
          ]
        },
        "status": "current",
        "content": [
          {
            "attachment": {
              "contentType": "application/fhir+json; fhirVersion=5.0",
              "data": "eyJyZXNvdXJjZVR5cGUiOiJQYXRpZW50IiwiaWQiOiJleGFtcGxlIn0="
            }
          }
        ]
      }
    }
  ]
}
```

### 3:PXX.3.3 Proposed DICOM and CDA Bindings (Informative)

The [draft DICOM and CDA bindings](draft-native-payload-bindings.html) describe proposed mappings to the FHIR R4 envelope. Phase 1 conformance uses DIS-FHIR-Payload.

<a name="mixed-payload-walkthrough"> </a>

See the [informative mixed R5 and DICOM job walkthrough](examples-mixed-r5-dicom.html) for an example of the proposed DICOM binding.

<a name="evidence-baseline"> </a>

<a name="3pxx15-evidence-baseline"> </a>

## 3:PXX.4 De-Identification Evidence

This section defines the minimum evidence elements that every completed de-identification task SHALL produce and specifies how they map to HL7 FHIR R4 Provenance resources.

<a name="3pxx151-minimum-evidence-elements"> </a>

### 3:PXX.4.1 Minimum Evidence Elements

Every completed de-identification task produces an HL7 FHIR R4 Provenance resource containing at minimum the nine evidence elements listed in Table 3:PXX.4-1.

<p id="tPXX.4-1" class="tableTitle"><strong>Table 3:PXX.4-1: DIS Evidence Baseline Elements</strong></p>

| # | Evidence Element | HL7 FHIR R4 Provenance Mapping | Description |
|---|------------------|-------------------------------|-------------|
| 1 | Evidence identifier | `Provenance.id` | Unique identifier for this evidence record |
| 2 | Outcome status | `Provenance.extension[dis-outcome-status]` | Overall task outcome: `complete` or `error` |
| 3 | Workflow reference | `Provenance.activity` | DIS activity coding; use the audit correlation identifier to associate the specific job or task |
| 4 | Target identifier | `Provenance.target` | Reference(s) to the de-identified output resource(s) |
| 5 | Policy-decision reference | `Provenance.policy` | URI identifying the exact validated policy version governing this task. For ITI-x3 tasks, copy the [source policy evidence URI](#execution-plan-source-policy) from the execution plan Library. |
| 6 | RuleSet identifier | `Provenance.extension[dis-ruleset]` | Identifier of the ruleSet that produced this evidence |
| 7 | Reversibility state | `Provenance.extension[dis-reversibility]` | `irreversible` or `reversible` |
| 8 | Validation status | `Provenance.extension[dis-validation-status]` | Output validation result: `valid` or `invalid` |
| 9 | Audit correlation identifier | `Provenance.extension[dis-audit-correlation]` | Identifier linking this evidence to the ATNA audit trail |
{: .grid}

Elements 2, 6, 7, 8, and 9 use DIS-defined extensions on the HL7 FHIR R4 Provenance resource. The extension URLs follow the pattern `https://profiles.ihe.net/ITI/DIS/StructureDefinition/<extension-name>`.

<a name="3pxx152-provenance-resource-structure"> </a>

<a name="3pxx42-provenance-resource-structure"> </a>

### 3:PXX.4.2 R4 Provenance Resource Structure

In addition to the nine baseline elements, the Provenance resource SHALL include the following standard HL7 FHIR R4 Provenance elements.

Table 3:PXX.4-2 lists the required Provenance elements beyond the baseline.

<p id="tPXX.4-2" class="tableTitle"><strong>Table 3:PXX.4-2: Required Provenance Elements</strong></p>

| Element | Cardinality | Description |
|---------|-------------|-------------|
| `Provenance.recorded` | 1..1 | Timestamp when the de-identification task completed |
| `Provenance.agent` (performer) | 1..1 | The De-Identifier that executed the task, identified by reference or identifier |
| `Provenance.agent` (policy authority) | 0..1 | The authority whose policy governed the task, when identifiable |
| `Provenance.reason` | 0..* | Coded reason for the de-identification (e.g., research, clinical pseudonymization) |
{: .grid}

The `Provenance.agent` entry for the De-Identifier SHALL use `Provenance.agent.type` with coding `http://terminology.hl7.org/CodeSystem/provenance-participant-type|performer`. The `Provenance.agent.who` SHALL reference or identify the De-Identifier.

<a name="3pxx114-evidence-representation-across-versions"> </a>

<a name="3pxx3214-evidence-representation-across-versions"> </a>

### 3:PXX.4.3 Identifying Results Across FHIR Releases

De-identification evidence is represented as HL7 FHIR R4 `Provenance` resources, which are part of the protocol layer. Evidence does not depend on the payload's HL7 FHIR version because:

- `Provenance.target` identifies a native R4 result or, for R5 and R6, the R4 wrapper carrying or locating the result.
- For a resource list, each `Provenance.target.reference` SHALL match a selected List item. For a bundled output, the reference SHALL resolve to exactly one entry by `Bundle.entry.fullUrl` in the same result package. For a hosted output, use the HTTPS reference selected by the List.
- For bulk, each `Provenance.target.reference` SHALL identify a selected DIS Bulk Result File descriptor by its Bundle entry `fullUrl`. The evidence targets the R4 descriptor rather than the NDJSON URL directly.
- Each selected output entry or file SHALL be covered by at least one evidence target. The receiver SHALL reject missing, unresolved, ambiguous, or unselected targets before accepting or releasing the result.
- Transformation summary entries use version-neutral FHIRPath target paths (e.g., `Patient.name`, `Patient.birthDate`). These paths describe what was transformed, not the version of the resource that was transformed.
- Policy references, ruleSet identifiers, reversibility state, validation status, and audit correlation identifiers are version-independent metadata.

The `Provenance` resource MAY include the payload HL7 FHIR version in an extension when consumers need to distinguish output versions. This is informational; it does not change the evidence structure.

<a name="3pxx153-transformation-summary"> </a>

<a name="3pxx43-transformation-summary"> </a>

### 3:PXX.4.4 Transformation Summary

Each Provenance resource SHOULD include a transformation summary recording the actions applied to individual elements. The transformation summary is carried as a DIS-defined extension `dis-transformation-summary` containing an array of entries.

Table 3:PXX.4-3 lists the elements of each transformation summary entry.

<p id="tPXX.4-3" class="tableTitle"><strong>Table 3:PXX.4-3: Transformation Summary Entry Elements</strong></p>

| Element | Cardinality | Type | Description |
|---------|-------------|------|-------------|
| `targetPath` | 1..1 | string | FHIRPath expression identifying the transformed element |
| `action` | 1..1 | code | Action code applied (from the core action family) |
| `outcome` | 1..1 | code | `applied`, `skipped` (element not present), or `error` |
| `ruleId` | 0..1 | string | Identifier of the execution plan rule that triggered this action |
{: .grid}

The transformation summary enables audit and review of the specific actions applied to each element. It does not contain the original or transformed values. Original values SHALL NOT appear in evidence, including in selector literals. If the producer cannot express a summary entry without exposing source values or protected material, it SHALL omit that entry from recipient-facing evidence.

<a name="3pxx154-evidence-example"> </a>

<a name="3pxx44-evidence-example"> </a>

### 3:PXX.4.5 Evidence Example

The [evidence example](Provenance-dis-evidence-uc3-001.html) illustrates the Provenance produced when a pseudonymization task completes in Use Case 3 (Clinical Pathology Order). It conforms to the [DIS Evidence profile](StructureDefinition-DIS-Evidence.html) and references a synthetic [pseudonymized Patient](Patient-pseudonym-abc123.html).

<a name="staged-release-evidence"> </a>

### 3:PXX.4.6 Staged Release Evidence

For each payload set processed in two or more stages in a distributed job, the De-ID Manager SHALL include exactly one [DIS Staged Release Evidence](StructureDefinition-DIS-StagedReleaseEvidence.html) Provenance in that set's job result package. This record is the Manager's assertion that it validated the assigned stage results and authorized release. The Manager SHALL include it only after validating all assigned results and rechecking release authorization. It applies to completed ITI-x1 and ITI-x4 job results.

| Provenance element | Staged release requirement |
|---|---|
| `agent.who` | Identify the De-ID Manager as the record's author. |
| `recorded` | Time the Manager recorded the release decision. |
| `policy` | The version-specific evidence URI for the exact approved policy for the set. Use the same URI as the dispatched execution plans. |
| `target` | Reference every final output entry selected by the manifest, exactly once, using the rules in [§3:PXX.4.3](#3pxx3214-evidence-representation-across-versions). |
| `extension[dis-validated-stage]` | One entry for every assigned ruleSet whose result the Manager validated. Each entry contains `stageId`, `ruleSetId` and a positive integer `sequence`. Number entries consecutively from 1 in policy stage order and ruleSet order within each stage. The sequence represents policy order, including where independent tasks run concurrently. |

The Manager SHALL preserve DIS Evidence from the tasks that produced the selected final output. If it changes result delivery, apply the [result packaging rules](#result-evidence-placement) while preserving task attribution. Earlier task Provenance remains associated with its own task output. The Manager SHALL exclude from the job result any superseded intermediate output and its evidence, along with source identifiers, protected mappings, confidential salts and protected transformation parameters. The staged release record SHALL appear only in the job result package for the qualifying set.

The Manager SHALL ensure the Requester can determine the expected stage and ruleSet sequence and exact policy identity for a staged set independently of the result package. The approved policy may provide this information. If the Requester cannot determine it from the policy, the Manager SHALL make the authorized metadata available by an implementation-defined mechanism. This mechanism may provide the stage and ruleSet IDs and policy identity without disclosing the policy contents.

For each set expected to use multiple stages, the Requester SHALL verify that the package contains one staged release record authored by the responding Manager, that its policy identifies the approved version, and that its sequence matches the expected stage and ruleSet IDs in policy order. It SHALL verify that the staged release record covers all and only the selected final outputs. It SHALL also validate the accompanying DIS Evidence and its coverage. The Requester SHALL reject the job result if any required check fails. The evidence checks apply independently of the number of Bundle entries.

The [staged R4 Patient example](Bundle-staged-r4-patient-result.html) shows the final worker's DIS Evidence alongside the Manager's release record.

<a name="3pxx17-reversible-lookup-table"> </a>

## 3:PXX.5 Reversible Lookup Table

This section defines the protected lookup table used to supply or retain patient identifier mappings. See [Patient Identifier Pseudonymization](#3pxx123-patient-identifier-pseudonymization) for the rules that assign pseudonyms.

### 3:PXX.5.1 Lookup Table Structure and Handling

[DIS-LookupTable](StructureDefinition-DIS-LookupTable.html) is a protected, identified R4 DocumentReference. The `lookupTable` input to ITI-x1 or ITI-x3 is a reference to a supplied table. The `generatedLookupTable` output in ITI-x3 or ITI-x7 is a task-generated instance carried inline as a resource in `Parameters`. Both use the [DIS patient lookup table JSON Schema](schemas/dis-lookup-table.schema.json) for patient identifier mappings. The generated table carries its JSON inline. A supplied table may carry JSON inline or reference a protected [DIS-LookupTableContent](StructureDefinition-DIS-LookupTableContent.html) Binary.

| DocumentReference element | DIS requirement |
|---|---|
| `identifier` | Stable business identifiers. At least one value SHALL equal the decoded JSON `tableId`. |
| `masterIdentifier` | A system and value identifying this immutable content version. A change to the JSON bytes requires a new `masterIdentifier`. |
| `status` | `current` when used for a new job or returned as generated output. |
| `type` | DIS document-type code `lookup-table`. |
| `extension[dis-identity-linkage-scope]` | Resolved scope type and identifier. Both SHALL match the authorized job scope and decoded JSON. |
| `content` | Exactly one `application/json` attachment. It carries either inline Base64 data or a protected Binary URL. |

The decoded JSON contains `tableId`, format `version` of `1`, a resolved `identity-linkage-scope`, and a nonempty `entries` array. A patient mapping has exactly four fields. `sourceSystem` and `sourceValue` are the original `Identifier.system` and `Identifier.value`. `targetSystem` and `targetValue` are the pseudonym identifier pair. See [lookup-backed assignment](#lookup-backed-assignment) for how the De-Identifier applies supplied mappings.

Source identifier pairs SHALL be unique within a table.

**Supplied tables.** A task-scoped subset has its own business identifier and `masterIdentifier`, retains the authorized scope, and links to the pinned source with `relatesTo` code `transforms`. A reference may use a literal, version-specific history URL or an identifier that resolves unambiguously to an exact version. Repository provisioning and table lifecycle remain deployment concerns. ITI-x1 defines admission and pinning, and ITI-x3 defines restricted dispatch and cleanup.

**Generated tables.** When a reversible Manager-managed task generates patient identifier pseudonyms, the De-Identifier SHALL return one `generatedLookupTable` containing the resulting patient mappings and the resolved scope. The Manager SHALL validate the table against the task and retain the mappings before job release. Repeated identical pairs across tasks or retries are idempotent. If a source pair maps to conflicting targets in the same job or a target is assigned to distinct patients, the Manager SHALL fail the job without partial release. A task applying supplied patient mappings or executing an irreversible policy SHALL NOT return a generated patient lookup table.

Generated and supplied tables are protected operational material and SHALL be excluded from recipient-facing output, evidence, logs and errors.

<a name="3pxx18-worked-mapping-examples"> </a>

<a name="3pxx51-worked-mapping-examples"> </a>

### 3:PXX.5.2 Worked Mapping Examples

These synthetic, informative FHIR R4 examples accompany the [lookup table binding](#3pxx5-reversible-lookup-table). They also appear in the [artifact index](artifacts.html) and the [FHIR example downloads](download.html).

| Published example | What it shows |
|---|---|
| [Lookup table with Binary content](DocumentReference-lookup-document-example.html) | A persistent DocumentReference with a business identifier, a content version identifier, and a reference to the JSON attachment. |
| [Lookup table JSON content](Binary-lookup-content-example.html) | The Binary carrying the lookup table JSON for the DocumentReference above. |
| [Lookup table with inline content](DocumentReference-lookup-inline-example.html) | The same lookup table content carried directly in a DocumentReference attachment. |
| [Task-scoped lookup table](DocumentReference-lookup-task-s1.html) | A supplied table subset with its own identifiers and a `transforms` relationship to the version of the source DocumentReference. |
| [Generated lookup table](DocumentReference-generated-lookup-uc3.html) | The patient identifier mapping generated by the clinical pathology salted hash example and returned to the Manager. |
{: .grid}
