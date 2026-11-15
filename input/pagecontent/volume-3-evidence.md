<a name="evidence-baseline"> </a>

<a name="3pxx15-evidence-baseline"> </a>

<a name="3pxx4-de-identification-evidence"> </a>

<a name="3pxx5-de-identification-evidence"> </a>

This section defines the minimum evidence elements that every completed de-identification task SHALL produce and specifies how they map to HL7 FHIR R4 Provenance resources.

<a name="3pxx151-minimum-evidence-elements"> </a>

<a name="3pxx41-minimum-evidence-elements"> </a>

## 3:PXX.5.1 Minimum Evidence Elements

Every completed de-identification task produces an HL7 FHIR R4 Provenance resource containing at minimum the nine evidence elements listed in Table 3:PXX.5-1.

<p id="tPXX.4-1" class="tableTitle"><strong>Table 3:PXX.5-1: DIS Evidence Baseline Elements</strong></p>

| # | Evidence Element | HL7 FHIR R4 Provenance Mapping | Description |
|---|------------------|-------------------------------|-------------|
| 1 | Evidence identifier | `Provenance.id` | Unique identifier for this evidence record |
| 2 | Outcome status | `Provenance.extension[dis-outcome-status]` | Overall task outcome: `complete` or `error` |
| 3 | Workflow reference | `Provenance.activity` | DIS activity coding; use the audit correlation identifier to associate the specific job or task |
| 4 | Target identifier | `Provenance.target` | Reference(s) to the de-identified output resource(s) |
| 5 | Policy-decision reference | `Provenance.policy` | URI identifying the exact validated policy version governing this task. For ITI-x3 tasks, copy the [source policy evidence URI](volume-3-execution-plan.html#execution-plan-source-policy) from the execution plan Contract. |
| 6 | RuleSet identifier | `Provenance.extension[dis-ruleset]` | Identifier of the ruleSet that produced this evidence |
| 7 | Reversibility state | `Provenance.extension[dis-reversibility]` | `irreversible` or `reversible` |
| 8 | Validation status | `Provenance.extension[dis-validation-status]` | Output validation result: `valid` or `invalid` |
| 9 | Audit correlation identifier | `Provenance.extension[dis-audit-correlation]` | Identifier linking this evidence to the ATNA audit trail |
{: .grid}

Elements 2, 6, 7, 8, and 9 use DIS-defined extensions on the HL7 FHIR R4 Provenance resource. The extension URLs follow the pattern `https://profiles.ihe.net/ITI/DIS/StructureDefinition/<extension-name>`.

<a name="3pxx152-provenance-resource-structure"> </a>

<a name="3pxx42-provenance-resource-structure"> </a>

<a name="3pxx42-r4-provenance-resource-structure"> </a>

## 3:PXX.5.2 R4 Provenance Resource Structure

In addition to the nine baseline elements, the Provenance resource SHALL include the following standard HL7 FHIR R4 Provenance elements.

Table 3:PXX.5-2 lists the required Provenance elements beyond the baseline.

<p id="tPXX.4-2" class="tableTitle"><strong>Table 3:PXX.5-2: Required Provenance Elements</strong></p>

| Element | Cardinality | Description |
|---------|-------------|-------------|
| `Provenance.recorded` | 1..1 | Timestamp when the de-identification task completed |
| `Provenance.agent` (performer) | 1..1 | The De-Identifier that executed the task, identified by reference or identifier |
| `Provenance.agent` (policy authority) | 0..1 | The authority whose policy governed the task, when identifiable |
| `Provenance.reason` | 0..* | Coded reason for the de-identification (e.g., research, clinical pseudonymization) |
{: .grid}

The `Provenance.agent` entry for the De-Identifier SHALL use `Provenance.agent.type` with coding `http://terminology.hl7.org/CodeSystem/provenance-participant-type|performer`. The `Provenance.agent.who` SHALL reference or identify the De-Identifier.

<a name="3pxx114-evidence-representation-across-versions"> </a>

<a name="3pxx3214-evidence-representation-across-versions"> </a>

<a name="3pxx43-identifying-results-across-fhir-releases"> </a>

## 3:PXX.5.3 Identifying Results Across FHIR Releases

De-identification evidence is represented as HL7 FHIR R4 `Provenance` resources, which are part of the protocol layer. The following rules identify the payload covered by the R4 evidence:

- `Provenance.target` identifies a native R4 result, an R4 wrapper carrying or locating the result, or the direct release-qualified HTTPS reference to a hosted R5 result.
- For a resource list, each `Provenance.target.reference` SHALL match a selected List item. For a bundled output, the reference SHALL resolve to exactly one entry by `Bundle.entry.fullUrl` in the same result package. For a hosted output, use the HTTPS reference selected by the List. If the List item has the DIS Target FHIR Release extension, the evidence target SHALL carry the same extension value. The receiver SHALL compare both the reference and the presence and value of the release extension before accepting a match. Resolve a direct hosted R5 target under the same rules as its List item.
- For bulk, each `Provenance.target.reference` SHALL identify a selected DIS Bulk Result File descriptor by its Bundle entry `fullUrl`. The evidence targets the R4 descriptor rather than the NDJSON URL directly.
- Each selected output entry or file SHALL be covered by at least one evidence target. The receiver SHALL reject missing, unresolved, ambiguous, or unselected targets before accepting or releasing the result.
- Transformation summary entries use version-neutral FHIRPath target paths (e.g., `Patient.name`, `Patient.birthDate`). These paths describe what was transformed, not the version of the resource that was transformed.
- Policy references, ruleSet identifiers, reversibility state, validation status, and audit correlation identifiers are version-independent metadata.

The target release extension on a direct hosted R5 reference governs retrieval of that target. The Provenance resource itself remains R4.

<a name="3pxx153-transformation-summary"> </a>

<a name="3pxx43-transformation-summary"> </a>

<a name="3pxx44-transformation-summary"> </a>

## 3:PXX.5.4 Transformation Summary

Each Provenance resource SHOULD include a transformation summary recording the actions applied to individual elements. The transformation summary is carried as a DIS-defined extension `dis-transformation-summary` containing an array of entries.

Table 3:PXX.5-3 lists the elements of each transformation summary entry.

<p id="tPXX.4-3" class="tableTitle"><strong>Table 3:PXX.5-3: Transformation Summary Entry Elements</strong></p>

| Element | Cardinality | Type | Description |
|---------|-------------|------|-------------|
| `targetPath` | 1..1 | string | FHIRPath expression identifying the transformed element |
| `action` | 1..1 | code | Action code applied from the DIS Transformation Action Value Set |
| `outcome` | 1..1 | code | `applied`, `skipped` (element not present), or `error` |
| `ruleId` | 0..1 | string | Identifier of the execution plan rule that triggered this action |
{: .grid}

The transformation summary enables audit and review of the specific actions applied to each element. It does not contain the original or transformed values. Original values SHALL NOT appear in evidence, including in selector literals. If the producer cannot express a summary entry without exposing source values or protected material, it SHALL omit that entry from recipient-facing evidence.

<a name="3pxx154-evidence-example"> </a>

<a name="3pxx44-evidence-example"> </a>

<a name="3pxx45-evidence-example"> </a>

## 3:PXX.5.5 Evidence Example

The [evidence example](Provenance-dis-evidence-uc3-001.html) illustrates the Provenance produced when a pseudonymization task completes in Use Case 3 (Clinical Pathology Order). It conforms to the [DIS Evidence profile](StructureDefinition-DIS-Evidence.html) and references a synthetic [pseudonymized Patient](Patient-pseudonym-abc123.html).

<a name="staged-release-evidence"> </a>

<a name="3pxx46-staged-release-evidence"> </a>

## 3:PXX.5.6 Staged Release Evidence

For each payload set processed in two or more stages in a distributed job, the De-ID Manager SHALL include exactly one [DIS Staged Release Evidence](StructureDefinition-DIS-StagedReleaseEvidence.html) Provenance in that set's job result package. This record is the Manager's assertion that it validated the assigned stage results and authorized release. The Manager SHALL include it only after validating all assigned results and rechecking release authorization. It applies to completed ITI-x1 and ITI-x4 job results.

| Provenance element | Staged release requirement |
|---|---|
| `agent.who` | Identify the De-ID Manager as the record's author. |
| `recorded` | Time the Manager recorded the release decision. |
| `policy` | The version-specific evidence URI for the exact approved policy for the set. Use the same URI as the dispatched execution plans. |
| `target` | Reference every final output entry selected by the manifest, exactly once, using the rules in [evidence targets](#3pxx3214-evidence-representation-across-versions). |
| `extension[dis-validated-stage]` | One entry for every assigned ruleSet whose result the Manager validated. Each entry contains `stageId`, `ruleSetId` and a positive integer `sequence`. Number entries consecutively from 1 in policy stage order and ruleSet order within each stage. The sequence represents policy order, including where independent tasks run concurrently. |

The Manager SHALL preserve DIS Evidence from the tasks that produced the selected final output. If it changes result delivery, apply the [result packaging rules](volume-3-fhir-delivery.html#result-evidence-placement) while preserving task attribution. Earlier task Provenance remains associated with its own task output. The Manager SHALL exclude from the job result any superseded intermediate output and its evidence, along with source identifiers, protected mappings, confidential salts and protected transformation parameters. The staged release record SHALL appear only in the job result package for the qualifying set.

The Requester SHALL use the [exact approved policy](volume-3-policy.html#approved-policy-access) to determine the expected stage and ruleSet sequence for the submitted set. The Requester SHALL verify that `Provenance.policy` identifies that same version using the policy identity it obtained independently of the result package.

For each set expected to use multiple stages, the Requester SHALL verify that the package contains one staged release record authored by the responding Manager, that its policy identifies the approved version, and that its sequence matches the expected stage and ruleSet IDs in policy order. It SHALL verify that the staged release record covers all and only the selected final outputs. It SHALL also validate the accompanying DIS Evidence and its coverage. The Requester SHALL reject the job result if any required check fails. The evidence checks apply independently of the number of Bundle entries.

The [staged R4 Patient example](Bundle-staged-r4-patient-result.html) shows the final worker's DIS Evidence alongside the Manager's release record. The [approved example policy](Contract-staged-patient.html) supplies the expected stage and ruleSet order. In this example, the version-specific evidence URI for the approved policy is `https://governance.example.org/fhir/Contract/staged-patient/_history/1`.
