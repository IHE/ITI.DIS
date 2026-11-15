<a name="3pxx11-cross-version-payload-support"> </a>

<a name="cross-version-payload"> </a>

<a name="content-model"> </a>

<a name="3pxx12-content-model"> </a>

<a name="3pxx322-content-model"> </a>

<a name="3pxx321-cross-version-payload-support"> </a>

<a name="3pxx321-addressing-and-processing"> </a>

<a name="3pxx421-addressing-and-processing"> </a>

The declared payload release determines the element selectors, traversal of the target resources, and validation of the result.

<a name="3pxx111-version-identification"> </a>

<a name="3pxx3211-version-identification"> </a>

<a name="3pxx3211-fhir-release-and-capability-matching"> </a>

## 3:PXX.4.2.1.1 FHIR Release Identification

For a FHIR set, the `payloadVersion` field declares the FHIR release of the processing payload. The De-ID Manager SHALL reject a request if the declaration is absent or specifies a release other than `R4` or `R5`. The Manager SHALL use the same declaration in ITI-x3. A De-Identifier declaring DIS-FHIR-Payload SHALL advertise the payload releases it supports. The Manager SHALL verify that the assigned De-Identifier supports the declared release before dispatch and SHALL reject the job when no available De-Identifier supports that release. Source server capabilities and attachment metadata are used to check the declaration. The retrieving actor SHALL fail processing when the retrieved content or its version metadata conflicts with the declaration.

<a name="fhir-processing-capabilities"> </a>

## 3:PXX.4.2.1.2 FHIR Processing Capabilities

A De-Identifier or Integrated actor SHALL support and declare all nine [core actions](volume-3-policy.html#transformation-actions) for DIS-FHIR-Payload. This requirement applies to the actor's processing capabilities as a whole. An individual entry may advertise a subset of actions for its release and manifest formats.

Each [DIS Processing Capability](StructureDefinition-dis-processing-capability.html) entry describes one combination of binding, release, input and result manifest formats, and the actions supported together. For DIS-FHIR-Payload the input and result manifest formats in an entry SHALL match. De-Identifiers and externally invoked Integrated actors SHALL publish the entries on their implementation CapabilityStatement. They SHALL declare each supported reversibility mode separately using one [DIS Reversibility Support](StructureDefinition-dis-reversibility-support.html) extension with the applicable code (`irreversible` or `reversible`). A standalone Integrated actor SHALL make both declarations available for inspection as part of its content conformance claim. The Requester and Manager declare support for their transaction roles as specified in Volume 2.

Before dispatch, the De-ID Manager SHALL verify that the actor declares the job's reversibility mode under the [Volume 1 options](volume-1.html#tPXX.2-2) and that one processing entry covers the assigned binding, release, manifest formats and every required action. It SHALL also verify the action parameters and compliance with the selected option's rules. If any check fails, the Manager SHALL withhold dispatch. The Integrated actor applies the same checks locally. An actor advertising the optional `encrypt` action SHALL also declare the reversible option. AES-FF1 is permitted only in reversible assignments.

For example, a worker can declare both modes and list `hash` once for R4 resource-list payloads. In an irreversible assignment, a patient identifier `hash` rule executes without a DIS-maintained reverse mapping. In a reversible assignment using Manager-managed mappings, the worker returns the mappings the Manager needs for authorized reversal.

For each combination that includes `date-shift`, the processing actor SHALL document the supported derivation method and version, supported scope forms, patient identity inputs and limits for `maxOffsetDays`. The De-ID Manager SHALL verify compatibility with the assignment before dispatch and establish compatible derivation inputs across workers when the policy requires a consistent shift across tasks. The Integrated actor applies these checks locally. Provisioning of derivation material is deployment-defined. Confidential seeds and offsets are protected under the [custody rules](volume-1.html#1pxx54-reversibility-material-custody).

<a name="3pxx121-element-addressing"> </a>

<a name="3pxx113-version-neutral-element-addressing"> </a>

<a name="3pxx3213-version-neutral-element-addressing"> </a>

<a name="3pxx3221-element-addressing"> </a>

<a name="fhirpath-element-addressing"> </a>

<a name="3pxx3212-fhirpath-element-addressing"> </a>

## 3:PXX.4.2.1.3 FHIRPath Element Addressing

DIS-FHIR-Payload uses FHIRPath expressions as the element addressing language. Execution plan rules and semantic group definitions reference HL7 FHIR elements using FHIRPath-compatible path expressions rooted at the resource type.

An element path SHALL be one of the following forms:

- **Resource-rooted path** -- a FHIRPath expression starting with a resource type (e.g., `Patient.name`, `Observation.value`). The path identifies one or more elements within a single resource instance.
- **Semantic group reference** -- a reference to a named semantic group (e.g., `@subject-identifiers`). The `@` prefix distinguishes a semantic group reference from a FHIRPath expression. The group expands to its member paths at policy compilation time (see [policy compilation](volume-3-execution-plan.html#policy-compilation)).

A concrete selector SHALL identify locations of existing FHIR elements within the input resource, including individual occurrences of repeating elements. A filter such as `where()` may narrow the selection. Standalone calculated results such as `Patient.identifier.count()` are invalid transformation targets. A selector SHALL NOT follow a reference to select a target in another resource. The action definition determines which parts of a selected element it changes. If rules also select descendants, apply the [plan evaluation rules](volume-3-execution-plan.html#3pxx212-execution-plan-json-structure-and-rule-evaluation).

In FHIRPath, write the base name of a choice element, such as `Observation.value`. To select a specific type, use a type restriction such as `Observation.value.ofType(Quantity)`. It selects `valueQuantity` when present and yields no match for `valueString`. `Observation.value[x]` is the element definition label. `valueQuantity` is the FHIR JSON property name. For an unqualified selector such as `Observation.value`, the De-Identifier SHALL apply the action to the actual selected type under the action's type requirements. See the HL7 FHIRPath choice rules for [R4](https://hl7.org/fhir/R4/fhirpath.html#polymorphism-in-fhir) and [R5](https://hl7.org/fhir/R5/fhirpath.html#polymorphism-in-fhir).

Semantic-Level policies use the same group codes across releases. The [Semantic Group Binding](#3pxx3213-semantic-group-bindings) supplies release-specific selectors during compilation. For example, `@dates` selects the encounter period through `Encounter.period` in R4 and `Encounter.actualPeriod` in R5.

<a name="3pxx122-semantic-groups"> </a>

<a name="3pxx3222-semantic-groups"> </a>

<a name="3pxx3213-semantic-group-bindings"> </a>

## 3:PXX.4.2.1.4 Semantic Group Bindings

Semantic groups categorize HL7 FHIR elements by privacy sensitivity. Semantic-Level policies reference semantic groups instead of individual element paths. The De-ID Manager expands semantic group references to individual element paths during policy compilation (see [policy compilation](volume-3-execution-plan.html#policy-compilation)).

The [DIS Semantic Group CodeSystem](CodeSystem-dis-semantic-group.html) defines the group codes and their meanings. Table 3:PXX.4.2.1-1 is the authoritative FHIR Semantic Group Binding for selector membership and order by payload release. The table defines binding version 0.2.0 independently of the FHIR payload version.

The [R4/R5 PII path catalog](bindings/dis-fhir-pii-path-catalog-0.2.0.csv) and [classification and semantic group guide](fhir-semantic-group-guide.html) are informative. They help policy authors identify candidate FHIRPath selectors for syntax-level policies. Catalog groups and paths do not extend the selector membership defined in the table.

Binding version 0.2.0 assigns `Patient.birthDate` to `birth-dates` in both R4 and R5. When migrating a policy from version 0.1.0, review rules targeting `@dates` or `@subject-demographics` and add an explicit `@birth-dates` rule if the policy still governs birth date. If both older groups targeted birth date, resolve the intended action during migration.

Policies may use the applicable date actions or remove the birth date. If the policy needs to preserve age relative to a shifted event, use the same date-shift scope for both. Deriving an age band is a separate transformation that requires a reference event or date, band boundaries, handling for partial birth dates, and an output destination. The core action family does not define age-band derivation.

<a name="tPXX.3.2.2-1"> </a>

<p id="tPXX.3.2.1-1" class="tableTitle"><strong>Table 3:PXX.4.2.1-1: DIS FHIR Semantic Group Binding</strong></p>

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

For the declared FHIR payload release, the Manager SHALL expand each semantic group using the selectors in the corresponding release column of Table 3:PXX.4.2.1-1. The Manager SHALL preserve the listed selector order and the order of source policy rules. A selector with a concrete resource root applies to resources of that type. `DomainResource.text` applies to the narrative element on each governed resource derived from `DomainResource`.

The FHIR payload binding defines group membership. A policy selects groups and actions. It cannot change the group's selectors. The `subject-identifiers` group intentionally shares its two selectors with `subject-business-identifiers` and `subject-names`. Use the narrower groups when applying different actions to identifiers and names. A group containing a composite element selects the element as a whole. The separate action applicability rules still apply to every expanded target.

The `dates` group covers the listed structured temporal values. Its choice selectors constrain the selected FHIR types using `ofType()`. Free-text dates, ages, ranges, and schedules expressed as `Timing` are outside this binding. Other paths, including extensions and other references, require separate policy coverage as applicable. The binding does not establish that a policy covers all identifying content in a payload.

Implementations MAY define additional semantic groups beyond those listed in Table 3:PXX.4.2.1-1 for local governance requirements. Additional groups SHALL NOT conflict with the element assignments of the groups in Table 3:PXX.4.2.1-1.

<a name="3pxx123-resource-traversal"> </a>

<a name="3pxx3223-resource-traversal"> </a>

<a name="3pxx3214-resource-traversal"> </a>

## 3:PXX.4.2.1.5 Resource Traversal

An execution plan applies to a set of processing target resources. The De-Identifier SHALL traverse the processing target according to the following rules.

**Bundle traversal.** When the processing target is a Bundle, the De-Identifier SHALL apply execution plan rules to each entry resource in the Bundle. Rules are matched by the entry resource's resource type. Bundle metadata elements (`Bundle.id`, `Bundle.identifier`, `Bundle.timestamp`, `Bundle.link`) are not governed by resource-type-rooted rules; separate rules targeting `Bundle.*` paths are required to govern them.

**Contained resources.** When a processing target resource contains other resources via `Resource.contained`, the De-Identifier SHALL apply execution plan rules to each contained resource according to its resource type. References from the containing resource to contained resources (e.g., `#contained-id`) SHALL be updated if the contained resource's identifier is transformed.

**Reference chains.** In by-reference delivery mode, the processing target MAY include references to resources not included in the processing target set. The De-Identifier SHALL NOT follow references outside the processing target set. Only resources explicitly included in the processing target (directly or as Bundle entries) are governed by the execution plan. Reference elements pointing to resources outside the processing target set are governed by rules targeting the `references` semantic group.

<a name="3pxx115-validation-across-versions"> </a>

<a name="3pxx3215-validation-across-versions"> </a>

<a name="3pxx3215-output-validation-in-the-declared-release"> </a>

## 3:PXX.4.2.1.6 Output Validation in the Declared Release

De-identified output SHALL be validated against the processing payload's declared HL7 FHIR version, not against the HL7 FHIR R4 protocol binding version.

The following minimum validation checks apply to all payload versions:

1. Well-formed HL7 FHIR JSON or XML conforming to the declared version.
2. Valid against the base resource definition for the declared version.
3. Valid against declared output StructureDefinition profiles when supplied. Output profiles SHALL be compatible with the payload version.
4. Each governed element matches its authorized action. A direct identifier may remain only where the approved policy explicitly permits its retention.
5. Internal references remain resolvable within the output graph or Bundle.
6. Remapped identifiers and references are consistent within the declared scope.
7. Narrative XHTML remains valid and contains no detected PHI for governed narrative targets.
8. Provenance evidence maps all required DIS evidence baseline elements (see [De-Identification Evidence](volume-3-evidence.html#evidence-baseline)).

A De-Identifier SHALL use an HL7 FHIR validation library or equivalent mechanism compatible with the declared payload version. Validation against the wrong HL7 FHIR version (e.g., validating HL7 FHIR R5 output against HL7 FHIR R4 definitions) is a conformance failure.

<a name="3pxx22-fhir-reference-integrity"> </a>

<a name="fhir-reference-integrity"> </a>

**FHIR reference integrity.**

The De-Identifier SHALL ensure that references between retained resources resolve correctly in the de-identified output. In a Bundle, this includes keeping `Bundle.entry.fullUrl` values and internal references consistent with the resource identities in the output. Handle references to removed resources and external references according to the approved policy. The De-Identifier SHALL fail the task without partial output if it cannot produce a valid result under the declared FHIR version and policy.

Patient pseudonymization transforms the business identifier pair in `Patient.identifier`. See [Patient Identifier Pseudonymization](volume-3-policy.html#3pxx123-patient-identifier-pseudonymization) for the supported methods. The output packaging rules govern FHIR resource identities and references.

<a name="fhir-r4-dpv-mapping"> </a>

## 3:PXX.4.2.1.7 FHIR R4 DPV Category Mapping

For the [DPV–ODRL policy profile](volume-3-policy.html#dpv-odrl-policy-profile), an implementation claiming FHIR R4 mapping support SHALL use the [normative FHIR R4 mapping revision 1 (JSON-LD)](bindings/dis-fhir-r4-dpv-mapping-1.jsonld). The [full CSV](bindings/dis-fhir-r4-dpv-mapping-1.csv) and the sample below are generated from that artifact and identify the same revision. The [resource review inventory (CSV)](bindings/dis-fhir-r4-dpv-resource-review-1.csv) records the 146 concrete R4 resources and the two abstract base definitions examined for this mapping.

<!-- BEGIN GENERATED FHIR R4 DPV MAPPING SAMPLE -->

| Order | DPV category | Person role | FHIR R4 target |
| --- | --- | --- | --- |
| 1 | `pd:Name` | `disdpv:patient` | `Patient.name` |
| 3 | `pd:Name` | `disdpv:care-provider` | `Practitioner.name` |
| 5 | `pd:BirthDate` | `disdpv:patient` | `Patient.birthDate` |
| 18 | `pd:Name` | `disdpv:contact-person` | `ContactDetail.name` |
{: .grid}

<!-- END GENERATED FHIR R4 DPV MAPPING SAMPLE -->

The JSON-LD document's absolute `@id` is the mapping revision used in the compiled plan. Its context is embedded. The document identifies the payload binding, FHIR release, exact FHIR package, manifest format, DPV edition, and coverage rule. Each entry supplies a category IRI, role IRI, location IRI, unique positive integer expansion order, target path, selector language, role rule IRI, and expansion rule IRI. The Manager SHALL recognize the pinned mapping revision and implement its referenced rules before compilation. Changes to the mapping or its referenced rule semantics require a new revision.

Read the entries by increasing `order`. Match `category` and `location` by exact IRI equality. A request for a specific role selects entries for that role and applies the entry's `roleRule`. A request for `disdpv:all-person-roles` selects every entry for the category and location and includes each instance irrespective of role. In particular, it uses `Practitioner.name` for both care-team members and other Practitioners in scope. A tuple that has no mapping is unsupported. Apply the mapping entry's `expansionRule` to produce resource-local FHIRPath selectors for the verified assignment. Preserve the policy's source rule order and the mapping's expansion order within each rule. Deduplicate identical selectors produced for the same source obligation while preserving first occurrence.

{% include fhir-r4-dpv-mapping-rules.md %}
