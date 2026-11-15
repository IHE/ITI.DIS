<div id="execution-plan-content"> </div>
<div id="3pxx2-de-identification-execution-plan"> </div>
<div id="3pxx3-de-identification-execution-plan"> </div>

The execution plan is the task-specific artifact produced from a validated policy. The [policy compilation rules](#policy-compilation) define how policy rules become concrete payload selectors. The plan uses the [transformation actions](volume-3-policy.html#transformation-actions) defined by the policy section. [ITI-x3](volume-2.html#23x3-submit-de-identification-task-iti-x3) defines how the Manager dispatches the plan. [FHIR Addressing and Processing](volume-3-fhir-addressing.html) defines selector syntax, resource traversal, processing capabilities, and output validation for FHIR.

<div id="execution-plan-format"> </div>
<div id="3pxx14-execution-plan-format"> </div>
<div id="3pxx21-execution-plan-format"> </div>

## 3:PXX.3.1 Execution Plan Format

An execution plan is a task-specific FHIR R4 [Execution Plan Contract](StructureDefinition-DIS-ExecutionPlan.html). It carries a compiled [ODRL Set](odrl-content.html#execution-plan-set), uses the Set revision `uid` as its identifier, and carries the Manager in `authority` and the assigned De-Identifier in `subject`, both as Organization references. It supplies `id`, `meta.versionId`, `url`, `version`, `name`, and `issued`. The Set is carried in one inline `rule.contentAttachment` as Base64-encoded UTF-8 JSON-LD with content type `application/ld+json`. Apply the [shared Contract signature rules](volume-3-contract-rules.html#contract-signatures).

<div id="3pxx141-library-resource-structure"> </div>
<div id="3pxx211-execution-plan-contract-structure"> </div>

### 3:PXX.3.1.1 Execution Plan Contract Structure

<div id="execution-plan-source-policy"> </div>

The plan SHALL identify its source policy with exactly one `Contract.supportingInfo` reference to the Policy Contract, using an absolute HTTPS URL ending in `/Contract/{id}/_history/{vid}`. Before dispatch, the Manager SHALL verify that this reference identifies the exact Policy Contract approved by the selected permission. The Manager SHALL retain the exact authorization Contract revision and permission `uid` with the assignment. The De-Identifier SHALL confirm that the assignment parties match the plan and copy the source policy reference URL into the task's `Provenance.policy`. The De-Identifier can use the reference for evidence without retrieving the policy. The Manager SHALL verify that returned evidence names the same policy version before accepting or releasing the result. The reference SHALL exclude credentials and temporary access tokens.

<div id="policy-compilation"> </div>
<div id="3pxx24-policy-compilation"> </div>
<div id="3pxx14-policy-compilation"> </div>
<div id="3pxx15-policy-compilation"> </div>

## 3:PXX.3.2 Policy Compilation

Before dispatching tasks via ITI-x3, the De-ID Manager resolves targets against the payload binding and assembles the execution plan from the validated policy Contract.


### 3:PXX.3.2.1 Resolve Policy Targets

The De-ID Manager SHALL resolve DPV–ODRL targets using the DPV Category Mapping for the assigned release, [FHIR R4](#fhir-r4-dpv-mapping) or [FHIR R5](#fhir-r5-dpv-mapping). It SHALL produce concrete resource-local FHIRPath selectors for the verified assignment before dispatch.

<div id="compilation-and-evidence"> </div>

#### DPV–ODRL compilation and evidence

Use one immutable DPV mapping revision that applies to the assignment's binding, release, and manifest format. For standalone document export, the Integrated actor establishes a verified R4 resource selection from the authorized document entries before compilation. The Manager SHALL fail compilation if the selected revision does not cover the required targets.

1. The Manager admits the job under [ITI-x1](volume-2.html#23x1-submit-de-identification-job-iti-x1), including verification of the exact authorized Policy Contract revision and input scope. It chooses an immutable mapping revision for the assigned binding and release, checks the assignment against the mapping's declared scope, and verifies support for each category, role, location and applicable action.
2. The Manager resolves roles from verified assignment inputs. If role uncertainty could change the winning rule or its action for a selected element, the Manager SHALL fail compilation. It SHALL fail before dispatch when requested coverage is unsupported. A supported optional element that is absent contributes zero matches. The Manager retains the selector for an optional mapped element where the binding permits that selector to be evaluated independently of the element's presence.
3. The Manager compiles the [DIS Execution Plan Set](odrl-content.html#execution-plan-set) with `profile` equal to `disdpv:ExecutionPlan` and adds exactly one `disdpv:mappingRevision` as an absolute IRI reference. Every compiled obligation SHALL carry its `dis:sourceRule` and a concrete selector tied to the verified assignment manifest. The Manager SHALL preserve source rule order and the mapping's expansion order. The Manager SHALL check the dispatch actor's support for the DPV–ODRL Execution Plan profile and the applicable [processing capabilities](volume-3-fhir-addressing.html#fhir-processing-capabilities).
4. The De-Identifier checks the plan, its mapping revision for the declared binding and release, and the exact inputs verified for [ITI-x3](volume-2.html#23x3-submit-de-identification-task-iti-x3). It evaluates the concrete rules and validates the output. It uses the Plan Contract's exact source Policy Contract reference in `Provenance.policy`. The Manager records the authorization, plan, mapping revision, and returned evidence for the assignment. This trace stays subject to the existing DIS disclosure controls. Worker evidence need not disclose role-resolution details or source names.

<div id="execution-plan-assembly"> </div>
<div id="3pxx152-assemble-the-plan-and-check-capabilities"> </div>

### 3:PXX.3.2.2 Assemble the Plan and Check Capabilities

**Execution plan assembly.** The Manager preserves rule order and source rule IDs and adds the resolved scope to salted hash and encryption rules. The Manager binds the rules to the [verified assignment inputs](volume-3-payload-bindings.html#assigned-input-verification) and assembles the resolved or validated rules into a compiled [ODRL Execution Plan Set](odrl-content.html#execution-plan-set) and packages the plan in a Contract resource with `Contract.type` coding `dis-execution-plan` from the [DIS Document Type CodeSystem](CodeSystem-dis-document-type.html).

**Capability verification.** The De-ID Manager SHALL verify that the complete assignment is supported by the target De-Identifier's [declared processing capabilities](volume-3-fhir-addressing.html#fhir-processing-capabilities) before dispatch. The Integrated actor applies the same check before local execution.

For each applicable payload set, each ruleSet produces one execution plan Contract, dispatched as one ITI-x3 task for that set. When stages are declared, the Manager dispatches in stage order. Before dispatch, the Manager SHALL identify the exact source policy as specified in [Execution Plan Contract Structure](#execution-plan-source-policy).

<div id="fhir-r4-dpv-mapping"> </div>
<div id="3pxx4217-fhir-r4-dpv-category-mapping"> </div>

### 3:PXX.3.2.3 FHIR R4 DPV Category Mapping

<div id="fhir-r4-dpv-mapping-revision-2"> </div>
<div id="revision-2"> </div>

Use the [current draft FHIR R4 DPV Category Mapping (JSON-LD)](bindings/dis-fhir-r4-dpv-mapping-3.jsonld) to compile DPV–ODRL targets for FHIR R4 assignments. The [full CSV](bindings/dis-fhir-r4-dpv-mapping-3.csv) and the sample below are generated from the JSON-LD. The [resource review inventory (CSV)](bindings/dis-fhir-r4-dpv-resource-review-3.csv) distinguishes mapped declarations and other screened paths in the R4 core package.

The mapping uses DPV Personal Data Categories v2.3. It covers structured identifiers, demographics, contact and address information, family information, clinical information, prescriptions, insurance, and financial information, among other categories. Its entries define the exact scope for each category, person role, and location. A combination with no matching entry is unsupported for that assignment.

<!-- BEGIN GENERATED FHIR R4 DPV MAPPING SAMPLE 3 -->

| Order | DPV category | Person role | FHIR R4 target |
| --- | --- | --- | --- |
| 1 | `pd:Name` | `disdpv:patient` | `Patient.name` |
| 39 | `pd:PostalCode` | `disdpv:patient` | `Patient.address.postalCode` |
| 104 | `pd:EmailAddress` | `disdpv:patient` | `Patient.telecom.where(system = 'email')` |
| 202 | `pd:MedicalHealth` | `disdpv:patient` | `Condition.code` |
| 333 | `pd:Insurance` | `disdpv:patient` | `Coverage.type` |
{: .grid}

<!-- END GENERATED FHIR R4 DPV MAPPING SAMPLE 3 -->

The JSON-LD document has an embedded context and declares the payload binding, FHIR release and package, applicable manifest formats, DPV edition, and coverage rule. Each entry specifies a category, person role, location, expansion order, target path, selector language, role rule, and expansion rule. The Manager SHALL recognize the mapping revision and implement its referenced rules before compilation. It SHALL record the document's absolute `@id` in `disdpv:mappingRevision`. Changes to the mapping or to its referenced rule semantics require a new revision.

Read entries by increasing `order` and match `category` and `location` by exact IRI equality. For a specific person role, select entries for that role and apply the entry's role rule. An all-person-roles target selects entries for every role at the requested category and location. It can include both care-team members and other Practitioners in scope. In both cases, apply the entry's subject rule where specified.

An entry with `subjectPath` also carries `subjectResourceType` and `subjectRule`. For example, the entry for `Condition.code` uses `Condition.subject` and the resource type `Patient`. The Manager verifies that patient association before selecting the condition, including for an all-person-roles target. Some entries also restrict the FHIR type, code, or extension URL. Examples include HL7 R4 [Vital Signs](https://hl7.org/fhir/R4/observation-vitalsigns.html) for height and weight, [LOINC ABO and Rh group](https://loinc.org/882-1/) for blood type, and the FHIR R4 [Patient Birth Place extension](https://hl7.org/fhir/R4/extension-patient-birthplace.html). Email entries distinguish home and work use from the general `pd:EmailAddress` category.

Apply the [coverage rule](volume-3.html#fhir-r4-dpv-coverage-3), the [verified subject rule](volume-3.html#fhir-r4-dpv-verified-subject-2), and each entry's referenced role and expansion rules. Generate resource-local FHIRPath selectors for the verified assignment. Preserve source rule order and mapping expansion order within each rule. Deduplicate identical selectors from the same source obligation while preserving the first occurrence.

<div id="fhir-r5-dpv-mapping"> </div>

### 3:PXX.3.2.4 FHIR R5 DPV Category Mapping

Use the [FHIR R5 DPV Category Mapping (JSON-LD)](bindings/dis-fhir-r5-dpv-mapping-1.jsonld) for FHIR R5 assignments. The [CSV](bindings/dis-fhir-r5-dpv-mapping-1.csv) presents the same entries. Use the same DPV category and role identifiers in policies for either release.

The draft maps a reviewed subset of structured FHIR R5 locations. The [R4-to-R5 review (CSV)](bindings/dis-fhir-r4-to-r5-dpv-review-1.csv) records which R4 selectors carry forward and which still need review. It compares the pinned FHIR packages for element paths, types, cardinalities, terminology bindings, definitions, and any subject reference. Apply the [R5 coverage rule](volume-3.html#fhir-r5-dpv-coverage-1) and the referenced role and expansion rules. Fail compilation before dispatch when the requested target coverage is outside this mapping.

For example, a patient `pd:MedicalHealth` target can select `Encounter.actualPeriod` in R5 and `Encounter.period` in R4. A patient `pd:Identifying` target in the R5 report example selects `DiagnosticReport.subject` when the reference identifies a verified Patient in the assigned resources. Refer to the [HL7 R5 Encounter definitions](https://hl7.org/fhir/R5/encounter-definitions.html), [HL7 R5 DiagnosticReport definitions](https://hl7.org/fhir/R5/diagnosticreport-definitions.html), and the [UC-2 worked example](examples-grouped-fhir-job.html).

<div id="3pxx142-execution-plan-json-structure"> </div>
<div id="3pxx212-execution-plan-json-structure"> </div>
<div id="3pxx212-execution-plan-json-structure-and-rule-evaluation"> </div>
<div id="3pxx212-execution-plan-structure-and-rule-evaluation"> </div>

## 3:PXX.3.3 Execution Plan Structure and Rule Evaluation

The decoded plan attachment SHALL conform to the [DIS ODRL Execution Plan Set](odrl-content.html#execution-plan-set). Each compiled obligation SHALL identify its source policy obligation, a concrete selector and its resolved action parameters. The De-Identifier SHALL check the plan's set, rule-set, stage, binding and release declarations against the task before processing. It SHALL reject a plan that cannot be validated, including unrecognized selectors, actions or parameters. For a DPV–ODRL plan, it SHALL validate the [mapping revision](volume-3-execution-plan.html#compilation-and-evidence) for the declared binding and release.

Within one plan, the De-Identifier SHALL evaluate all selectors against the input resource before applying any action. A selector that matches no elements on a resource contributes no action for that resource. If several rules select the same concrete element instance, the De-Identifier SHALL use the first matching rule in the plan's rule order for that instance. Each occurrence of a repeated element is a distinct instance. This lets a policy keep an entire selected `Patient.identifier` occurrence before removing the other occurrences.

After resolving same-element matches, the De-Identifier SHALL check the selected ancestor and descendant targets for conflicting actions. If one action prevents the other from producing its defined result, the De-Identifier SHALL fail the task without returning partial output. For example, removing a `Patient.identifier` conflicts with keeping its `value`. Keeping a composite element also conflicts with modifying a descendant that would change the kept element. The outcome in these cases is the same regardless of rule order. The Integrated actor SHALL apply the same evaluation and failure rules during local execution.

Execution plans dispatched via ITI-x3 SHALL contain only concrete FHIRPath selectors for the assigned input.

<div id="3pxx143-execution-plan-example"> </div>
<div id="3pxx213-execution-plan-example"> </div>

## 3:PXX.3.4 Execution Plan Examples

See the [DPV–ODRL worked examples](examples-odrl.html#dpv-odrl-worked-examples) for compiled FHIR selectors and the recorded mapping revision. See the [decoded ODRL Execution Plan Set](examples-odrl.html#decoded-plan-example) for the R4 clinical assignment and the [UC-2 walkthrough](examples-grouped-fhir-job.html#grouped-fhir-dispatch) for the two FHIR processing releases and the [UC-3 clinical pathology workflow](examples-reversible-pathology.html) for an example involving a supplied lookup table.
