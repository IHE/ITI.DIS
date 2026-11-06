
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

Each processing payload SHALL explicitly declare its HL7 FHIR version. The version declaration enables the De-ID Manager to verify De-Identifier compatibility before task dispatch and ensures that de-identified output is validated against the correct HL7 FHIR version.

A De-Identifier declaring DIS-FHIR-Payload SHALL advertise the HL7 FHIR payload versions it supports in its capability declaration. The De-ID Manager SHALL verify that the processing payload's declared version is included in the assigned De-Identifier's supported versions before dispatching a task via ITI-x3. The De-ID Manager SHALL reject a job when no available De-Identifier supports the payload's declared HL7 FHIR version.

Table 3:PXX.1.1-1 lists the mechanisms for declaring the payload version.

<p id="tPXX.1.1-1" class="tableTitle"><strong>Table 3:PXX.1.1-1: Payload Version Declaration Mechanisms</strong></p>

| Mechanism | Context | Example |
|-----------|---------|---------|
| Processing target `fhirVersion` field | ITI-x1 job submission and ITI-x3 task dispatch | `{ "family": "fhir", "fhirVersion": "5.0.0", "reference": "Patient/123" }` |
| Content type parameter | Inline attachment | `application/fhir+json; fhirVersion=5.0.0` |
| Source server capability | By-reference retrieval | De-Identifier reads `CapabilityStatement.fhirVersion` from the source HL7 FHIR server |
| Manifest metadata | Bulk Data | Manifest declares the HL7 FHIR version of referenced NDJSON files |
{: .grid}

An explicit payload version declaration is REQUIRED for R4, R5 and R6 payloads. The De-ID Manager SHALL reject a submission that omits the declaration rather than infer R4 from the protocol binding. Source server capabilities and retrieved content are used to verify the declared version, not to replace the submission declaration.

#### 3:PXX.1.1.2 Version-Safe Packaging

An HL7 FHIR payload whose version differs from the HL7 FHIR R4 protocol binding SHALL NOT be embedded as a native resource in the HL7 FHIR R4 transaction envelope. Embedding a non-R4 resource directly in HL7 FHIR R4 `Parameters`, `Task`, or `Bundle` structures would produce invalid HL7 FHIR R4 content and conflate the protocol and payload version boundaries.

The following packaging patterns are permitted for cross-version payloads:

##### By-Reference

The processing target identifies the resource by HL7 FHIR reference or URL. The De-Identifier retrieves it from a source HL7 FHIR server that supports the payload version. The HL7 FHIR R4 transaction envelope carries only the reference, not the resource content.

```json
{
  "family": "fhir",
  "fhirVersion": "5.0.0",
  "reference": "Patient/123",
  "sourceBaseUrl": "https://source.example.org/fhir/r5"
}
```

The De-Identifier SHALL use the declared `fhirVersion` and `sourceBaseUrl` to interact with the source server. The source server is expected to return resources conforming to the declared version.

##### Inline Attachment

The payload is serialized as JSON or XML and carried as a `valueAttachment` in the HL7 FHIR R4 task input. The HL7 FHIR R4 envelope treats the attachment content as opaque bytes.

```json
{
  "type": {
    "coding": [
      {
        "system": "https://dis.ihe.net/CodeSystem/task-input",
        "code": "processingTarget"
      }
    ]
  },
  "valueAttachment": {
    "contentType": "application/fhir+json; fhirVersion=5.0.0",
    "data": "<base64-encoded HL7 FHIR R5 resource>"
  }
}
```

The content type parameter `fhirVersion` is a DIS-defined convention for declaring the payload version within inline attachments; it is not a registered HL7 FHIR MIME type parameter. The De-Identifier SHALL parse the attachment content according to the declared version.

##### Bulk Data Manifest

NDJSON files referenced by a Bulk Data manifest contain serialized resources in the declared payload version. The manifest metadata declares the HL7 FHIR version; each NDJSON line is a complete serialized resource.

```json
{
  "family": "fhir",
  "fhirVersion": "5.0.0",
  "bulkManifest": "https://manager.example.org/dis-jobs/job-001/source-manifest"
}
```

##### De-Identified Output Packaging

De-identified output SHALL be returned or persisted using the same packaging patterns. Output resources retain the payload's HL7 FHIR version -- the De-Identifier does not convert output to HL7 FHIR R4. When output is returned inline, it SHALL be carried as a `valueAttachment` or serialized in a multipart response, not embedded as a native resource in the HL7 FHIR R4 response envelope.

When output is persisted by reference (e.g., to an output HL7 FHIR server or as NDJSON files), the output server or files operate at the payload version. The HL7 FHIR R4 protocol response carries only the output references.

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

DIS-FHIR-Payload uses FHIRPath-compatible path expressions to address data elements within the processing payload (see [§1:PXX.2.3](volume-1.html#1pxx23-hl7-fhir-payload-option)). The path expressions used by DIS execution plans, semantic group mappings, and Provenance transformation summaries are version-neutral: they resolve consistently across HL7 FHIR R4, R5, and R6 for the resource types and elements governed by DIS transformation actions.

Most governed element paths are stable across HL7 FHIR R4, R5, and R6:

- `Patient` direct-identifier and demographic elements (`Patient.name`, `Patient.identifier`, `Patient.birthDate`, `Patient.address`, `Patient.telecom`, `Patient.photo`, `Patient.gender`, `Patient.maritalStatus`) retain identical paths across all three versions.
- HL7 FHIR datatypes used by DIS transformation actions (`HumanName`, `Identifier`, `Address`, `ContactPoint`, `Narrative`, `date`, `dateTime`, `instant`, `Period`, `Quantity`) have stable structures across these versions.
- DIS semantic groups for subject identifiers, demographics, contact information, references, and narrative map to stable paths.
- Resource types commonly governed by DIS (`Patient`, `Practitioner`, `Encounter`, `Condition`, `Observation`, `DiagnosticReport`, `Procedure`, `MedicationRequest`, `DocumentReference`, `ImagingStudy`) exist in all three versions.

However, several governed elements were renamed between HL7 FHIR R4 and R5. The De-ID Manager SHALL apply version-conditional path mappings for these elements when compiling execution plans for HL7 FHIR R5 or R6 payloads.

Table 3:PXX.1.1-3 lists the version-conditional path mappings for elements that changed between HL7 FHIR R4 and R5.

<p id="tPXX.1.1-3" class="tableTitle"><strong>Table 3:PXX.1.1-3: Version-Conditional Path Mappings (HL7 FHIR R4 to R5)</strong></p>

| Semantic Group | HL7 FHIR R4 Path | HL7 FHIR R5 Path | Affected Element |
|----------------|-------------------|-------------------|-----------------|
| `subject.dates` | `Encounter.period` | `Encounter.actualPeriod` | Encounter date/time |
| `subject.dates` | `Procedure.performed[x]` | `Procedure.occurrence[x]` | Procedure date/time (choice types vary by version; HL7 FHIR R5 adds `Timing`) |
| `provider.name` | `Encounter.participant.individual` | `Encounter.participant.actor` | Encounter participant reference |
| `device-identifiers` | `Device.deviceName` | `Device.name` | Device name (sub-element `deviceName.name` in HL7 FHIR R4 becomes `name.value` in HL7 FHIR R5) |
{: .grid}

The De-ID Manager SHALL resolve these mappings at execution plan compilation time based on the declared payload version. A single governance policy using semantic groups remains version-neutral; the version-conditional mapping is applied during compilation, not by the De-Identifier. The De-Identifier receives resolved paths appropriate for the payload version.

For elements not listed in Table 3:PXX.1.1-3, a single execution plan can govern payloads of different HL7 FHIR versions without requiring version-specific rule variants. When future HL7 FHIR versions introduce additional structural changes to governed elements, this table SHALL be extended.

#### 3:PXX.1.1.4 Evidence Representation Across Versions

De-identification evidence is represented as HL7 FHIR R4 `Provenance` resources, which are part of the protocol layer. Evidence does not depend on the payload's HL7 FHIR version because:

- `Provenance.target` references de-identified output by resource URI or identifier, not by embedding the output resource. A URI reference to an HL7 FHIR R5 Patient is syntactically identical to a reference to an HL7 FHIR R4 Patient.
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

- **Resource-rooted path** -- a FHIRPath expression starting with a resource type (e.g., `Patient.name`, `Observation.value[x]`). The path identifies one or more elements within a single resource instance.
- **Semantic group reference** -- a reference to a named semantic group (e.g., `@subject-identifiers`). The `@` prefix distinguishes a semantic group reference from a FHIRPath expression. The group expands to its member paths at policy compilation time (see [§3:PXX.2.4](#3pxx24-policy-compilation)).

When a path targets an element with child elements (e.g., `Patient.name` which contains `HumanName.family`, `HumanName.given`, `HumanName.prefix`, `HumanName.suffix`, `HumanName.text`, `HumanName.period`), the action applies to the targeted element and all its children unless the execution plan specifies a more specific child path.

Choice-type elements use the `[x]` notation (e.g., `Observation.value[x]`). The De-Identifier SHALL apply the rule to whichever concrete type is present in the resource instance.

#### 3:PXX.1.2.2 Semantic Groups

Semantic groups categorize HL7 FHIR elements by privacy sensitivity. Semantic-Level policies reference semantic groups instead of individual element paths. The De-ID Manager expands semantic group references to individual element paths during policy compilation (see [§3:PXX.2.4](#3pxx24-policy-compilation)).

Table 3:PXX.1.2-1 defines the Phase 1 semantic groups for DIS-FHIR-Payload.

<p id="tPXX.1.2-1" class="tableTitle"><strong>Table 3:PXX.1.2-1: DIS-FHIR-Payload Semantic Groups</strong></p>

| Semantic Group | Description | Example Member Paths |
|----------------|-------------|----------------------|
| `subject-identifiers` | Direct identifiers of the data subject | `Patient.identifier`, `Patient.name`, `Patient.identifier.value`, `Patient.name.family`, `Patient.name.given` |
| `subject-business-identifiers` | Patient business identifiers used by baseline patient pseudonym derivation | `Patient.identifier` |
| `subject-names` | Patient names governed separately from business pseudonyms | `Patient.name` |
| `subject-demographics` | Demographic elements of the data subject | `Patient.birthDate`, `Patient.gender`, `Patient.address`, `Patient.telecom`, `Patient.photo`, `Patient.maritalStatus`, `Patient.communication`, `Patient.multipleBirth[x]`, `Patient.deceased[x]` |
| `contact-information` | Contact persons and their identifying elements | `Patient.contact.name`, `Patient.contact.telecom`, `Patient.contact.address`, `Patient.contact.organization`, `RelatedPerson.identifier`, `RelatedPerson.name`, `RelatedPerson.telecom`, `RelatedPerson.address`, `RelatedPerson.photo` |
| `provider-identifiers` | Identifiers and names of care providers | `Practitioner.identifier`, `Practitioner.name`, `Practitioner.telecom`, `Practitioner.address`, `Practitioner.photo`, `PractitionerRole.identifier` |
| `dates` | Date and time elements across governed resource types | `Patient.birthDate`, `Patient.deceased[x]` (when dateTime), `Encounter.period`, `Condition.onset[x]`, `Condition.abatement[x]`, `Procedure.performed[x]`, `Observation.effective[x]`, `MedicationRequest.authoredOn`, `DiagnosticReport.effective[x]`, `DocumentReference.date` |
| `narrative` | Resource narrative content | `DomainResource.text` (the `Narrative` element on any governed resource type) |
| `references` | Reference elements that could link to identifiable resources | `Observation.subject`, `Condition.subject`, `Encounter.subject`, `Procedure.subject`, `DiagnosticReport.subject`, `MedicationRequest.subject`, `Encounter.participant.individual` (HL7 FHIR R4) / `Encounter.participant.actor` (HL7 FHIR R5), `DocumentReference.subject`, `DocumentReference.author` |
| `device-identifiers` | Device identifiers and names | `Device.identifier`, `Device.serialNumber`, `Device.deviceName` (HL7 FHIR R4) / `Device.name` (HL7 FHIR R5), `Device.udiCarrier` |
{: .grid}

A semantic group MAY include elements from multiple resource types. Semantic group membership is defined by the content module and is not configurable by the policy. Policies select which groups to govern and which action to apply; they do not add or remove elements from a group.

Implementations MAY define additional semantic groups beyond those listed in Table 3:PXX.1.2-1 for local governance requirements. Additional groups SHALL NOT conflict with the element assignments of the Phase 1 groups.

<div markdown="1" class="stu-note">
**Editorial Note:** The semantic group definitions in Table 3:PXX.1.2-1 are illustrative. The formal CodeSystem and membership definitions will be provided when FSH conformance artifacts are finalized.
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
| `replace` | Fixed-value or reversible lookup-backed replacement | Fixed mode: `string`, `HumanName`, `Address`, `ContactPoint`, `Identifier`, `uri`; lookup mode: `Identifier`, `id`, `Reference`, namespaced direct-identifier strings | Yes | Fixed mode: `value`; lookup mode: `source: lookupTable` (mutually exclusive) |
| `keep` | Preserve the element unchanged in the de-identified output | Any element | Yes | None |
| `hash` | Replace the value with a cryptographic hash digest | `Identifier`, `HumanName`, `string`, `id`, `Reference` | Yes | Patient/resource derivation: `derivationMethod`, `scope`, `keyVersion`, `outputSystem`; other values: approved `algorithm` and optional `scope` |
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

With `parameters.source` set to `lookupTable`, `replace` performs reversible direct-identifier mapping using the job/task lookup table described in §3:PXX.1.7. This mode is mutually exclusive with a fixed `value`. It SHALL preserve identifier/reference consistency and SHALL NOT fall back to fixed replacement or hashing when an entry is absent. The following fixed-value behavior applies only when lookup mode is not selected.

The `replace` action replaces the targeted element's displayable content with the string specified by the `value` parameter. An empty string is permitted, producing an element that is present but contains no displayable content.

For `HumanName`, each sub-element (`family`, `given`, `text`) is replaced with the specified value. For `Address`, each sub-element (`text`, `line`, `city`, `district`, `state`, `postalCode`) is replaced with the specified value; `Address.country` is preserved. For `ContactPoint`, `ContactPoint.value` is replaced with the specified value; `ContactPoint.system` and `ContactPoint.use` are preserved.

##### keep

The `keep` action preserves the targeted element unchanged in the de-identified output. In first-match-wins evaluation, `keep` enables execution plans to express exceptions before general rules — for example, preserving a specific identifier before removing all identifiers:

```
R01: target Patient.identifier[mrn]    action keep
R02: target Patient.identifier         action remove
```

##### hash

The `hash` action replaces the targeted element's value with a cryptographic hash digest.

For patient pseudonymization with patient-and-scope-specific seed material, the baseline derivation contract in §3:PXX.1.3.3 applies instead of hashing local identifier values.

For other value-level hashing, when `scope` is present, the hash is keyed: the digest is computed using HMAC with the scope-derived seed material and the original value as inputs. Given the same scope and input value, the same digest SHALL be produced. This enables consistent hashing across resources within the same consistency scope.

When `scope` is absent, the hash is unkeyed: the digest is computed directly over the original value using the specified algorithm. The same input value always produces the same digest regardless of context.

The output is hex-encoded. Keyed hashing is not inverted to recover the input; authorized reversal uses retained mapping records. Unkeyed hashes of predictable identifiers may be matched by enumerating candidate values. Direct patient pseudonym generation SHALL use the keyed baseline contract below; unkeyed hashing SHALL NOT be used for that purpose.

For `HumanName` elements, the action replaces `family`, `given`, `prefix`, `suffix`, and `text` with hashed values. The `use` sub-element is preserved. The `period` sub-element is removed because a name-validity period can reveal the timing of legal name changes.

For `Identifier` elements, the action replaces `Identifier.value` with the hash digest. `Identifier.system` SHALL be replaced with a DIS pseudonym system URI (e.g., `urn:oid:dis-pseudonym:<scope>`) to prevent collision with real identifier systems. `Identifier.type`, `Identifier.use`, and `Identifier.period` are preserved. `Identifier.assigner` SHALL be removed because the referenced Organization could identify the data subject's care context.

For `Reference` elements, the action replaces the reference target with the hashed identifier of the referenced resource, when that resource is within the processing target set. References to resources outside the processing target set are governed by the `references` semantic group rules.

##### truncate-date

The `truncate-date` action reduces the precision of the targeted date value to the level specified by the `precision` parameter.

- `precision: year` — retain only the year (e.g., `1985-03-15` → `1985`)
- `precision: year-month` — retain year and month (e.g., `1985-03-15` → `1985-03`)

##### date-shift

The patient/resource pseudonym contracts below do not define date-shift derivation. Date shifting requires its separately declared, purpose-specific parameter/derivation capability; patient/resource pseudonym seeds SHALL NOT be repurposed for it. The `date-shift` action shifts the targeted date or time value by a per-patient offset. The offset is deterministically derived from the scope-derived seed material and the patient identifier, ensuring that all dates for the same patient within the same consistency scope are shifted by the same offset. The offset magnitude SHALL NOT exceed the `maxOffsetDays` parameter. The direction (forward or backward) is determined by the derivation.

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

The method identifier is `dis-patient-hmac-sha256-v1`. The Manager SHALL resolve the same patient within an authorized scope to consistent 32-byte secret seed material. Seeds SHALL be cryptographically generated or derived through a protected key-management arrangement; local patient identifiers alone SHALL NOT be seeds. Cross-job seed retention and regeneration follow Volume 1 §1:PXX.2.6. Cross-community identity resolution and coordination remain external deployment prerequisites.

The execution plan's patient `hash` rule SHALL declare `derivationMethod`, `scope`, `keyVersion` and `outputSystem`. The execution parameter `scope` SHALL be the exact validated policy `identity-linkage-scope` value; it is not an independently selectable scope. For the baseline method, all are non-empty strings and `derivationMethod` is `dis-patient-hmac-sha256-v1`. The task's protected seed material SHALL unambiguously associate each processing subject with its patient-and-scope-specific seed. This association is task-local and SHALL NOT be exposed in recipient-facing artifacts. The `seedMaterial` Binary binding in §3:PXX.1.3.4 supplies these task-local associations for single- and multi-patient tasks.

The De-Identifier SHALL compute HMAC-SHA-256 using the 32-byte patient seed as key and the UTF-8 bytes of the JSON array `["DIS-patient-pseudonym-v1", scope, keyVersion]` as message. Serialize the array without whitespace, escape quotation marks, backslashes and control characters as required by JSON, emit other Unicode characters directly, do not escape forward slashes, use \b/\t/\n/\f/\r for their corresponding controls and lowercase \u00xx escapes for other U+0000–U+001F controls, and perform no Unicode normalization. Unpaired surrogates SHALL be rejected. UTF-8 SHALL have no byte-order mark. The pseudonym is the complete 32-byte digest encoded as 64 lowercase hexadecimal characters, without truncation. `outputSystem` identifies the resulting pseudonym namespace and SHALL be consistent across participants claiming matching identifiers. Local patient IDs, resource IDs, element paths and worker identifiers SHALL NOT be added to this message. For patient business identifiers, Identifier.system SHALL be the declared outputSystem and Identifier.value SHALL be this digest; the generic value-level hash namespace rule does not override this baseline method.

For a synthetic test vector, seed bytes are hexadecimal `000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f`, scope is `job-example`, and keyVersion is `1`. The message is exactly `["DIS-patient-pseudonym-v1","job-example","1"]`; the expected pseudonym is `4b2fd4a29e41f8afe0be9565eda9f4709f00966bd9bd2f27a070ef8a8c40ab70`. These are public test values, never production secrets.

Different local identifiers resolved to the same patient therefore produce the same patient pseudonym when the seed, scope, keyVersion and method are identical. References SHALL be updated to the corresponding transformed resource IDs; the same patient pseudonym SHALL NOT be assigned indiscriminately to unrelated clinical-resource IDs. Resource-ID rewriting follows §3:PXX.1.3.5 and uses separate resource seeds; it does not reuse a patient pseudonym as every clinical resource ID. Unknown methods, ambiguous subject-to-seed associations or incompatible parameters SHALL fail the task. Detected pseudonym collisions between distinct resolved subjects SHALL fail the job without release; implementations SHALL NOT silently choose worker-specific suffixes. A key-version change defines a new derivation context and does not promise continuity with earlier pseudonyms.

#### 3:PXX.1.3.4 Task Subject and Seed Context

`seedMaterial` is an R4 `Binary` with `contentType` `application/json` and base64-encoded UTF-8 JSON conforming to [dis-seed-material.schema.json](schemas/dis-seed-material.schema.json). Its fields are:

| Field | Meaning |
|---|---|
| `version` | Binding version, `1`. |
| `identity-linkage-scope`, `keyVersion` | Exact validated scope and execution-plan key version. |
| `subjects` | Entries with a task-local `subjectId` and, when patient derivation is required, a base64 `patientSeed` decoding to exactly 32 bytes. |
| `resources` | Original resource identity bindings: `source`, `aliases`, `resourceType`, `subjectId`, `sourceSystem`, `sourceId` and, when resource derivation is required, base64 `resourceSeed` decoding to exactly 32 bytes. |

`subjectId` is a task-local opaque association token, not a patient pseudonym. It SHALL be unique within the context. Every resource's subjectId SHALL resolve to one entry. The Manager establishes subject associations through authorized identity resolution; the De-Identifier SHALL NOT infer that two different tokens identify the same patient. Each source and alias SHALL resolve unambiguously to one resource. `sourceSystem` identifies the resource-type namespace (for example, `https://source.example/fhir/Patient`) and `sourceId` is the original id; `source` is its absolute identity or Bundle fullUrl. Aliases explicitly list other accepted forms such as `Patient/p1` or a Bundle URN. Missing, ambiguous or conflicting bindings SHALL fail processing. Resources lacking an approved subject association require an explicit separate plan; they SHALL NOT be silently assigned a patient's seed.

Seed strings SHALL use canonical padded base64 and decode to 32 bytes. Distinct resolved patients SHALL NOT be assigned the same patient seed in a scope; distinct resource identities SHALL NOT share a resource seed. Patient and resource seeds SHALL be purpose-separated. The Manager controls consistent regeneration or protected reuse across tasks according to the authorized scope and lifecycle; independent worker randomness SHALL NOT replace assigned seeds. The context may omit seed fields for lookup-only tasks, but subject and resource associations remain required for lookup-backed resource rewriting. It SHALL contain only associations required by the task, remain protected and be deleted by the De-Identifier at task termination. This carrier SHALL NOT include patient names or identifying attributes as substitute seeds.

#### 3:PXX.1.3.5 Resource Identity and Reference Rewriting

For Manager-managed resource-ID derivation, an approved `hash` rule targeting resource `id` SHALL declare `derivationMethod: dis-resource-hmac-sha256-v1`, `scope`, `keyVersion` and `outputSystem`. The De-Identifier SHALL use the assigned resourceSeed as HMAC-SHA-256 key and the UTF-8 JSON array `["DIS-resource-id-v1", scope, keyVersion]` as message, with the serialization rules of §3:PXX.1.3.3. The output id is the full lowercase 64-character digest, distinct from patient business-identifier pseudonyms. `outputSystem` is an absolute output FHIR base URL without a trailing slash; the resulting resource URI is `outputSystem/resourceType/outputId`. Both methods require exact agreement with context scope/keyVersion. A method applied to the wrong target (patient method to a clinical resource id, for example) SHALL fail validation.

For supplied tables, approved resource-id `replace` rules SHALL provide `source: lookupTable` and `sourceSystem` equal to the resource's context namespace. The table's `resource-id` entry supplies the new id and target namespace; the namespace SHALL end in the unchanged resourceType and the id SHALL satisfy FHIR id syntax. Business-identifier entries are not resource-id entries and SHALL NOT be used to rewrite resource IDs.

Before mutation, resolve references against the original source/alias graph. The De-Identifier SHALL build a complete old-to-new resource identity map and apply it to resource `id`, Bundle entry `fullUrl`, and all governed internal Reference.reference values, including references to resources transformed in other assigned stages. Internal references SHALL become the mapped absolute target URI, not a hash of the reference text. Reference.display containing source identity SHALL be removed; Reference.identifier is processed by its own approved identifier rule. Graph fixup is a required consequence of approved identity transformations, even when a reference path has a `keep` rule; it does not authorize transforming additional identifiers. Unsupported external, version-specific or contained references SHALL be handled by an explicit approved rule or fail the job; they SHALL NOT be silently guessed or left dangling. If the target map is incomplete, the Manager SHALL schedule a combined task or supply an approved lookup-backed map; successful earlier tasks alone do not authorize partial release.

Validate the entire output graph before release, including references from retained resources, unique output resource identities and format constraints. If multiple local identifiers for one patient share a business pseudonym, the Patient resource remains one resource with its own id. Distinct clinical resources SHALL retain distinct output identities. Collisions, missing mappings or inconsistent aliases SHALL fail the job without partial output.

For a reversible Manager-managed job, ITI-x3 (or ITI-x7 on completion) SHALL return a protected `mappingReport` Binary to the Manager alongside the task result. It contains version `1`, `subjects` with subjectId/system/value for generated patient pseudonyms, and `resources` with source/subjectId/target for rewritten resources. The Manager SHALL bind these task-local tokens to its authorized identity records and persist the reverse mapping before releasing the job. This report is protected operational material, not Provenance evidence, and SHALL NOT be forwarded in ITI-x1/ITI-x4 output, manifests, logs or recipient evidence. No report SHALL be returned for irreversible jobs. Supplied-table jobs do not require a generated report; the supplied table remains authoritative. The schema is [dis-mapping-report.schema.json](schemas/dis-mapping-report.schema.json).

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

The execution plan JSON contains `planVersion`, `payloadBinding`, `payloadVersion` and an ordered `rules` array. Each rule specifies a target, an action, and action-specific parameters.

Table 3:PXX.1.4-2 lists the elements of each rule in the execution plan.

<p id="tPXX.1.4-2" class="tableTitle"><strong>Table 3:PXX.1.4-2: Execution Plan Rule Elements</strong></p>

| Element | Cardinality | Type | Description |
|---------|-------------|------|-------------|
| `ruleId` | 1..1 | string | Unique identifier for the rule within the plan |
| `target` | 1..1 | string | FHIRPath expression identifying the target element(s). Semantic group references (`@`) SHALL have been expanded during compilation; they SHALL NOT appear in dispatched execution plans. |
| `action` | 1..1 | code | Action code from the core action family (see [§3:PXX.1.3](#3pxx13-transformation-actions)) |
| `parameters` | 0..1 | object | Action-specific parameters as key-value pairs |
{: .grid}

Rules are evaluated in order. When multiple rules match the same element, the first matching rule applies and subsequent matching rules are skipped. This first-match-wins evaluation enables execution plans to specify exceptions before general rules (e.g., keep a specific identifier before removing all identifiers).

Execution plans dispatched via ITI-x3 SHALL contain only concrete element paths. Semantic group references (`@` prefix) SHALL have been expanded by the De-ID Manager during policy compilation. The presence of an unresolved `@` reference in a dispatched execution plan is a conformance error.

#### 3:PXX.1.4.3 Execution Plan Example

The decoded execution plan below illustrates a single-ruleSet plan for Use Case 3 (Clinical Pathology Order). It derives patient business pseudonyms, removes names, address and telecom, shifts the birth date and redacts narrative content. Semantic group references have been expanded to concrete element paths. Reference `keep` rules still follow the [resource identity and reference rewriting requirements](#3pxx135-resource-identity-and-reference-rewriting). The [evidence example](Provenance-dis-evidence-uc3-001.html) shows how the task reports selected applied rules.

```json
{
  "planVersion": "1.0",
  "payloadBinding": "DIS-FHIR-Payload",
  "payloadVersion": "R4",
  "rules": [
    {
      "ruleId": "R01",
      "target": "Patient.identifier",
      "action": "hash",
      "parameters": {
        "derivationMethod": "dis-patient-hmac-sha256-v1",
        "scope": "hospital-lab-project-2026",
        "keyVersion": "1",
        "outputSystem": "urn:example:subject"
      }
    },
    {
      "ruleId": "R02",
      "target": "Patient.name",
      "action": "remove"
    },
    {
      "ruleId": "R03",
      "target": "Patient.address",
      "action": "remove"
    },
    {
      "ruleId": "R04",
      "target": "Patient.telecom",
      "action": "remove"
    },
    {
      "ruleId": "R05",
      "target": "Patient.birthDate",
      "action": "date-shift",
      "parameters": {
        "scope": "${identity-linkage-scope}",
        "maxOffsetDays": 30
      }
    },
    {
      "ruleId": "R06",
      "target": "Patient.photo",
      "action": "remove"
    },
    {
      "ruleId": "R07",
      "target": "Patient.text",
      "action": "redact"
    },
    {
      "ruleId": "R08",
      "target": "Observation.text",
      "action": "redact"
    },
    {
      "ruleId": "R09",
      "target": "Observation.subject",
      "action": "keep"
    },
    {
      "ruleId": "R10",
      "target": "DiagnosticReport.subject",
      "action": "keep"
    }
  ]
}
```

<div markdown="1" class="stu-note">
**Editorial Note:** The execution plan JSON structure shown above is illustrative. The formal JSON Schema will be provided when FSH conformance artifacts are finalized.
</div>

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

### 3:PXX.1.6 Data-Plane Access

This section defines how DIS-FHIR-Payload processing targets are retrieved by the De-Identifier and how de-identified output is returned. Three delivery modes are supported: by-reference, by-value, and by-manifest.

#### 3:PXX.1.6.1 By-Reference

In by-reference delivery mode, the processing target is identified by an HL7 FHIR reference (e.g., `Patient/123`) and an optional source base URL. The De-Identifier retrieves the resource from the source HL7 FHIR server using HL7 FHIR REST read interactions.

The De-Identifier SHALL present authorization credentials when retrieving resources from the source server. The De-ID Manager provides the necessary authorization context in the ITI-x3 task dispatch.

De-identified output in by-reference mode MAY be:
- Returned inline in the ITI-x3 response (synchronous mode) as HL7 FHIR R4 resources (for HL7 FHIR R4 payloads) or as attachments (for cross-version payloads)
- Persisted to an output HL7 FHIR server designated by the De-ID Manager, with output references returned in the response

#### 3:PXX.1.6.2 By-Value

In by-value delivery mode, the processing target resource content is embedded directly in the ITI-x1 request `Parameters` resource. This mode is typical for synchronous single-patient workflows where the data volume is small.

For HL7 FHIR R4 payloads, by-value resources are carried as native HL7 FHIR R4 resources within the `Parameters` envelope. For HL7 FHIR R5 or R6 payloads, by-value resources SHALL be carried as attachments using the inline attachment packaging pattern defined in [§3:PXX.1.1.2](#3pxx112-version-safe-packaging).

De-identified output in by-value mode is returned inline in the response using the same packaging pattern as the input.

#### 3:PXX.1.6.3 By-Manifest

In by-manifest delivery mode, the processing target is identified by a URI referencing an NDJSON manifest. This mode is used for bulk data cohort jobs.

The manifest follows the conventions of the [HL7 Bulk Data Access IG](https://hl7.org/fhir/uv/bulkdata/). Each line of a referenced NDJSON file contains a complete serialized HL7 FHIR resource in the declared payload version.

The De-Identifier SHALL present authorization credentials when retrieving manifest files and NDJSON data files. File retrieval SHALL use TLS.

De-identified output in by-manifest mode is returned as a manifest referencing de-identified NDJSON output files together with evidence references. Recipient-facing manifests and files SHALL NOT contain seeds or other protected transformation material. A failed job SHALL NOT release a partial dataset; failures SHALL be reported through job status.

Table 3:PXX.1.6-1 summarizes the delivery modes and their characteristics.

<p id="tPXX.1.6-1" class="tableTitle"><strong>Table 3:PXX.1.6-1: DIS-FHIR-Payload Delivery Modes</strong></p>

| Delivery Mode | Input Mechanism | Typical Use | Output Mechanism |
|---------------|-----------------|-------------|------------------|
| By-reference | HL7 FHIR reference + source base URL | Source data on an HL7 FHIR server | Inline in response or persisted to output server |
| By-value | Resource embedded in `Parameters` (native or attachment) | Synchronous single-patient, small data volume | Inline in response |
| By-manifest | URI referencing NDJSON manifest | Bulk data cohort jobs | Manifest referencing de-identified NDJSON files |
{: .grid}

### 3:PXX.1.7 Reversible Lookup Table

The optional ITI-x1 and ITI-x3 `lookupTable` parameter is a `Reference(DocumentReference)` targeting [DIS-LookupTable](StructureDefinition-DIS-LookupTable.html), a persistent identified R4 document reference. It describes protected JSON mapping content, supplied inline in its attachment or through an authorized retrieval of [DIS-LookupTableContent](StructureDefinition-DIS-LookupTableContent.html) Binary. The table is operational input, not recipient-facing evidence. Managers and Integrated actors declaring DIS-REVERSIBLE SHALL support both supplied and Manager-managed mappings.

| DocumentReference element | DIS requirement |
|---|---|
| `identifier` | One or more stable business identifiers. At least one value SHALL equal the decoded JSON tableId, with an explicitly declared identifier system. |
| `masterIdentifier` | Required system/value identifying this exact immutable content version, distinct from a server's resource id or meta.versionId. Any change to JSON bytes SHALL receive a new masterIdentifier. |
| `status` | `current` when selected for a new job. A superseded or entered-in-error document SHALL NOT be admitted as a new supplied table. |
| `type` | DIS document-type code `lookup-table`. |
| `extension[dis-identity-linkage-scope]` | Required non-secret scope, exactly matching both the approved policy and decoded JSON scope. |
| `content` | Exactly one attachment with contentType `application/json` and exactly one of inline base64 data or a protected Binary URL. Both delivery forms SHALL be supported. |

A literal reference may identify `DocumentReference/id` or a version-specific history URL on an authorized repository. Reference.identifier may be used only if the deployment can resolve it unambiguously to one exact document/content version; ambiguous or unresolvable identifiers SHALL be rejected. Identifier resolution, repository provisioning and table lifecycle administration remain deployment concerns; DIS adds no table-management transaction.

A task-scoped derivative has its own business identifier and `masterIdentifier`, retains the authorized scope, and links to the pinned source through `relatesTo` with code `transforms`. Its business identifier matches the derivative JSON `tableId`.

[ITI-x1](volume-2.html#23x1-submit-de-identification-job-iti-x1) defines admission, authorization and content pinning. [ITI-x3](volume-2.html#23x3-submit-de-identification-task-iti-x3) defines restricted dispatch, task validation and cleanup. Manager-managed reversible tables may use the same representation. Metadata identifiers and lookup URLs SHALL be excluded from recipient-facing output and logs where they would expose or grant access to protected mapping material.

The JSON contains `tableId` (non-empty string), `version` (JSON format version `1`, not the document content-version identifier), `identity-linkage-scope` (the exact approved scope), and `entries` (non-empty array). Each entry contains `sourceSystem`, `sourceValue`, `targetSystem`, and `targetValue`, all non-empty strings. Keys are exact, case-sensitive `(sourceSystem, sourceValue)` pairs. Each entry additionally requires `subjectId` and `kind` (`identifier`, `resource-id`, or `value`). Matching keys are exact `(kind, sourceSystem, sourceValue)` triples and SHALL be unique. A repeated `(kind, targetSystem, targetValue)` is permitted for different identifiers belonging to the same subjectId, but SHALL be rejected when it links different subjectIds. Resource-id targets SHALL be unique even within one subject. SubjectIds SHALL match the task context. Multiple identifiers may resolve to one patient pseudonym; authorized reversal may return that subject's set of source identifiers rather than pretend there is one original value. Source systems identify the identifier namespace, including a declared namespace for resource IDs; a bare value alone is insufficient. Values SHALL NOT be normalized implicitly.

The [worked mapping examples](#3pxx18-worked-mapping-examples) use the same lookup table in two forms. To inspect the decoded JSON, Base64-decode `Binary.data` in the [Binary example](Binary-lookup-content-example.html) or `content.attachment.data` in the [inline DocumentReference example](DocumentReference-lookup-inline-example.html). The table shows two source identifiers for one subject mapping to the same business pseudonym, alongside separate resource ID mappings.

The validated reversible policy uses `replace` with `parameters: {"source": "lookupTable"}` for direct identifiers. `Identifier` mappings replace both `system` and `value`; resource IDs and References use the same assigned target identity consistently. Type and reference-integrity validation SHALL precede release. Each approved lookup-backed rule requires an applicable entry. [ITI-x1](volume-2.html#23x1-submit-de-identification-job-iti-x1) defines how the Manager handles missing entries or policy and table incompatibility. The supplied table does not authorize changing a `hash` or fixed-value rule to lookup-backed `replace`. Hashing remains available for Manager-managed derivation; it SHALL NOT override supplied direct-identifier mappings.

The Manager SHALL verify authorization to use the supplied table for the job's purpose and scope. Only entries needed for an assigned task may be carried to its De-Identifier. Tables SHALL be protected in transit and at rest, excluded from recipient-facing artifacts and logs, and deleted from temporary processing storage at termination. The Requester may retain its original table; Manager persistence of supplied mappings is not mandatory. Without a supplied table, the Manager SHALL create or maintain and persist an equivalent mapping for authorized reversal. In standalone Integrated processing, locally supplied tables follow the same rules.

The structural contract is [dis-lookup-table.schema.json](schemas/dis-lookup-table.schema.json). Schema validation does not establish authorization, coverage or graph consistency; the semantic checks above are also mandatory. `Identifier` matching uses its original system/value and kind `identifier`. Lookup-backed strings require an explicit policy `sourceSystem` and kind `value`; implicit name matching and normalization are not supported. Resource IDs use kind `resource-id`. Unsupported targets SHALL be rejected rather than inferred.

### 3:PXX.1.8 Worked Mapping Examples

These synthetic, informative FHIR R4 examples accompany the [lookup table binding](#3pxx17-reversible-lookup-table). They also appear in the [artifact index](artifacts.html) and the [FHIR example downloads](download.html).

| Published example | What it shows |
|---|---|
| [Lookup table with Binary content](DocumentReference-lookup-document-example.html) | A persistent DocumentReference with a business identifier, a content version identifier, and a reference to the JSON attachment. |
| [Lookup table JSON content](Binary-lookup-content-example.html) | The Binary carrying the lookup table JSON for the DocumentReference above. |
| [Lookup table with inline content](DocumentReference-lookup-inline-example.html) | The same lookup table content carried directly in a DocumentReference attachment. |
| [Task-scoped lookup table](DocumentReference-lookup-task-s1.html) | A derived table restricted to one subject, with its own identifiers and a `transforms` relationship to the version of the source DocumentReference. |
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

The policy rules JSON carried in `Library.content` defines de-identification rules at one of two representation levels:

- **Semantic-Level** — rules use semantic group references (prefixed with `@`) and action codes. The policy is format-neutral and requires compilation into a payload-specific execution plan before dispatch. This is the default representation for reusable, cross-format policies.
- **Syntax-Level** — rules use concrete element paths (e.g., FHIRPath expressions for HL7 FHIR, DICOM tag paths for DICOM) and action codes. The policy is specific to a payload family and version, and is directly executable after validation. A Syntax-Level policy requires `payloadFamily` and `payloadVersion` declarations.

Both levels use the same JSON structure, delivery modes, and four-point validation. The `@` prefix on rule targets is the syntactic marker distinguishing Semantic-Level from Syntax-Level rules. A De-Identifier SHALL never receive rules containing unresolved `@` references — that would indicate a compilation failure.

Table 3:PXX.2.2-1 lists the top-level elements of the policy rules JSON.

<p id="tPXX.2.2-1" class="tableTitle"><strong>Table 3:PXX.2.2-1: Policy Rules JSON — Top-Level Elements</strong></p>

| Element | Cardinality | Type | Description |
|---------|-------------|------|-------------|
| `policyVersion` | 1..1 | string | Version of the policy rules schema |
| `representationLevel` | 1..1 | code | `semantic` or `syntax` |
| `reversibilityMode` | 1..1 | code | `irreversible` or `reversible` |
| `identity-linkage-scope` | 0..1 | string | Non-secret identifier of the authorized job, institutional or cross-community linkage scope; not a patient identifier, key or seed. Required when consistent patient pseudonyms are requested. |
| `payloadFamily` | 0..1 | string | Required when `representationLevel` is `syntax`. Payload family (e.g., `fhir`, `dicom`) |
| `payloadVersion` | 0..1 | string | Required when `representationLevel` is `syntax`. Payload version (e.g., `R4`, `R5`) |
| `ruleSets` | 1..* | array | Named groups of de-identification rules |
| `stages` | 0..* | array | Optional ordered list of execution stages referencing ruleSet IDs |
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

Syntax-Level policy rules use concrete element paths appropriate to the declared `payloadFamily`. For HL7 FHIR payloads, these are FHIRPath expressions (e.g., `Patient.identifier`, `Patient.name`). For future DICOM payloads, these would be DICOM tag paths. The De-ID Manager validates that all rule targets are valid paths for the declared payload family and version.

Rules within a ruleSet are evaluated in order; first-match-wins evaluation applies, consistent with execution plan evaluation (see [§3:PXX.1.4.2](#3pxx142-execution-plan-json-structure)).

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

The following decoded Semantic-Level policy illustrates a single-ruleSet pseudonymization policy for Use Case 3 (Clinical Pathology Order). The [execution plan example](#3pxx143-execution-plan-example) illustrates concrete element paths for the same use case.

```json
{
  "policyVersion": "1.0",
  "representationLevel": "semantic",
  "reversibilityMode": "reversible",
  "identity-linkage-scope": "hospital-lab-project-2026",
  "ruleSets": [
    {
      "ruleSetId": "direct-identifiers",
      "description": "Pseudonymize direct identifiers for external lab order",
      "rules": [
        {
          "ruleId": "P01",
          "target": "@subject-business-identifiers",
          "action": "hash",
          "parameters": {
            "derivationMethod": "dis-patient-hmac-sha256-v1",
            "scope": "hospital-lab-project-2026",
            "keyVersion": "1",
            "outputSystem": "urn:example:subject"
          }
        },
        {
          "ruleId": "P01N",
          "target": "@subject-names",
          "action": "remove"
        },
        {
          "ruleId": "P02",
          "target": "@subject-demographics",
          "action": "remove"
        },
        {
          "ruleId": "P03",
          "target": "@dates",
          "action": "date-shift",
          "parameters": {
            "maxOffsetDays": 30
          }
        },
        {
          "ruleId": "P04",
          "target": "@contact-information",
          "action": "remove"
        },
        {
          "ruleId": "P05",
          "target": "@narrative",
          "action": "redact"
        },
        {
          "ruleId": "P06",
          "target": "@references",
          "action": "keep"
        }
      ]
    }
  ]
}
```

The following Semantic-Level policy illustrates Use Case 1 (Cross-Border Epidemiological Study) with two ruleSets organized into two stages. The preliminary stage hashes direct identifiers to scoped pseudonyms; the advanced stage applies record-level removal, rounding, and truncation of quasi-identifiers.

```json
{
  "policyVersion": "1.0",
  "representationLevel": "semantic",
  "reversibilityMode": "irreversible",
  "identity-linkage-scope": "epi-study-2026-cohort-a",
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
            "derivationMethod": "dis-patient-hmac-sha256-v1",
            "scope": "epi-study-2026-cohort-a",
            "keyVersion": "1",
            "outputSystem": "urn:example:subject"
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
      "description": "Record-level removal and truncation of quasi-identifiers",
      "rules": [
        {
          "ruleId": "A01",
          "target": "@dates",
          "action": "truncate-date",
          "parameters": {
            "precision": "year"
          }
        },
        {
          "ruleId": "A02",
          "target": "@subject-demographics",
          "action": "truncate",
          "parameters": {
            "length": 3
          }
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

The following Syntax-Level policy illustrates the same Use Case 3 pseudonymization, authored with concrete FHIRPath targets for HL7 FHIR R4.

```json
{
  "policyVersion": "1.0",
  "representationLevel": "syntax",
  "payloadFamily": "fhir",
  "payloadVersion": "R4",
  "reversibilityMode": "reversible",
  "identity-linkage-scope": "hospital-lab-project-2026",
  "ruleSets": [
    {
      "ruleSetId": "direct-identifiers",
      "description": "Pseudonymize direct identifiers for external lab order",
      "rules": [
        {
          "ruleId": "P01",
          "target": "Patient.identifier",
          "action": "hash",
          "parameters": {
            "derivationMethod": "dis-patient-hmac-sha256-v1",
            "scope": "hospital-lab-project-2026",
            "keyVersion": "1",
            "outputSystem": "urn:example:subject"
          }
        },
        {
          "ruleId": "P02",
          "target": "Patient.name",
          "action": "remove"
        },
        {
          "ruleId": "P03",
          "target": "Patient.address",
          "action": "remove"
        },
        {
          "ruleId": "P04",
          "target": "Patient.telecom",
          "action": "remove"
        },
        {
          "ruleId": "P05",
          "target": "Patient.birthDate",
          "action": "date-shift",
          "parameters": {
            "maxOffsetDays": 30
          }
        },
        {
          "ruleId": "P06",
          "target": "Patient.photo",
          "action": "remove"
        },
        {
          "ruleId": "P07",
          "target": "Patient.text",
          "action": "redact"
        },
        {
          "ruleId": "P08",
          "target": "Observation.subject",
          "action": "keep"
        }
      ]
    }
  ]
}
```

<div markdown="1" class="stu-note">
**Editorial Note:** The policy rules JSON structure shown above is illustrative. The formal JSON Schema will be provided when FSH conformance artifacts are finalized.
</div>

### 3:PXX.2.3 Policy Delivery and Validation

A de-identification policy is a reusable knowledge artifact. The same policy may be approved for multiple independent data requests. The ITI-x1 `policy` parameter always declares the approved policy by canonical URL (`policy.url`) and version (`policy.version`). The `authorization` parameter provides evidence that the data request — including approval of that specific policy — was authorized by the data governance authority. The De-ID Manager validates that the declared policy matches the policy approved in the authorization.

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
3. **Schema** — verify the Library conforms to the DIS-Policy Library profile and the policy rules JSON conforms to the policy rules schema.
4. **Currency** — verify the current date falls within `Library.effectivePeriod` and that the policy has not been revoked. Revocation checking uses the deployment's implementation-defined policy trust and lifecycle mechanisms.

### 3:PXX.2.4 Policy Compilation

The De-ID Manager processes a validated policy Library before dispatching tasks via ITI-x3. The processing depends on the policy's representation level.

#### 3:PXX.2.4.1 Semantic-Level Compilation

When the policy's `representationLevel` is `semantic`, the De-ID Manager compiles each ruleSet into a payload-specific execution plan Library. The compilation process performs the following steps for each ruleSet:

1. **Semantic group expansion** — each `@` semantic group reference in the ruleSet's rules is expanded to the individual element paths defined by the applicable payload binding's semantic groups (see [§3:PXX.1.2.2](#3pxx122-semantic-groups) for DIS-FHIR-Payload groups).

2. **Version-conditional path mapping** — for HL7 FHIR R5 or R6 payloads, the De-ID Manager applies the version-conditional path mappings defined in [Table 3:PXX.1.1-3](#3pxx113-version-neutral-element-addressing) to the expanded element paths.

3. **Execution plan assembly** — the expanded and version-resolved rules are assembled into an execution plan JSON (see [§3:PXX.1.4.2](#3pxx142-execution-plan-json-structure)) and packaged in a Library resource with `Library.type` coding `dis-execution-plan`.

4. **Capability verification** — the De-ID Manager verifies that the target De-Identifier's declared capabilities support all action codes and the payload binding and version required by the execution plan. The Manager SHALL NOT dispatch a task with an incompatible execution plan.

Each ruleSet in the policy produces one execution plan Library, dispatched as one ITI-x3 task. When stages are declared, the Manager dispatches in stage order. The compiled execution plan Library MAY reference the source policy Library via `Library.relatedArtifact` with type `derived-from`.

#### 3:PXX.2.4.2 Syntax-Level Validation

When the policy's `representationLevel` is `syntax`, the De-ID Manager validates the rules and packages them as execution plan Libraries without semantic group expansion or version-conditional path mapping. The validation process performs the following steps for each ruleSet:

1. **Path validation** — the De-ID Manager verifies that all rule targets are valid element paths for the declared `payloadFamily` and `payloadVersion`. For HL7 FHIR payloads, this means each target is a valid FHIRPath expression for the declared HL7 FHIR version.

2. **Consistency check** — the De-ID Manager verifies that the policy's declared `payloadFamily` and `payloadVersion` are consistent with the `payloadBinding` and `payloadVersion` in the ITI-x1 request.

3. **Execution plan assembly** — the validated rules are packaged in a Library resource with `Library.type` coding `dis-execution-plan`. No semantic group expansion is performed; rule targets are already concrete paths.

4. **Capability verification** — same as for Semantic-Level compilation.

### 3:PXX.2.5 Policy Lifecycle

The DIS-Policy content module defines the artifact structure and validation requirements. Phase 1 does not standardize policy lifecycle management (authoring, approval, distribution, revocation, versioning workflows). Implementations obtain policies through implementation-defined mechanisms, including local configuration, administrative provisioning, bilateral agreement, or integration with an external policy management system.

The following lifecycle states are supported through `Library.status`:

- `draft` — the policy is under development and SHALL NOT be accepted by the De-ID Manager for job execution
- `active` — the policy is approved and valid for use within its `effectivePeriod`
- `retired` — the policy is no longer valid and SHALL NOT be accepted for new jobs

The De-ID Manager SHALL reject a policy with `Library.status` other than `active`. The De-ID Manager SHALL reject a policy whose `Library.effectivePeriod` does not include the current date.

<div markdown="1" class="stu-note">
**Editorial Note:** A future phase may introduce a standardized policy management transaction (e.g., ITI-x8) for policy discovery, retrieval, and lifecycle management. Phase 1 relies on implementation-defined mechanisms.
</div>
