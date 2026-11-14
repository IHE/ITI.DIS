## DIS Conformance Test Plan

This draft checklist follows [Volume 1](volume-1.html), the authoritative profile baseline. Detailed procedures, fixtures and expected messages remain drafting work. This page does not report executed interoperability tests.

## Actor and Transaction Conformance

### Actor and Option Coverage

- De-Identification Requester: ITI-x1; ITI-x4 when DIS-ASYNC-JOB is declared.
- De-ID Manager: ITI-x1 and ITI-x3; ITI-x4 for DIS-ASYNC-JOB and ITI-x7 for DIS-ASYNC-TASK.
- De-Identifier: ITI-x3; ITI-x7 when DIS-ASYNC-TASK is declared.
- Integrated De-ID Manager/De-Identifier: content conformance in standalone mode; ITI-x1 when external job submission is supported, and ITI-x4 when DIS-ASYNC-JOB is declared. ITI-x3 and ITI-x7 do not apply.

Check the mandatory R4 protocol binding on external transactions, the applicable content requirements and the required actor groupings against Volume 1. Check DIS-FHIR-Payload support for each actor and at least one declared reversibility option for each processing actor. Test async job and task options independently and reject unsupported capability combinations before dispatch.

### Wire and Release Procedures

| Actor and setup | Stimulus | Pass criteria |
|---|---|---|
| Requester, Manager, and De-Identifier with R4 list delivery | Authorize and submit only the [UC-2 R4 payload set](examples-grouped-fhir-job.html#grouped-fhir-submission). Omit `Prefer: respond-async` on both submissions. Repeat with no `payload-set` input, a duplicated `setId`, an unexpected Task input code, and a Parameters body. Send an ITI-x3 task submission with its execution plan input missing. | The valid exchange returns HTTP 200 and one result with matching set ID, evidence and valid status. Each invalid submission returns 400 without acceptance, dispatch or a result. |
| Manager with both async options; peers with the option used on their leg | Inspect the [async capability declarations](volume-2.html#asynchronous-capability-declaration) on the corresponding client and server operation entries. Run all supported synchronous and asynchronous combinations with the same policy and data and a fresh submission identifier per run. Poll accepted work while pending and after completion. Compare with a server that declares only synchronous processing. | Only the selected legs return 202 with a polling URL associated with the submitted `Task.identifier`. Pending responses carry no result. Successful polls return the same Parameters shape as synchronous success. The initiator selects async only when the corresponding server entry declares it. |
| Manager and De-Identifier with FHIR payload support | For each supported manifest format, match the full capability entry and dispatch a task. In a separate run, return an otherwise valid task result in the other manifest format. | The successful task result uses the assigned input manifest format. A mismatched result fails validation and the Manager withholds all job output. |
| Worker serving an asynchronous reversible task | Poll the same URL as the assigned Manager, then as a different authenticated Manager without task access. | The assigned Manager can retrieve the authorized result. The other Manager receives an authorization error without task state, evidence, or mapping. |
| Manager and worker after an accepted job | Return a transient ITI-x7 error, then return successful task output on a subsequent authorized poll. Repeat with a terminal task failure after another set has completed. | The transient error leaves the task unresolved. In the success run, the Manager can complete the job after validation. In the failure run, ITI-x4 returns 422 with an OperationOutcome and the Requester cannot retrieve either result set. |
| Manager processing an asynchronous job with synchronous worker dispatch | Accept the job with HTTP 202, then have the synchronous ITI-x3 assignment fail. Repeat with a definitive rejection of an async assignment. | The Requester receives the terminal failure on an authorized ITI-x4 poll. No result is released. |
| Worker receiving an asynchronous assignment | Submit a malformed Task, submit with invalid credentials, and repeat with an unsupported payload version or asynchronous mode. In a separate valid run, make a referenced payload unavailable after acceptance. | The admission failures return 400, 401, or 422, respectively, without a handle. The accepted run returns HTTP 202 with a task handle and reports the later failure through ITI-x7. |
| Job or task responder with documented terminal retention | Poll an accepted item while pending and again after it reaches a terminal state, within the responder's documented retention period. Test an expired handle separately. | The authorized caller can retrieve the status during the documented period. An expired handle reports a retrieval error. |
| Manager with a two-stage policy | First pseudonymize a Patient, then apply a record-level transformation. Repeat with two ruleSets in the same stage selecting that Patient. | The later operation receives the validated preceding output. The Manager preserves policy order and returns one authoritative result. A plan with unresolved output composition is rejected before dispatch. |
{: .grid}

### Work Order Identifier and Recovery

Exercise the [shared identifier and retry rules](volume-2.html#submission-retries) on ITI-x1 and ITI-x3.

| Stimulus | Pass criteria |
|---|---|
| Send equivalent submissions concurrently, then repeat once the original response is available. | Only one work item starts. A pending retry returns HTTP 409 with `DIS-Submission: pending`. A later retry replays the recorded response and, for async acceptance, the original polling URL. |
| Reuse the scoped identifier with a changed body or processing selection. | HTTP 409 with an OperationOutcome indicating an identifier conflict. The original work item is preserved. |
| Lose either submission response and recover with refreshed credentials for the same actor. Repeat for a never-submitted identifier and from another actor. | An accepted submission returns the original URL with `DIS-Submission: replayed`. Recovery for an absent record starts no work. The other actor learns nothing about the original submission. |
| Lose an ITI-x3 response while the Manager is cancelling the job. Repeat with an accepted assignment, a recorded rejection and an absent record. | The Manager cancels an outstanding assignment once it recovers its URL, accounts for a recorded rejection without starting work, and treats an absent record as unresolved. No recovery creates an assignment or permits result release. |
{: .grid}

<a name="job-and-execution-task-correlation"></a>

### Correlating De-Identification Jobs and Tasks

Exercise the [assignment correlation and disclosure rules](volume-2.html#assignment-correlation).

| Actor and setup | Stimulus | Pass criteria |
|---|---|---|
| Manager with two accepted jobs and multiple assignments | Use two Requesters with the same submitted `Task.identifier` pair and reuse the same `setId`, ruleSet ID, and stage ID in both jobs. Dispatch to the same De-Identifier and deliver results out of order. Where cancellation is supported, cancel one job while both have outstanding work. | Each result, audit record, and cancellation action is associated with the correct job and assignment. The other job's processing and result remain independent. |
| Manager and De-Identifier with an authorized parent alias | Run once with disclosure denied and once with disclosure authorized. Compare the assignment without `Task.partOf` and the assignment with an authorized identifier-only `Task.partOf`. Repeat with a literal parent URL, a missing identifier system or value, `Task.basedOn`, or `Task.groupIdentifier`. | Both valid forms are accepted. Invalid forms are rejected before task admission. The valid request discloses only the authorized assignment and any permitted opaque parent alias, and that alias conveys no job access. |
{: .grid}

### Asynchronous Job and Task Cancellation

Use the [cancellation contract](volume-2.html#asynchronous-cancellation) with synthetic data. Verify that the asynchronous processing support extension on each applicable submission operation declares both polling and cancellation.

| Actor and setup | Stimulus | Pass criteria |
|---|---|---|
| Requester and Manager declaring DIS-ASYNC-JOB, and the Manager and both De-Identifiers declaring DIS-ASYNC-TASK | Adapt the [two-file cohort](examples-bulk-fhir-cohort.html) to use two authorized sets. Submit the job and both tasks with `Prefer: respond-async`. Send DELETE to the job URL while one task runs and the other acceptance is in flight. | The job and both tasks return HTTP 202 with their respective polling URLs. The Manager returns pending cancellation, stops new dispatch, and sends DELETE to each outstanding task URL as it becomes available. Once both tasks reach known terminal states, the job poll returns HTTP 410 with `DIS-Cancellation: cancelled`. No job output is released. |
| Requester and Manager with a synchronous worker as in [UC-2](examples-grouped-fhir-job.html) | In separate runs, send DELETE before dispatch, while the synchronous submission is outstanding, and after the worker has finished while the job is still active. Exercise both orderings of dispatch and cancellation at the dispatch boundary. | Before dispatch or after the worker is known terminal, the Manager accepts cancellation of the active job, withholds results, and dispatches no further task. While the submission is outstanding, cancellation returns HTTP 409 and ordinary job processing continues. No execution both commits a synchronous dispatch and accepts cancellation while that assignment is outstanding. |
| Manager and De-Identifier declaring DIS-ASYNC-TASK | Submit a task with `Prefer: respond-async`. After HTTP 202, send an authorized DELETE to the task URL while the task is active. | ITI-x7 accepts cancellation and confirms it after the task stops. Subsequent polls report cancellation and withhold the task result. |
| Obsolete submission opt-in | Send `DIS-Cancellation: required` on ITI-x1 or ITI-x3, with and without `Prefer: respond-async`. | Each returns HTTP 400 with an R4 OperationOutcome without accepting the submission. |
| Receiver with authorized polling and cancellation callers | Repeat an authorized DELETE while pending and after confirmation. Also send DELETE with missing credentials and with credentials that authorize polling only. | The authorized retry returns the recorded outcome without creating work. The other requests return 401 and 403 respectively, without disclosing cancellation details or altering state. |
| Manager and De-Identifier in a completion race | Complete one task just before the Manager cancels it. In a separate run, make the job result available just before the Requester requests cancellation. | The task's DELETE returns HTTP 409 and the ordinary poll confirms terminal completion. The Manager discards the task output when job cancellation was accepted. In the second run, the job's DELETE returns HTTP 409 and ordinary authorized retrieval remains available. |
| Manager with an unresolved remote assignment | Drop the task submission response or make the task endpoint unavailable during cancellation. Continue authorized job polling beyond the advertised confirmation interval. | The Manager uses recovery-only requests for a lost handle and starts no new assignment. While confirmation is pending, job polling returns HTTP 202 with `DIS-Cancellation: pending`. If work remains unconfirmed when the interval expires, polling returns HTTP 422 with `DIS-Cancellation: unconfirmed`. No result is released. |
| Cancellation receiver with a retained unconfirmed outcome | For ITI-x4 and ITI-x7, establish that the outstanding work stopped after reporting `unconfirmed` but before the polling URL expires. Poll and repeat DELETE with authorized credentials. | The poll returns HTTP 410 and DELETE returns HTTP 204, both with `DIS-Cancellation: cancelled`. The confirmed outcome remains available for at least the documented cancellation retention period from confirmation. No result is released. |
| Externally invoked Integrated actor declaring DIS-ASYNC-JOB | Submit and cancel an accepted job while local processing is still running. | The actor stops processing, reports confirmation after local work stops, and withholds the result. All exchanges use ITI-x1 and ITI-x4. |
{: .grid}

### Transport, Authorization and Audit

Apply the [actor grouping table](volume-1.html#required-groupings) and the [shared transaction authorization and audit rules](volume-2.html#transaction-authorization) to the actors and options under test. Use synthetic work items and credentials.

| Actor and setup | Stimulus | Pass criteria |
|---|---|---|
| Actors on either DIS exchange | Inspect each actor's declared ATNA grouping. Connect over TLS 1.2 or later with both trusted peers, then repeat with an untrusted peer. | The Requester declares Secure Application. Each processing actor declares Secure Node or Secure Application. Only the trusted peers can complete the DIS exchange. |
| Requester, retrieval delegate, and job responder | Poll with a delegate credential that permits retrieval only. With that credential, attempt job cancellation and recovery of the original submission. Repeat recovery as the original actor using renewed credentials. | The delegate can poll within its authorized scope. Its cancellation and recovery attempts reveal no protected state and cause no change. Authorized recovery under the original actor identity returns the retained submission outcome. |
| De-Identifier and two authenticated Managers | Give one Manager a task assignment. Have the other Manager attempt recovery, polling, and cancellation using the known identifier or polling URL. | The assigned Manager can perform its authorized actions. The other Manager obtains no task state, output, evidence, or generated mapping, and its attempts leave the assignment unchanged. |
| Polling initiator with a configured trusted responder | Return a polling URL for an unauthorized endpoint. Repeat with a trusted initial URL that redirects to an unauthorized destination. | The initiator sends no poll, cancellation request, or credentials to the unauthorized destination. |
| Manager and result service after completion | Revoke the Requester's release authorization before it retrieves the job result. Attempt an authorized submission replay for a completed synchronous job after its release authorization has been revoked. | The responder and result service withhold the output and evidence. A replay does not bypass the current release check. |
| Audit inspection on both actor exchanges | Exercise initial submission, recovery, authorized and denied polling, terminal failure, and allowed and denied cancellation where supported. | The audit trail records the actions and outcomes required by each transaction. Completed task evidence correlates to the audit trail. Logs and error diagnostics omit tokens, signed access URLs, source payload bodies, salts, and lookup contents. |
{: .grid}

### Policy Admission and Execution

Configure the Requester with access to the approved policy and the Manager with a trusted means of obtaining or verifying the same version. Test both optional JWS-signed Requester-carried content and Manager-resolved content. Verify authorization consistency, integrity, schema conformance and currency before acceptance or dispatch.

| Stimulus | Pass criteria |
|---|---|
| Submit the authorized canonical URL and version with the approved signed content. Repeat with the Manager resolving the same approved version. | Both modes use the exact approved rules. The Requester can read the same approved version in both cases. |
| Substitute a different valid policy or version for one payload set. | The Manager returns an authorization consistency error with no acceptance, dispatch or result. |
| Submit a job with two sets under different approved policies. Give both policies the same reversibility mode, then repeat with one policy declaring the other mode and approval for that policy. | With a common mode, every ITI-x3 task submission carries that mode. With mixed modes, ITI-x1 returns HTTP 422 with an OperationOutcome before acceptance or dispatch and returns no result. |
| Modify the carried rules while retaining their declared URL and version. Repeat with Manager-resolved content that changes under the same identity. | The Manager returns an integrity error with no acceptance, dispatch or result. |

Cover Semantic-Level compilation, Syntax-Level validation and packaging, ordered rules, one execution plan per ruleSet, and optional stage ordering. Full composable execution plans and dataset-level statistical disclosure control are outside the scope of this supplement.

Compile a policy targeting `@dates` against R4 and R5 Encounter payloads. Verify that the plan uses `Encounter.period` for R4 and `Encounter.actualPeriod` for R5, that the plans preserve source rule and selector order, and that no semantic group references remain. Use an unknown group or a release with no binding and verify that the Manager fails compilation before dispatch. For a choice selector, verify that a dateTime or Period value is selected and a free-text value is outside the selection. Compile separate rules for `@birth-dates`, `@dates`, and `@subject-demographics` using binding version 0.2.0 for R4 and R5. Verify that only the `@birth-dates` rule emits a selector for `Patient.birthDate`.

#### Source Policy Identity in an ITI-x3 Plan

Dispatch the [UC-2 R4 clinical task](Task-grouped-fhir-task-patient-r4.html) with its versioned execution plan Library in the [hosted artifact collection](Bundle-grouped-fhir-hosted-artifacts.html). Give the De-Identifier access to the plan and assigned payload. Verify that the De-Identifier can return the exact evidence URI carried by the plan in `Provenance.policy` with no retrieval of the source policy. Verify that the Manager checks that URI against the dispatched plan before release.

Repeat with the `derived-from` entry absent, with an unversioned canonical, with the evidence URI absent, and with two source policy entries. Each task fails before transformation and returns an OperationOutcome without a result. Supply a policy URI for a different version when assembling the plan and verify that the Manager does not dispatch it. Return successful task evidence with a different policy URI and verify that the Manager withholds job output.

### Shared Policy Across Payload Sets

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

Cover R4 workflow resources with independently versioned R4 and R5 payloads. Verify declared-version validation and exercise inline R5 in an R4 wrapper and hosted R5 both directly and through a wrapper. Verify that a request for a payload release outside the supported binding is rejected before dispatch.

Submit one inline R4 Patient through a manifest package and verify that the List selects exactly the intended Patient. Verify that ITI-x3 carries the assigned set and that the returned result and evidence preserve its `setId`. Reject a Task with no `payload-set` input, a Task using a `processingTarget` or `resourceManifest` input code, a manifest with an unauthorized entry, and a payload whose release conflicts with the declared `payloadVersion`. Verify stable selection across retries and verify that task and job result manifests resolve to authorized de-identified resources. For bulk input, cover a complete authorized manifest, a dataset outside the approved scope, and missing files or expired access. Verify that a required input failure withholds all job output, including access through result endpoints.

Inspect all nine evidence elements: evidence identifier, outcome status, workflow reference, target identifier, policy-decision reference, ruleSet identifier, reversibility state, validation status and audit correlation identifier. Verify reference integrity and handling of narratives, extensions, contained resources and attachments.

Check Manager custody of mappings/reversibility records, mode-dependent retention, deletion of temporary mapping copies at task termination and exclusion of protected transformation material from recipient-facing output, evidence and logs. Patient association in UC-3/4 remains implementation-defined and outside standardized DIS transactions.

### Bulk Result Content Identity and Access Renewal

Test the [bulk result content identity rules](volume-3.html#bulk-result-content-identity) with the [two-file R4 cohort example](examples-bulk-fhir-cohort.html). Record the validated output manifest and NDJSON bytes before release. Use an authorized Requester to retrieve the result. Compare the retrieved bytes after decoding any HTTP content coding. The test harness may use byte comparison or locally computed digests.

| Case | Procedure | Pass criteria |
|---|---|---|
| Substituted manifest | After validation and before release, attempt to replace the manifest at the same locator. Change `requiresAccessToken` and preserve both file URLs. | The result service refuses the replacement and serves the original validated manifest, or the producer detects the change and withholds the result. The Requester cannot retrieve the changed manifest as the released version. |
| Substituted file | Repeat with one valid NDJSON file changed at its original locator. Preserve the declared FHIR resource type and manifest. | The result service refuses the replacement and serves the original bytes, or the producer detects the change and withholds the result. The Requester cannot retrieve the changed bytes as the released version. |
| Authorized renewal | Where the deployment supports renewal, expire the temporary access for one file within the release window. Request renewal with authorized credentials, then repeat with a Requester lacking access. | Authorized renewal restores access to the original bytes and preserves the released manifest, file identities, and evidence coverage. Unauthorized renewal grants no access. |

For a signed-download deployment, repeat the renewal case with `requiresAccessToken = false`. The manifest lists a stable HTTPS capability URL for the selected file version. A request to that URL redirects to a short-lived signed download URL. Verify that the client follows the redirect without a SMART bearer token. After the signed URL expires, verify that the unchanged file URL listed in the manifest can yield a fresh signed link and that the expired link still fails. Compare the downloaded bytes with the validated version after HTTP decompression. Repeat with the capability removed or revoked and with the original file version unavailable. Neither case grants renewed access or returns a substitute version.

For the substitution cases, repeat after release where the test setup allows the producer to detect a storage or retrieval fault. Confirm that the affected result set becomes inaccessible after detection and that access renewal does not expose substituted content. An authorization error or expired download does not by itself report a terminal job failure.

### Jobs with Multiple Payload Sets

Submit a job with two payload sets, distinct set identifiers, and an approved policy for each set. Verify dispatch and plan selection per set, including a handoff from bundled to hosted content that preserves the target set. Compare bundled and externally hosted manifest entries for each supported binding. For R5, exercise a direct hosted reference and R4 wrappers with inline bytes and with an HTTPS attachment URL. Reject an unqualified R5 reference that does not resolve to a conformant R4 wrapper, unresolved bundle-local references, wrappers with both data and URL, a mismatched payload release, duplicate set identifiers, inputs outside the applicable Task profile, and unauthorized manifest entries. Verify correlation of each result and its evidence to the submitted set. Fail one task after another set succeeds and verify that the Requester receives no output for either set.

### Result Packages and Evidence Coverage

Exercise fully inline R4 and wrapped R5 results, direct hosted R5 results, a List selecting bundled and hosted resources, and a bulk set with two NDJSON files. For each successful response, retrieve or decode its single `resultPackage`, validate the R4 Bundle, and verify that it has one manifest of the declared format and DIS Evidence Provenance. Verify that the outer result has no `manifest` or `evidence` part. Check synchronous task and job responses and the corresponding completed polling responses.

For a List, verify that evidence covers each selected resource or wrapper, including the exact revision and release extension for direct hosted R5. For bulk, match the file descriptors one to one to the JSON manifest, match evidence targets to those descriptors, and pass the extracted manifest to a Bulk Data client. Verify that hosted results remain accessible only to the authorized receiver. Apply the bulk content identity and renewal procedures above.

Repeat with missing evidence, the wrong manifest type, duplicate entry URLs, a missing or unlisted file descriptor, an unresolved target, a target outside the set, and an outer evidence part. Verify that the receiver rejects each result and that the Manager withholds release.

### Direct Hosted R5 References

Use the [hosted R5 input List](List-hosted-r5-input.html) and [result package](Bundle-hosted-r5-result.html) with a synthetic R5 endpoint. Verify that each retrieving actor requests the pinned revision with `fhirVersion=5.0` on a separate GET, confirms the release, validates the native payload, and checks the exact resource type, ID, and revision. Repeat with a version-specific endpoint that omits the parameter on its response and exposes an R5 CapabilityStatement. The R4 workflow resources remain independently valid.

Repeat with an unqualified R5 URL in the input List, a qualified reference on an R4 set, a missing revision, a conflicting response release, a wrong body revision, and an endpoint or response that cannot establish the requested release. Verify rejection or work-item failure as applicable and no partial job output. Repeat result verification with a Provenance target that drops the extension or identifies another revision. Verify that the receiver rejects each mismatched package. Run the same target comparison for staged release Provenance when applicable.

### Requester Validation of Staged Release Evidence

Test a De-Identification Requester with synchronous ITI-x1 and repeat with a completed ITI-x4 response if the Requester supports DIS-ASYNC-JOB. Give the Requester the [approved staged policy](Library-staged-patient.html) and its version-specific evidence URI independently of the result package. Derive the expected sequence from `stages` and their ordered `ruleSetRefs`. Run with Requester-carried content and with Manager-resolved content. Use the [staged Patient package](Bundle-staged-r4-patient-result.html) for the positive staged case. For a separate single-stage run, submit only the R4 set from [UC-2](examples-grouped-fhir-job.html#grouped-fhir-submission) under its own approved policy, `patient-name-removal|1.0`, and return the corresponding R4 set from the [UC-2 job result](Parameters-grouped-fhir-job-result.html). For the asynchronous run, adapt the [UC-1 staged cohort exchange](examples-bulk-fhir-cohort.html#submit-dispatch-and-retrieve) or use the compact [staged job submission](Task-staged-async-job.html) and the [preliminary](Task-staged-async-preliminary-task.html) and [advanced](Task-staged-async-advanced-task.html) task fixtures. Exercise both ITI-x7 polls and repeat with [recovery of a lost acceptance](examples-grouped-fhir-job.html#grouped-fhir-submission).

| Stimulus | Pass criteria |
|---|---|
| Return the single-stage and staged packages in their corresponding runs. Reorder the Bundle entries while preserving references and stage sequence values. | The Requester accepts both. It resolves the manifest and DIS Evidence by profile and reference, verifies the Manager's record for the staged set and selects only the final Patient. |
| Remove or duplicate the staged release record. Repeat with a missing ruleSet, duplicate sequence, altered order, wrong policy version or wrong Manager identity. | The Requester rejects the job result and does not use the clinical output. |
| Change the release record to reference an unresolved target or a bundled intermediate Patient that the List does not select. Repeat with missing or invalid DIS Evidence. | The Requester rejects the job result. The release record does not substitute for task evidence. |
| Complete both stages and revoke release authorization before the Manager responds. Repeat with a failure in one stage. | The Manager withholds the entire result, including the release record. |

### Reversible Lookup Mapping

Cover both mandatory DIS-REVERSIBLE arrangements: absent table causes Manager mapping creation/maintenance and persistence; supplied table causes authoritative direct-identifier replacement without mandatory Manager persistence. Test complete tables, missing entries before acceptance and after async acceptance, duplicate/ambiguous mappings, incompatible irreversible policy, unauthorized scope, no fallback generation, consistent patient identifier replacement and valid output references, task-scoped disclosure and terminal deletion. Missing entries must reject/fail the complete job and release no partial output. Inspect that source identifiers and mappings are absent from recipient-facing evidence, logs and error diagnostics.

### Cross-Community Consistency Prerequisites

For deployments claiming cross-community pseudonym consistency, inspect externally established identity resolution, shared-scope authorization and coordination of salt versions. For matching source identifier pairs, the same scope and salt version SHALL produce the same pseudonym across participating De-Identifiers. Cross-community prerequisites remain outside the DIS transaction test.

### Pseudonym Derivation and Policy Compatibility

Exercise the published salted and unsalted test vectors. Verify matching output across workers and retries using the same source identifier, scope and effective salt. Verify different salted scopes, rejection of an unauthorized scope, missing or incorrectly sized salts, and incompatible execution plan parameters. For patient identifier hashing, verify the replacement system and full digest. Verify that retained internal FHIR references resolve in the output.

For reversible patient hashing, verify the inline `generatedLookupTable` in synchronous ITI-x3 and asynchronous ITI-x7 completion. Validate the original-to-pseudonym pairs, resolved scope and Manager retention before release. Check that the supplied-table and irreversible patient workflows do not return a generated patient table. Verify that mapping artifacts and confidential salts stay out of recipient output, evidence, logs and errors.

### Encryption-Based Pseudonymization (Informative Proposal)

For the [proposed encryption method](volume-3.html#encryption-based-patient-pseudonymization), run the [synthetic FF1 vector](volume-3.html#ff1-interoperability-vector) with two independent De-Identifiers. Check the exact output identifier pair, including leading zeroes, and verify that an authorized decryptor can recover the original value. Repeat with another approved identifier format, with a retry using the pinned configuration, and with changes to the scope or key version. Check that equivalent assignments use matching pseudonyms and that the output namespace follows the approved configuration.

Verify the protected lookup table on synchronous ITI-x3 and successful asynchronous ITI-x7 responses. Check that the Manager can resolve the pseudonym by lookup and withholds release when the mapping is missing, invalid, unauthorized, or conflicting. Exercise an unsupported configuration, a changed configuration on retry, an unavailable key version, and an identifier outside the approved format. Check that key material and mappings are excluded from recipient output, evidence, logs, and errors.

### Persistent Lookup Table References

Check the DIS-LookupTable DocumentReference and DIS-LookupTableContent Binary profiles. Exercise literal and version-specific references, exact-version identifier resolution, inline JSON and Binary attachments, stable business identifiers and content-version masterIdentifier, policy/content scope agreement, current-status admission, unavailable or unauthorized retrieval, ambiguous identifiers, and changed bytes under a pinned identifier. Verify a job/retry uses one pinned snapshot and task subsets use distinct derived document identifiers with transforms provenance. Delete temporary snapshots and derived task artifacts without deleting the Requester's authoritative repository.

## Artifact Validation and Reporting

Use synthetic fixtures. Validate available FHIR artifacts and examples, compile FSH, check links and diagrams, and build the guide. Record actor, declared options, preconditions, inputs, observable expected behavior and pass/fail criteria for each procedure. Standalone Integrated actor review includes pipeline behavior as well as output/evidence inspection. Artifact validity alone does not demonstrate operational interoperability or de-identification adequacy.

The [Data Recipient and push-delivery proposal](issues.html#data-recipient-and-push-delivery) remains open. The standalone UC-5 case is assessed through content conformance.

### Published Lookup Table Examples

Validate the [published lookup table examples](volume-3.html#3pxx52-worked-mapping-examples) against their declared FHIR profiles. Decode the Binary and inline attachments and check that they carry the same table. Check that the task-scoped example references the source version and contains only the assigned mappings. Validate the generated table and confirm that its pseudonym matches the salted test vector and the published Patient example.

## Informative Future Binding Feasibility

These checks support the draft DICOM and CDA design review. DIS conformance tests use published R4 or R5 processing payloads. The draft CDA check resolves an authorized DocumentReference to one CDA document and rejects the wrong index type.

### Mixed R5 and DICOM Job Procedure

Use the [mixed payload walkthrough](draft-native-payload-bindings.html#illustrative-mixed-fhir-and-dicom-job) once the DICOM binding is available for testing. Configure an R5-capable De-Identifier, a DICOM-capable De-Identifier, and an imaging endpoint with two authorized instances and an additional instance outside the manifest. Use one permit covering both sets and their approved policies.

| Step | Action | Expected result |
|------|--------|-----------------|
| 1 | Submit the inline R5 package and the version-specific imaging List in ITI-x1 with `Prefer: respond-async`. | The Manager returns `202 Accepted` and a polling URL. Both set-to-policy assignments are recorded under the job. |
| 2 | Inspect the two ITI-x3 requests and observe source retrieval. Repeat the imaging retrieval against the same job selection. | The clinical task receives the submitted R5 bytes. The imaging task uses the assigned endpoint and the same two SOP Instance UIDs on each attempt. The worker does not retrieve the unlisted instance. |
| 3 | Complete the clinical task while the imaging task remains in progress. Poll ITI-x4 with the Requester's credentials. | The Manager returns in-progress status and no payload results. The Requester cannot retrieve intermediate output through the result service. |
| 4 | Complete imaging and poll ITI-x4 again. | One successful response contains two `payloadResult` groups with the original set IDs. Verify that the clinical evidence resolves to the R4 wrapper, the draft imaging evidence resolves to the result index, and the manifest selects only the two de-identified DICOM instances. |
| 5 | Repeat with one imaging instance unavailable after acceptance and the clinical task successful. | The imaging task reports failure. ITI-x4 returns HTTP 422 with an `OperationOutcome`. Neither set is made available to the Requester. |
{: .grid}
