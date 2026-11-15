<a name="execution-plan-content"> </a>

<a name="3pxx2-de-identification-execution-plan"> </a>

<a name="3pxx3-de-identification-execution-plan"> </a>

The execution plan is the task-specific artifact produced from a validated policy. The [policy compilation rules](#policy-compilation) define how policy rules become concrete payload selectors. The plan uses the [transformation actions](volume-3-policy.html#transformation-actions) defined by the policy section. [ITI-x3](volume-2.html#23x3-submit-de-identification-task-iti-x3) defines how the Manager dispatches the plan. [FHIR Addressing and Processing](volume-3-fhir-addressing.html) defines selector syntax, resource traversal, processing capabilities, and output validation for FHIR.

<a name="execution-plan-format"> </a>

<a name="3pxx14-execution-plan-format"> </a>

<a name="3pxx21-execution-plan-format"> </a>

## 3:PXX.3.1 Execution Plan Format

An execution plan is a task-specific FHIR R4 [Execution Plan Contract](StructureDefinition-DIS-ExecutionPlan.html). It carries a compiled [ODRL Set](odrl-content.html#execution-plan-set), uses the Set revision `uid` as its identifier, and carries the Manager in `authority` and the assigned De-Identifier in `subject`, both as Organization references. It supplies `id`, `meta.versionId`, `url`, `version`, `name`, and `issued`. The Set is carried in one inline `rule.contentAttachment` as Base64-encoded UTF-8 JSON-LD with content type `application/ld+json`. Apply the [shared Contract signature rules](volume-3-contract-rules.html#contract-signatures).

<a name="3pxx141-library-resource-structure"> </a>

<a name="3pxx211-execution-plan-contract-structure"> </a>

### 3:PXX.3.1.1 Execution Plan Contract Structure

<a name="execution-plan-source-policy"> </a>

The plan SHALL identify its source policy with exactly one `Contract.supportingInfo` reference to the Policy Contract, using an absolute HTTPS URL ending in `/Contract/{id}/_history/{vid}`. Before dispatch, the Manager SHALL verify that this reference identifies the exact Policy Contract approved by the selected permission. The Manager SHALL retain the exact authorization Contract revision and permission `uid` with the assignment. The De-Identifier SHALL confirm that the assignment parties match the plan and copy the source policy reference URL into the task's `Provenance.policy`. The De-Identifier can use the reference for evidence without retrieving the policy. The Manager SHALL verify that returned evidence names the same policy version before accepting or releasing the result. The reference SHALL exclude credentials and temporary access tokens.

<a name="policy-compilation"> </a>

<a name="3pxx24-policy-compilation"> </a>

<a name="3pxx14-policy-compilation"> </a>

<a name="3pxx15-policy-compilation"> </a>

## 3:PXX.3.2 Policy Compilation

Before dispatching tasks via ITI-x3, the De-ID Manager resolves targets against the payload binding and assembles the execution plan from the validated policy Contract.

<a name="3pxx241-semantic-level-compilation"> </a>

<a name="3pxx141-semantic-level-compilation"> </a>

<a name="3pxx242-syntax-level-validation"> </a>

<a name="3pxx142-syntax-level-validation"> </a>

<a name="3pxx152-syntax-level-validation"> </a>

<a name="3pxx151-semantic-level-compilation"> </a>

<a name="3pxx151-resolve-semantic-groups-or-validate-concrete-selectors"> </a>

<a name="3pxx321-resolve-semantic-groups-or-validate-concrete-selectors"> </a>

### 3:PXX.3.2.1 Resolve Policy Targets

**Semantic-Level policies.** The De-ID Manager SHALL resolve each `@` group reference using the [Semantic Group Binding](volume-3-fhir-addressing.html#3pxx3213-semantic-group-bindings) for the declared payload family and release. If a referenced group has no binding for that release, the Manager SHALL fail compilation before dispatch.

**Syntax-Level policies.** The De-ID Manager verifies that all rule targets are valid element paths for the declared `payloadFamily` and `payloadVersion`. For HL7 FHIR payloads, the Manager SHALL validate each target against the [FHIRPath element addressing rules](volume-3-fhir-addressing.html#fhirpath-element-addressing) for the declared FHIR release before dispatch. The Manager verifies that the policy's declared `payloadFamily` and `payloadVersion` are consistent with the `payloadBinding` and `payloadVersion` in the ITI-x1 request. The Manager preserves concrete paths without semantic group expansion or version-conditional path mapping.

<a name="compilation-and-evidence"> </a>

#### DPV–ODRL compilation and evidence

Use the immutable mapping for the assigned payload binding and release. Select one supported [FHIR R4 DPV mapping revision](#fhir-r4-dpv-mapping) per FHIR R4 assignment. The Manager SHALL fail compilation if the selected revision does not cover the required targets.

1. The Manager admits the job under [ITI-x1](volume-2.html#23x1-submit-de-identification-job-iti-x1), including verification of the exact authorized Policy Contract revision and input scope. It chooses an immutable mapping revision for the assigned binding and release, checks the assignment against the mapping's declared scope, and verifies support for each category, role, location and applicable action.
2. The Manager resolves roles from verified assignment inputs. If role uncertainty could change the winning rule or its action for a selected element, the Manager SHALL fail compilation. It SHALL fail before dispatch when requested coverage is unsupported. A supported optional element that is absent contributes zero matches. The Manager retains the selector for an optional mapped element where the binding permits that selector to be evaluated independently of the element's presence.
3. The Manager compiles the [DIS Execution Plan Set](odrl-content.html#execution-plan-set) with `profile` equal to `disdpv:ExecutionPlan` and adds exactly one `disdpv:mappingRevision` as an absolute IRI reference. Every compiled obligation SHALL carry its `dis:sourceRule` and a concrete selector tied to the verified assignment manifest. The Manager SHALL preserve source rule order and the mapping's expansion order. The Manager SHALL check the dispatch actor's support for the DPV–ODRL Execution Plan profile and the applicable [processing capabilities](volume-3-fhir-addressing.html#fhir-processing-capabilities).
4. The De-Identifier checks the plan, its mapping revision for the declared binding and release, and the exact inputs verified for [ITI-x3](volume-2.html#23x3-submit-de-identification-task-iti-x3). It evaluates the concrete rules and validates the output. It uses the Plan Contract's exact source Policy Contract reference in `Provenance.policy`. The Manager records the authorization, plan, mapping revision, and returned evidence for the assignment. This trace stays subject to the existing DIS disclosure controls. Worker evidence need not disclose role-resolution details or source names.

<a name="execution-plan-assembly"> </a>

<a name="3pxx152-assemble-the-plan-and-check-capabilities"> </a>

### 3:PXX.3.2.2 Assemble the Plan and Check Capabilities

**Execution plan assembly.** The Manager preserves rule order and source rule IDs and adds the resolved scope to salted hash and encryption rules. The Manager binds the rules to the [verified assignment inputs](volume-3-payload-bindings.html#assigned-input-verification) and assembles the resolved or validated rules into a compiled [ODRL Execution Plan Set](odrl-content.html#execution-plan-set) and packages the plan in a Contract resource with `Contract.type` coding `dis-execution-plan` from the [DIS Document Type CodeSystem](CodeSystem-dis-document-type.html).

**Capability verification.** The De-ID Manager SHALL verify that the complete assignment is supported by the target De-Identifier's [declared processing capabilities](volume-3-fhir-addressing.html#fhir-processing-capabilities) before dispatch. The Integrated actor applies the same check before local execution.

For each applicable payload set, each ruleSet produces one execution plan Contract, dispatched as one ITI-x3 task for that set. When stages are declared, the Manager dispatches in stage order. Before dispatch, the Manager SHALL identify the exact source policy as specified in [Execution Plan Contract Structure](#execution-plan-source-policy).

<a name="fhir-r4-dpv-mapping"> </a>

<a name="3pxx4217-fhir-r4-dpv-category-mapping"> </a>

### 3:PXX.3.2.3 FHIR R4 DPV Category Mapping

<a name="fhir-r4-dpv-mapping-revision-2"> </a>

#### Revision 2

Use [FHIR R4 mapping revision 2 (JSON-LD)](bindings/dis-fhir-r4-dpv-mapping-2.jsonld) to compile assignments needing its broader coverage. The [full CSV](bindings/dis-fhir-r4-dpv-mapping-2.csv) and the sample below are generated from the JSON-LD. The [resource review inventory (CSV)](bindings/dis-fhir-r4-dpv-resource-review-2.csv) distinguishes mapped declarations and other screened paths in the R4 core package.

Revision 2 uses the DPV Personal Data Categories v2.3 edition. It covers structured identifiers, demographics, contact and address information, family information, clinical information, prescriptions, insurance, and financial information, among other categories. The mapping's entries define the exact scope of each category. A category IRI with no entry for the requested role and location is unsupported for that assignment.

<!-- BEGIN GENERATED FHIR R4 DPV MAPPING SAMPLE 2 -->

| Order | DPV category | Person role | FHIR R4 target |
| --- | --- | --- | --- |
| 1 | `pd:Name` | `disdpv:patient` | `Patient.name` |
| 39 | `pd:PostalCode` | `disdpv:patient` | `Patient.address.postalCode` |
| 104 | `pd:EmailAddress` | `disdpv:patient` | `Patient.telecom.where(system = 'email')` |
| 202 | `pd:MedicalHealth` | `disdpv:patient` | `Condition.code` |
| 333 | `pd:Insurance` | `disdpv:patient` | `Coverage.type` |
{: .grid}

<!-- END GENERATED FHIR R4 DPV MAPPING SAMPLE 2 -->

The JSON-LD uses the same entry structure as revision 1. An entry with `subjectPath` also carries `subjectResourceType` and `subjectRule`. These properties bind a contextual occurrence to a person represented by an assigned resource. For example, an entry for `Condition.code` uses `Condition.subject` and the resource type `Patient`. The verifier must establish the patient association before selecting the condition, including for an all-person-roles target. Static person roles and the care-team exception continue to use their versioned role rules.

Some entries limit the selector to a particular FHIR type, code, or extension URL. Examples include HL7 R4 [Vital Signs](https://hl7.org/fhir/R4/observation-vitalsigns.html) observations for height and weight, [LOINC ABO and Rh group](https://loinc.org/882-1/) for blood type, and the FHIR R4 [Patient Birth Place extension](https://hl7.org/fhir/R4/extension-patient-birthplace.html) for birthplace. A contact point with email system and home use matches personal email. A contact point with email system and work use matches work email. Selecting `pd:EmailAddress` uses the entry for the general email system.

Apply the [revision 2 coverage rule](volume-3.html#fhir-r4-dpv-coverage-2), the [verified subject rule](volume-3.html#fhir-r4-dpv-verified-subject-2), and the entry's expansion rule. The Manager SHALL record the exact revision used in `disdpv:mappingRevision`. For example, a plan compiled with revision 1 carries its revision 1 IRI even when revision 2 is available.

<a name="fhir-r4-dpv-mapping-revision-1"> </a>

#### Revision 1

For an assignment using the [DPV–ODRL policy profile](volume-3-policy.html#dpv-odrl-policy-profile) with mapping revision 1, use the [normative FHIR R4 mapping revision 1 (JSON-LD)](bindings/dis-fhir-r4-dpv-mapping-1.jsonld). The [full CSV](bindings/dis-fhir-r4-dpv-mapping-1.csv) and the sample below are generated from that artifact and identify the same revision. The [resource review inventory (CSV)](bindings/dis-fhir-r4-dpv-resource-review-1.csv) records the 146 concrete R4 resources and the two abstract base definitions examined for this mapping.

<!-- BEGIN GENERATED FHIR R4 DPV MAPPING SAMPLE 1 -->

| Order | DPV category | Person role | FHIR R4 target |
| --- | --- | --- | --- |
| 1 | `pd:Name` | `disdpv:patient` | `Patient.name` |
| 3 | `pd:Name` | `disdpv:care-provider` | `Practitioner.name` |
| 5 | `pd:BirthDate` | `disdpv:patient` | `Patient.birthDate` |
| 18 | `pd:Name` | `disdpv:contact-person` | `ContactDetail.name` |
{: .grid}

<!-- END GENERATED FHIR R4 DPV MAPPING SAMPLE 1 -->

The JSON-LD document's absolute `@id` is the mapping revision used in the compiled plan. Its context is embedded. The document identifies the payload binding, FHIR release, exact FHIR package, manifest format, DPV edition, and coverage rule. Each entry supplies a category IRI, role IRI, location IRI, unique positive integer expansion order, target path, selector language, role rule IRI, and expansion rule IRI. The Manager SHALL recognize the pinned mapping revision and implement its referenced rules before compilation. Changes to the mapping or its referenced rule semantics require a new revision.

Read the entries by increasing `order`. Match `category` and `location` by exact IRI equality. A request for a specific role selects entries for that role and applies the entry's `roleRule`. A request for `disdpv:all-person-roles` selects every entry for the category and location and includes each instance irrespective of role. In particular, it uses `Practitioner.name` for both care-team members and other Practitioners in scope. A tuple that has no mapping is unsupported. Apply the mapping entry's `expansionRule` to produce resource-local FHIRPath selectors for the verified assignment. Preserve the policy's source rule order and the mapping's expansion order within each rule. Deduplicate identical selectors produced for the same source obligation while preserving first occurrence.

{% include fhir-r4-dpv-mapping-rules.md %}

<a name="3pxx142-execution-plan-json-structure"> </a>

<a name="3pxx212-execution-plan-json-structure"> </a>

<a name="3pxx212-execution-plan-json-structure-and-rule-evaluation"> </a>

<a name="3pxx212-execution-plan-structure-and-rule-evaluation"> </a>

## 3:PXX.3.3 Execution Plan Structure and Rule Evaluation

The decoded plan attachment SHALL conform to the [DIS ODRL Execution Plan Set](odrl-content.html#execution-plan-set). Each compiled obligation SHALL identify its source policy obligation, a concrete selector and its resolved action parameters. The De-Identifier SHALL check the plan's set, rule-set, stage, binding and release declarations against the task before processing. It SHALL reject a plan that cannot be validated, including unrecognized selectors, actions or parameters. For a DPV–ODRL plan, it SHALL validate the [mapping revision](volume-3-execution-plan.html#compilation-and-evidence) for the declared binding and release.

Within one plan, the De-Identifier SHALL evaluate all selectors against the input resource before applying any action. A selector that matches no elements on a resource contributes no action for that resource. If several rules select the same concrete element instance, the De-Identifier SHALL use the first matching rule in the plan's rule order for that instance. Each occurrence of a repeated element is a distinct instance. This lets a policy keep an entire selected `Patient.identifier` occurrence before removing the other occurrences.

After resolving same-element matches, the De-Identifier SHALL check the selected ancestor and descendant targets for conflicting actions. If one action prevents the other from producing its defined result, the De-Identifier SHALL fail the task without returning partial output. For example, removing a `Patient.identifier` conflicts with keeping its `value`. Keeping a composite element also conflicts with modifying a descendant that would change the kept element. The outcome in these cases is the same regardless of rule order. The Integrated actor SHALL apply the same evaluation and failure rules during local execution.

Execution plans dispatched via ITI-x3 SHALL contain only concrete element paths. Semantic group references (`@` prefix) SHALL have been expanded by the De-ID Manager during policy compilation. The presence of an unresolved `@` reference in a dispatched execution plan is a conformance error.

<a name="3pxx143-execution-plan-example"> </a>

<a name="3pxx213-execution-plan-example"> </a>

## 3:PXX.3.4 Execution Plan Examples

See the [DPV–ODRL worked examples](examples-odrl.html#dpv-odrl-worked-examples) for compiled FHIR selectors and the recorded mapping revision. See the [decoded ODRL Execution Plan Set](examples-odrl.html#decoded-plan-example) for the R4 clinical assignment and the [UC-2 walkthrough](examples-grouped-fhir-job.html#grouped-fhir-dispatch) for the two FHIR processing releases and the [UC-3 clinical pathology workflow](examples-reversible-pathology.html) for an example involving a supplied lookup table.
