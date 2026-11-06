
This section defines the DIS-FHIR-Payload content module.

<a name="fhir-payload-content-module"> </a>

## 3:PXX.1 DIS-FHIR-Payload Content Module

The DIS-FHIR-Payload content module defines format-specific rules for de-identification of HL7 FHIR processing payloads within the DIS workflow. It specifies how HL7 FHIR data elements are identified and addressed, how DIS transformation actions are realized for HL7 FHIR datatypes, how payloads are carried within and retrieved from the HL7 FHIR R4 protocol envelope, and how de-identification evidence is represented using HL7 FHIR Provenance.

DIS-FHIR-Payload is independent of the DIS HL7 FHIR R4 protocol binding version. It supports processing payloads in HL7 FHIR R4, R5, and R6 without requiring a corresponding version of the protocol binding. This independence is achieved through version identification, version-safe packaging, and version-neutral element addressing. As specified in Volume 1, R6 support is based on the ballot draft and will be confirmed upon final publication.

<a name="cross-version-payload"> </a>

**Scope.** This module defines the payload formats, version rules, processing content and output evidence exchanged through the DIS workflow. Volume 1 defines actor and option obligations. Volume 2 defines how transactions carry and process this content.

**Referenced standards.** The protocol artifacts use [HL7 FHIR R4]({{site.data.fhir.path}}). The payload version rules below describe the independently versioned FHIR resources. [FHIRPath](https://hl7.org/fhirpath/) provides the element addressing language.

**FHIR artifacts.** The draft content profiles cover [execution plans](StructureDefinition-DIS-ExecutionPlan.html), [evidence](StructureDefinition-DIS-Evidence.html), [lookup table metadata](StructureDefinition-DIS-LookupTable.html) and [lookup table content](StructureDefinition-DIS-LookupTableContent.html). The [worked mapping examples](#3pxx18-worked-mapping-examples) illustrate the lookup table profiles.

### 3:PXX.1.1 Cross-Version Payload Support

This section specifies how DIS-FHIR-Payload enables de-identification of HL7 FHIR payloads whose version differs from the HL7 FHIR R4 protocol binding.

#### 3:PXX.1.1.1 Version Identification

For a FHIR set, the `payloadVersion` field declares the FHIR release of the processing payload. The De-ID Manager SHALL reject a request that omits it and SHALL use the same declaration in ITI-x3. A De-Identifier declaring DIS-FHIR-Payload SHALL advertise the payload releases it supports. The Manager SHALL verify that the assigned De-Identifier supports the declared release before dispatch and SHALL reject the job when no available De-Identifier supports that release. Source server capabilities and attachment metadata are used to check the declaration. The retrieving actor SHALL fail processing when the retrieved content or its version metadata conflicts with the declaration.

#### 3:PXX.1.1.2 Version-Safe Packaging

The DIS transaction envelope uses HL7 FHIR R4. A payload in the same release may be carried as a native resource where the transaction permits it. For ungrouped ITI-x1 submissions, inline R5 and R6 payloads SHALL be serialized as FHIR JSON or XML and carried in `Parameters.parameter.valueAttachment`. Grouped submissions and results use the [manifest packaging rules](#resource-manifest-resolution). The attachment SHALL contain the serialized bytes in `data` and declare the corresponding FHIR media type in `contentType`. If the standard [FHIR media-type version parameter](https://hl7.org/fhir/R4/http.html#version-parameter) is present, it SHALL agree with `payloadVersion`. For example, an R5 JSON attachment uses `application/fhir+json; fhirVersion=5.0` when the parameter is included.

For an inline R5 input in ITI-x1, the R4 `Parameters` resource contains entries of this form. The attachment data shown is a placeholder for the base64-encoded R5 resource.

```json
[
  {
    "name": "payloadVersion",
    "valueCode": "R5"
  },
  {
    "name": "processingTarget",
    "valueAttachment": {
      "contentType": "application/fhir+json; fhirVersion=5.0",
      "data": "<base64-encoded FHIR R5 resource>"
    }
  }
]
```

For references and bulk file manifests, the R4 envelope carries the resource reference or manifest URI. The referenced content uses the release declared in `payloadVersion`. See [Obtaining Processing Targets](#obtaining-processing-targets) for retrieval and authorization requirements.

##### Protocol Resources Remain HL7 FHIR R4

Table 3:PXX.1.1-2 lists the resources that are part of the HL7 FHIR R4 protocol layer and remain HL7 FHIR R4 regardless of the payload version.

<p id="tPXX.1.1-2" class="tableTitle"><strong>Table 3:PXX.1.1-2: HL7 FHIR R4 Protocol Resources</strong></p>

| HL7 FHIR R4 Protocol Resource | Role |
|-------------------------------|------|
| `Parameters` | ITI-x1 job request and response envelope |
| `Task` | ITI-x3 task dispatch and status |
| `Provenance` | De-identification evidence |
| `OperationOutcome` | Error and validation reporting |
| `Bundle` | Workflow packaging (message, result collection) |
| `Library` | Policy artifact ([§3:PXX.2.1](#3pxx21-policy-library-resource-structure)) and execution plan carrier ([§3:PXX.1.4](#3pxx14-execution-plan-format)) |
| `CapabilityStatement` | Actor capability declaration |
{: .grid}

#### 3:PXX.1.1.3 Version-Neutral Element Addressing

DIS-FHIR-Payload uses FHIRPath selectors to address elements within the declared processing payload release. Semantic-Level policies use the same group codes across releases. The [Semantic Group Binding](#3pxx122-semantic-groups) supplies release-specific selectors during compilation. For example, `@dates` selects the encounter period through `Encounter.period` in R4 and `Encounter.actualPeriod` in R5.

#### 3:PXX.1.1.4 Evidence Representation Across Versions

De-identification evidence is represented as HL7 FHIR R4 `Provenance` resources, which are part of the protocol layer. Evidence does not depend on the payload's HL7 FHIR version because:

- `Provenance.target` identifies the de-identified result. For grouped FHIR R5 and R6 results, it identifies the R4 wrapper carrying or locating that result. Use a literal R4 reference for a hosted wrapper. For a bundled wrapper, use a logical reference whose identifier matches a unique `DocumentReference.identifier` in the result package. Ungrouped FHIR exchanges use the declared payload release to interpret any direct cross-release target URI under the DIS binding.
- Transformation summary entries use version-neutral FHIRPath target paths (e.g., `Patient.name`, `Patient.birthDate`). These paths describe what was transformed, not the version of the resource that was transformed.
- Policy references, ruleSet identifiers, reversibility state, validation status, and audit correlation identifiers are version-independent metadata.

The `Provenance` resource MAY include the payload HL7 FHIR version in an extension when consumers need to distinguish output versions. This is informational; it does not change the evidence structure.

#### 3:PXX.1.1.5 Validation Across Versions

De-identified output SHALL be validated against the processing payload's declared HL7 FHIR version, not against the HL7 FHIR R4 protocol binding version.

The following minimum validation checks apply to all payload versions:

1. Well-formed HL7 FHIR JSON or XML conforming to the declared version.
2. Valid against the base resource definition for the declared version.
3. Valid against declared output StructureDefinition profiles when supplied. Output profiles SHALL be compatible with the payload version.
4. No direct identifiers remain in elements governed by the execution plan.
5. Internal references remain resolvable within the output graph or Bundle.
6. Remapped identifiers and references are consistent within the declared scope.
7. Narrative XHTML remains valid and contains no detected PHI for governed narrative targets.
8. Provenance evidence maps all required DIS evidence baseline elements (see [§3:PXX.1.5](#3pxx15-evidence-baseline)).

A De-Identifier SHALL use an HL7 FHIR validation library or equivalent mechanism compatible with the declared payload version. Validation against the wrong HL7 FHIR version (e.g., validating HL7 FHIR R5 output against HL7 FHIR R4 definitions) is a conformance failure.

<a name="content-model"> </a>

### 3:PXX.1.2 Content Model

This section defines the content model for DIS-FHIR-Payload: how HL7 FHIR data elements are identified, addressed, and grouped for de-identification governance.

#### 3:PXX.1.2.1 Element Addressing

DIS-FHIR-Payload uses FHIRPath expressions as the element addressing language. Execution plan rules and semantic group definitions reference HL7 FHIR elements using FHIRPath-compatible path expressions rooted at the resource type.

An element path SHALL be one of the following forms:

- **Resource-rooted path** -- a FHIRPath expression starting with a resource type (e.g., `Patient.name`, `Observation.value`). The path identifies one or more elements within a single resource instance.
- **Semantic group reference** -- a reference to a named semantic group (e.g., `@subject-identifiers`). The `@` prefix distinguishes a semantic group reference from a FHIRPath expression. The group expands to its member paths at policy compilation time (see [§3:PXX.2.4](#3pxx24-policy-compilation)).

When a path targets an element with child elements (e.g., `Patient.name` which contains `HumanName.family`, `HumanName.given`, `HumanName.prefix`, `HumanName.suffix`, `HumanName.text`, `HumanName.period`), the action applies to the targeted element and all its children unless the execution plan specifies a more specific child path.

Choice-type elements use the `[x]` notation (e.g., `Observation.value`). The De-Identifier SHALL apply the rule to whichever concrete type is present in the resource instance.

#### 3:PXX.1.2.2 Semantic Groups

Semantic groups categorize HL7 FHIR elements by privacy sensitivity. Semantic-Level policies reference semantic groups instead of individual element paths. The De-ID Manager expands semantic group references to individual element paths during policy compilation (see [§3:PXX.2.4](#3pxx24-policy-compilation)).

The [DIS Semantic Group CodeSystem](CodeSystem-dis-semantic-group.html) defines the group codes and their meanings. Table 3:PXX.1.2-1 is the authoritative FHIR Semantic Group Binding for selector membership and order by payload release. The table defines binding version 0.2.0 independently of the FHIR payload version.

The [R4/R5 PII path catalog](bindings/dis-fhir-pii-path-catalog-0.2.0.csv) and [classification and semantic group guide](fhir-semantic-group-guide.html) are informative. They help policy authors identify candidate FHIRPath selectors for syntax-level policies. Catalog groups and paths do not extend the selector membership defined in the table.

Binding version 0.2.0 assigns `Patient.birthDate` to `birth-dates` in both R4 and R5. When migrating a policy from version 0.1.0, review rules targeting `@dates` or `@subject-demographics` and add an explicit `@birth-dates` rule if the policy still governs birth date. If both older groups targeted birth date, resolve the intended action during migration.

Policies may use the applicable date actions or remove the birth date. If the policy needs to preserve age relative to a shifted event, use the same date-shift scope for both. Deriving an age band is a separate transformation that requires a reference event or date, band boundaries, handling for partial birth dates, and an output destination. The Phase 1 core action family does not define age-band derivation.

<p id="tPXX.1.2-1" class="tableTitle"><strong>Table 3:PXX.1.2-1: DIS FHIR Semantic Group Binding</strong></p>

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

For the declared FHIR payload release, the Manager SHALL expand each semantic group using the selectors in the corresponding release column of Table 3:PXX.1.2-1. The Manager SHALL preserve the listed selector order and the order of source policy rules. A selector with a concrete resource root applies to resources of that type. `DomainResource.text` applies to the narrative element on each governed resource derived from `DomainResource`.

Group membership is defined by the content module. A policy selects groups and actions. It cannot change the group's selectors. The `subject-identifiers` group intentionally shares its two selectors with `subject-business-identifiers` and `subject-names`. Use the narrower groups when applying different actions to identifiers and names. A group containing a composite element selects the element as a whole. The separate action applicability rules still apply to every expanded target.

The `dates` group covers the listed structured temporal values. Its choice selectors constrain the selected FHIR types using `ofType()`. Free-text dates, ages, ranges, and schedules expressed as `Timing` are outside this binding. Other paths, including extensions and other references, require separate policy coverage as applicable. The binding does not establish that a policy covers all identifying content in a payload.

Implementations MAY define additional semantic groups beyond those listed in Table 3:PXX.1.2-1 for local governance requirements. Additional groups SHALL NOT conflict with the element assignments of the Phase 1 groups.

<div markdown="1" class="stu-note">
**Editorial Note:** This draft defines the proposed Phase 1 membership for R4 and R5. An R6 Semantic Group Binding remains pending.
</div>

#### 3:PXX.1.2.3 Resource Traversal

An execution plan applies to a set of processing target resources. The De-Identifier SHALL traverse the processing target according to the following rules.

**Bundle traversal.** When the processing target is a Bundle, the De-Identifier SHALL apply execution plan rules to each entry resource in the Bundle. Rules are matched by the entry resource's resource type. Bundle metadata elements (`Bundle.id`, `Bundle.identifier`, `Bundle.timestamp`, `Bundle.link`) are not governed by resource-type-rooted rules; separate rules targeting `Bundle.*` paths are required to govern them.

**Contained resources.** When a processing target resource contains other resources via `Resource.contained`, the De-Identifier SHALL apply execution plan rules to each contained resource according to its resource type. References from the containing resource to contained resources (e.g., `#contained-id`) SHALL be updated if the contained resource's identifier is transformed.

**Reference chains.** In by-reference delivery mode, the processing target MAY include references to resources not included in the processing target set. The De-Identifier SHALL NOT follow references outside the processing target set. Only resources explicitly included in the processing target (directly or as Bundle entries) are governed by the execution plan. Reference elements pointing to resources outside the processing target set are governed by rules targeting the `references` semantic group.

<a name="transformation-actions"> </a>

### 3:PXX.1.3 Transformation Actions

This section defines the Phase 1 core transformation action family (`core`) for DIS-FHIR-Payload. Every De-Identifier declaring DIS-FHIR-Payload SHALL support all actions in the `core` family.

#### 3:PXX.1.3.1 Action Catalog

Table 3:PXX.1.3-1 lists the Phase 1 core transformation actions.

<p id="tPXX.1.3-1" class="tableTitle"><strong>Table 3:PXX.1.3-1: Phase 1 Core Transformation Actions</strong></p>

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

#### 3:PXX.1.3.2 Action Definitions

##### remove

The `remove` action removes the targeted element and all its children from the resource. After removal, the element SHALL NOT be present in the de-identified output. If the targeted element is required by the HL7 FHIR base resource definition (cardinality 1..1 or 1..*), the De-Identifier SHALL reject the task with an OperationOutcome. Execution plans SHALL NOT target required elements with the `remove` action.

##### replace

With `parameters.source` set to `lookupTable`, `replace` replaces patient business identifiers in `Patient.identifier` using the job/task lookup table described in §3:PXX.1.7. This mode is mutually exclusive with a fixed `value`. It SHALL preserve identifier/reference consistency and SHALL NOT fall back to fixed replacement or hashing when an entry is absent. The following fixed-value behavior applies only when lookup mode is not selected.

The `replace` action replaces the targeted element's displayable content with the nonempty string specified by the `value` parameter.

For `HumanName`, each sub-element (`family`, `given`, `text`) is replaced with the specified value. For `Address`, each sub-element (`text`, `line`, `city`, `district`, `state`, `postalCode`) is replaced with the specified value; `Address.country` is preserved. For `ContactPoint`, `ContactPoint.value` is replaced with the specified value; `ContactPoint.system` and `ContactPoint.use` are preserved.

##### keep

The `keep` action preserves the targeted element unchanged in the de-identified output. In first-match-wins evaluation, `keep` enables execution plans to express exceptions before general rules — for example, preserving a specific identifier before removing all identifiers:

```
R01: target Patient.identifier[mrn]    action keep
R02: target Patient.identifier         action remove
```

##### hash

The `hash` action computes a SHA-256 digest. The `algorithm` parameter uses the `SHA-256` code from HL7's [IntegrityCheckAlgorithm CodeSystem](https://terminology.hl7.org/CodeSystem-v3-IntegrityCheckAlgorithm.html). The `mode` parameter selects `salted` or `unsalted`.

For patient business identifiers, the rule SHALL use `salted` and declare `pseudonymSystem`. Apply the patient identifier recipe in [§3:PXX.1.3.3](#3pxx133-baseline-patient-pseudonym-derivation). Generic value rules hash the exact original string, including a selected displayable string sub-element where applicable. The unsalted message is the UTF-8 serialization of `["DIS-value-digest-v1", value]`. The salted message is the UTF-8 serialization of `["DIS-value-digest-v1", scope.type, scope.identifier.system, scope.identifier.value, value]` followed by the raw scope salt. Both modes use the serialization and output rules in §3:PXX.1.3.3. An unsalted rule is unsuitable for patient business identifiers because an observer can test guesses against the digest.

For `HumanName`, hash `family`, `given`, `prefix`, `suffix` and `text` individually. Preserve `use` and remove `period`. For an `Identifier` governed by a generic hash rule, replace `value` with the digest and set `system` to the rule's required `pseudonymSystem`. Preserve `type`, `use` and `period`, and remove `assigner`.

Unsalted test vector. The exact UTF-8 message is `["DIS-value-digest-v1","example"]` and the digest is `7a5d5b43b1725c76debaedcb17ccfb99d6bd99299593c8b18eab0b4d0e4643b9`.

##### truncate-date

The `truncate-date` action reduces the precision of the targeted date value to the level specified by the `precision` parameter.

- `precision: year` — retain only the year (e.g., `1985-03-15` → `1985`)
- `precision: year-month` — retain year and month (e.g., `1985-03-15` → `1985-03`)

##### date-shift

Date shifting requires a separately declared, purpose-specific derivation capability. The De-Identifier SHALL use patient hashing salts only for the authorized hash rules. The `date-shift` action shifts the targeted date or time value by a per-patient offset. The offset is deterministically derived from the scope-derived seed material and the patient identifier, ensuring that all dates for the same patient within the same consistency scope are shifted by the same offset. The offset magnitude SHALL NOT exceed the `maxOffsetDays` parameter. The direction (forward or backward) is determined by the derivation.

Date shifting preserves temporal ordering and intervals between events for the same patient. The De-Identifier SHALL apply the same offset to all `date`, `dateTime`, `instant`, and `Period` elements for a given patient within a single task.

For `Period` elements, both `Period.start` and `Period.end` are shifted by the same offset.

##### round

The `round` action bins a numeric value to the nearest multiple of the `step` parameter. The rounding centers at zero.

- `round(57, step: 10)` → `60`
- `round(23, step: 5)` → `25`
- `round(82, step: 10)` → `80`

##### truncate

The `truncate` action retains only the first `length` characters of a string value, discarding the remainder.

- `truncate("02139", length: 3)` → `"021"`
- `truncate("SW1A 2AA", length: 4)` → `"SW1A"`

##### redact

The `redact` action removes the narrative content (`DomainResource.text`) from a resource. The De-Identifier SHALL set `Narrative.status` to `empty` and replace `Narrative.div` with an empty XHTML div element (`<div xmlns="http://www.w3.org/1999/xhtml"/>`) conforming to the HL7 FHIR Narrative datatype constraints.

#### 3:PXX.1.3.3 Baseline Patient Pseudonym Derivation

The Manager SHALL copy the resolved policy `identity-linkage-scope` into each compiled salted `hash` rule. The De-Identifier SHALL obtain the confidential salt for the resolved scope through its deployment. The deployment SHALL generate or derive a distinct effective salt of exactly **16 bytes** for each scope and salt version using cryptographically secure material. Authorized workers that need matching pseudonyms SHALL use the same effective salt and version. The deployment SHALL keep the selected version consistent across all tasks and retries of a job. For example, a deployment can coordinate rotation after the jobs using a version finish. Rotating the salt changes the pseudonym derivation context. The De-Identifier SHALL fail the task if it cannot obtain the applicable salt or if the decoded salt length differs from 16 bytes.

For each `Patient.identifier` targeted by the rule, require a nonempty source `system` and `value`. Construct this ordered array of strings using the exact scope and source identifier values:

```text
["DIS-patient-identifier-v1", scope.type, scope.identifier.system, scope.identifier.value, source.system, source.value]
```

Serialize the array without whitespace, escape quotation marks, backslashes and control characters as required by JSON, emit other Unicode characters directly, preserve forward slashes, use the short JSON escapes for backspace, tab, newline, form feed and carriage return, and use lowercase Unicode escapes for the remaining control characters U+0000–U+001F. Perform no Unicode normalization and reject unpaired surrogates. Encode the resulting text as UTF-8 without a byte-order mark. Append the 16 raw salt bytes to the UTF-8 bytes, then compute SHA-256 over the concatenation. Set `Identifier.system` to the rule's `pseudonymSystem` and `Identifier.value` to the complete 32-byte digest as 64 lowercase hexadecimal characters. Scope and identifier values use exact string matching. Cross-community identity resolution and salt coordination remain deployment prerequisites. On detecting a digest collision between distinct source identifier pairs within the job, fail the job without partial output.

Salted test vector. The exact UTF-8 message is `["DIS-patient-identifier-v1","source-institution","https://hospital.example.org/identifiers/linkage-scope","lab-project-2026","https://hospital.example.org/identifiers/mrn","A123"]`. Append the 16 public test bytes `000102030405060708090a0b0c0d0e0f` (hexadecimal). The expected digest is `8162610a149e7b6700513fa3f0ceff46328e2b584fd3d351e4d5c2775a42ff0c`. Deployments generate their own confidential salts.

#### 3:PXX.1.3.4 FHIR Reference Integrity

The De-Identifier SHALL ensure that references between retained resources resolve correctly in the de-identified output. In a Bundle, this includes keeping `Bundle.entry.fullUrl` values and internal references consistent with the resource identities in the output. Handle references to removed resources and external references according to the approved policy. The De-Identifier SHALL fail the task without partial output if it cannot produce a valid result under the declared FHIR version and policy.

Patient pseudonymization transforms the business identifier pair in `Patient.identifier`. The lookup-table and hash bindings define that transformation. The output packaging rules govern FHIR resource identities and references.

<a name="execution-plan-format"> </a>

### 3:PXX.1.4 Execution Plan Format

This section defines the structure of DIS-FHIR-Payload execution plans carried within HL7 FHIR R4 Library resources.

#### 3:PXX.1.4.1 Library Resource Structure

A DIS-FHIR-Payload execution plan is carried as a content attachment in an HL7 FHIR R4 `Library` resource. The Library resource provides metadata about the plan; the plan content is a DIS-specific JSON format.

Table 3:PXX.1.4-1 lists the required Library resource elements.

<p id="tPXX.1.4-1" class="tableTitle"><strong>Table 3:PXX.1.4-1: Execution Plan Library Resource Elements</strong></p>

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

#### 3:PXX.1.4.2 Execution Plan JSON Structure

The [DIS execution plan JSON Schema](schemas/dis-execution-plan.schema.json) defines the decoded attachment. It contains `planVersion`, `ruleSetId`, `payloadBinding`, `payloadVersion` and an ordered `rules` array. The `ruleSetId`, `payloadBinding` and `payloadVersion` SHALL match the ITI-x3 parameters. Each compiled rule identifies the source policy rule and specifies a target, an action, and action-specific parameters.

Table 3:PXX.1.4-2 lists the elements of each rule in the execution plan.

<p id="tPXX.1.4-2" class="tableTitle"><strong>Table 3:PXX.1.4-2: Execution Plan Rule Elements</strong></p>

| Element | Cardinality | Type | Description |
|---------|-------------|------|-------------|
| `ruleId` | 1..1 | string | Unique identifier for the compiled rule within the plan |
| `sourceRuleId` | 1..1 | string | Identifier of the approved policy rule from which this rule was compiled |
| `target` | 1..1 | string | FHIRPath expression identifying the target element(s). Semantic group references (`@`) SHALL have been expanded during compilation; they SHALL NOT appear in dispatched execution plans. |
| `action` | 1..1 | code | Action code from the core action family (see [§3:PXX.1.3](#3pxx13-transformation-actions)) |
| `parameters` | 0..1 | object | Action-specific parameters as key-value pairs |
{: .grid}

Rules are evaluated in order. When multiple rules match the same element, the first matching rule applies and subsequent matching rules are skipped. This first-match-wins evaluation enables execution plans to specify exceptions before general rules (e.g., keep a specific identifier before removing all identifiers).

Execution plans dispatched via ITI-x3 SHALL contain only concrete element paths. Semantic group references (`@` prefix) SHALL have been expanded by the De-ID Manager during policy compilation. The presence of an unresolved `@` reference in a dispatched execution plan is a conformance error.

#### 3:PXX.1.4.3 Execution Plan Example

This decoded execution plan compiles the clinical pathology [policy example](#3pxx221-policy-rules-examples). The Manager copies the resolved institutional scope into the salted `hash` rule and expands the semantic targets to concrete paths. See the corresponding [evidence example](Provenance-dis-evidence-uc3-001.html) and [generated lookup table](DocumentReference-generated-lookup-uc3.html).

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

<a name="evidence-baseline"> </a>

### 3:PXX.1.5 Evidence Baseline

This section defines the minimum evidence elements that every completed de-identification task SHALL produce and specifies how they map to HL7 FHIR R4 Provenance resources.

#### 3:PXX.1.5.1 Minimum Evidence Elements

Every completed de-identification task produces an HL7 FHIR R4 Provenance resource containing at minimum the nine evidence elements listed in Table 3:PXX.1.5-1.

<p id="tPXX.1.5-1" class="tableTitle"><strong>Table 3:PXX.1.5-1: DIS Evidence Baseline Elements</strong></p>

| # | Evidence Element | HL7 FHIR R4 Provenance Mapping | Description |
|---|------------------|-------------------------------|-------------|
| 1 | Evidence identifier | `Provenance.id` | Unique identifier for this evidence record |
| 2 | Outcome status | `Provenance.extension[dis-outcome-status]` | Overall task outcome: `complete` or `error` |
| 3 | Workflow reference | `Provenance.activity` | Coding identifying the DIS transaction and job/task context |
| 4 | Target identifier | `Provenance.target` | Reference(s) to the de-identified output resource(s) |
| 5 | Policy-decision reference | `Provenance.policy` | URI of the validated policy governing this task |
| 6 | RuleSet identifier | `Provenance.extension[dis-ruleset]` | Identifier of the ruleSet that produced this evidence |
| 7 | Reversibility state | `Provenance.extension[dis-reversibility]` | `irreversible` or `reversible` |
| 8 | Validation status | `Provenance.extension[dis-validation-status]` | Output validation result: `valid` or `invalid` |
| 9 | Audit correlation identifier | `Provenance.extension[dis-audit-correlation]` | Identifier linking this evidence to the ATNA audit trail |
{: .grid}

Elements 2, 6, 7, 8, and 9 use DIS-defined extensions on the HL7 FHIR R4 Provenance resource. The extension URLs follow the pattern `https://profiles.ihe.net/ITI/DIS/StructureDefinition/<extension-name>`.

#### 3:PXX.1.5.2 Provenance Resource Structure

In addition to the nine baseline elements, the Provenance resource SHALL include the following standard HL7 FHIR R4 Provenance elements.

Table 3:PXX.1.5-2 lists the required Provenance elements beyond the baseline.

<p id="tPXX.1.5-2" class="tableTitle"><strong>Table 3:PXX.1.5-2: Required Provenance Elements</strong></p>

| Element | Cardinality | Description |
|---------|-------------|-------------|
| `Provenance.recorded` | 1..1 | Timestamp when the de-identification task completed |
| `Provenance.agent` (performer) | 1..1 | The De-Identifier that executed the task, identified by reference or identifier |
| `Provenance.agent` (policy authority) | 0..1 | The authority whose policy governed the task, when identifiable |
| `Provenance.reason` | 0..* | Coded reason for the de-identification (e.g., research, clinical pseudonymization) |
{: .grid}

The `Provenance.agent` entry for the De-Identifier SHALL use `Provenance.agent.type` with coding `http://terminology.hl7.org/CodeSystem/provenance-participant-type|performer`. The `Provenance.agent.who` SHALL reference or identify the De-Identifier.

#### 3:PXX.1.5.3 Transformation Summary

Each Provenance resource SHOULD include a transformation summary recording the actions applied to individual elements. The transformation summary is carried as a DIS-defined extension `dis-transformation-summary` containing an array of entries.

Table 3:PXX.1.5-3 lists the elements of each transformation summary entry.

<p id="tPXX.1.5-3" class="tableTitle"><strong>Table 3:PXX.1.5-3: Transformation Summary Entry Elements</strong></p>

| Element | Cardinality | Type | Description |
|---------|-------------|------|-------------|
| `targetPath` | 1..1 | string | FHIRPath expression identifying the transformed element |
| `action` | 1..1 | code | Action code applied (from the core action family) |
| `outcome` | 1..1 | code | `applied`, `skipped` (element not present), or `error` |
| `ruleId` | 0..1 | string | Identifier of the execution plan rule that triggered this action |
{: .grid}

The transformation summary enables audit and review of the specific actions applied to each element. It does not contain the original or transformed values. Original values SHALL NOT appear in evidence.

#### 3:PXX.1.5.4 Evidence Example

The [evidence example](Provenance-dis-evidence-uc3-001.html) illustrates the Provenance produced for a completed synchronous pseudonymization task in Use Case 3 (Clinical Pathology Order). It conforms to the [DIS Evidence profile](StructureDefinition-DIS-Evidence.html) and references a synthetic [pseudonymized Patient](Patient-pseudonym-abc123.html).

<a name="data-plane-access"> </a>
<a name="obtaining-processing-targets"> </a>

### 3:PXX.1.6 Obtaining Processing Targets

DIS-FHIR-Payload supports inline and referenced inputs. Grouped exchanges use the [common manifest contract](#payload-set-delivery). The ungrouped FHIR forms below also support inline submission, direct resource references, and bulk file manifests. The job request identifies the proposed processing targets. The task request identifies the data that the assigned De-Identifier is to retrieve.

#### 3:PXX.1.6.1 Inline Submission

The Requester supplies resource content in ITI-x1 using the [version-safe packaging rules](#3pxx112-version-safe-packaging). An Integrated De-ID Manager/De-Identifier can process the submitted content directly. When dispatching to a separate De-Identifier, the Manager SHALL make the submitted content available through authorized task input references. The references SHALL resolve to the submitted content in its declared FHIR release.

#### 3:PXX.1.6.2 FHIR Resource References

The Requester can enumerate resources using repeated `processingTarget` parameters. The actor that retrieves a referenced resource uses a FHIR REST read, or a version-specific read when the reference identifies a resource version. An absolute HTTPS reference identifies the source directly. The Manager MAY accept a relative reference in ITI-x1 when the applicable source base URL is unambiguously established by deployment configuration. The Manager SHALL reject a relative reference with no unambiguous source and SHALL dispatch absolute HTTPS references in ITI-x3.

<a name="resource-manifest"> </a>

##### Resource Manifest

A [DIS Resource Manifest](StructureDefinition-DIS-ResourceManifest.html) is a profiled FHIR R4 [List](https://hl7.org/fhir/R4/list.html). In an ungrouped exchange, each `List.entry.item.reference` is an absolute HTTPS FHIR REST reference. In a grouped exchange, the List may also use bundle-local references under the [manifest package rules](#manifest-package). The manifest belongs to one payload set. The selected binding and version determine whether an entry identifies a payload resource, an R4 payload wrapper, or an R4 index. See [Resource Manifest Resolution](#resource-manifest-resolution) for the mapping by binding.

| Use | Ungrouped FHIR carrier | Grouped carrier |
|-----|------------------------|-----------------|
| Input | `resourceManifest.valueReference` in ITI-x1 or ITI-x3 | `payload.manifest` with format `dis-resource-list` |
| Result | `output.resource` in ITI-x1, ITI-x4, ITI-x3, or ITI-x7 | `payloadResult.manifest` with format `dis-resource-list` |
{: .grid}

The Manager SHALL establish the manifest's entry set before dispatch and verify that authorization covers every entry and the corresponding native content. It SHALL ensure the job and its retries resolve to the same target set. The Manager can use version-specific references or a protected snapshot of the manifest and any index resources used to resolve the targets. The Manager SHALL give the De-Identifier access only to the manifest, indexes, and payloads authorized for its task. The Integrated De-ID Manager/De-Identifier applies the same rules when processing directly.

For existing ungrouped FHIR exchanges, resolution of an absolute HTTPS manifest entry in the declared R5 or R6 release is a DIS-specific rule. FHIR R4 leaves cross-release reference resolution undefined. In the ungrouped FHIR form, `resourceManifest` referencing `List/42` selects the resources listed in `List/42`. A direct `processingTarget` referencing `List/42` selects the List resource itself.

#### 3:PXX.1.6.3 Bulk File Manifests

For an asynchronous cohort job, the Requester supplies an HTTPS URI identifying a JSON manifest that lists prepared input files. Each line of a listed NDJSON file contains one complete resource in the declared payload release. [Volume 1](volume-1.html) defines the Phase 1 boundary for bulk data input and output.

DIS uses the file listing conventions of the [HL7 Bulk Data Access IG STU 3](https://hl7.org/fhir/uv/bulkdata/STU3/en/export.html#response---output-manifest). For a manifest prepared for DIS, the required fields are `requiresAccessToken` (boolean) and `output` (array of file entries). Each entry SHALL identify the resource type in `type` and the file location in `url` as an absolute HTTPS URL. The manifest SHALL enumerate the complete dataset in one file listing. It may omit export-specific metadata such as `request` and `transactionTime`. The job's `payloadVersion` applies to all listed input files. A manifest with continuation links or reported export errors SHALL be rejected for processing under this binding.

<a name="referenced-input-authorization"> </a>

#### 3:PXX.1.6.4 Authorization for Referenced Inputs

The Manager SHALL verify that the approved data request covers the processing target set, including every resource identified by a resource manifest and the dataset described by a bulk file manifest. It SHALL dispatch only references within the authorized scope. Retrieval of a resource or manifest SHALL NOT expand that scope. The data request authorization governs the full target set.

The actor making the retrieval request SHALL use HTTPS and obtain credentials valid for the specific resource or file service. For automated FHIR REST reads, the retrieving actor SHOULD use [SMART Backend Services](https://hl7.org/fhir/smart-app-launch/STU2.2/backend-services.html) with its registered client identity to obtain an access token. The source service enforces the applicable resource access restrictions. The data request authorization in ITI-x1 is evidence of approval for the job. The retrieving actor obtains credentials through the source service's access mechanism.

Authorization SHALL cover retrieval of each manifest and each resource or file listed in it. If `requiresAccessToken` is true, the retrieving actor SHALL present an access token valid at the file endpoint. When the file endpoint uses a signed URL as the access credential, the retrieving actor SHALL use the URL without forwarding a bearer token. The signed URL SHALL be limited to the specific file and have a bounded lifetime. A signed URL SHALL be handled as a credential. The retrieving actor SHALL send credentials only to the service for which they are valid.

The Manager SHALL reject the job if it cannot establish that the identified dataset is authorized. If a required input is missing, inaccessible, invalid or outside the authorized scope, the Manager SHALL reject the job before acceptance or fail the accepted job and withhold all job output. A De-Identifier that detects such a failure SHALL report it to the Manager using the applicable task transaction.

#### 3:PXX.1.6.5 Delivery of De-Identified Results

The De-Identifier returns task results to the Manager in ITI-x3 or ITI-x7. The Manager returns job results to the Requester in ITI-x1 or ITI-x4. Result resources retain the input FHIR release. Inline results use the [version-safe packaging rules](#3pxx112-version-safe-packaging). Jobs submitted with inline content return the job result inline. For jobs submitted with FHIR resource references or a resource manifest, results MAY be returned inline or persisted to an output service designated by the Manager. Where results are delivered by reference, the receiving actor retrieves them from that service using its authorized access.

For ungrouped FHIR results delivered as a resource manifest, the producing actor SHALL place the profiled R4 List in `Parameters.parameter.resource` for the `output` parameter. An output List that declares the DIS Resource Manifest profile is interpreted as a manifest. To return such a List as a de-identified payload resource, place it in a result Bundle. Manifest entries SHALL identify only de-identified resources in the result set available to the receiving actor. The producing actor SHALL ensure that each reference resolves to the corresponding authorized result before returning the manifest and remains bound to that result while available for retrieval. Recipient-facing manifest metadata SHALL exclude source identifiers and protected transformation material. Associated Provenance is carried in the transaction's `evidence` parameters.

For asynchronous cohort jobs, the Manager returns a bulk file manifest for the de-identified NDJSON files and supplies the associated evidence with the job result. Recipient-facing manifests and files SHALL NOT contain confidential salts or other protected transformation material. A failed job SHALL NOT release a partial dataset. The Manager SHALL report the failure through job status for an accepted asynchronous job.

### 3:PXX.1.7 Reversible Lookup Table

[DIS-LookupTable](StructureDefinition-DIS-LookupTable.html) is a protected, identified R4 DocumentReference. The `lookupTable` input to ITI-x1 or ITI-x3 is a reference to a supplied table. The `generatedLookupTable` output in ITI-x3 or ITI-x7 is a task-generated instance carried inline as a resource in `Parameters`. Both use the [DIS patient lookup table JSON Schema](schemas/dis-lookup-table.schema.json) for patient identifier mappings. The generated table carries its JSON inline. A supplied table may carry JSON inline or reference a protected [DIS-LookupTableContent](StructureDefinition-DIS-LookupTableContent.html) Binary.

| DocumentReference element | DIS requirement |
|---|---|
| `identifier` | Stable business identifiers. At least one value SHALL equal the decoded JSON `tableId`. |
| `masterIdentifier` | A system and value identifying this immutable content version. A change to the JSON bytes requires a new `masterIdentifier`. |
| `status` | `current` when used for a new job or returned as generated output. |
| `type` | DIS document-type code `lookup-table`. |
| `extension[dis-identity-linkage-scope]` | Resolved scope type and identifier. Both SHALL match the authorized job scope and decoded JSON. |
| `content` | Exactly one `application/json` attachment. It carries either inline Base64 data or a protected Binary URL. |

The decoded JSON contains `tableId`, format `version` of `1`, a resolved `identity-linkage-scope`, and a nonempty `entries` array. A patient mapping has exactly four fields. `sourceSystem` and `sourceValue` are the original `Identifier.system` and `Identifier.value`. `targetSystem` and `targetValue` are the pseudonym identifier pair. The De-Identifier SHALL match both source fields exactly, without implicit normalization, and replace both target fields. A supplied table may map multiple approved source identifiers to one assigned pseudonym for the same patient. The table authority and Manager SHALL ensure that a shared target pair is authorized for the same patient. A missing or conflicting source mapping SHALL fail the job without partial output.

Source identifier pairs SHALL be unique within a table.

A task-scoped subset has its own business identifier and `masterIdentifier`, retains the authorized scope, and links to the pinned source with `relatesTo` code `transforms`. A reference may use a literal, version-specific history URL or an identifier that resolves unambiguously to an exact version. Repository provisioning and table lifecycle remain deployment concerns. ITI-x1 defines admission and pinning, and ITI-x3 defines restricted dispatch and cleanup.

When a reversible Manager-managed task generates patient identifier pseudonyms, the De-Identifier SHALL return one `generatedLookupTable` containing the resulting patient mappings and the resolved scope. The Manager SHALL validate the table against the task and retain the mappings before job release. Repeated identical pairs across tasks or retries are idempotent. If a source pair maps to conflicting targets in the same job or a target is assigned to distinct patients, the Manager SHALL fail the job without partial release. A task applying supplied patient mappings or executing an irreversible policy SHALL NOT return a generated patient lookup table. Generated and supplied tables are protected operational material and SHALL be excluded from recipient-facing output, evidence, logs and errors.

### 3:PXX.1.8 Worked Mapping Examples

These synthetic, informative FHIR R4 examples accompany the [lookup table binding](#3pxx17-reversible-lookup-table). They also appear in the [artifact index](artifacts.html) and the [FHIR example downloads](download.html).

| Published example | What it shows |
|---|---|
| [Lookup table with Binary content](DocumentReference-lookup-document-example.html) | A persistent DocumentReference with a business identifier, a content version identifier, and a reference to the JSON attachment. |
| [Lookup table JSON content](Binary-lookup-content-example.html) | The Binary carrying the lookup table JSON for the DocumentReference above. |
| [Lookup table with inline content](DocumentReference-lookup-inline-example.html) | The same lookup table content carried directly in a DocumentReference attachment. |
| [Task-scoped lookup table](DocumentReference-lookup-task-s1.html) | A supplied table subset with its own identifiers and a `transforms` relationship to the version of the source DocumentReference. |
| [Generated lookup table](DocumentReference-generated-lookup-uc3.html) | The patient identifier mapping generated by the clinical pathology salted hash example and returned to the Manager. |
{: .grid}

<a name="policy-content-module"> </a>

## 3:PXX.2 DIS-Policy Content Module

The DIS-Policy content module defines the structure, delivery modes, validation rules, and compilation rules for de-identification policy artifacts. A policy is a reusable knowledge artifact that governs what de-identification transformations are applied. A policy may be authored at the Semantic-Level (using semantic group references, format-neutral) or at the Syntax-Level (using concrete element paths for a specific payload family and version). Both representation levels use the same Library carrier, delivery modes, and four-point validation. The De-ID Manager validates the policy, and when required, compiles it into one or more payload-specific execution plans (see [§3:PXX.1.4](#3pxx14-execution-plan-format)) before dispatching tasks.

The policy artifact is an HL7 FHIR R4 Library resource, part of the protocol layer. It is fixed to HL7 FHIR R4 regardless of the payload version being de-identified.

**Referenced standards and artifacts.** The [HL7 FHIR R4 Library]({{site.data.fhir.path}}library.html) carries the policy. The draft [DIS Policy profile](StructureDefinition-DIS-Policy.html) and [DIS Library Type CodeSystem](CodeSystem-dis-library-type.html) define its FHIR constraints. [ITI-x1](volume-2.html#23x1-submit-de-identification-job-iti-x1) defines the policy submission and admission behavior.

### 3:PXX.2.1 Policy Library Resource Structure

A DIS policy is carried as an HL7 FHIR R4 `Library` resource. The Library resource provides versioned metadata about the policy; the policy rules are carried as a DIS-specific JSON format within `Library.content`. Policies and execution plans both use Library but are distinguished by `Library.type` coding.

Table 3:PXX.2.1-1 lists the required Library resource elements for a DIS policy.

<p id="tPXX.2.1-1" class="tableTitle"><strong>Table 3:PXX.2.1-1: DIS-Policy Library Resource Elements</strong></p>

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

Table 3:PXX.2.1-2 lists the `Library.type` codings used to distinguish DIS Library artifacts.

<p id="tPXX.2.1-2" class="tableTitle"><strong>Table 3:PXX.2.1-2: DIS Library Type Codings</strong></p>

| Coding | Artifact |
|--------|----------|
| `dis-policy` | De-identification policy (Semantic-Level or Syntax-Level rules) |
| `dis-execution-plan` | Execution plan (payload-specific compiled rules, see [§3:PXX.1.4](#3pxx14-execution-plan-format)) |
{: .grid}

<div markdown="1" class="stu-note">
The draft [DIS Policy](StructureDefinition-DIS-Policy.html) and [DIS Execution Plan](StructureDefinition-DIS-ExecutionPlan.html) profiles use the [DIS Library Type CodeSystem](CodeSystem-dis-library-type.html).
</div>

### 3:PXX.2.2 Policy Rules JSON Structure

The [DIS policy JSON Schema](schemas/dis-policy.schema.json) defines the structure of the decoded JSON in `Library.content.data`. The [DIS Policy profile](StructureDefinition-DIS-Policy.html) defines the structure of the enclosing FHIR Library. The policy rules use one of two representation levels:

- **Semantic-Level** — rules use semantic group references (prefixed with `@`) and action codes. The policy is format-neutral and requires compilation into a payload-specific execution plan before dispatch. This is the default representation for reusable, cross-format policies.
- **Syntax-Level** — rules use concrete element paths (e.g., FHIRPath expressions for HL7 FHIR, DICOM tag paths for DICOM) and action codes. The policy is specific to a payload family and version, and is directly executable after validation. A Syntax-Level policy requires `payloadFamily` and `payloadVersion` declarations.

Both levels use the same JSON structure, delivery modes, and four-point validation. The `@` prefix on rule targets is the syntactic marker distinguishing Semantic-Level from Syntax-Level rules. A De-Identifier SHALL never receive rules containing unresolved `@` references — that would indicate a compilation failure.

Table 3:PXX.2.2-1 lists the top-level elements of the policy rules JSON.

<p id="tPXX.2.2-1" class="tableTitle"><strong>Table 3:PXX.2.2-1: Policy Rules JSON — Top-Level Elements</strong></p>

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

Each ruleSet in the `ruleSets` array contains the elements listed in Table 3:PXX.2.2-2.

<p id="tPXX.2.2-2" class="tableTitle"><strong>Table 3:PXX.2.2-2: Policy Rules JSON — RuleSet Elements</strong></p>

| Element | Cardinality | Type | Description |
|---------|-------------|------|-------------|
| `ruleSetId` | 1..1 | string | Unique identifier for the ruleSet within the policy |
| `description` | 0..1 | string | Human-readable description of the ruleSet |
| `rules` | 1..* | array | Ordered list of rules for this ruleSet |
{: .grid}

Each rule in the `rules` array contains the elements listed in Table 3:PXX.2.2-3.

<p id="tPXX.2.2-3" class="tableTitle"><strong>Table 3:PXX.2.2-3: Policy Rules JSON — Rule Elements</strong></p>

| Element | Cardinality | Type | Description |
|---------|-------------|------|-------------|
| `ruleId` | 1..1 | string | Unique identifier for the rule within the policy |
| `target` | 1..1 | string | Semantic group reference (prefixed with `@`) for Semantic-Level policies, or a concrete element path (e.g., FHIRPath expression) for Syntax-Level policies |
| `action` | 1..1 | code | Action code from the core action family (see [§3:PXX.1.3](#3pxx13-transformation-actions)) |
| `parameters` | 0..1 | object | Action-specific parameters as key-value pairs |
{: .grid}

Semantic-Level policy rules use semantic group references (e.g., `@subject-identifiers`) rather than element paths. This keeps the policy format-neutral. The De-ID Manager expands semantic group references to payload-specific element paths during compilation (see [§3:PXX.2.4](#3pxx24-policy-compilation)).

Syntax-Level policy rules use concrete element paths appropriate to the declared `payloadFamily`. For HL7 FHIR payloads, these are FHIRPath expressions (e.g., `Patient.identifier`, `Patient.name`). The De-ID Manager validates that all rule targets are valid paths for the declared payload family and version.

Rules within a ruleSet are evaluated in order; first-match-wins evaluation applies, consistent with execution plan evaluation (see [§3:PXX.1.4.2](#3pxx142-execution-plan-json-structure)).

The schema checks which parameters an action accepts. Lookup-backed `replace` requires reversible mode and is mutually exclusive with fixed replacement. A salted `hash` rule uses the policy scope. For a patient business identifier target, the Manager SHALL require `mode` of `salted` and a `pseudonymSystem`, including when a target is expressed as a FHIRPath selector. The Manager SHALL validate its authorization and resolve a `job` scope to a stable scope identifier for the job and its retries. For other scope types, the Manager SHALL copy the authorized `system` and `value` as supplied in the approved policy. The scope level and identifier SHALL be copied into each applicable compiled rule. Date-shift derivation and its protected inputs remain a separate capability contract.

Each stage in the optional `stages` array contains the elements listed in Table 3:PXX.2.2-4.

<p id="tPXX.2.2-4" class="tableTitle"><strong>Table 3:PXX.2.2-4: Policy Rules JSON — Stage Elements</strong></p>

| Element | Cardinality | Type | Description |
|---------|-------------|------|-------------|
| `stageId` | 1..1 | string | Stage identifier (e.g., `preliminary`, `advanced`) |
| `description` | 0..1 | string | Human-readable description of the stage |
| `ruleSetRefs` | 1..* | array of string | Ordered list of ruleSet IDs assigned to this stage |
{: .grid}

When `stages` is present, the De-ID Manager dispatches ruleSets in stage order. RuleSets assigned to the same stage MAY be dispatched concurrently. RuleSets in later stages are dispatched only after all earlier stages complete. When `stages` is absent, all ruleSets are dispatched as a single execution pass.

#### 3:PXX.2.2.1 Policy Rules Examples

This decoded Semantic-Level policy illustrates reversible pseudonymization for Use Case 3 (Clinical Pathology Order). See the [compiled execution plan](#3pxx143-execution-plan-example) for the resolved scope and concrete targets.

```json
{
  "policyVersion": "1.0",
  "representationLevel": "semantic",
  "reversibilityMode": "reversible",
  "identity-linkage-scope": {
    "type": "source-institution",
    "identifier": {
      "system": "https://hospital.example.org/identifiers/linkage-scope",
      "value": "lab-project-2026"
    }
  },
  "ruleSets": [
    {
      "ruleSetId": "direct-identifiers",
      "rules": [
        {
          "ruleId": "P01",
          "target": "@subject-business-identifiers",
          "action": "hash",
          "parameters": {
            "mode": "salted",
            "algorithm": "SHA-256",
            "pseudonymSystem": "https://hospital.example.org/identifiers/pseudonym"
          }
        },
        {
          "ruleId": "P02",
          "target": "@subject-names",
          "action": "remove"
        }
      ]
    }
  ]
}
```

This Semantic-Level policy illustrates staged irreversible pseudonymization for Use Case 1 (Cross-Border Epidemiological Study).

```json
{
  "policyVersion": "1.0",
  "representationLevel": "semantic",
  "reversibilityMode": "irreversible",
  "identity-linkage-scope": {
    "type": "cross-community",
    "identifier": {
      "system": "https://study.example/identifiers/linkage-scope",
      "value": "epi-study-2026-cohort-a"
    }
  },
  "ruleSets": [
    {
      "ruleSetId": "direct-identifiers",
      "description": "Irreversible hashing of direct identifiers",
      "rules": [
        {
          "ruleId": "P01",
          "target": "@subject-business-identifiers",
          "action": "hash",
          "parameters": {
            "mode": "salted",
            "algorithm": "SHA-256",
            "pseudonymSystem": "https://study.example/identifiers/pseudonym"
          }
        },
        {
          "ruleId": "P01N",
          "target": "@subject-names",
          "action": "remove"
        },
        {
          "ruleId": "P02",
          "target": "@contact-information",
          "action": "remove"
        },
        {
          "ruleId": "P03",
          "target": "@narrative",
          "action": "redact"
        },
        {
          "ruleId": "P04",
          "target": "@references",
          "action": "keep"
        }
      ]
    },
    {
      "ruleSetId": "quasi-identifiers",
      "description": "Record-level removal of quasi-identifiers",
      "rules": [
        {
          "ruleId": "A01",
          "target": "@dates",
          "action": "remove"
        },
        {
          "ruleId": "A02",
          "target": "@subject-demographics",
          "action": "remove"
        },
        {
          "ruleId": "A03",
          "target": "@provider-identifiers",
          "action": "remove"
        },
        {
          "ruleId": "A04",
          "target": "@device-identifiers",
          "action": "remove"
        },
        {
          "ruleId": "A05",
          "target": "@birth-dates",
          "action": "remove"
        }
      ]
    }
  ],
  "stages": [
    {
      "stageId": "preliminary",
      "description": "Direct identifier handling with trust isolation",
      "ruleSetRefs": [
        "direct-identifiers"
      ]
    },
    {
      "stageId": "advanced",
      "description": "Quasi-identifier truncation and removal",
      "ruleSetRefs": [
        "quasi-identifiers"
      ]
    }
  ]
}
```

This Syntax-Level policy illustrates the same Use Case 3 rules with concrete FHIR R4 targets.

```json
{
  "policyVersion": "1.0",
  "representationLevel": "syntax",
  "reversibilityMode": "reversible",
  "identity-linkage-scope": {
    "type": "source-institution",
    "identifier": {
      "system": "https://hospital.example.org/identifiers/linkage-scope",
      "value": "lab-project-2026"
    }
  },
  "payloadFamily": "fhir",
  "payloadVersion": "R4",
  "ruleSets": [
    {
      "ruleSetId": "direct-identifiers",
      "rules": [
        {
          "ruleId": "P01",
          "target": "Patient.identifier",
          "action": "hash",
          "parameters": {
            "mode": "salted",
            "algorithm": "SHA-256",
            "pseudonymSystem": "https://hospital.example.org/identifiers/pseudonym"
          }
        },
        {
          "ruleId": "P02",
          "target": "Patient.name",
          "action": "remove"
        }
      ]
    }
  ]
}
```

<div markdown="1" class="stu-note">
**Editorial Note:** The examples illustrate policy structure. The date-shift derivation contract and how concurrent ruleSet outputs combine remain open.
</div>

### 3:PXX.2.3 Policy Delivery and Validation

A de-identification policy is a reusable knowledge artifact. The same policy may be approved for multiple independent data requests. The ITI-x1 `policy` group, at the top level for ungrouped jobs or within each `payload` for grouped jobs, declares the approved policy by canonical URL (`policy.url`) and version (`policy.version`). The `authorization` parameter provides evidence that the data request — including approval of that specific policy — was authorized by the data governance authority. The De-ID Manager validates that the declared policy matches the policy approved in the authorization.

#### 3:PXX.2.3.1 Policy Content Resolution

The `policy.content` parameter is optional. It determines how the De-ID Manager obtains the policy Library:

**When `policy.content` is present (inline delivery):** The Requester carries the JWS-signed policy Library directly in the ITI-x1 request as a `Binary` resource with `Binary.contentType` of `application/jose`. The JWS protects the policy content from tampering by the Requester, who acts as an untrusted courier. The De-ID Manager SHALL verify the JWS signature against the trusted policy authority's public key. The JWS payload is the JSON serialization of the Library resource. The JWS header SHALL include:

- `alg` — the signing algorithm (e.g., `RS256`, `ES256`)
- `x5c` or `jwk` — the signing key or certificate chain, enabling the De-ID Manager to verify the signature against a trusted policy authority

The De-ID Manager SHALL confirm that `Library.url` and `Library.version` inside the JWS payload match the declared `policy.url` and `policy.version`. A mismatch indicates the Requester declared one policy but couriered different content; the Manager SHALL reject the job.

**When `policy.content` is absent (Manager-resolved):** The ITI-x1 request carries only `policy.url` and `policy.version`. No policy content appears in the ITI-x1 message. The De-ID Manager resolves the policy from the declared canonical URL through its own mechanisms:

- When the URL matches a policy managed locally by the De-ID Manager (e.g., provisioned by administrative configuration), the Manager resolves it from its own store.
- When the URL identifies an externally hosted policy, the Manager retrieves the policy through its implementation-defined trust model (e.g., TLS-protected fetch, mutual TLS, or externally stored JWS artifacts).

Locally managed policies are trusted by virtue of their administrative provisioning; the Manager is not required to verify a JWS signature at each job submission.

#### 3:PXX.2.3.2 Policy Validation

The De-ID Manager SHALL perform the following validation on the resolved policy Library, as defined in [§1:PXX.4.1](volume-1.html#1pxx41-concepts):

1. **Authorization consistency** — verify that `policy.url` and `policy.version` declared in the ITI-x1 request identify the policy approved in the data request authorization. The mechanism for extracting the approved policy identity from the authorization is implementation-defined (it depends on the authorization format used in the deployment).
2. **Integrity** — when `policy.content` is present, verify the JWS signature and confirm that the Library's canonical URL and version match the declared values. When `policy.content` is absent, integrity is established by the Manager's resolution trust model.
3. **Schema** — verify the Library conforms to the [DIS Policy profile](StructureDefinition-DIS-Policy.html) and the decoded policy rules conform to the [DIS policy JSON Schema](schemas/dis-policy.schema.json). Also verify unique ruleSet, rule, and stage IDs in their applicable scopes, resolve all stage references, and check that each ruleSet appears exactly once when stages are declared. Validate target paths or semantic groups, action applicability, and parameter values that depend on the target, approved scope, or declared capabilities.
4. **Currency** — verify the current date falls within `Library.effectivePeriod` and that the policy has not been revoked. Revocation checking uses the deployment's implementation-defined policy trust and lifecycle mechanisms.

### 3:PXX.2.4 Policy Compilation

The De-ID Manager processes a validated policy Library before dispatching tasks via ITI-x3. The processing depends on the policy's representation level.

#### 3:PXX.2.4.1 Semantic-Level Compilation

When the policy's `representationLevel` is `semantic`, the De-ID Manager compiles each ruleSet into a payload-specific execution plan Library for the assigned set. The compilation process performs the following steps for each ruleSet:

1. **Semantic group expansion** — the De-ID Manager SHALL resolve each `@` group reference using the [Semantic Group Binding](#3pxx122-semantic-groups) for the declared payload family and release. If a referenced group has no binding for that release, the Manager SHALL fail compilation before dispatch.

2. **Execution plan assembly** — the Manager preserves rule order and source rule IDs and adds the resolved scope to salted rules. The expanded and version-resolved rules are assembled into an execution plan JSON (see [§3:PXX.1.4.2](#3pxx142-execution-plan-json-structure)) and packaged in a Library resource with `Library.type` coding `dis-execution-plan`.

3. **Capability verification** — the De-ID Manager verifies that the target De-Identifier's declared capabilities support all action codes and the payload binding and version required by the execution plan. The Manager SHALL NOT dispatch a task with an incompatible execution plan.

For each applicable payload set, each ruleSet produces one execution plan Library, dispatched as one ITI-x3 task for that set. When stages are declared, the Manager dispatches in stage order. The compiled execution plan Library MAY reference the source policy Library via `Library.relatedArtifact` with type `derived-from`.

#### 3:PXX.2.4.2 Syntax-Level Validation

When the policy's `representationLevel` is `syntax`, the De-ID Manager validates the rules and packages them as execution plan Libraries without semantic group expansion or version-conditional path mapping. The validation process performs the following steps for each ruleSet:

1. **Path validation** — the De-ID Manager verifies that all rule targets are valid element paths for the declared `payloadFamily` and `payloadVersion`. For HL7 FHIR payloads, this means each target is a valid FHIRPath expression for the declared HL7 FHIR version.

2. **Consistency check** — the De-ID Manager verifies that the policy's declared `payloadFamily` and `payloadVersion` are consistent with the `payloadBinding` and `payloadVersion` in the ITI-x1 request.

3. **Execution plan assembly** — preserve rule order and source rule IDs, add the resolved scope to salted rules, and package the validated rules in a Library resource with `Library.type` coding `dis-execution-plan`. The existing concrete paths are preserved.

3. **Capability verification** — same as for Semantic-Level compilation.

### 3:PXX.2.5 Policy Lifecycle

The DIS-Policy content module defines the artifact structure and validation requirements. Phase 1 does not standardize policy lifecycle management (authoring, approval, distribution, revocation, versioning workflows). Implementations obtain policies through implementation-defined mechanisms, including local configuration, administrative provisioning, bilateral agreement, or integration with an external policy management system.

The following lifecycle states are supported through `Library.status`:

- `draft` — the policy is under development and SHALL NOT be accepted by the De-ID Manager for job execution
- `active` — the policy is approved and valid for use within its `effectivePeriod`
- `retired` — the policy is no longer valid and SHALL NOT be accepted for new jobs

The De-ID Manager SHALL reject a policy with `Library.status` other than `active`. The De-ID Manager SHALL reject a policy whose `Library.effectivePeriod` does not include the current date.

<a name="payload-set-delivery"> </a>

## 3:PXX.3 Common Payload Set Delivery

A grouped job can contain multiple payload sets. Each set uses one binding and version and carries one manifest at each exchange. The manifest can select bundled and externally hosted content. A job can combine, for example, an inline R5 Patient and a set of separately hosted FHIR Observations. The FHIR R4 envelope carries the delivery description. The selected binding defines the native data, retrieval rules, execution plan, validation, and evidence mapping.

The [shared grouped payload parameters](volume-2.html#grouped-payload-parameters) define how the transactions carry a payload set.

### 3:PXX.3.1 Manifest Formats

The `dis-resource-list` format carries an R4 DIS Resource Manifest as a standalone List or in an R4 [DIS Manifest Package](StructureDefinition-DIS-ManifestPackage.html). Serialize either as FHIR JSON or XML and declare the corresponding FHIR media type in the `manifest` attachment. The same format applies to task and job inputs and results.

The `fhir-bulk-data` format uses the JSON [bulk file manifest](#3pxx163-bulk-file-manifests) of DIS-FHIR-Payload. It enumerates NDJSON files.

<a name="manifest-package"> </a>

#### Manifest Package

Use an R4 `Bundle` of type `collection` when the manifest and its targets or indexes travel together. It SHALL contain exactly one List declaring the DIS Resource Manifest profile. Each entry in that List SHALL use either an absolute HTTPS FHIR REST reference to an R4 resource or a `urn:uuid` reference matching exactly one `Bundle.entry.fullUrl` in the same package. A standalone List SHALL use absolute HTTPS references. Only the List's selected entries determine the payload set. Other Bundle entries may support resolution under the selected binding.

A bundled R4 resource can be the target itself or a wrapper or index. The package SHALL carry non-R4 bytes inside the attachment of an R4 resource. It SHALL NOT embed a native R5 or R6 resource as a Bundle entry.

<a name="resource-manifest-resolution"> </a>

#### Resource Manifest Resolution

| Binding and version | Resource selected by a List entry | Payload selected |
|---------------------|------------------------------------|------------------|
| DIS-FHIR-Payload R4 | An R4 resource, or an R4 [DIS Payload Wrapper](StructureDefinition-DIS-PayloadWrapper.html) | The resource itself or, for a wrapper, the R4 content carried or located by its attachment |
| DIS-FHIR-Payload R5 or R6 | R4 DIS Payload Wrapper | The serialized R5 or R6 resource carried or located by the wrapper's attachment |
{: .grid}

**Payload wrapper.** The wrapper is a profiled R4 DocumentReference with one attachment. Its `data` carries the payload bytes inline, or its `url` locates the payload at an authorized HTTPS endpoint. Exactly one SHALL be present. A FHIR wrapper SHALL use `application/fhir+json` or `application/fhir+xml`. The receiving actor SHALL retrieve or decode the payload and validate it against the containing set's binding and version. If the FHIR media-type release parameter is present, it SHALL agree with `payloadVersion`. Any HTTP negotiation for R5 or R6 occurs on retrieval of the attachment content. The manifest, package, and wrapper exchanges use R4.

In a grouped FHIR set, the receiving actor SHALL follow the attachment only when the DocumentReference declares and conforms to the DIS Payload Wrapper profile. A DocumentReference claiming that profile but failing validation SHALL cause a set failure. To deliver a resource that itself declares the wrapper profile as a FHIR payload, serialize it inside a separate wrapper. An inline R5 DocumentReference is therefore carried as R5 bytes in the R4 wrapper, just like any other R5 resource.

**Results.** A result manifest SHALL reference only result resources or result indexes whose native targets resolve to the authorized de-identified output. The producing actor SHALL verify retrieval and identity of the referenced results before returning the manifest. Recipient-facing manifests, result indexes, and their referenced metadata SHALL exclude source identifiers and protected transformation material. Associated evidence stays in the result's `evidence` parts.

### 3:PXX.3.2 Authorization and Stable Retrieval

The Manager SHALL verify that the job authorization covers every set, including the indexes, native objects, or files reached through its references or manifests. The retrieving actor SHALL use HTTPS and obtain credentials accepted by each endpoint. For automated FHIR REST retrieval of manifests, indexes, or payloads, apply the [FHIR retrieval authorization rules](#referenced-input-authorization). Other bindings define the access mechanism for their endpoints. The job authorization and credentials for reading the source serve separate purposes.

The Manager SHALL establish the authorized target set before dispatch and ensure retries use that same set, including any expansion of a reference that selects multiple objects. When publishing results by reference or manifest, the producing actor SHALL ensure the locators resolve to the intended de-identified objects and are accessible only to authorized recipients. A failed or inaccessible required set SHALL cause job failure without release of any set to the Requester.

### 3:PXX.3.3 FHIR Payload Delivery

| Binding | Version | Inline content in a manifest package | Hosted content selected through a manifest |
|---------|---------|-----------------------|------------------------------------------------|
| DIS-FHIR-Payload | `R4`, `R5`, provisional `R6` | Native R4 resource or FHIR JSON/XML in a wrapper | R4 resource URL or wrapper whose attachment URL retrieves the declared FHIR release. Use the validation rules in [DIS-FHIR-Payload](#fhir-payload-content-module) |
{: .grid}

See [Draft DICOM and CDA Payload Bindings](draft-native-payload-bindings.html) for proposed extensions.

<a name="mixed-payload-walkthrough"> </a>

See the [informative mixed R5 and DICOM job walkthrough](examples-mixed-r5-dicom.html) for an example of manifest submission, task dispatch, and result release across transactions.

<a name="inline-r5-manifest-package"></a>

### 3:PXX.3.4 Inline R5 Manifest Package Example

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
