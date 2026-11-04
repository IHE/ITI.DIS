
This section defines the DIS-FHIR-Payload content module.

<a name="fhir-payload-content-module"> </a>

## 3:5.9 DIS-FHIR-Payload Content Module

The DIS-FHIR-Payload content module defines format-specific rules for de-identification of HL7 FHIR processing payloads within the DIS workflow. It specifies how HL7 FHIR data elements are identified and addressed, how DIS transformation actions are realized for HL7 FHIR datatypes, how payloads are carried within and retrieved from the HL7 FHIR R4 protocol envelope, and how de-identification evidence is represented using HL7 FHIR Provenance.

DIS-FHIR-Payload is independent of the DIS HL7 FHIR R4 protocol binding version. It supports processing payloads in HL7 FHIR R4, R5, and R6 without requiring a corresponding version of the protocol binding. This independence is achieved through version identification, version-safe packaging, and version-neutral element addressing.

<a name="cross-version-payload"> </a>

### 3:5.9.1 Cross-Version Payload Support

This section specifies how DIS-FHIR-Payload enables de-identification of HL7 FHIR payloads whose version differs from the HL7 FHIR R4 protocol binding.

#### 3:5.9.1.1 Version Identification

Each processing payload SHALL explicitly declare its HL7 FHIR version. The version declaration enables the De-ID Manager to verify De-Identifier compatibility before task dispatch and ensures that de-identified output is validated against the correct HL7 FHIR version.

A De-Identifier declaring DIS-FHIR-Payload SHALL advertise the HL7 FHIR payload versions it supports in its capability declaration. The De-ID Manager SHALL verify that the processing payload's declared version is included in the assigned De-Identifier's supported versions before dispatching a task via ITI-x3. The De-ID Manager SHALL reject a job when no available De-Identifier supports the payload's declared HL7 FHIR version.

Table 3:5.9.1-1 lists the mechanisms for declaring the payload version.

<p id="t3.5.9.1-1" class="tableTitle"><strong>Table 3:5.9.1-1: Payload Version Declaration Mechanisms</strong></p>

| Mechanism | Context | Example |
|-----------|---------|---------|
| Processing target `fhirVersion` field | ITI-x1 job submission and ITI-x3 task dispatch | `{ "family": "fhir", "fhirVersion": "5.0.0", "reference": "Patient/123" }` |
| Content type parameter | Inline attachment | `application/fhir+json; fhirVersion=5.0.0` |
| Source server capability | By-reference retrieval | De-Identifier reads `CapabilityStatement.fhirVersion` from the source HL7 FHIR server |
| Manifest metadata | Bulk Data | Manifest declares the HL7 FHIR version of referenced NDJSON files |
{: .grid}

When a processing target omits an explicit version declaration, the De-ID Manager SHALL treat the payload as the same version as the protocol binding (HL7 FHIR R4). Explicit declaration is REQUIRED for HL7 FHIR R5 and R6 payloads.

#### 3:5.9.1.2 Version-Safe Packaging

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
    "coding": [{
      "system": "https://dis.ihe.net/CodeSystem/task-input",
      "code": "processingTarget"
    }]
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

Table 3:5.9.1-2 lists the resources that are part of the HL7 FHIR R4 protocol layer and remain HL7 FHIR R4 regardless of the payload version.

<p id="t3.5.9.1-2" class="tableTitle"><strong>Table 3:5.9.1-2: HL7 FHIR R4 Protocol Resources</strong></p>

| HL7 FHIR R4 Protocol Resource | Role |
|-------------------------------|------|
| `Parameters` | ITI-x1 job request and response envelope |
| `Task` | ITI-x3 task dispatch and status |
| `Provenance` | De-identification evidence |
| `OperationOutcome` | Error and validation reporting |
| `Bundle` | Workflow packaging (message, result collection) |
| `Library` | Execution plan carrier |
| `CapabilityStatement` | Actor capability declaration |
{: .grid}

#### 3:5.9.1.3 Version-Neutral Element Addressing

DIS-FHIR-Payload uses FHIRPath-compatible path expressions to address data elements within the processing payload (see [§1:PXX.2.3](volume-1.html#1pxx23-hl7-fhir-payload-option)). The path expressions used by DIS execution plans, semantic group mappings, and Provenance transformation summaries are version-neutral: they resolve consistently across HL7 FHIR R4, R5, and R6 for the resource types and elements governed by DIS transformation actions.

Most governed element paths are stable across HL7 FHIR R4, R5, and R6:

- `Patient` direct-identifier and demographic elements (`Patient.name`, `Patient.identifier`, `Patient.birthDate`, `Patient.address`, `Patient.telecom`, `Patient.photo`, `Patient.gender`, `Patient.maritalStatus`) retain identical paths across all three versions.
- HL7 FHIR datatypes used by DIS transformation actions (`HumanName`, `Identifier`, `Address`, `ContactPoint`, `Narrative`, `date`, `dateTime`, `instant`, `Period`, `Quantity`) have stable structures across these versions.
- DIS semantic groups for subject identifiers, demographics, contact information, references, and narrative map to stable paths.
- Resource types commonly governed by DIS (`Patient`, `Practitioner`, `Encounter`, `Condition`, `Observation`, `DiagnosticReport`, `Procedure`, `MedicationRequest`, `DocumentReference`, `ImagingStudy`) exist in all three versions.

However, several governed elements were renamed between HL7 FHIR R4 and R5. The De-ID Manager SHALL apply version-conditional path mappings for these elements when compiling execution plans for HL7 FHIR R5 or R6 payloads.

<p id="t3.5.9.1-3" class="tableTitle"><strong>Table 3:5.9.1-3: Version-Conditional Path Mappings (HL7 FHIR R4 to R5)</strong></p>

| Semantic Group | HL7 FHIR R4 Path | HL7 FHIR R5 Path | Affected Element |
|----------------|-------------------|-------------------|-----------------|
| `subject.dates` | `Encounter.period` | `Encounter.actualPeriod` | Encounter date/time |
| `subject.dates` | `Procedure.performed[x]` | `Procedure.occurrence[x]` | Procedure date/time (all choice types: dateTime, Period, string, Age, Range) |
| `provider.name` | `Encounter.participant.individual` | `Encounter.participant.actor` | Encounter participant reference |
| `device-identifiers` | `Device.deviceName` | `Device.name` | Device name |
{: .grid}

The De-ID Manager SHALL resolve these mappings at execution plan compilation time based on the declared payload version. A single governance policy using semantic groups remains version-neutral; the version-conditional mapping is applied during compilation, not by the De-Identifier. The De-Identifier receives resolved paths appropriate for the payload version.

For elements not listed in Table 3:5.9.1-3, a single execution plan can govern payloads of different HL7 FHIR versions without requiring version-specific rule variants. When future HL7 FHIR versions introduce additional structural changes to governed elements, this table SHALL be extended.

#### 3:5.9.1.4 Evidence Representation Across Versions

De-identification evidence is represented as HL7 FHIR R4 `Provenance` resources, which are part of the protocol layer. Evidence does not depend on the payload's HL7 FHIR version because:

- `Provenance.target` references de-identified output by resource URI or identifier, not by embedding the output resource. A URI reference to an HL7 FHIR R5 Patient is syntactically identical to a reference to an HL7 FHIR R4 Patient.
- Transformation summary entries use version-neutral FHIRPath target paths (e.g., `Patient.name`, `Patient.birthDate`). These paths describe what was transformed, not the version of the resource that was transformed.
- Policy references, stage categories, reversibility state, validation status, and audit correlation identifiers are version-independent metadata.

The `Provenance` resource MAY include the payload HL7 FHIR version in an extension when consumers need to distinguish output versions. This is informational; it does not change the evidence structure.

#### 3:5.9.1.5 Validation Across Versions

De-identified output SHALL be validated against the processing payload's declared HL7 FHIR version, not against the HL7 FHIR R4 protocol binding version.

The following minimum validation checks apply to all payload versions:

1. Well-formed HL7 FHIR JSON or XML conforming to the declared version.
2. Valid against the base resource definition for the declared version.
3. Valid against declared output StructureDefinition profiles when supplied. Output profiles SHALL be compatible with the payload version.
4. No direct identifiers remain in elements governed by the execution plan.
5. Internal references remain resolvable within the output graph or Bundle.
6. Remapped identifiers and references are consistent within the declared scope.
7. Narrative XHTML remains valid and contains no detected PHI for governed narrative targets.
8. Provenance evidence maps all required DIS evidence baseline elements (see [§3:5.9.5](#3595-evidence-baseline)).

A De-Identifier SHALL use an HL7 FHIR validation library or equivalent mechanism compatible with the declared payload version. Validation against the wrong HL7 FHIR version (e.g., validating HL7 FHIR R5 output against HL7 FHIR R4 definitions) is a conformance failure.

<a name="content-model"> </a>

### 3:5.9.2 Content Model

This section defines the content model for DIS-FHIR-Payload: how HL7 FHIR data elements are identified, addressed, and grouped for de-identification governance.

#### 3:5.9.2.1 Element Addressing

DIS-FHIR-Payload uses FHIRPath expressions as the element addressing language. Execution plan rules and semantic group definitions reference HL7 FHIR elements using FHIRPath-compatible path expressions rooted at the resource type.

An element path SHALL be one of the following forms:

- **Resource-rooted path** -- a FHIRPath expression starting with a resource type (e.g., `Patient.name`, `Observation.value[x]`). The path identifies one or more elements within a single resource instance.
- **Semantic group reference** -- a reference to a named semantic group (e.g., `@subject-identifiers`). The `@` prefix distinguishes a semantic group reference from a FHIRPath expression. The group expands to its member paths at execution plan compilation time.

When a path targets an element with child elements (e.g., `Patient.name` which contains `HumanName.family`, `HumanName.given`, `HumanName.prefix`, `HumanName.suffix`, `HumanName.text`, `HumanName.period`), the action applies to the targeted element and all its children unless the execution plan specifies a more specific child path.

Choice-type elements use the `[x]` notation (e.g., `Observation.value[x]`). The De-Identifier SHALL apply the rule to whichever concrete type is present in the resource instance.

#### 3:5.9.2.2 Semantic Groups

Semantic groups categorize HL7 FHIR elements by privacy sensitivity. Policies and execution plans MAY reference semantic groups instead of individual element paths. The De-ID Manager expands semantic group references to individual element paths during execution plan compilation.

Table 3:5.9.2-1 defines the Phase 1 semantic groups for DIS-FHIR-Payload.

<p id="t3.5.9.2-1" class="tableTitle"><strong>Table 3:5.9.2-1: DIS-FHIR-Payload Semantic Groups</strong></p>

| Semantic Group | Description | Example Member Paths |
|----------------|-------------|----------------------|
| `subject-identifiers` | Direct identifiers of the data subject | `Patient.identifier`, `Patient.name`, `Patient.identifier.value`, `Patient.name.family`, `Patient.name.given` |
| `subject-demographics` | Demographic elements of the data subject | `Patient.birthDate`, `Patient.gender`, `Patient.address`, `Patient.telecom`, `Patient.photo`, `Patient.maritalStatus`, `Patient.communication`, `Patient.multipleBirth[x]`, `Patient.deceased[x]` |
| `contact-information` | Contact persons and their identifying elements | `Patient.contact.name`, `Patient.contact.telecom`, `Patient.contact.address`, `Patient.contact.organization`, `RelatedPerson.identifier`, `RelatedPerson.name`, `RelatedPerson.telecom`, `RelatedPerson.address`, `RelatedPerson.photo` |
| `provider-identifiers` | Identifiers and names of care providers | `Practitioner.identifier`, `Practitioner.name`, `Practitioner.telecom`, `Practitioner.address`, `Practitioner.photo`, `PractitionerRole.identifier` |
| `dates` | Date and time elements across governed resource types | `Patient.birthDate`, `Patient.deceased[x]` (when dateTime), `Encounter.period`, `Condition.onset[x]`, `Condition.abatement[x]`, `Procedure.performed[x]`, `Observation.effective[x]`, `MedicationRequest.authoredOn`, `DiagnosticReport.effective[x]`, `DocumentReference.date` |
| `narrative` | Resource narrative content | `Resource.text` (the `Narrative` element on any governed resource type) |
| `references` | Reference elements that could link to identifiable resources | `Observation.subject`, `Condition.subject`, `Encounter.subject`, `Procedure.subject`, `DiagnosticReport.subject`, `MedicationRequest.subject`, `Encounter.participant.individual` (HL7 FHIR R4) / `Encounter.participant.actor` (HL7 FHIR R5), `DocumentReference.subject`, `DocumentReference.author` |
| `device-identifiers` | Device identifiers and names | `Device.identifier`, `Device.serialNumber`, `Device.deviceName` (HL7 FHIR R4) / `Device.name` (HL7 FHIR R5), `Device.udiCarrier` |
{: .grid}

A semantic group MAY include elements from multiple resource types. Semantic group membership is defined by the content module and is not configurable by the policy. Policies select which groups to govern and which action to apply; they do not add or remove elements from a group.

Implementations MAY define additional semantic groups beyond those listed in Table 3:5.9.2-1 for local governance requirements. Additional groups SHALL NOT conflict with the element assignments of the Phase 1 groups.

<div markdown="1" class="stu-note">
**Editorial Note:** The semantic group definitions in Table 3:5.9.2-1 are illustrative. The formal CodeSystem and membership definitions will be provided when FSH conformance artifacts are finalized.
</div>

#### 3:5.9.2.3 Resource Traversal

An execution plan applies to a set of processing target resources. The De-Identifier SHALL traverse the processing target according to the following rules.

**Bundle traversal.** When the processing target is a Bundle, the De-Identifier SHALL apply execution plan rules to each entry resource in the Bundle. Rules are matched by the entry resource's resource type. Bundle metadata elements (`Bundle.id`, `Bundle.identifier`, `Bundle.timestamp`, `Bundle.link`) are not governed by resource-type-rooted rules; separate rules targeting `Bundle.*` paths are required to govern them.

**Contained resources.** When a processing target resource contains other resources via `Resource.contained`, the De-Identifier SHALL apply execution plan rules to each contained resource according to its resource type. References from the containing resource to contained resources (e.g., `#contained-id`) SHALL be updated if the contained resource's identifier is transformed.

**Reference chains.** In by-reference delivery mode, the processing target MAY include references to resources not included in the processing target set. The De-Identifier SHALL NOT follow references outside the processing target set. Only resources explicitly included in the processing target (directly or as Bundle entries) are governed by the execution plan. Reference elements pointing to resources outside the processing target set are governed by rules targeting the `references` semantic group.

<a name="transformation-actions"> </a>

### 3:5.9.3 Transformation Actions

This section defines the Phase 1 core transformation action family (`core`) for DIS-FHIR-Payload. Every De-Identifier declaring DIS-FHIR-Payload SHALL support all actions in the `core` family.

#### 3:5.9.3.1 Action Catalog

Table 3:5.9.3-1 lists the Phase 1 core transformation actions.

<p id="t3.5.9.3-1" class="tableTitle"><strong>Table 3:5.9.3-1: Phase 1 Core Transformation Actions</strong></p>

| Action Code | Description | Applicable HL7 FHIR Datatypes | Deterministic | Parameters |
|-------------|-------------|-------------------------------|---------------|------------|
| `suppress` | Remove the element entirely from the resource | Any element | Yes | None |
| `pseudonymize` | Replace with a deterministic pseudonym derived from seed material and the input value | `Identifier`, `HumanName`, `string`, `id`, `Reference` | Yes (given same seed and input) | `algorithm` (default: `HMAC-SHA-256`), `outputFormat` |
| `generalize` | Reduce the precision of the value | `date`, `dateTime`, `Address`, `Quantity`, `Age`, `integer`, `decimal` | Yes | `precision` (e.g., `year`, `month`, `state`, `country`) |
| `date-shift` | Shift all dates by a consistent per-patient offset derived from seed material | `date`, `dateTime`, `instant`, `Period` | Yes (given same seed) | `maxOffsetDays` (maximum magnitude of the shift in days) |
| `mask` | Replace the value with a fixed mask string | `string`, `HumanName`, `Address`, `ContactPoint`, `Identifier`, `uri` | Yes | `maskValue` (e.g., `"XXXXX"`, `"REDACTED"`) |
| `redact-narrative` | Remove or sanitize the narrative content | `Narrative` | Yes | `mode` (`remove` or `sanitize`) |
| `cryptographic-hash` | Replace with a one-way cryptographic hash of the value | `Identifier.value`, `string`, `id` | Yes | `algorithm` (default: `SHA-256`) |
| `perturb` | Add noise to a numeric value | `Quantity.value`, `integer`, `decimal` | No (stochastic) | `distribution` (`uniform` or `gaussian`), `magnitude` |
{: .grid}

#### 3:5.9.3.2 Action Definitions

##### suppress

The `suppress` action removes the targeted element and all its children from the resource. After suppression, the element SHALL NOT be present in the de-identified output. If the suppressed element is required by the HL7 FHIR base resource definition (cardinality 1..1 or 1..*), the De-Identifier SHALL reject the task with an OperationOutcome. Execution plans SHALL NOT target required elements with the `suppress` action.

##### pseudonymize

The `pseudonymize` action replaces the targeted element's value with a deterministic pseudonym. The pseudonym is derived from the seed material provided by the De-ID Manager and the original input value using the specified algorithm. Given the same seed and input value, the same pseudonym SHALL be produced. This enables consistent pseudonymization across resources within the same consistency scope.

For `HumanName` elements, the action replaces `family`, `given`, `prefix`, `suffix`, and `text` with pseudonymous values. The `use` and `period` sub-elements are preserved.

For `Identifier` elements, the action replaces `Identifier.value` with a pseudonymous value. `Identifier.system` SHALL be replaced with a DIS pseudonym system URI (e.g., `urn:oid:dis-pseudonym:<scope>`) to prevent collision with real identifier systems. `Identifier.type`, `Identifier.use`, and `Identifier.period` are preserved.

For `Reference` elements, the action replaces the reference target with the pseudonymized identifier of the referenced resource, when that resource is within the processing target set. References to resources outside the processing target set are governed by the `references` semantic group rules.

The pseudonym is not reversible from the output alone. Reversal requires access to the De-ID Manager's identity table and pseudonym index (see [§1:PXX.2.2](volume-1.html#1pxx22-reversible-pseudonymization-option)).

##### generalize

The `generalize` action reduces the precision of the targeted element's value to the level specified by the `precision` parameter.

For `date` and `dateTime` elements:
- `precision: year` — retain only the year (e.g., `1985-03-15` → `1985`)
- `precision: month` — retain year and month (e.g., `1985-03-15` → `1985-03`)

For `Address` elements:
- `precision: country` — retain only `Address.country`; suppress `Address.line`, `Address.city`, `Address.district`, `Address.state`, `Address.postalCode`
- `precision: state` — retain `Address.country` and `Address.state`; suppress remaining sub-elements

For `Quantity` and `Age` elements:
- `precision` specifies a rounding interval (e.g., `precision: 5` rounds `Quantity.value` to the nearest 5)

For `integer` and `decimal` elements:
- `precision` specifies a rounding interval applied directly to the value

##### date-shift

The `date-shift` action shifts the targeted date or time value by a per-patient offset. The offset is deterministically derived from the seed material and the patient identifier, ensuring that all dates for the same patient within the same consistency scope are shifted by the same offset. The offset magnitude SHALL NOT exceed the `maxOffsetDays` parameter. The direction (forward or backward) is determined by the derivation.

Date shifting preserves temporal ordering and intervals between events for the same patient. The De-Identifier SHALL apply the same offset to all `date`, `dateTime`, `instant`, and `Period` elements for a given patient within a single task.

For `Period` elements, both `Period.start` and `Period.end` are shifted by the same offset.

##### mask

The `mask` action replaces the targeted element's displayable content with the value specified by the `maskValue` parameter.

For `HumanName`, each sub-element (`family`, `given`, `text`) is replaced with the mask value. For `Address`, each sub-element (`line`, `city`, `district`, `state`, `postalCode`) is replaced with the mask value; `Address.country` is preserved. For `ContactPoint`, `ContactPoint.value` is replaced with the mask value; `ContactPoint.system` and `ContactPoint.use` are preserved.

##### redact-narrative

The `redact-narrative` action governs the `Narrative` element (`Resource.text`) of a resource.

In `remove` mode, the De-Identifier SHALL set `Narrative.status` to `empty` and replace `Narrative.div` with an empty XHTML div element (`<div xmlns="http://www.w3.org/1999/xhtml"/>`) conforming to the HL7 FHIR Narrative datatype constraints.

In `sanitize` mode, the De-Identifier SHALL scan the XHTML content for detected PHI patterns (names, identifiers, dates, addresses, contact information) and replace detected values with the corresponding pseudonymized or masked values produced by other rules in the execution plan. `Narrative.status` SHALL be set to `extensions` to indicate the narrative has been modified. Sanitization is best-effort; undetected PHI in narrative is an implementation limitation.

##### cryptographic-hash

The `cryptographic-hash` action replaces the targeted element's value with a one-way cryptographic hash. The hash is computed over the original value using the specified algorithm. The output is hex-encoded.

Cryptographic hashing is not reversible. It is suitable for elements where deterministic linkage is needed but the original value is never required. The De-ID Manager SHALL NOT use this action when the policy requires reversibility for the targeted element.

##### perturb

The `perturb` action adds noise to a numeric value. The noise is drawn from the specified distribution with the specified magnitude.

For `uniform` distribution, the noise is drawn uniformly from `[-magnitude, +magnitude]`. For `gaussian` distribution, the noise is drawn from a normal distribution with standard deviation equal to `magnitude`.

The `perturb` action is stochastic and does not produce deterministic output. It SHALL NOT be used when cross-job consistency is required for the targeted element.

<a name="execution-plan-format"> </a>

### 3:5.9.4 Execution Plan Format

This section defines the structure of DIS-FHIR-Payload execution plans carried within HL7 FHIR R4 Library resources.

#### 3:5.9.4.1 Library Resource Structure

A DIS-FHIR-Payload execution plan is carried as a content attachment in an HL7 FHIR R4 `Library` resource. The Library resource provides metadata about the plan; the plan content is a DIS-specific JSON format.

Table 3:5.9.4-1 lists the required Library resource elements.

<p id="t3.5.9.4-1" class="tableTitle"><strong>Table 3:5.9.4-1: Execution Plan Library Resource Elements</strong></p>

| Element | Cardinality | Description |
|---------|-------------|-------------|
| `Library.url` | 1..1 | Canonical URL identifying this execution plan |
| `Library.identifier` | 0..* | Business identifiers for the plan |
| `Library.version` | 1..1 | Version of the execution plan |
| `Library.name` | 1..1 | Machine-readable name |
| `Library.title` | 0..1 | Human-readable title |
| `Library.status` | 1..1 | `draft`, `active`, or `retired` |
| `Library.type` | 1..1 | SHALL be `logic-library` |
| `Library.date` | 1..1 | Date the plan was compiled |
| `Library.description` | 0..1 | Human-readable description |
| `Library.content` | 1..1 | Attachment containing the execution plan JSON |
| `Library.content.contentType` | 1..1 | SHALL be `application/vnd.ihe.dis.execution-plan+json` |
| `Library.content.data` | 1..1 | Base64-encoded execution plan JSON |
{: .grid}

#### 3:5.9.4.2 Execution Plan JSON Structure

The execution plan JSON content is an ordered array of rules. Each rule specifies a target, an action, and action-specific parameters.

Table 3:5.9.4-2 lists the elements of each rule in the execution plan.

<p id="t3.5.9.4-2" class="tableTitle"><strong>Table 3:5.9.4-2: Execution Plan Rule Elements</strong></p>

| Element | Cardinality | Type | Description |
|---------|-------------|------|-------------|
| `ruleId` | 1..1 | string | Unique identifier for the rule within the plan |
| `target` | 1..1 | string | FHIRPath expression or semantic group reference (prefixed with `@`) identifying the target element(s) |
| `action` | 1..1 | code | Action code from the core action family (see [§3:5.9.3](#3593-transformation-actions)) |
| `parameters` | 0..1 | object | Action-specific parameters as key-value pairs |
{: .grid}

Rules are evaluated in order. When multiple rules match the same element, the first matching rule applies and subsequent matching rules are skipped. This first-match-wins evaluation enables execution plans to specify exceptions before general rules (e.g., preserve a specific identifier before pseudonymizing all identifiers).

A rule whose `target` is a semantic group reference (e.g., `@subject-identifiers`) applies to all member paths of that group. The De-ID Manager expands semantic group references to individual element paths at compilation time and records the expanded paths in the compiled plan dispatched via ITI-x3.

#### 3:5.9.4.3 Execution Plan Example

The following execution plan illustrates a single-stage pseudonymization plan for Use Case 3 (Clinical Pathology Order). The plan pseudonymizes patient identifiers and names, suppresses address and telecom, date-shifts the birth date, and redacts narrative content.

```json
{
  "planVersion": "1.0",
  "payloadBinding": "DIS-FHIR-Payload",
  "payloadVersion": "R4",
  "rules": [
    {
      "ruleId": "R01",
      "target": "Patient.identifier",
      "action": "pseudonymize",
      "parameters": {
        "algorithm": "HMAC-SHA-256",
        "outputFormat": "urn:oid:dis-pseudonym:${consistencyKey}"
      }
    },
    {
      "ruleId": "R02",
      "target": "Patient.name",
      "action": "pseudonymize",
      "parameters": {
        "algorithm": "HMAC-SHA-256"
      }
    },
    {
      "ruleId": "R03",
      "target": "Patient.address",
      "action": "suppress"
    },
    {
      "ruleId": "R04",
      "target": "Patient.telecom",
      "action": "suppress"
    },
    {
      "ruleId": "R05",
      "target": "Patient.birthDate",
      "action": "date-shift",
      "parameters": {
        "maxOffsetDays": 30
      }
    },
    {
      "ruleId": "R06",
      "target": "Patient.photo",
      "action": "suppress"
    },
    {
      "ruleId": "R07",
      "target": "@narrative",
      "action": "redact-narrative",
      "parameters": {
        "mode": "remove"
      }
    },
    {
      "ruleId": "R08",
      "target": "@references",
      "action": "pseudonymize",
      "parameters": {
        "algorithm": "HMAC-SHA-256"
      }
    }
  ]
}
```

<div markdown="1" class="stu-note">
**Editorial Note:** The execution plan JSON structure shown above is illustrative. The formal JSON Schema will be provided when FSH conformance artifacts are finalized.
</div>

<a name="evidence-baseline"> </a>

### 3:5.9.5 Evidence Baseline

This section defines the minimum evidence elements that every completed de-identification task SHALL produce and specifies how they map to HL7 FHIR R4 Provenance resources.

#### 3:5.9.5.1 Minimum Evidence Elements

Every completed de-identification task produces an HL7 FHIR R4 Provenance resource containing at minimum the nine evidence elements listed in Table 3:5.9.5-1.

<p id="t3.5.9.5-1" class="tableTitle"><strong>Table 3:5.9.5-1: DIS Evidence Baseline Elements</strong></p>

| # | Evidence Element | HL7 FHIR R4 Provenance Mapping | Description |
|---|------------------|-------------------------------|-------------|
| 1 | Evidence identifier | `Provenance.id` | Unique identifier for this evidence record |
| 2 | Outcome status | `Provenance.extension[dis-outcome-status]` | Overall task outcome: `complete` or `error` |
| 3 | Workflow reference | `Provenance.activity` | Coding identifying the DIS transaction and job/task context |
| 4 | Target identifier | `Provenance.target` | Reference(s) to the de-identified output resource(s) |
| 5 | Policy-decision reference | `Provenance.policy` | URI of the validated policy governing this task |
| 6 | Stage category | `Provenance.extension[dis-stage]` | Processing stage: `preliminary` or `advanced` |
| 7 | Reversibility state | `Provenance.extension[dis-reversibility]` | `irreversible` or `reversible` |
| 8 | Validation status | `Provenance.extension[dis-validation-status]` | Output validation result: `valid` or `invalid` |
| 9 | Audit correlation identifier | `Provenance.extension[dis-audit-correlation]` | Identifier linking this evidence to the ATNA audit trail |
{: .grid}

Elements 2, 6, 7, 8, and 9 use DIS-defined extensions on the HL7 FHIR R4 Provenance resource. The extension URLs follow the pattern `https://profiles.ihe.net/ITI/DIS/StructureDefinition/<extension-name>`.

#### 3:5.9.5.2 Provenance Resource Structure

In addition to the nine baseline elements, the Provenance resource SHALL include the following standard HL7 FHIR R4 Provenance elements.

Table 3:5.9.5-2 lists the required Provenance elements beyond the baseline.

<p id="t3.5.9.5-2" class="tableTitle"><strong>Table 3:5.9.5-2: Required Provenance Elements</strong></p>

| Element | Cardinality | Description |
|---------|-------------|-------------|
| `Provenance.recorded` | 1..1 | Timestamp when the de-identification task completed |
| `Provenance.agent` (performer) | 1..1 | The De-Identifier that executed the task, identified by reference or identifier |
| `Provenance.agent` (policy authority) | 0..1 | The authority whose policy governed the task, when identifiable |
| `Provenance.reason` | 0..* | Coded reason for the de-identification (e.g., research, clinical pseudonymization) |
{: .grid}

The `Provenance.agent` entry for the De-Identifier SHALL use `Provenance.agent.type` with coding `http://terminology.hl7.org/CodeSystem/provenance-participant-type|performer`. The `Provenance.agent.who` SHALL reference or identify the De-Identifier.

#### 3:5.9.5.3 Transformation Summary

Each Provenance resource SHOULD include a transformation summary recording the actions applied to individual elements. The transformation summary is carried as a DIS-defined extension `dis-transformation-summary` containing an array of entries.

Table 3:5.9.5-3 lists the elements of each transformation summary entry.

<p id="t3.5.9.5-3" class="tableTitle"><strong>Table 3:5.9.5-3: Transformation Summary Entry Elements</strong></p>

| Element | Cardinality | Type | Description |
|---------|-------------|------|-------------|
| `targetPath` | 1..1 | string | FHIRPath expression identifying the transformed element |
| `action` | 1..1 | code | Action code applied (from the core action family) |
| `outcome` | 1..1 | code | `applied`, `skipped` (element not present), or `error` |
| `ruleId` | 0..1 | string | Identifier of the execution plan rule that triggered this action |
{: .grid}

The transformation summary enables audit and review of the specific actions applied to each element. It does not contain the original or transformed values. Original values SHALL NOT appear in evidence.

#### 3:5.9.5.4 Evidence Example

The following Provenance resource illustrates the evidence produced for Use Case 3 (Clinical Pathology Order), where a single-stage pseudonymization task is completed synchronously.

```json
{
  "resourceType": "Provenance",
  "id": "dis-evidence-uc3-001",
  "meta": {
    "profile": ["https://profiles.ihe.net/ITI/DIS/StructureDefinition/DIS-Evidence"]
  },
  "extension": [
    {
      "url": "https://profiles.ihe.net/ITI/DIS/StructureDefinition/dis-outcome-status",
      "valueCode": "complete"
    },
    {
      "url": "https://profiles.ihe.net/ITI/DIS/StructureDefinition/dis-stage",
      "valueCode": "preliminary"
    },
    {
      "url": "https://profiles.ihe.net/ITI/DIS/StructureDefinition/dis-reversibility",
      "valueCode": "reversible"
    },
    {
      "url": "https://profiles.ihe.net/ITI/DIS/StructureDefinition/dis-validation-status",
      "valueCode": "valid"
    },
    {
      "url": "https://profiles.ihe.net/ITI/DIS/StructureDefinition/dis-audit-correlation",
      "valueIdentifier": {
        "system": "urn:oid:dis-audit",
        "value": "audit-corr-20261104-001"
      }
    },
    {
      "url": "https://profiles.ihe.net/ITI/DIS/StructureDefinition/dis-transformation-summary",
      "extension": [
        {
          "url": "entry",
          "extension": [
            { "url": "targetPath", "valueString": "Patient.identifier" },
            { "url": "action", "valueCode": "pseudonymize" },
            { "url": "outcome", "valueCode": "applied" },
            { "url": "ruleId", "valueString": "R01" }
          ]
        },
        {
          "url": "entry",
          "extension": [
            { "url": "targetPath", "valueString": "Patient.name" },
            { "url": "action", "valueCode": "pseudonymize" },
            { "url": "outcome", "valueCode": "applied" },
            { "url": "ruleId", "valueString": "R02" }
          ]
        },
        {
          "url": "entry",
          "extension": [
            { "url": "targetPath", "valueString": "Patient.address" },
            { "url": "action", "valueCode": "suppress" },
            { "url": "outcome", "valueCode": "applied" },
            { "url": "ruleId", "valueString": "R03" }
          ]
        },
        {
          "url": "entry",
          "extension": [
            { "url": "targetPath", "valueString": "Patient.telecom" },
            { "url": "action", "valueCode": "suppress" },
            { "url": "outcome", "valueCode": "applied" },
            { "url": "ruleId", "valueString": "R04" }
          ]
        },
        {
          "url": "entry",
          "extension": [
            { "url": "targetPath", "valueString": "Patient.birthDate" },
            { "url": "action", "valueCode": "date-shift" },
            { "url": "outcome", "valueCode": "applied" },
            { "url": "ruleId", "valueString": "R05" }
          ]
        },
        {
          "url": "entry",
          "extension": [
            { "url": "targetPath", "valueString": "Patient.photo" },
            { "url": "action", "valueCode": "suppress" },
            { "url": "outcome", "valueCode": "applied" },
            { "url": "ruleId", "valueString": "R06" }
          ]
        }
      ]
    }
  ],
  "target": [
    { "reference": "Patient/pseudonym-abc123" }
  ],
  "recorded": "2026-11-04T10:30:00Z",
  "policy": ["urn:oid:dis-policy:hospital-lab-pseudonymization/1.0"],
  "activity": {
    "coding": [{
      "system": "https://profiles.ihe.net/ITI/DIS/CodeSystem/dis-activity",
      "code": "dis-task",
      "display": "DIS De-Identification Task"
    }]
  },
  "agent": [
    {
      "type": {
        "coding": [{
          "system": "http://terminology.hl7.org/CodeSystem/provenance-participant-type",
          "code": "performer"
        }]
      },
      "who": {
        "identifier": {
          "system": "https://hospital.example.org/systems/de-identifiers",
          "value": "de-identifier-01"
        }
      }
    }
  ]
}
```

<div markdown="1" class="stu-note">
**Editorial Note:** The extension URLs, CodeSystem URIs, and profile URLs shown above are illustrative. The formal StructureDefinition resources for the DIS evidence extensions will be provided when FSH conformance artifacts are finalized.
</div>

<a name="data-plane-access"> </a>

### 3:5.9.6 Data-Plane Access

This section defines how DIS-FHIR-Payload processing targets are retrieved by the De-Identifier and how de-identified output is returned. Three delivery modes are supported: by-reference, by-value, and by-manifest.

#### 3:5.9.6.1 By-Reference

In by-reference delivery mode, the processing target is identified by an HL7 FHIR reference (e.g., `Patient/123`) and an optional source base URL. The De-Identifier retrieves the resource from the source HL7 FHIR server using HL7 FHIR REST read interactions.

The De-Identifier SHALL present authorization credentials when retrieving resources from the source server. The De-ID Manager provides the necessary authorization context in the ITI-x3 task dispatch.

De-identified output in by-reference mode MAY be:
- Returned inline in the ITI-x3 response (synchronous mode) as HL7 FHIR R4 resources (for HL7 FHIR R4 payloads) or as attachments (for cross-version payloads)
- Persisted to an output HL7 FHIR server designated by the De-ID Manager, with output references returned in the response

#### 3:5.9.6.2 By-Value

In by-value delivery mode, the processing target resource content is embedded directly in the ITI-x1 request `Parameters` resource. This mode is typical for synchronous single-patient workflows where the data volume is small.

For HL7 FHIR R4 payloads, by-value resources are carried as native HL7 FHIR R4 resources within the `Parameters` envelope. For HL7 FHIR R5 or R6 payloads, by-value resources SHALL be carried as attachments using the inline attachment packaging pattern defined in [§3:5.9.1.2](#35912-version-safe-packaging).

De-identified output in by-value mode is returned inline in the response using the same packaging pattern as the input.

#### 3:5.9.6.3 By-Manifest

In by-manifest delivery mode, the processing target is identified by a URI referencing an NDJSON manifest. This mode is used for bulk data cohort jobs.

The manifest follows the conventions of the [HL7 Bulk Data Access IG](https://hl7.org/fhir/uv/bulkdata/). Each line of a referenced NDJSON file contains a complete serialized HL7 FHIR resource in the declared payload version.

The De-Identifier SHALL present authorization credentials when retrieving manifest files and NDJSON data files. File retrieval SHALL use TLS.

De-identified output in by-manifest mode is returned as a manifest referencing de-identified NDJSON output files together with evidence references. Recipient-facing manifests and files SHALL NOT contain seeds or other protected transformation material. A failed job SHALL NOT release a partial dataset; failures SHALL be reported through job status.

Table 3:5.9.6-1 summarizes the delivery modes and their characteristics.

<p id="t3.5.9.6-1" class="tableTitle"><strong>Table 3:5.9.6-1: DIS-FHIR-Payload Delivery Modes</strong></p>

| Delivery Mode | Input Mechanism | Typical Use | Output Mechanism |
|---------------|-----------------|-------------|------------------|
| By-reference | HL7 FHIR reference + source base URL | Source data on an HL7 FHIR server | Inline in response or persisted to output server |
| By-value | Resource embedded in `Parameters` (native or attachment) | Synchronous single-patient, small data volume | Inline in response |
| By-manifest | URI referencing NDJSON manifest | Bulk data cohort jobs | Manifest referencing de-identified NDJSON files |
{: .grid}
