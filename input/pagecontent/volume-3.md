
This section defines the DIS-FHIR-Payload content module.

<a name="fhir-payload-content-module"> </a>

## 3:5.9 DIS-FHIR-Payload Content Module

The DIS-FHIR-Payload content module defines format-specific rules for de-identification of FHIR processing payloads within the DIS workflow. It specifies how FHIR data elements are identified and addressed, how DIS transformation actions are realized for FHIR datatypes, how payloads are carried within and retrieved from the FHIR R4 protocol envelope, and how de-identification evidence is represented using FHIR Provenance.

DIS-FHIR-Payload is independent of the DIS FHIR R4 protocol binding version. It supports processing payloads in FHIR R4, R5, and R6 without requiring a corresponding version of the protocol binding. This independence is achieved through version identification, version-safe packaging, and version-neutral element addressing.

<a name="cross-version-payload"> </a>

### 3:5.9.1 Cross-Version Payload Support

This section specifies how DIS-FHIR-Payload enables de-identification of FHIR payloads whose version differs from the FHIR R4 protocol binding.

#### 3:5.9.1.1 Version Identification

Each processing payload SHALL explicitly declare its FHIR version. The version declaration enables the De-ID Manager to verify De-Identifier compatibility before task dispatch and ensures that de-identified output is validated against the correct FHIR version.

A De-Identifier declaring DIS-FHIR-Payload SHALL advertise the FHIR payload versions it supports in its capability declaration. The De-ID Manager SHALL verify that the processing payload's declared version is included in the assigned De-Identifier's supported versions before dispatching a task via ITI-x3. The De-ID Manager SHALL reject a job when no available De-Identifier supports the payload's declared FHIR version.

Table 3:5.9.1-1 lists the mechanisms for declaring the payload version.

<p id="t3.5.9.1-1" class="tableTitle"><strong>Table 3:5.9.1-1: Payload Version Declaration Mechanisms</strong></p>

| Mechanism | Context | Example |
|-----------|---------|---------|
| Processing target `fhirVersion` field | ITI-x1 job submission and ITI-x3 task dispatch | `{ "family": "fhir", "fhirVersion": "5.0.0", "reference": "Patient/123" }` |
| Content type parameter | Inline attachment | `application/fhir+json; fhirVersion=5.0.0` |
| Source server capability | By-reference retrieval | De-Identifier reads `CapabilityStatement.fhirVersion` from the source FHIR server |
| Manifest metadata | Bulk Data | Manifest declares the FHIR version of referenced NDJSON files |
{: .grid}

When a processing target omits an explicit version declaration, the De-ID Manager SHALL treat the payload as the same version as the protocol binding (FHIR R4). Explicit declaration is REQUIRED for R5 and R6 payloads.

#### 3:5.9.1.2 Version-Safe Packaging

A FHIR payload whose version differs from the R4 protocol binding SHALL NOT be embedded as a native resource in the R4 transaction envelope. Embedding a non-R4 resource directly in R4 `Parameters`, `Task`, or `Bundle` structures would produce invalid R4 content and conflate the protocol and payload version boundaries.

The following packaging patterns are permitted for cross-version payloads:

##### By-Reference

The processing target identifies the resource by FHIR reference or URL. The De-Identifier retrieves it from a source FHIR server that supports the payload version. The R4 transaction envelope carries only the reference, not the resource content.

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

The payload is serialized as JSON or XML and carried as a `valueAttachment` in the R4 task input. The R4 envelope treats the attachment content as opaque bytes.

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
    "data": "<base64-encoded FHIR R5 resource>"
  }
}
```

The content type parameter `fhirVersion` is a DIS-defined convention for declaring the payload version within inline attachments; it is not a registered FHIR MIME type parameter. The De-Identifier SHALL parse the attachment content according to the declared version.

##### Bulk Data Manifest

NDJSON files referenced by a Bulk Data manifest contain serialized resources in the declared payload version. The manifest metadata declares the FHIR version; each NDJSON line is a complete serialized resource.

```json
{
  "family": "fhir",
  "fhirVersion": "5.0.0",
  "bulkManifest": "https://manager.example.org/dis-jobs/job-001/source-manifest"
}
```

##### De-Identified Output Packaging

De-identified output SHALL be returned or persisted using the same packaging patterns. Output resources retain the payload's FHIR version -- the De-Identifier does not convert output to R4. When output is returned inline, it SHALL be carried as a `valueAttachment` or serialized in a multipart response, not embedded as a native resource in the R4 response envelope.

When output is persisted by reference (e.g., to an output FHIR server or as NDJSON files), the output server or files operate at the payload version. The R4 protocol response carries only the output references.

##### Protocol Resources Remain R4

Table 3:5.9.1-2 lists the resources that are part of the R4 protocol layer and remain R4 regardless of the payload version.

<p id="t3.5.9.1-2" class="tableTitle"><strong>Table 3:5.9.1-2: R4 Protocol Resources</strong></p>

| R4 Protocol Resource | Role |
|----------------------|------|
| `Parameters` | ITI-x1 job request and response envelope |
| `Task` | ITI-x3 task dispatch and status |
| `Provenance` | De-identification evidence |
| `OperationOutcome` | Error and validation reporting |
| `Bundle` | Workflow packaging (message, result collection) |
| `Library` | Execution plan carrier |
| `CapabilityStatement` | Actor capability declaration |
{: .grid}

#### 3:5.9.1.3 Version-Neutral Element Addressing

DIS-FHIR-Payload uses FHIRPath-compatible path expressions to address data elements within the processing payload (see [§1:PXX.2.7](volume-1.html#1pxx27-fhir-payload-option)). The path expressions used by DIS execution plans, semantic group mappings, and Provenance transformation summaries are version-neutral: they resolve consistently across FHIR R4, R5, and R6 for the resource types and elements governed by DIS transformation actions.

Most governed element paths are stable across R4, R5, and R6:

- `Patient` direct-identifier and demographic elements (`Patient.name`, `Patient.identifier`, `Patient.birthDate`, `Patient.address`, `Patient.telecom`, `Patient.photo`, `Patient.gender`, `Patient.maritalStatus`) retain identical paths across all three versions.
- FHIR datatypes used by DIS transformation actions (`HumanName`, `Identifier`, `Address`, `ContactPoint`, `Narrative`, `date`, `dateTime`, `instant`, `Period`, `Quantity`) have stable structures across these versions.
- DIS semantic groups for subject identifiers, demographics, contact information, references, and narrative map to stable paths.
- Resource types commonly governed by DIS (`Patient`, `Practitioner`, `Encounter`, `Condition`, `Observation`, `DiagnosticReport`, `Procedure`, `MedicationRequest`, `DocumentReference`, `ImagingStudy`) exist in all three versions.

However, several governed elements were renamed between R4 and R5. The De-ID Manager SHALL apply version-conditional path mappings for these elements when compiling execution plans for R5 or R6 payloads.

<p id="t3.5.9.1-3" class="tableTitle"><strong>Table 3:5.9.1-3: Version-Conditional Path Mappings (R4 to R5)</strong></p>

| Semantic Group | R4 Path | R5 Path | Affected Element |
|----------------|---------|---------|-----------------|
| `subject.dates` | `Encounter.period` | `Encounter.actualPeriod` | Encounter date/time |
| `subject.dates` | `Procedure.performed[x]` | `Procedure.occurrence[x]` | Procedure date/time (all choice types: dateTime, Period, string, Age, Range) |
| `provider.name` | `Encounter.participant.individual` | `Encounter.participant.actor` | Encounter participant reference |
| `device-identifiers` | `Device.deviceName` | `Device.name` | Device name |
{: .grid}

The De-ID Manager SHALL resolve these mappings at execution plan compilation time based on the declared payload version. A single governance policy using semantic groups remains version-neutral; the version-conditional mapping is applied during compilation, not by the De-Identifier. The De-Identifier receives resolved paths appropriate for the payload version.

For elements not listed in Table 3:5.9.1-3, a single execution plan can govern payloads of different FHIR versions without requiring version-specific rule variants. When future FHIR versions introduce additional structural changes to governed elements, this table SHALL be extended.

#### 3:5.9.1.4 Evidence Representation Across Versions

De-identification evidence is represented as FHIR R4 `Provenance` resources, which are part of the protocol layer. Evidence does not depend on the payload's FHIR version because:

- `Provenance.target` references de-identified output by resource URI or identifier, not by embedding the output resource. A URI reference to an R5 Patient is syntactically identical to a reference to an R4 Patient.
- Transformation summary entries use version-neutral FHIRPath target paths (e.g., `Patient.name`, `Patient.birthDate`). These paths describe what was transformed, not the version of the resource that was transformed.
- Policy references, stage categories, reversibility state, validation status, and audit correlation identifiers are version-independent metadata.

The `Provenance` resource MAY include the payload FHIR version in an extension when Consumers need to distinguish output versions. This is informational; it does not change the evidence structure.

#### 3:5.9.1.5 Validation Across Versions

De-identified output SHALL be validated against the processing payload's declared FHIR version, not against the R4 protocol binding version.

The minimum validation checks specified in [1:PXX.2.7](volume-1.html#1pxx27-fhir-payload-option) apply to all payload versions:

1. Well-formed FHIR JSON or XML conforming to the declared version.
2. Valid against the base resource definition for the declared version.
3. Valid against declared output StructureDefinition profiles when supplied. Output profiles SHALL be compatible with the payload version.
4. No direct identifiers remain in elements governed by the execution plan.
5. Internal references remain resolvable within the output graph or Bundle.
6. Remapped identifiers and references are consistent within the declared scope.
7. Narrative XHTML remains valid and contains no detected PHI for governed narrative targets.
8. Provenance evidence maps all required DIS evidence baseline elements.

A De-Identifier SHALL use a FHIR validation library or equivalent mechanism compatible with the declared payload version. Validation against the wrong FHIR version (e.g., validating R5 output against R4 definitions) is a conformance failure.
