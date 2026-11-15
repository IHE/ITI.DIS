This Volume 3 proposal defines a reusable, format-independent De-Identification Policy using the Data Privacy Vocabulary (DPV) and ODRL. The requirements on this page describe the proposed binding for review.

## Content artifacts

| Artifact | What it specifies |
| --- | --- |
| [Data Request Authorization](volume-3.html#data-request-authorization) | An ODRL Agreement authorizes a Requester, purpose, recipient, assigned scope, payload binding and release, and exact Policy Contract revision. |
| De-Identification Policy | An ODRL Set describes which personal information to transform and how. Its targets use a DPV category, the role of the person in the record, and the location of the information. |
| [Payload binding](volume-3.html#payload-bindings) | A versioned mapping associates each supported target with concrete elements and states how to determine the person's role and establish coverage. |
| [De-Identification Execution Plan](volume-3.html#execution-plan-content) | An ODRL Set binds the applicable policy rules to concrete selectors, the mapping revision, and the assigned input. |
| [De-Identification Evidence](volume-3.html#evidence-baseline) | FHIR R4 Provenance links the outcome to the exact source policy and returned results. The assignment record links the evidence to the plan and mapping revision. |
{: .grid}

The proposed Policy and Execution Plan use the existing DIS FHIR R4 Contract carriers and signature rules. The Agreement uses the existing [ODRL Agreement binding](odrl-content.html#odrl-authorization). Approval of a policy for one scope and recipient grants only the processing described by that permission.

## Common personal information model

Each ODRL target describes a class of occurrences using exactly one value from each dimension.

| Dimension | ODRL constraint operand | Proposed values |
| --- | --- | --- |
| Personal data category | `disdpv:category` | The DPV v2.3 concept IRI. The pilot maps `pd:Name`, `pd:Identifier`, and `pd:BirthDate`. |
| Role in the record | `disdpv:personRole` | `disdpv:patient`, `disdpv:patient-contact`, `disdpv:care-provider`, or `disdpv:all-person-roles`. |
| Location | `disdpv:location` | `disdpv:structured` for structured elements, `disdpv:narrative` for names or other information within free text, and `disdpv:pixel` for information in image pixels. The pilot supports only `disdpv:structured`. |
{: .grid}

Category matching uses the exact IRI defined in [DPV Personal Data Categories v2.3](https://w3c-cg.github.io/dpv/2.3/pd/). A binding declares the categories it can evaluate. The Manager SHALL reject an unsupported category and SHALL use no implicit expansion to related, broader, or narrower categories. For example, selecting `pd:BirthDate` does not select a recorded age. The [DPV Health Sector Concepts v2.3 draft](https://w3c-cg.github.io/dpv/2.3/sector/health/) provides context for interpreting health sector roles. The DIS role codes below have their own matching rules.

- **Patient** applies to information about a person in the role of receiving care represented by the assigned record.
- **Patient contact** applies to information about a person represented as a patient's contact.
- **Care provider** applies to information about a person represented as participating in the patient's care in the assigned record. A person can have another role elsewhere in the same payload. A name in a patient record remains in the patient role even if the same person is also named as a care provider.
- **All person roles** matches every occurrence with the selected category and location within the supported assignment scope. It also matches occurrences where the person's precise role is unnecessary to determine the action.

Location values are exact. To cover several locations, author a rule for each location. Where an action requires complete coverage of a location, a binding SHALL establish that coverage for the governed assignment. For example, a mapping for a person's structured name does not cover the same name in a narrative or image. The policy's coverage statement applies to the selected locations and the input scope admitted under the Agreement.

## ODRL representation

Use the [draft JSON-LD context](schemas/dis-dpv-odrl-draft-1.jsonld) as the sole context for the draft Policy and Execution Plan. The [draft Turtle vocabulary](schemas/dis-dpv-odrl-draft-1.ttl) identifies the new profiles and terms. The `dis:` prefix continues to identify the [existing DIS actions and shared terms](odrl-content.html#dis-odrl-vocabulary). Apply the [common JSON-LD requirements](odrl-content.html#common-json-ld-requirements) with the context and profile identifiers below.

| Artifact | ODRL type | Profile identifier |
| --- | --- | --- |
| Policy | `Set` | `disdpv:Policy` |
| Execution Plan | `Set` | `disdpv:ExecutionPlan` |
{: .grid}

### Policy rules

Use the `uid`, `obligation`, `dis:reversibilityMode`, `dis:ruleSets`, and optional staging and linkage scope fields of the [DIS Policy Set](odrl-content.html#de-identification-policy-set). In this draft, omit `dis:representationLevel`, `dis:payloadFamily`, and `dis:payloadVersion` from the Policy Set.

Each obligation SHALL have a unique `uid`, an `action`, and one `target`. The target is an ODRL `AssetCollection` with `source` equal to `disdpv:personal-information`. Its `refinement` is an array of three constraints, one for each dimension. Each constraint uses `eq` and an explicit `{"@id":"…"}` right operand. All three constraints SHALL match. Reject unknown or duplicate operands, unsupported values, and additional target properties. See the [ODRL Information Model, §2.5.5](https://www.w3.org/TR/odrl-model/).

Use the nine DIS actions and their [existing definitions and parameters](volume-3.html#transformation-actions), including the [ODRL action encoding](odrl-content.html#action-parameters). The allowed actions are `remove`, `replace`, `keep`, `hash`, `truncate-date`, `date-shift`, `round`, `truncate`, and `redact`. Reversibility is declared independently of action support. The applicable option, assignment capabilities, and action-specific requirements still govern each selected action.

Within a plan, the first matching rule controls each concrete occurrence. Put a role-specific `keep` rule before an all-roles `remove` rule to preserve an exception. The serialized obligation array carries no precedence. Apply the existing [rule evaluation and overlap checks](volume-3.html#3pxx212-execution-plan-json-structure-and-rule-evaluation) to same-element matches and to incompatible ancestor and descendant actions.

### Compilation and evidence

1. The Manager admits the job under [ITI-x1](volume-2.html#23x1-submit-de-identification-job-iti-x1), including verification of the exact authorized Policy Contract revision and input scope. It chooses an immutable mapping revision for the assigned binding and release, checks the assignment against the mapping's declared scope, and verifies support for each category, role, location and applicable action.
2. The Manager resolves roles from verified assignment inputs. If role uncertainty could change the winning rule or its action for a selected element, the Manager SHALL fail compilation. It SHALL fail before dispatch when requested coverage is unsupported. A supported optional element that is absent contributes zero matches. The Manager retains the selector for an optional mapped element where the binding permits that selector to be evaluated independently of the element's presence.
3. The Manager compiles the [DIS Execution Plan Set](odrl-content.html#execution-plan-set) using the draft profile identifier and adds exactly one `disdpv:mappingRevision` as an absolute IRI reference. Every compiled obligation SHALL carry its `dis:sourceRule` and a concrete selector tied to the verified assignment manifest. The Manager SHALL preserve source rule order and the mapping's expansion order. The Manager SHALL check the dispatch actor's support for the draft plan profile and the applicable [processing capabilities](volume-3.html#fhir-processing-capabilities).
4. The De-Identifier checks the plan, its mapping revision for the declared binding and release, and the exact inputs verified for [ITI-x3](volume-2.html#23x3-submit-de-identification-task-iti-x3). It evaluates the concrete rules and validates the output. It uses the Plan Contract's exact source Policy Contract reference in `Provenance.policy`. The Manager records the authorization, plan, mapping revision, and returned evidence for the assignment. This trace stays subject to the existing DIS disclosure controls. Worker evidence need not disclose role-resolution details or source names.

## FHIR R4 pilot mapping

In the worked examples, `https://profiles.ihe.net/ITI/DIS/draft-dpv-odrl-policy.html#fhir-r4-pilot-1` identifies this immutable pilot mapping revision. A change to a mapping entry or its classification or coverage rules requires a new revision identifier.

<a name="fhir-r4-pilot-1"> </a>

### Structured elements and roles

The pilot input scope is a versioned resource-list assignment containing R4 Patient, Practitioner, and CareTeam resources. It is limited to information explicitly covered by the following table, with no additional in-scope locations for the same targets. A Manager SHALL check the actual assignment against those limits, including name occurrences in reference displays, contained resources, extensions or narrative that might otherwise be mistaken for covered information. The examples do not contain these locations. Any excluded locations in a broader deployment require their own declared scope and coverage. This pilot uses whole `HumanName` and `Identifier` occurrences.

| Order | DPV category | FHIR R4 path | Role determination |
| --- | --- | --- | --- |
| 1 | `pd:Name` | `Patient.name` | Patient. |
| 2 | `pd:Name` | `Patient.contact.name` | Patient contact. |
| 3 | `pd:Name` | `Practitioner.name` | Care provider if a qualified CareTeam member reference identifies the Practitioner in the assigned care context. Include this path for an all-person-roles target. |
| 4 | `pd:Identifier` | `Patient.identifier` | Patient. This maps patient business identifiers. |
| 5 | `pd:BirthDate` | `Patient.birthDate` | Patient. |
{: .grid}

For role-specific matching in the pilot, the Manager verifies that the approved assignment scope identifies the active CareTeam records that collectively provide the complete in-scope care roster. Each such record links its `subject` to an assigned Patient and links a clinician through a direct `participant.member` reference to an assigned Practitioner. Membership in any of these care teams establishes the care-provider role for that Practitioner's name in this context. Use the matching immutable manifest entries as the reference resolution scope. A known non-member of the complete roster remains included in all-person-roles matching. An incomplete roster, ambiguous identity or unresolved reference prevents a role-specific decision when it could affect the result. Names on distinct Patient and Practitioner resources remain separate occurrences even when they describe the same individual.

The Manager SHALL bind the role-specific selector to the identified Practitioner in the verified input. In this pilot, the assigned resources have unique logical IDs within their resource type, and the Manager can compile a resource-local selector such as `Practitioner.where(id = 'provider-example').name`. Qualify each selected Practitioner separately and emit those selectors in manifest order. If the complete roster contains no qualified Practitioner, emit `Practitioner.where(false).name` for the care-provider name rule so that a valid zero-match rule still has a concrete selector. The De-Identifier evaluates the selector independently on each assigned input resource. Role resolution takes place during compilation, before FHIRPath is evaluated on a single resource.

See the HL7 FHIR R4 definitions for [Patient](https://hl7.org/fhir/R4/patient-definitions.html), [Practitioner](https://hl7.org/fhir/R4/practitioner-definitions.html#Practitioner.name), and [CareTeam](https://hl7.org/fhir/R4/careteam-definitions.html#CareTeam.participant.member). FHIR R5 requires a separately reviewed mapping revision and corresponding tests.

## DICOM crosswalk (informative)

[DICOM PS3.15 Annex E](https://dicom.nema.org/medical/dicom/current/output/chtml/part15/chapter_E.html) helps locate personal information and identify the requirements of the selected DICOM Attribute Confidentiality Profile and options. A future DICOM binding must address dataset attributes, nested items, textual content and image pixels according to its declared scope.

| DPV category and role | DICOM attribute example | Annex E Basic Profile consideration |
| --- | --- | --- |
| `pd:Name`, patient | Patient's Name `(0010,0010)` | `Z` allows an empty or valid dummy value. A required attribute that permits an empty value may still prohibit DIS `remove`, which requires absence. |
| `pd:Identifier`, patient | Patient ID `(0010,0020)` | `Z/D` requires handling appropriate to the attribute type. Evaluate the identifier and its issuer context together. |
| `pd:BirthDate`, patient | Patient's Birth Date `(0010,0030)` | `Z` requires checking the attribute type and output constraints. |
| `pd:Name`, care provider | Performing Physician's Name `(0008,1050)` | `X` requires removal under the Basic Profile. A `keep` policy rule requires a separately applicable DICOM profile or option permitting retention. |
{: .grid}

The Manager checks each proposed DIS action against the applicable DICOM constraints for the concrete attribute, selected profile, and options. An incompatible action makes the assignment unsupported. For example, a Manager SHALL reject a policy that keeps Performing Physician's Name when the selected DICOM profile requires its removal. This table is a crosswalk for review.

## Worked policies and expected evidence

Both policies target the same synthetic R4 input scope. They cover structured names under the pilot mapping. The through-line uses two independent assignments, each granted to the same Requester and recipient for the same purpose. Each permission explicitly authorizes its own policy revision.

| Example | Authorization | Policy | Execution Plan | Expected result |
| --- | --- | --- | --- | --- |
| Remove every in-scope name | [Agreement A](examples/dpv-odrl/remove-all-agreement.json) | [Policy A](examples/dpv-odrl/remove-all-policy.json) | [Plan A](examples/dpv-odrl/remove-all-plan.json) | Remove every patient, contact, and practitioner name, including the care provider's name. |
| Keep care-provider names | [Agreement B](examples/dpv-odrl/keep-providers-agreement.json) | [Policy B](examples/dpv-odrl/keep-providers-policy.json) | [Plan B](examples/dpv-odrl/keep-providers-plan.json) | Keep the name on the Practitioner who is a member of the assigned care team. Remove the names on the Patient, their contact, and the other Practitioner. |
{: .grid}

The attachments are shown decoded. The [fixture and trace](examples/dpv-odrl/example-trace.json) show the assigned resource-list manifest, resources, approved scope, exact Contract references, and expected evidence linkage for both assignments. In the fixture, the patient and the care-provider Practitioner represent the same fictional person in two roles. Policy B preserves the name only on the Practitioner. The Manager checks the exact source policy reference in `Provenance.policy` when accepting the evidence.

[Draft Test Plan cases](testplan.html#draft-dpv-odrl-policy-cases) exercise these outcomes and the admission and compilation failures.
