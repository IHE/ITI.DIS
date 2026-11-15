Volume 3 defines the DIS content artifacts, their carriers, and their validation rules. [Volume 1](volume-1.html) describes the actors and options. [Volume 2](volume-2.html) defines the exchanges that carry these artifacts, including admission, dispatch, and result retrieval.

The approved data request identifies the policy and covered inputs. The De-ID Manager compiles the policy for the declared payload binding and release. The De-Identifier applies the plan to the assigned content and returns validated output and evidence. The Integrated actor performs those functions locally when it claims standalone conformance.

| Content specification | Bindings and related content | Worked example |
|---|---|---|
| [Data Request Authorization](volume-3-authorization.html#data-request-authorization) | [Authorization Contract](StructureDefinition-DIS-DataRequestAuthorizationContract.html) and [ODRL Agreement](odrl-content.html#odrl-authorization) | [UC-2 decoded Agreement](examples-odrl.html#decoded-authorization-example) |
| [De-Identification Policy](volume-3-policy.html#de-identification-policy) | [Policy Contract](StructureDefinition-DIS-Policy.html) and [ODRL Policy Set](odrl-content.html#de-identification-policy-set)<br />[Normative DPV–ODRL profile](volume-3-policy.html#dpv-odrl-policy-profile) and [transformation actions](volume-3-policy.html#transformation-actions) | [UC-2 decoded Policy Set](examples-odrl.html#decoded-policy-example) |
| [De-Identification Execution Plan](volume-3-execution-plan.html#execution-plan-content) | [Execution Plan Contract](StructureDefinition-DIS-ExecutionPlan.html) and [ODRL Execution Plan Set](odrl-content.html#execution-plan-set) | [UC-2 decoded Execution Plan](examples-odrl.html#decoded-plan-example) |
| [Payload Bindings](volume-3-payload-bindings.html#payload-bindings) | [FHIR payload binding](volume-3-payload-bindings.html#fhir-payload-binding), [input manifest](StructureDefinition-DIS-ResourceManifest.html), and [result package](StructureDefinition-DIS-ResultPackage.html)<br />[FHIR R4 DPV mapping](#fhir-r4-dpv-mapping) ([JSON-LD](bindings/dis-fhir-r4-dpv-mapping-1.jsonld), [CSV](bindings/dis-fhir-r4-dpv-mapping-1.csv))<br />[Proposed DICOM and CDA bindings (informative)](volume-3-payload-bindings.html#3pxx33-proposed-dicom-and-cda-bindings-informative) | [UC-2 mixed-release submission](examples-grouped-fhir-job.html#grouped-fhir-submission) |
| [De-Identification Evidence](volume-3-evidence.html#evidence-baseline) | [DIS Evidence Provenance](StructureDefinition-DIS-Evidence.html) and [Staged Release Evidence](StructureDefinition-DIS-StagedReleaseEvidence.html) | [UC-3 pseudonymization evidence](Provenance-dis-evidence-uc3-001.html) |
| [Protected Lookup Tables](volume-3-lookup-tables.html#protected-lookup-tables) | [Lookup Table DocumentReference](StructureDefinition-DIS-LookupTable.html) and [JSON Schema](schemas/dis-lookup-table.schema.json) | [Worked mapping examples](volume-3-lookup-tables.html#lookup-table-examples) |
| [Shared Contract Rules](#shared-contract-rules) | [Signatures and disclosure](#contract-signatures) | [UC-4 signature verification](examples-cloud-decision-support.html#signature-verification) |
{: .grid}

The [normative DIS ODRL content binding](odrl-content.html) defines the decoded Agreement and Sets.

## Shared Contract Rules

<a name="contract-signatures"> </a>

### Contract Signatures and Disclosure

A DIS digital signature on a Contract SHALL be carried in [`Contract.signer.signature`]({{site.data.fhir.path}}contract-definitions.html#Contract.signer.signature). A deployment determines which signatures it requires on Data Request Authorization and Policy Contracts at ITI-x1 and on Execution Plan Contracts at ITI-x3. It configures the accepted signature format, signed bytes, trusted keys and signer authority. When a signature is required, the receiving actor SHALL reject an absent or unverifiable signature and verify that the signer is authorized to sign for `Contract.signer.party`. Apply the same rules to Requester-carried and Manager-resolved policies. The [UC-4 example](examples-cloud-decision-support.html#signature-verification) illustrates one configuration.

A deployment also determines whether to make signed authorization or policy Contracts available with a job result and how to handle unavailable or restricted supporting Contracts. The Manager SHALL apply the deployment's disclosure rules together with the [current grant and recipient checks](volume-3-authorization.html#data-request-authorization) before releasing the result or any supporting Contract. When supplied as part of a result package, supporting Contracts remain outside the clinical output manifest. Transformation Provenance records processing and release evidence.

<a name="fhir-r4-dpv-mapping"> </a>

## 3:PXX.4.2.1.7 FHIR R4 DPV Category Mapping

See [FHIR Addressing and Processing](volume-3-fhir-addressing.html) for the rest of §3:PXX.4.2.1.

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

<a name="fhir-r4-dpv-coverage-1"> </a>

**Coverage rule, revision 1.** This mapping covers the declared structured occurrences of `pd:Name`, `pd:Identifier`, and `pd:BirthDate` in a versioned R4 `dis-resource-list` assignment. Verify the resource type, release, and version for each selected resource. Logical IDs SHALL be unique within each resource type in the assignment. The review uses the base definitions in `hl7.fhir.r4.core#4.0.1` and evaluates inherited declarations at their defining type. Reusable datatype entries appear once in the mapping. A generated execution plan still names concrete use sites as required by the assignment.

The mapping covers whole `HumanName` and `Identifier` occurrences where those types are selected. It covers a declared date of birth on `FamilyMemberHistory.born[x]` through `ofType(date)`. A birth period or textual estimate, references and their displays or logical identifiers, narrative, arbitrary string values, generic choice values, contained or embedded resources, and extensions require separate coverage when in scope. Business identifiers for encounters, studies, plans, and other records are distinct from identifiers assigned to people. `Resource.id` is a logical record key. The review inventory counts each declaration at its defining resource and lists other name, identifier, and birth-date candidates separately from the mapped paths. A candidate may describe a non-person entity or need context that the base definition does not provide. The Manager SHALL fail compilation if the authorization scope requires coverage outside the mapping. An absent optional mapped element contributes zero matches.

<a name="fhir-r4-dpv-declared-role-1"> </a>

**Declared role rule, revision 1.** The path definition establishes the role. For example, `Coverage.subscriberId` identifies the subscriber, and `FamilyMemberHistory.name` names the relative. A `Person` record describes the person in that record. It does not supply the patient or care-provider role for other resources linked to the same person.

<a name="fhir-r4-dpv-care-team-role-1"> </a>

**Care-team role rule, revision 1.** For a role-specific care-provider rule, verify that the approved scope identifies the active CareTeam records that collectively provide the complete in-scope care roster. Each applicable record links its `subject` to an assigned Patient and its clinician `participant.member` directly to an assigned Practitioner. Resolve both links against the verified immutable manifest entries. Membership in any of these care teams qualifies the Practitioner's mapped occurrences in the care-provider role. An incomplete roster, ambiguous identity, or unresolved relevant reference SHALL fail compilation when it could change the winning rule or action for a selected occurrence. A name on a Patient resource remains in the patient role even when a Practitioner resource describes the same person.

<a name="fhir-r4-dpv-local-path-1"> </a>

**Resource-local expansion rule, revision 1.** Emit the entry's FHIRPath when its root resource type is assigned. If the care-team role rule applies, qualify the resource root by each matching Practitioner ID in manifest order, as in `Practitioner.where(id = 'provider-example').name`. A complete roster with no qualifying Practitioner yields zero matches. If a supported policy rule generates no selector for an assignment, it contributes no compiled obligation. If this leaves the entire rule set empty, compile the first applicable resource-rooted entry in mapping order with `where(false)` on its resource root. For a rule set with only the reusable datatype entry, use `ActivityDefinition.where(false).contact.name` as the zero-match selector. This preserves the nonempty plan structure and makes no change to the assigned content.

<a name="fhir-r4-dpv-contact-detail-1"> </a>

**ContactDetail expansion rule, revision 1.** For each assigned resource type, read its effective R4 element definitions and find the local paths whose only declared type is `ContactDetail`. Include the paths inherited by that resource once. Use the resource's concrete type as the root, append `.name`, and emit the resulting FHIRPath selectors in lexicographic order. For example, `Organization.contact.name` comes from its own declared entry, while `ActivityDefinition.contact.name` expands from the shared `ContactDetail.name` entry. Generic choice elements and locations within embedded resources remain outside this rule.

## Earlier Volume 3 section links

### Earlier links for Data Request Authorization

<ul>
<li><a name="data-request-authorization"> </a><a name="3pxx6-data-request-authorization"> </a><a name="3pxx1-data-request-authorization"> </a><a name="markdown-toc-3pxx1-data-request-authorization"> </a><a href="volume-3-authorization.html#3pxx1-data-request-authorization">3:PXX.1 Data Request Authorization</a></li>
<li><a name="data-request-authorization-contract"> </a><a name="3pxx61-data-request-authorization-contract"> </a><a name="3pxx11-data-request-authorization-contract"> </a><a href="volume-3-authorization.html#3pxx11-data-request-authorization-contract">3:PXX.1.1 Data Request Authorization Contract</a></li>
<li><a name="grant-validation-and-scope"> </a><a name="3pxx12-grant-validation-and-approved-scope"> </a><a href="volume-3-authorization.html#3pxx12-grant-validation-and-approved-scope">3:PXX.1.2 Grant Validation and Approved Scope</a></li>
<li><a name="job-result-recipient"> </a><a name="result-recipient-eligibility"> </a><a name="3pxx13-result-recipient-eligibility-and-release"> </a><a href="volume-3-authorization.html#3pxx13-result-recipient-eligibility-and-release">3:PXX.1.3 Result Recipient Eligibility and Release</a></li>
</ul>

### Earlier links for De-Identification Policy

<ul>
<li><a name="de-identification-policy"> </a><a name="policy-content-module"> </a><a name="3pxx2-dis-policy-content-module"> </a><a name="3pxx1-de-identification-policy"> </a><a name="3pxx2-de-identification-policy"> </a><a name="markdown-toc-3pxx2-de-identification-policy"> </a><a href="volume-3-policy.html#3pxx2-de-identification-policy">3:PXX.2 De-Identification Policy</a></li>
<li><a name="3pxx21-policy-library-resource-structure"> </a><a name="3pxx11-policy-library-resource-structure"> </a><a name="3pxx11-policy-contract-resource-structure"> </a><a name="policy-contract-structure"> </a><a name="3pxx21-policy-contract-resource-structure"> </a><a href="volume-3-policy.html#3pxx21-policy-contract-resource-structure">3:PXX.2.1 Policy Contract Resource Structure</a></li>
<li><a name="transformation-actions"> </a><a name="3pxx13-transformation-actions"> </a><a name="3pxx22-transformation-actions"> </a><a name="3pxx12-transformation-actions"> </a><a href="volume-3-policy.html#3pxx22-transformation-actions">3:PXX.2.2 Transformation Actions</a></li>
<li><a name="3pxx131-action-catalog"> </a><a name="3pxx221-action-catalog"> </a><a name="3pxx121-action-catalog"> </a><a href="volume-3-policy.html#3pxx221-action-catalog">3:PXX.2.2.1 Action Catalog</a></li>
<li><a name="tPXX.1.2-1"> </a><a href="volume-3-policy.html#tPXX.1.2-1">Table 3:PXX.2.2-1: Core Transformation Actions</a></li>
<li><a name="tPXX.1.2-2"> </a><a href="volume-3-policy.html#tPXX.1.2-2">Table 3:PXX.2.2-2: Core Transformation Actions — ISO/IEC 20889 Classification</a></li>
<li><a name="3pxx132-action-definitions"> </a><a name="3pxx222-action-definitions"> </a><a name="3pxx122-action-definitions"> </a><a href="volume-3-policy.html#3pxx222-action-definitions">3:PXX.2.2.2 Action Definitions</a></li>
<li><a name="remove"> </a><a href="volume-3-policy.html#remove">remove</a></li>
<li><a name="replace"> </a><a href="volume-3-policy.html#replace">replace</a></li>
<li><a name="keep"> </a><a href="volume-3-policy.html#keep">keep</a></li>
<li><a name="hash"> </a><a href="volume-3-policy.html#hash">hash</a></li>
<li><a name="truncate-date"> </a><a href="volume-3-policy.html#truncate-date">truncate-date</a></li>
<li><a name="date-shift"> </a><a href="volume-3-policy.html#date-shift">date-shift</a></li>
<li><a name="round"> </a><a href="volume-3-policy.html#round">round</a></li>
<li><a name="truncate"> </a><a href="volume-3-policy.html#truncate">truncate</a></li>
<li><a name="redact"> </a><a href="volume-3-policy.html#redact">redact</a></li>
<li><a name="3pxx133-baseline-patient-pseudonym-derivation"> </a><a name="3pxx223-baseline-patient-pseudonym-derivation"> </a><a name="3pxx123-baseline-patient-pseudonym-derivation"> </a><a name="3pxx123-patient-identifier-pseudonymization"> </a><a name="3pxx223-patient-identifier-pseudonymization"> </a><a href="volume-3-policy.html#3pxx223-patient-identifier-pseudonymization">3:PXX.2.2.3 Patient Identifier Pseudonymization</a></li>
<li><a name="lookup-backed-assignment"> </a><a href="volume-3-policy.html#lookup-backed-assignment">Lookup-backed assignment</a></li>
<li><a name="encryption-based-patient-pseudonymization"> </a><a name="encryption-based-derivation"> </a><a href="volume-3-policy.html#encryption-based-derivation">Encryption-based derivation</a></li>
<li><a name="3pxx22-policy-rules-json-structure"> </a><a name="3pxx12-policy-rules-json-structure"> </a><a name="3pxx13-policy-rules-json-structure"> </a><a name="3pxx13-policy-rules-and-ordering"> </a><a name="3pxx23-policy-rules-and-ordering"> </a><a href="volume-3-policy.html#3pxx23-policy-rules-and-ordering">3:PXX.2.3 Policy Rules and Ordering</a></li>
<li><a name="3pxx221-policy-rules-examples"> </a><a name="3pxx121-policy-rules-examples"> </a><a name="3pxx131-policy-rules-examples"> </a><a href="volume-3-policy.html#3pxx221-policy-rules-examples">3:PXX.2.3 Policy Rules and Ordering</a></li>
<li><a name="3pxx23-policy-delivery-and-validation"> </a><a name="3pxx13-policy-delivery-and-validation"> </a><a name="3pxx14-policy-delivery-and-validation"> </a><a name="3pxx24-policy-delivery-and-validation"> </a><a href="volume-3-policy.html#3pxx24-policy-delivery-and-validation">3:PXX.2.4 Policy Delivery and Validation</a></li>
<li><a name="3pxx231-policy-content-resolution"> </a><a name="3pxx131-policy-content-resolution"> </a><a name="3pxx141-policy-content-resolution"> </a><a name="3pxx241-policy-content-resolution"> </a><a href="volume-3-policy.html#3pxx241-policy-content-resolution">3:PXX.2.4.1 Policy Content Resolution</a></li>
<li><a name="approved-policy-access"> </a><a href="volume-3-policy.html#approved-policy-access">3:PXX.2.4.1 Policy Content Resolution</a></li>
<li><a name="3pxx232-policy-validation"> </a><a name="3pxx132-policy-validation"> </a><a name="3pxx142-policy-validation"> </a><a name="3pxx242-policy-validation"> </a><a href="volume-3-policy.html#3pxx242-policy-validation">3:PXX.2.4.2 Policy Validation</a></li>
<li><a name="3pxx25-policy-lifecycle"> </a><a name="3pxx15-policy-lifecycle"> </a><a name="3pxx16-policy-lifecycle"> </a><a href="volume-3-policy.html#3pxx25-policy-lifecycle">3:PXX.2.5 Policy Lifecycle</a></li>
</ul>

### Earlier links for De-Identification Execution Plan

<ul>
<li><a name="execution-plan-content"> </a><a name="3pxx2-de-identification-execution-plan"> </a><a name="3pxx3-de-identification-execution-plan"> </a><a name="markdown-toc-3pxx3-de-identification-execution-plan"> </a><a href="volume-3-execution-plan.html#3pxx3-de-identification-execution-plan">3:PXX.3 De-Identification Execution Plan</a></li>
<li><a name="execution-plan-format"> </a><a name="3pxx14-execution-plan-format"> </a><a name="3pxx21-execution-plan-format"> </a><a name="3pxx31-execution-plan-format"> </a><a href="volume-3-execution-plan.html#3pxx31-execution-plan-format">3:PXX.3.1 Execution Plan Format</a></li>
<li><a name="3pxx141-library-resource-structure"> </a><a name="3pxx211-execution-plan-contract-structure"> </a><a name="3pxx311-execution-plan-contract-structure"> </a><a href="volume-3-execution-plan.html#3pxx311-execution-plan-contract-structure">3:PXX.3.1.1 Execution Plan Contract Structure</a></li>
<li><a name="execution-plan-source-policy"> </a><a href="volume-3-execution-plan.html#execution-plan-source-policy">3:PXX.3.1.1 Execution Plan Contract Structure</a></li>
<li><a name="policy-compilation"> </a><a name="3pxx24-policy-compilation"> </a><a name="3pxx14-policy-compilation"> </a><a name="3pxx15-policy-compilation"> </a><a name="3pxx32-policy-compilation"> </a><a href="volume-3-execution-plan.html#3pxx32-policy-compilation">3:PXX.3.2 Policy Compilation</a></li>
<li><a name="3pxx241-semantic-level-compilation"> </a><a name="3pxx141-semantic-level-compilation"> </a><a name="3pxx242-syntax-level-validation"> </a><a name="3pxx142-syntax-level-validation"> </a><a name="3pxx152-syntax-level-validation"> </a><a name="3pxx151-semantic-level-compilation"> </a><a name="3pxx151-resolve-semantic-groups-or-validate-concrete-selectors"> </a><a name="3pxx321-resolve-semantic-groups-or-validate-concrete-selectors"> </a><a name="3pxx321-resolve-policy-targets"> </a><a href="volume-3-execution-plan.html#3pxx321-resolve-policy-targets">3:PXX.3.2.1 Resolve Policy Targets</a></li>
<li><a name="execution-plan-assembly"> </a><a name="3pxx152-assemble-the-plan-and-check-capabilities"> </a><a name="3pxx322-assemble-the-plan-and-check-capabilities"> </a><a href="volume-3-execution-plan.html#3pxx322-assemble-the-plan-and-check-capabilities">3:PXX.3.2.2 Assemble the Plan and Check Capabilities</a></li>
<li><a name="3pxx142-execution-plan-json-structure"> </a><a name="3pxx212-execution-plan-json-structure"> </a><a name="3pxx212-execution-plan-json-structure-and-rule-evaluation"> </a><a name="3pxx212-execution-plan-structure-and-rule-evaluation"> </a><a name="3pxx33-execution-plan-structure-and-rule-evaluation"> </a><a href="volume-3-execution-plan.html#3pxx33-execution-plan-structure-and-rule-evaluation">3:PXX.3.3 Execution Plan Structure and Rule Evaluation</a></li>
<li><a name="3pxx143-execution-plan-example"> </a><a name="3pxx213-execution-plan-example"> </a><a name="3pxx34-execution-plan-examples"> </a><a href="volume-3-execution-plan.html#3pxx34-execution-plan-examples">3:PXX.3.4 Execution Plan Examples</a></li>
</ul>

### Earlier links for Payload Bindings

<ul>
<li><a name="payload-bindings"> </a><a name="3pxx3-payload-bindings"> </a><a name="3pxx4-payload-bindings"> </a><a name="markdown-toc-3pxx4-payload-bindings"> </a><a href="volume-3-payload-bindings.html#3pxx4-payload-bindings">3:PXX.4 Payload Bindings</a></li>
<li><a name="payload-binding-framework"> </a><a name="payload-binding-requirements"> </a><a href="volume-3-payload-bindings.html#payload-binding-framework">Payload binding requirements</a></li>
<li><a name="payload-set-delivery"> </a><a name="3pxx3-common-payload-set-delivery"> </a><a name="3pxx31-common-payload-set-delivery"> </a><a name="3pxx41-common-payload-set-delivery"> </a><a href="volume-3-payload-bindings.html#3pxx41-common-payload-set-delivery">3:PXX.4.1 Common Payload Set Delivery</a></li>
<li><a name="3pxx31-manifest-formats"> </a><a name="3pxx311-manifest-formats"> </a><a name="3pxx311-manifest-formats-and-packages"> </a><a name="3pxx411-manifest-formats-and-packages"> </a><a href="volume-3-payload-bindings.html#3pxx411-manifest-formats-and-packages">3:PXX.4.1.1 Manifest Formats and Packages</a></li>
<li><a name="manifest-package"> </a><a href="volume-3-payload-bindings.html#manifest-package">3:PXX.4.1.1 Manifest Formats and Packages</a></li>
<li><a name="3pxx32-authorization-and-stable-retrieval"> </a><a name="3pxx312-authorization-and-stable-retrieval"> </a><a name="3pxx412-authorization-and-stable-retrieval"> </a><a href="volume-3-payload-bindings.html#3pxx412-authorization-and-stable-retrieval">3:PXX.4.1.2 Authorization and Stable Retrieval</a></li>
<li><a name="assigned-input-verification"> </a><a name="3pxx313-assigned-input-verification"> </a><a name="3pxx413-assigned-input-verification"> </a><a href="volume-3-payload-bindings.html#3pxx413-assigned-input-verification">3:PXX.4.1.3 Assigned Input Verification</a></li>
<li><a name="fhir-payload-binding"> </a><a name="fhir-payload-content-module"> </a><a name="3pxx1-dis-fhir-payload-content-module"> </a><a name="3pxx32-fhir-payload-binding"> </a><a name="3pxx42-fhir-payload-binding"> </a><a href="volume-3-payload-bindings.html#3pxx42-fhir-payload-binding">3:PXX.4.2 FHIR Payload Binding</a></li>
<li><a name="3pxx33-proposed-dicom-and-cda-bindings-informative"> </a><a name="3pxx43-proposed-dicom-and-cda-bindings-informative"> </a><a href="volume-3-payload-bindings.html#3pxx43-proposed-dicom-and-cda-bindings-informative">3:PXX.4.3 Proposed DICOM and CDA Bindings (Informative)</a></li>
<li><a name="mixed-payload-walkthrough"> </a><a href="volume-3-payload-bindings.html#mixed-payload-walkthrough">3:PXX.4.3 Proposed DICOM and CDA Bindings (Informative)</a></li>
</ul>

### Earlier links for FHIR Addressing and Processing

<ul>
<li><a name="3pxx11-cross-version-payload-support"> </a><a name="cross-version-payload"> </a><a name="content-model"> </a><a name="3pxx12-content-model"> </a><a name="3pxx322-content-model"> </a><a name="3pxx321-cross-version-payload-support"> </a><a name="3pxx321-addressing-and-processing"> </a><a name="3pxx421-addressing-and-processing"> </a><a href="volume-3-fhir-addressing.html#3pxx421-addressing-and-processing">3:PXX.4.2.1 Addressing and Processing</a></li>
<li><a name="3pxx111-version-identification"> </a><a name="3pxx3211-version-identification"> </a><a name="3pxx3211-fhir-release-and-capability-matching"> </a><a name="3pxx4211-fhir-release-identification"> </a><a href="volume-3-fhir-addressing.html#3pxx4211-fhir-release-identification">3:PXX.4.2.1.1 FHIR Release Identification</a></li>
<li><a name="fhir-processing-capabilities"> </a><a name="3pxx4212-fhir-processing-capabilities"> </a><a href="volume-3-fhir-addressing.html#3pxx4212-fhir-processing-capabilities">3:PXX.4.2.1.2 FHIR Processing Capabilities</a></li>
<li><a name="3pxx121-element-addressing"> </a><a name="3pxx113-version-neutral-element-addressing"> </a><a name="3pxx3213-version-neutral-element-addressing"> </a><a name="3pxx3221-element-addressing"> </a><a name="fhirpath-element-addressing"> </a><a name="3pxx3212-fhirpath-element-addressing"> </a><a name="3pxx4213-fhirpath-element-addressing"> </a><a href="volume-3-fhir-addressing.html#3pxx4213-fhirpath-element-addressing">3:PXX.4.2.1.3 FHIRPath Element Addressing</a></li>
<li><a name="3pxx122-semantic-groups"> </a><a name="3pxx3222-semantic-groups"> </a><a name="3pxx3213-semantic-group-bindings"> </a><a name="3pxx4214-semantic-group-bindings"> </a><a href="volume-3-fhir-addressing.html#3pxx4214-semantic-group-bindings">3:PXX.4.2.1.4 Semantic Group Bindings</a></li>
<li><a name="tPXX.3.2.2-1"> </a><a href="volume-3-fhir-addressing.html#tPXX.3.2.2-1">3:PXX.4.2.1.4 Semantic Group Bindings</a></li>
<li><a name="tPXX.3.2.1-1"> </a><a href="volume-3-fhir-addressing.html#tPXX.3.2.1-1">Table 3:PXX.4.2.1-1: DIS FHIR Semantic Group Binding</a></li>
<li><a name="3pxx123-resource-traversal"> </a><a name="3pxx3223-resource-traversal"> </a><a name="3pxx3214-resource-traversal"> </a><a name="3pxx4215-resource-traversal"> </a><a href="volume-3-fhir-addressing.html#3pxx4215-resource-traversal">3:PXX.4.2.1.5 Resource Traversal</a></li>
<li><a name="3pxx115-validation-across-versions"> </a><a name="3pxx3215-validation-across-versions"> </a><a name="3pxx3215-output-validation-in-the-declared-release"> </a><a name="3pxx4216-output-validation-in-the-declared-release"> </a><a href="volume-3-fhir-addressing.html#3pxx4216-output-validation-in-the-declared-release">3:PXX.4.2.1.6 Output Validation in the Declared Release</a></li>
<li><a name="3pxx22-fhir-reference-integrity"> </a><a name="fhir-reference-integrity"> </a><a href="volume-3-fhir-addressing.html#3pxx22-fhir-reference-integrity">FHIR reference integrity</a></li>
</ul>

### Earlier links for FHIR Input and Result Delivery

<ul>
<li><a name="data-plane-access"> </a><a name="obtaining-processing-targets"> </a><a name="3pxx16-obtaining-processing-targets"> </a><a name="3pxx323-obtaining-processing-targets"> </a><a name="3pxx322-input-and-result-delivery"> </a><a name="3pxx422-input-and-result-delivery"> </a><a href="volume-3-fhir-delivery.html#3pxx422-input-and-result-delivery">3:PXX.4.2.2 Input and Result Delivery</a></li>
<li><a name="3pxx33-fhir-payload-delivery"> </a><a name="3pxx324-fhir-payload-delivery-summary"> </a><a name="3pxx3221-payload-set-delivery"> </a><a name="3pxx4221-payload-set-delivery"> </a><a href="volume-3-fhir-delivery.html#3pxx4221-payload-set-delivery">3:PXX.4.2.2.1 Payload Set Delivery</a></li>
<li><a name="fhir-input-result-delivery-table"> </a><a href="volume-3-fhir-delivery.html#fhir-input-result-delivery-table">Table 3:PXX.4.2.2-1: FHIR Input and Result Delivery</a></li>
<li><a name="3pxx112-version-safe-packaging"> </a><a name="3pxx3212-version-safe-packaging"> </a><a name="3pxx3223-version-safe-packaging-of-inline-and-hosted-resources"> </a><a name="3pxx4222-version-safe-packaging-of-inline-and-hosted-resources"> </a><a href="volume-3-fhir-delivery.html#3pxx4222-version-safe-packaging-of-inline-and-hosted-resources">3:PXX.4.2.2.2 Version-Safe Packaging of Inline and Hosted Resources</a></li>
<li><a name="protocol-resources-remain-hl7-fhir-r4"> </a><a href="volume-3-fhir-delivery.html#protocol-resources-remain-hl7-fhir-r4">Protocol Resources Remain HL7 FHIR R4</a></li>
<li><a name="tPXX.3.2.1-2"> </a><a href="volume-3-fhir-delivery.html#tPXX.3.2.1-2">3:PXX.4.2.2.2 Version-Safe Packaging of Inline and Hosted Resources</a></li>
<li><a name="tPXX.3.2.2-3"> </a><a href="volume-3-fhir-delivery.html#tPXX.3.2.2-3">Table 3:PXX.4.2.2-2: HL7 FHIR R4 Protocol Resources</a></li>
<li><a name="3pxx163-bulk-file-manifests"> </a><a name="3pxx3233-bulk-file-manifests"> </a><a name="resource-manifest"> </a><a name="resource-manifest-resolution"> </a><a name="fhir-resource-manifest-resolution"> </a><a name="3pxx3222-fhir-resource-manifest-and-wrapper-resolution"> </a><a name="fhir-input-manifests-and-retrieval"> </a><a name="3pxx4223-input-manifests-and-retrieval"> </a><a href="volume-3-fhir-delivery.html#3pxx4223-input-manifests-and-retrieval">3:PXX.4.2.2.3 Input Manifests and Retrieval</a></li>
<li><a name="tPXX.3.2.2-2"> </a><a href="volume-3-fhir-delivery.html#tPXX.3.2.2-2">Table 3:PXX.4.2.2-3: FHIR Resource Manifest Resolution</a></li>
<li><a name="direct-hosted-r5-references"> </a><a href="volume-3-fhir-delivery.html#direct-hosted-r5-references">Direct hosted R5 references</a></li>
<li><a name="3pxx3224-bulk-file-manifests-and-authorized-retrieval"> </a><a href="volume-3-fhir-delivery.html#3pxx3224-bulk-file-manifests-and-authorized-retrieval">Bulk input manifests</a></li>
<li><a name="referenced-input-authorization"> </a><a name="3pxx164-authorization-for-referenced-inputs"> </a><a name="3pxx3234-authorization-for-referenced-inputs"> </a><a href="volume-3-fhir-delivery.html#referenced-input-authorization">Authorization for referenced inputs</a></li>
<li><a name="inline-r5-manifest-package"> </a><a name="3pxx34-inline-r5-manifest-package-example"> </a><a name="3pxx325-inline-r5-manifest-package-example"> </a><a name="3pxx3225-inline-r5-manifest-package-example"> </a><a name="3pxx4224-inline-r5-manifest-package-example"> </a><a href="volume-3-fhir-delivery.html#3pxx4224-inline-r5-manifest-package-example">3:PXX.4.2.2.4 Inline R5 Manifest Package Example</a></li>
<li><a name="fhir-result-packages-and-delivery"> </a><a name="3pxx4225-result-packages-and-delivery"> </a><a href="volume-3-fhir-delivery.html#3pxx4225-result-packages-and-delivery">3:PXX.4.2.2.5 Result Packages and Delivery</a></li>
<li><a name="result-evidence-placement"> </a><a href="volume-3-fhir-delivery.html#result-evidence-placement">Result package and evidence placement</a></li>
<li><a name="bulk-result-content-identity"> </a><a href="volume-3-fhir-delivery.html#bulk-result-content-identity">Bulk result content identity</a></li>
<li><a name="bulk-result-download-authorization"> </a><a href="volume-3-fhir-delivery.html#bulk-result-download-authorization">Bulk job result downloads</a></li>
</ul>

### Earlier links for De-Identification Evidence

<ul>
<li><a name="evidence-baseline"> </a><a name="3pxx15-evidence-baseline"> </a><a name="3pxx4-de-identification-evidence"> </a><a name="3pxx5-de-identification-evidence"> </a><a name="markdown-toc-3pxx5-de-identification-evidence"> </a><a href="volume-3-evidence.html#3pxx5-de-identification-evidence">3:PXX.5 De-Identification Evidence</a></li>
<li><a name="3pxx151-minimum-evidence-elements"> </a><a name="3pxx41-minimum-evidence-elements"> </a><a name="3pxx51-minimum-evidence-elements"> </a><a href="volume-3-evidence.html#3pxx51-minimum-evidence-elements">3:PXX.5.1 Minimum Evidence Elements</a></li>
<li><a name="tPXX.4-1"> </a><a href="volume-3-evidence.html#tPXX.4-1">Table 3:PXX.5-1: DIS Evidence Baseline Elements</a></li>
<li><a name="3pxx152-provenance-resource-structure"> </a><a name="3pxx42-provenance-resource-structure"> </a><a name="3pxx42-r4-provenance-resource-structure"> </a><a name="3pxx52-r4-provenance-resource-structure"> </a><a href="volume-3-evidence.html#3pxx52-r4-provenance-resource-structure">3:PXX.5.2 R4 Provenance Resource Structure</a></li>
<li><a name="tPXX.4-2"> </a><a href="volume-3-evidence.html#tPXX.4-2">Table 3:PXX.5-2: Required Provenance Elements</a></li>
<li><a name="3pxx114-evidence-representation-across-versions"> </a><a name="3pxx3214-evidence-representation-across-versions"> </a><a name="3pxx43-identifying-results-across-fhir-releases"> </a><a name="3pxx53-identifying-results-across-fhir-releases"> </a><a href="volume-3-evidence.html#3pxx53-identifying-results-across-fhir-releases">3:PXX.5.3 Identifying Results Across FHIR Releases</a></li>
<li><a name="3pxx153-transformation-summary"> </a><a name="3pxx43-transformation-summary"> </a><a name="3pxx44-transformation-summary"> </a><a name="3pxx54-transformation-summary"> </a><a href="volume-3-evidence.html#3pxx54-transformation-summary">3:PXX.5.4 Transformation Summary</a></li>
<li><a name="tPXX.4-3"> </a><a href="volume-3-evidence.html#tPXX.4-3">Table 3:PXX.5-3: Transformation Summary Entry Elements</a></li>
<li><a name="3pxx154-evidence-example"> </a><a name="3pxx44-evidence-example"> </a><a name="3pxx45-evidence-example"> </a><a name="3pxx55-evidence-example"> </a><a href="volume-3-evidence.html#3pxx55-evidence-example">3:PXX.5.5 Evidence Example</a></li>
<li><a name="staged-release-evidence"> </a><a name="3pxx46-staged-release-evidence"> </a><a name="3pxx56-staged-release-evidence"> </a><a href="volume-3-evidence.html#3pxx56-staged-release-evidence">3:PXX.5.6 Staged Release Evidence</a></li>
</ul>

### Earlier links for Protected Lookup Tables

<ul>
<li><a name="3pxx17-reversible-lookup-table"> </a><a name="3pxx5-reversible-lookup-table"> </a><a name="protected-lookup-tables"> </a><a name="3pxx6-protected-lookup-tables"> </a><a name="markdown-toc-3pxx6-protected-lookup-tables"> </a><a href="volume-3-lookup-tables.html#3pxx6-protected-lookup-tables">3:PXX.6 Protected Lookup Tables</a></li>
<li><a name="3pxx51-lookup-table-structure-and-handling"> </a><a name="3pxx61-lookup-table-structure-and-handling"> </a><a href="volume-3-lookup-tables.html#3pxx61-lookup-table-structure-and-handling">3:PXX.6.1 Lookup Table Structure and Handling</a></li>
<li><a name="3pxx18-worked-mapping-examples"> </a><a name="3pxx51-worked-mapping-examples"> </a><a name="3pxx52-worked-mapping-examples"> </a><a name="lookup-table-examples"> </a><a name="3pxx62-worked-mapping-examples"> </a><a href="volume-3-lookup-tables.html#3pxx62-worked-mapping-examples">3:PXX.6.2 Worked Mapping Examples</a></li>
</ul>
