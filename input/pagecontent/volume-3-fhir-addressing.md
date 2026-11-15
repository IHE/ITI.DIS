<div id="3pxx11-cross-version-payload-support"> </div>
<div id="cross-version-payload"> </div>
<div id="content-model"> </div>
<div id="3pxx12-content-model"> </div>
<div id="3pxx322-content-model"> </div>
<div id="3pxx321-cross-version-payload-support"> </div>
<div id="3pxx321-addressing-and-processing"> </div>
<div id="3pxx421-addressing-and-processing"> </div>

The declared payload release determines the element selectors, traversal of the target resources, and validation of the result. See [FHIR Release Identification](volume-3-payload-bindings.html#3pxx421-fhir-release-identification) for release declarations in transaction messages and the DPV Category Mappings for [FHIR R4](volume-3-execution-plan.html#fhir-r4-dpv-mapping) and [FHIR R5](volume-3-execution-plan.html#fhir-r5-dpv-mapping) for mapping DPV–ODRL targets.

<div id="fhir-processing-capabilities"> </div>
<div id="3pxx4212-fhir-processing-capabilities"> </div>
<div id="markdown-toc-3pxx4212-fhir-processing-capabilities"> </div>

## 3:PXX.3.5.1 FHIR Processing Capabilities

A De-Identifier declaring DIS-FHIR-Payload SHALL advertise the payload releases it supports. The Manager SHALL verify that the assigned De-Identifier supports the declared release before dispatch and SHALL reject the job when no available De-Identifier supports that release.

A De-Identifier or Integrated actor SHALL support and declare all nine [core actions](volume-3-policy.html#transformation-actions) for DIS-FHIR-Payload. This requirement applies to the actor's processing capabilities as a whole. An individual entry may advertise a subset of actions for its release and manifest formats.

Each [DIS Processing Capability](StructureDefinition-dis-processing-capability.html) entry describes one combination of binding, release, input and result manifest formats, and the actions supported together. For DIS-FHIR-Payload the input and result manifest formats in an entry SHALL match. De-Identifiers and externally invoked Integrated actors SHALL publish the entries on their implementation CapabilityStatement. They SHALL declare each supported reversibility mode separately using one [DIS Reversibility Support](StructureDefinition-dis-reversibility-support.html) extension with the applicable code (`irreversible` or `reversible`). A standalone Integrated actor SHALL make both declarations available for inspection as part of its content conformance claim. The Requester and Manager declare support for their transaction roles as specified in Volume 2.

Before dispatch, the De-ID Manager SHALL verify that the actor declares the job's reversibility mode under the [Volume 1 options](volume-1.html#tPXX.2-2) and that one processing entry covers the assigned binding, release, manifest formats and every required action. It SHALL also verify the action parameters and compliance with the selected option's rules. If any check fails, the Manager SHALL withhold dispatch. The Integrated actor applies the same checks locally. An actor advertising the optional `encrypt` action SHALL also declare the reversible option. AES-FF1 is permitted only in reversible assignments.

For example, a worker can declare both modes and list `hash` once for R4 resource-list payloads. In an irreversible assignment, a patient identifier `hash` rule executes without a DIS-maintained reverse mapping. In a reversible assignment using Manager-managed mappings, the worker returns the mappings the Manager needs for authorized reversal.

For each combination that includes `date-shift`, the processing actor SHALL document the supported derivation method and version, supported scope forms, patient identity inputs and limits for `maxOffsetDays`. The De-ID Manager SHALL verify compatibility with the assignment before dispatch and establish compatible derivation inputs across workers when the policy requires a consistent shift across tasks. The Integrated actor applies these checks locally. Provisioning of derivation material is deployment-defined. Confidential seeds and offsets are protected under the [custody rules](volume-1.html#1pxx54-reversibility-material-custody).

<div id="3pxx121-element-addressing"> </div>
<div id="3pxx113-version-neutral-element-addressing"> </div>
<div id="3pxx3213-version-neutral-element-addressing"> </div>
<div id="3pxx3221-element-addressing"> </div>
<div id="fhirpath-element-addressing"> </div>
<div id="3pxx3212-fhirpath-element-addressing"> </div>
<div id="3pxx4213-fhirpath-element-addressing"> </div>
<div id="markdown-toc-3pxx4213-fhirpath-element-addressing"> </div>

## 3:PXX.3.5.2 FHIRPath Element Addressing

The FHIR R4 DPV Category Mapping and compiled execution plans use [FHIRPath](https://hl7.org/fhirpath/) to address elements. A compiled selector starts at the concrete resource type and selects elements within a single resource instance.

A concrete selector SHALL identify locations of existing FHIR elements within the input resource, including individual occurrences of repeating elements. A filter such as `where()` may narrow the selection. Standalone calculated results such as `Patient.identifier.count()` are invalid transformation targets. A selector SHALL NOT follow a reference to select a target in another resource. The action definition determines which parts of a selected element it changes. If rules also select descendants, apply the [plan evaluation rules](volume-3-execution-plan.html#3pxx212-execution-plan-json-structure-and-rule-evaluation).

In FHIRPath, write the base name of a choice element, such as `Observation.value`. To select a specific type, use a type restriction such as `Observation.value.ofType(Quantity)`. It selects `valueQuantity` when present and yields no match for `valueString`. `Observation.value[x]` is the element definition label. `valueQuantity` is the FHIR JSON property name. For an unqualified selector such as `Observation.value`, the De-Identifier SHALL apply the action to the actual selected type under the action's type requirements. See the HL7 FHIRPath choice rules for [R4](https://hl7.org/fhir/R4/fhirpath.html#polymorphism-in-fhir) and [R5](https://hl7.org/fhir/R5/fhirpath.html#polymorphism-in-fhir).

<div id="3pxx123-resource-traversal"> </div>
<div id="3pxx3223-resource-traversal"> </div>
<div id="3pxx3214-resource-traversal"> </div>
<div id="3pxx4215-resource-traversal"> </div>
<div id="markdown-toc-3pxx4215-resource-traversal"> </div>

<div id="3pxx354-resource-traversal"> </div>

## 3:PXX.3.5.3 Resource Traversal

An execution plan applies to a set of processing target resources. The De-Identifier SHALL traverse the processing target according to the following rules.

**Bundle traversal.** When the processing target is a Bundle, the De-Identifier SHALL apply execution plan rules to each entry resource in the Bundle. Rules are matched by the entry resource's resource type. Bundle metadata elements (`Bundle.id`, `Bundle.identifier`, `Bundle.timestamp`, `Bundle.link`) are not governed by resource-type-rooted rules; separate rules targeting `Bundle.*` paths are required to govern them.

**Contained resources.** When a processing target resource contains other resources via `Resource.contained`, the De-Identifier SHALL apply execution plan rules to each contained resource according to its resource type. References from the containing resource to contained resources (e.g., `#contained-id`) SHALL be updated if the contained resource's identifier is transformed.

**Reference chains.** In by-reference delivery mode, the processing target MAY include references to resources not included in the processing target set. The De-Identifier SHALL NOT follow references outside the processing target set. Only resources explicitly included in the processing target (directly or as Bundle entries) are governed by the execution plan. A reference element is a transformation target only when the applicable DPV mapping and compiled selector cover that element.

<div id="3pxx115-validation-across-versions"> </div>
<div id="3pxx3215-validation-across-versions"> </div>
<div id="3pxx3215-output-validation-in-the-declared-release"> </div>
<div id="3pxx4216-output-validation-in-the-declared-release"> </div>
<div id="markdown-toc-3pxx4216-output-validation-in-the-declared-release"> </div>

<div id="3pxx355-output-validation-in-the-declared-release"> </div>

## 3:PXX.3.5.4 Output Validation in the Declared Release

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

<div id="3pxx22-fhir-reference-integrity"> </div>
<div id="fhir-reference-integrity"> </div>

**FHIR reference integrity.**

The De-Identifier SHALL ensure that references between retained resources resolve correctly in the de-identified output. In a Bundle, this includes keeping `Bundle.entry.fullUrl` values and internal references consistent with the resource identities in the output. Handle references to removed resources and external references according to the approved policy. The De-Identifier SHALL fail the task without partial output if it cannot produce a valid result under the declared FHIR version and policy.

Patient pseudonymization transforms the business identifier pair in `Patient.identifier`. See [Patient Identifier Pseudonymization](volume-3-policy.html#3pxx123-patient-identifier-pseudonymization) for the supported methods. The output packaging rules govern FHIR resource identities and references.

<details>
<summary>Earlier section links</summary>
<ul>
<li><a name="3pxx111-version-identification"> </a><a name="3pxx3211-version-identification"> </a><a name="3pxx3211-fhir-release-and-capability-matching"> </a><a name="3pxx4211-fhir-release-identification"> </a><a name="markdown-toc-3pxx4211-fhir-release-identification"> </a><a href="volume-3-payload-bindings.html#3pxx421-fhir-release-identification">FHIR Release Identification</a></li>
<li><a name="fhir-r4-dpv-mapping"> </a><a name="3pxx4217-fhir-r4-dpv-category-mapping"> </a><a name="markdown-toc-3pxx4217-fhir-r4-dpv-category-mapping"> </a><a href="volume-3-execution-plan.html#fhir-r4-dpv-mapping">FHIR R4 DPV Category Mapping</a></li>
<li><a name="fhir-r4-dpv-coverage-1"> </a><a href="volume-3.html#fhir-r4-dpv-coverage-1">Coverage rule, revision 1</a></li>
<li><a name="fhir-r4-dpv-declared-role-1"> </a><a href="volume-3.html#fhir-r4-dpv-declared-role-1">Declared role rule, revision 1</a></li>
<li><a name="fhir-r4-dpv-care-team-role-1"> </a><a href="volume-3.html#fhir-r4-dpv-care-team-role-1">Care-team role rule, revision 1</a></li>
<li><a name="fhir-r4-dpv-local-path-1"> </a><a href="volume-3.html#fhir-r4-dpv-local-path-1">Resource-local expansion rule, revision 1</a></li>
<li><a name="fhir-r4-dpv-contact-detail-1"> </a><a href="volume-3.html#fhir-r4-dpv-contact-detail-1">ContactDetail expansion rule, revision 1</a></li>
</ul>
</details>
