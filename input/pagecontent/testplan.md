## DIS Conformance Test Plan

This draft checklist follows [Volume 1](volume-1.html), the authoritative profile baseline. Detailed procedures, fixtures and expected messages remain drafting work. This page does not report executed interoperability tests.

## Actor and Transaction Conformance

### Actor and Option Coverage

- De-Identification Requester: ITI-x1; ITI-x4 when DIS-ASYNC-JOB is declared.
- De-ID Manager: ITI-x1 and ITI-x3; ITI-x4 for DIS-ASYNC-JOB and ITI-x7 for DIS-ASYNC-TASK.
- De-Identifier: ITI-x3; ITI-x7 when DIS-ASYNC-TASK is declared.
- Integrated De-ID Manager/De-Identifier: content conformance in standalone mode; ITI-x1 when external job submission is supported, and ITI-x4 when DIS-ASYNC-JOB is declared. ITI-x3 and ITI-x7 do not apply.

Check the mandatory R4 protocol binding, applicable content requirements and required actor groupings against Volume 1. All actors require DIS-FHIR-Payload in Phase 1. Processing actors declare at least one of DIS-IRREVERSIBLE or DIS-REVERSIBLE. Test async job and task options independently and reject unsupported capability combinations before dispatch.

### Wire and Release Procedures

| Actor and setup | Stimulus | Pass criteria |
|---|---|---|
| Requester, Manager, and De-Identifier with R4 list delivery | Run the [single-Patient synchronous exchange](examples-single-r4-patient.html). Repeat with no `payload`, a duplicated `setId`, then a top-level `processingTarget` alongside a valid set. | The valid exchange returns HTTP 200 and one result with matching set ID, evidence and valid status. Each invalid submission returns 400 without acceptance, dispatch or a result. |
| Manager with both async options; peers with the option used on their leg | Run all supported synchronous and asynchronous combinations with the same policy and data. Poll accepted work while pending and after completion. | Only the selected legs return 202 with a polling URL. Pending responses carry no result. Successful polls return the same Parameters shape as synchronous success. |
| Worker serving an asynchronous reversible task | Poll the same URL as the assigned Manager, then as a different authenticated Manager without task access. | The assigned Manager can retrieve the authorized result. The other Manager receives an authorization error without task state, evidence, or mapping. |
| Manager and worker after an accepted job | Return a transient polling error, then simulate a terminal failure of a required task after another set has completed. | The first error does not assert terminal task failure. The terminal failure returns 422 to an authorized poll, with no job result. The Requester cannot retrieve any set from its result service. |
| Manager with a two-stage policy | First pseudonymize a Patient, then apply a record-level transformation. Repeat with two ruleSets in the same stage selecting that Patient. | The later operation receives the validated preceding output. The Manager preserves policy order and returns one authoritative result. A plan with unresolved output composition is rejected before dispatch. |
{: .grid}

### Policy Admission and Execution

Cover canonical policy URL/version declarations and their match to data request authorization. Test both optional JWS-signed Requester-carried content and Manager-resolved content using the deployment's trust model. Verify authorization consistency, integrity, schema conformance and currency before acceptance or dispatch; failed or incomplete admission validation produces a synchronous error.

Cover Semantic-Level compilation, Syntax-Level validation and packaging, ordered rules, one execution plan per ruleSet, and optional stage ordering. Full composable execution plans and dataset-level statistical disclosure control are outside Phase 1.

Compile a policy targeting `@dates` against R4 and R5 Encounter payloads. Verify that the plan uses `Encounter.period` for R4 and `Encounter.actualPeriod` for R5, that the plans preserve source rule and selector order, and that no semantic group references remain. Use an unknown group or a release with no binding and verify that the Manager fails compilation before dispatch. For a choice selector, verify that a dateTime or Period value is selected and a free-text value is outside the selection. Compile separate rules for `@birth-dates`, `@dates`, and `@subject-demographics` using binding version 0.2.0 for R4 and R5. Verify that only the `@birth-dates` rule emits a selector for `Patient.birthDate`.

#### Shared Policy Across Payload Sets

Submit an ITI-x1 job containing an R4 Encounter set and an R5 Encounter set with distinct `setId` values. Both sets declare the same canonical URL and version of an active Semantic-Level policy that applies `remove` to `@dates`. Use compatible De-Identifiers and one job authorization. Request asynchronous processing when both job actors support it so that premature acceptance is observable.

| Case | Setup or change | Pass criteria |
|---|---|---|
| Both sets are approved and supported | The job authorization covers both sets and approves the declared policy for each. Use the published R4 and R5 semantic group bindings. | The Manager checks approval for both sets and prepares an execution plan for each release. The R4 plan selects `Encounter.period` and the R5 plan selects `Encounter.actualPeriod`. Each task carries its assigned set ID. The successful job response contains both set results and their evidence. |
| Approval applies to only one set | Keep both sets within the authorized data scope, but approve the declared policy for the R4 set only. Leave both policy declarations unchanged. | ITI-x1 returns a synchronous error with an OperationOutcome. The Manager sends no HTTP 202, returns no polling URL, dispatches no task, and releases no result. |
| One release has no applicable selector binding | Restore approval for both sets. In a controlled test, make the binding for `@dates` unavailable for R5 while keeping the R4 binding and processing capabilities available. | The Manager detects the missing R5 binding during compilation and dispatches no tasks for the job. It reports the failure through the applicable job response and releases neither set. |
{: .grid}

### Transformation Actions

For each core action, specify valid and invalid parameters, applicable data types, expected transformed values and failure outcomes:

`remove`, `redact`, `replace`, `hash`, `truncate-date`, `round`, `truncate`, `date-shift`, and `keep`.

Use the action definitions in [Volume 3](volume-3.html#transformation-actions). Cover scope and salt compatibility, date-shift consistency, derivation versions, rotation, collision handling and capability matching. Test protected parameter return/reuse only when an explicit capability contract permits it.

### Payload, Evidence and Release

Cover R4 workflow resources with independently versioned R4/R5/R6 payloads. R6 feasibility is provisional and assessed separately from Phase 1. Verify declared-version validation and version-safe packaging; R5/R6 resources must not be embedded as native resources in R4 envelopes.

Submit one inline R4 Patient through a manifest package and verify that the List selects exactly the intended Patient. Verify that ITI-x3 carries the assigned set and that the returned result and evidence preserve its `setId`. Reject a request without a `payload` set, a request with a top-level `processingTarget` or `resourceManifest`, an unauthorized entry, and a payload whose version metadata conflicts with `payloadVersion`. Verify stable selection across retries and verify that task and job result manifests resolve to authorized de-identified resources. For bulk input, cover a complete authorized manifest, a dataset outside the approved scope, and missing files or expired access. Verify that a required input failure withholds all job output, including access through result endpoints.

Inspect all nine evidence elements: evidence identifier, outcome status, workflow reference, target identifier, policy-decision reference, ruleSet identifier, reversibility state, validation status and audit correlation identifier. Verify reference integrity and handling of narratives, extensions, contained resources and attachments.

Check Manager custody of mappings/reversibility records, mode-dependent retention, deletion of temporary mapping copies at task termination and exclusion of protected transformation material from recipient-facing output, evidence and logs. Patient association in UC-3/4 remains implementation-defined and outside standardized DIS transactions.

### Jobs with Multiple Payload Sets

Submit a job with two payload sets, distinct set identifiers, and an approved policy for each set. Verify dispatch and plan selection per set, including a handoff from bundled to hosted content that preserves the target set. Compare bundled and externally hosted manifest entries for each supported binding. For R5, exercise an R4 wrapper with inline bytes and with an HTTPS attachment URL. Reject direct cross-release List references, unresolved bundle-local references, wrappers with both data and URL, a mismatched payload release, duplicate set identifiers, parameters outside the applicable request table, and unauthorized manifest entries. Verify correlation of each result and its evidence to the submitted set. Fail one task after another set succeeds and verify that the Requester receives no output for either set.

### Evidence in Fully Inline FHIR Results

Use the native R4 Patient and wrapped R5 Encounter examples. For each fully inline set, verify that the receiver finds DIS Evidence Provenance in the decoded manifest package, that no outer evidence is present, and that each target matches exactly one selected entry by `fullUrl`. Verify that the R5 target is the R4 wrapper and that its decoded attachment validates as R5. Check synchronous job and task responses and the corresponding completed polling responses.

Repeat with no bundled evidence, an unresolved target, duplicate target entry URLs, a target pointing to an unselected entry, and a second evidence copy in the outer result group. In each case, the receiver rejects the result and the Manager withholds release. Repeat with a result that requires external retrieval and verify that evidence appears only in the outer result group. Exercise a job containing both fully inline and hosted sets and verify placement independently for each set.

### Reversible Lookup Mapping

Cover both mandatory DIS-REVERSIBLE arrangements: absent table causes Manager mapping creation/maintenance and persistence; supplied table causes authoritative direct-identifier replacement without mandatory Manager persistence. Test complete tables, missing entries before acceptance and after async acceptance, duplicate/ambiguous mappings, incompatible irreversible policy, unauthorized scope, no fallback generation, consistent patient identifier replacement and valid output references, task-scoped disclosure and terminal deletion. Missing entries must reject/fail the complete job and release no partial output. Inspect that source identifiers and mappings are absent from recipient-facing evidence, logs and error diagnostics.

### Cross-Community Consistency Prerequisites

For deployments claiming cross-community pseudonym consistency, inspect externally established identity resolution, shared-scope authorization and coordination of salt versions. For matching source identifier pairs, the same scope and salt version SHALL produce the same pseudonym across participating De-Identifiers. Cross-community prerequisites remain outside the DIS transaction test.

### Pseudonym Derivation and Policy Compatibility

Exercise the published salted and unsalted test vectors. Verify matching output across workers and retries using the same source identifier, scope and effective salt. Verify different salted scopes, rejection of an unauthorized scope, missing or incorrectly sized salts, and incompatible execution plan parameters. For patient identifier hashing, verify the replacement system and full digest. Verify that retained internal FHIR references resolve in the output.

For reversible patient hashing, verify the inline `generatedLookupTable` in synchronous ITI-x3 and asynchronous ITI-x7 completion. Validate the original-to-pseudonym pairs, resolved scope and Manager retention before release. Check that the supplied-table and irreversible patient workflows do not return a generated patient table. Verify that mapping artifacts and confidential salts stay out of recipient output, evidence, logs and errors.

### Persistent Lookup Table References

Check the DIS-LookupTable DocumentReference and DIS-LookupTableContent Binary profiles. Exercise literal and version-specific references, exact-version identifier resolution, inline JSON and Binary attachments, stable business identifiers and content-version masterIdentifier, policy/content scope agreement, current-status admission, unavailable or unauthorized retrieval, ambiguous identifiers, and changed bytes under a pinned identifier. Verify a job/retry uses one pinned snapshot and task subsets use distinct derived document identifiers with transforms provenance. Delete temporary snapshots and derived task artifacts without deleting the Requester's authoritative repository.

## Artifact Validation and Reporting

Use synthetic fixtures. Validate available FHIR artifacts and examples, compile FSH, check links and diagrams, and build the guide. Record actor, declared options, preconditions, inputs, observable expected behavior and pass/fail criteria for each procedure. Standalone Integrated actor review includes pipeline behavior as well as output/evidence inspection. Artifact validity alone does not demonstrate operational interoperability or de-identification adequacy.

The [Data Recipient and push-delivery proposal](issues.html#data-recipient-and-push-delivery) remains open. Phase 1 assesses the standalone UC-5 case through content conformance.

### Published Lookup Table Examples

Validate the [published lookup table examples](volume-3.html#3pxx52-worked-mapping-examples) against their declared FHIR profiles. Decode the Binary and inline attachments and check that they carry the same table. Check that the task-scoped example references the source version and contains only the assigned mappings. Validate the generated table and confirm that its pseudonym matches the salted test vector and the published Patient example.

## Informative Future Binding Feasibility

These checks support draft DICOM, CDA, and R6 design review. Phase 1 pass/fail criteria use published R4 or R5 payloads. The draft CDA check resolves an authorized DocumentReference to one CDA document and rejects the wrong index type.

### Mixed R5 and DICOM Job Procedure

Use the [mixed payload walkthrough](examples-mixed-r5-dicom.html) once the DICOM binding is available for testing. Configure an R5-capable De-Identifier, a DICOM-capable De-Identifier, and an imaging endpoint with two authorized instances and an additional instance outside the manifest. Use one permit covering both sets and their approved policies.

| Step | Action | Expected result |
|------|--------|-----------------|
| 1 | Submit the inline R5 package and the version-specific imaging List in ITI-x1 with `Prefer: respond-async`. | The Manager returns `202 Accepted` and a polling URL. Both set-to-policy assignments are recorded under the job. |
| 2 | Inspect the two ITI-x3 requests and observe source retrieval. Repeat the imaging retrieval against the same job selection. | The clinical task receives the submitted R5 bytes. The imaging task uses the assigned endpoint and the same two SOP Instance UIDs on each attempt. The worker does not retrieve the unlisted instance. |
| 3 | Complete the clinical task while the imaging task remains in progress. Poll ITI-x4 with the Requester's credentials. | The Manager returns in-progress status and no payload results. The Requester cannot retrieve intermediate output through the result service. |
| 4 | Complete imaging and poll ITI-x4 again. | One successful response contains two `payloadResult` groups with the original set IDs. Verify that the clinical evidence resolves to the R4 wrapper, the draft imaging evidence resolves to the result index, and the manifest selects only the two de-identified DICOM instances. |
| 5 | Repeat with one imaging instance unavailable after acceptance and the clinical task successful. | The imaging task reports failure. ITI-x4 returns HTTP 422 with an `OperationOutcome`. Neither set is made available to the Requester. |
{: .grid}
