This volume contains the DIS Profile transaction specifications. Each section defines the scope, actor roles, interaction model, and expected actor behaviors for one transaction. The transaction tables define the R4 message contract.

The following transactions are specified in this volume:

- [Submit De-Identification Job \[ITI-x1\]](#23x1-submit-de-identification-job-iti-x1)
- [Submit De-Identification Task \[ITI-x3\]](#23x3-submit-de-identification-task-iti-x3)
- [Retrieve Job Output \[ITI-x4\]](#23x4-retrieve-job-output-iti-x4)
- [Retrieve Task Output \[ITI-x7\]](#23x7-retrieve-task-output-iti-x7)

<a name="grouped-payload-parameters"> </a>

## Shared Work Orders and Payload Sets

ITI-x1 and ITI-x3 each define one required operation input named `workItem` of type `Task`. The sender SHALL POST the applicable profiled R4 Task directly as the request body. The body carries one complete work order. Successful HTTP 200 responses use R4 `Parameters`. Polling GET requests have no body. The optional [cancellation contract](#asynchronous-cancellation) defines DELETE messages at the same polling URLs.

| Transaction | Input | Successful response |
|-------------|-------|---------------------|
| ITI-x1 Submit Job | [DIS Job Task](StructureDefinition-DIS-JobTask.html) with one authorization and one or more payload sets. | HTTP 200 with one `payloadResult` per submitted set and one `validationStatus`, or HTTP 202 with `Content-Location` and an empty body for an accepted async job. |
| ITI-x3 Submit Task | [DIS Execution Task](StructureDefinition-DIS-ExecutionTask.html) with one assigned set and its execution instructions. | HTTP 200 with one `payloadResult` and one `validationStatus`, plus a protected `generatedLookupTable` when required, or HTTP 202 with `Content-Location` and an empty body for an accepted async task. |
| ITI-x4 Retrieve Job Output | Authorized GET of the job polling URL, or DELETE when cancellable mode was confirmed. | HTTP 200 with the same body as synchronous ITI-x1 success. HTTP 202 indicates processing is pending and carries no result. |
| ITI-x7 Retrieve Task Output | Authorized GET of the task polling URL, or DELETE when cancellable mode was confirmed. | HTTP 200 with the same body as synchronous ITI-x3 success. HTTP 202 indicates processing is pending and carries no result. |
{: .grid}

The sender SHALL assign a business identifier with a system and value to the work order. The receiver SHALL correlate work and handle retries according to the [shared identifier and retry rules](#submission-retries). For asynchronous acceptance, it SHALL associate the polling URL with the accepted work order and its identifier. Access to the polling URL requires the authorization defined for ITI-x4 or ITI-x7.

The receiver SHALL reject a malformed submission or a request body that fails to conform to the required Task profile with HTTP 400 and an R4 `OperationOutcome`. Successful results carry evidence inside the result package. `validationStatus` is `valid` on successful completion. Failure responses carry an `OperationOutcome` and withhold the result. A POST without `Prefer: respond-async` selects synchronous processing. A synchronous success returns the result on the original call. The receiver MAY retain a completed Task independently of the response. A receiver SHALL reject an async request with HTTP 422 and an R4 `OperationOutcome` if the applicable option is unsupported. It SHALL NOT accept that submission for synchronous processing. The bulk-file cohort binding requires async job selection. Execution mode is selected independently.

Each request set uses a coded Task input with a manifest attachment and [DIS Payload Set Metadata](StructureDefinition-dis-payload-set.html). Each result set uses a named `payloadResult` parameter with the following parts. The `payloadResult` SHALL omit outer `manifest` and `evidence` parts. See [Volume 3](volume-3.html#payload-set-delivery) for manifest formats and target resolution.

| Part | Cardinality | Encoding | Meaning |
|------|-------------|----------|---------|
| `setId` | 1..1 | `valueString` | Nonempty job-local identifier, reused from the request set |
| `payloadBinding` | 1..1 | `valueCode` | Binding that governs the set |
| `payloadVersion` | 1..1 | `valueCode` | Version defined by that binding |
| `manifestFormat` | 1..1 | `valueCode` | Use `dis-resource-list` or `fhir-bulk-data` |
| `resultPackage` | 1..1 | `valueAttachment` | [R4 DIS Result Package](volume-3.html#result-evidence-placement) with a FHIR media type and exactly one of inline `data` or an authorized HTTPS `url` |
{: .grid}

The Manager SHALL preserve set identity, binding, and version when changing how manifest entries are made available. Where a task processes a subset, its delivery description SHALL identify that subset. Before releasing job results, the Manager SHALL validate all output sets and any cross-set relationships required by the authorization and approved policies. A job that requires cross-set linkage SHALL be rejected if the selected bindings and policies cannot provide and validate that linkage.

See the [UC-2 job with R4 and R5 payload sets](examples-grouped-fhir-job.html) for complete submission, dispatch, and result examples and the [reversible mapping walkthrough for UC-3 and UC-4](examples-reversible-pathology.html) for a synchronous job with a deferred task.

<a name="transaction-authorization"> </a>

## Shared Transaction Authorization and Audit

For each request, the responder SHALL authenticate the caller and authorize the specific action and work item before disclosing work item state or changing it. The data request authorization governs the approved data scope and policy. Access credentials identify and authorize the actor for the transaction or for the specific service hosting referenced data. Apply the [referenced input and result access rules](volume-3.html#3pxx32-authorization-and-stable-retrieval) when data travels by reference.

Before polling or cancelling, the initiator SHALL verify that the polling URL identifies an HTTPS endpoint authorized to serve that work item on behalf of the original responder. If a redirect is used, the initiator SHALL verify the destination before sending credentials or issuing the request there. It SHALL use credentials valid for the destination. An authorization denial SHALL omit work item state, results, evidence, and protected transformation material.

Audit records SHALL distinguish a new submission, a recovery request, a poll, a cancellation request, and the applicable outcome. Use opaque work item and audit correlation identifiers when known. Audit records and error diagnostics SHALL exclude raw access tokens, signed access URLs, source payload bodies, salts, and supplied or generated lookup contents.

<a name="asynchronous-polling-lifecycle"> </a>

## Shared Asynchronous Polling Lifecycle

For ITI-x4 and ITI-x7, the responder SHALL keep the polling URL usable while processing is pending. It SHALL document a minimum terminal retention period in the applicable submission server operation's CapabilityStatement documentation. The period starts when a terminal outcome is recorded. During that period the responder SHALL keep the polling URL and terminal outcome available, subject to current retrieval authorization and the result release rules. For accepted cancellation, also apply the [cancellation retention rules](#asynchronous-cancellation). An expired polling URL is a retrieval error.

<a name="submission-retries"> </a>

## Shared Work Order Identifier and Retry Rules

These rules apply to ITI-x1 and ITI-x3. The receiver SHALL identify a submission by the receiving deployment and operation, the authenticated submitting actor, and the exact `Task.identifier.system` and `Task.identifier.value` pair. Credential changes that still authenticate the same actor preserve that scope. The submitter SHALL assign a fresh pair for each distinct work order in that scope. The business identifier is independent of the FHIR logical ID and polling URL.

A retry is equivalent when it preserves the scope, the exact FHIR JSON body bytes after HTTP content decoding, and the original processing selections for `Prefer: respond-async` and `DIS-Cancellation: required`. The sender SHALL preserve the original body bytes for retries. The receiver MAY retain a protected fingerprint of those bytes for comparison.

The receiver SHALL enforce a single admission per scoped identifier, including for concurrent requests. It SHALL record the binding before starting work and make an asynchronous acceptance and its original polling URL recoverable before sending HTTP 202. An ordinary equivalent repeat uses the recorded submission. An authorized repeat with changed bytes or processing selections SHALL return HTTP 409 with an R4 `OperationOutcome` indicating an identifier conflict.

To recover an uncertain submission outcome, the sender SHALL POST the equivalent request to the original operation with `DIS-Submission: recover`. The receiver SHALL check only the existing record and SHALL NOT create or restart work. The receiver SHALL authorize recovery under the original submitting actor's authenticated identity and current permissions. Renewed credentials may identify the same actor. Successful replayed results are subject to the original result release rules.

| Recorded state | Response to an authorized equivalent repeat |
|---|---|
| Initial admission or synchronous execution is pending | HTTP 409 with `DIS-Submission: pending` and an R4 `OperationOutcome`. The receiver SHOULD include `Retry-After` in seconds. |
| Asynchronous work was accepted and its polling URL remains available | The original HTTP 202 acceptance with the same `Content-Location` and, where applicable, `DIS-Cancellation: enabled`. Include `DIS-Submission: replayed`. The sender polls that URL for current status. |
| A definitive rejection or synchronous outcome is retained | The recorded response with `DIS-Submission: replayed`. |
| The receiver knows the recorded response or polling URL has expired | HTTP 410 with an R4 `OperationOutcome`. |
| No record is visible to the authorized sender and recovery only was requested | HTTP 404 with an R4 `OperationOutcome`. This response does not establish that the original submission was rejected or that work has stopped. |

{: .grid}

The receiver SHALL document its minimum replay retention period in the applicable server operation's CapabilityStatement documentation. It SHALL retain the binding while work is active, for at least the documented period after a terminal outcome or definitive rejection, and for at least as long as the polling URL is valid. After an uncertain submission, the sender SHALL use recovery-only mode. A missing record or expired URL alone SHALL NOT cause the sender to submit replacement work. After a recorded definitive rejection, a fresh submission uses a new identifier. Recovery responses SHALL include `Cache-Control: no-store`.

<a name="asynchronous-cancellation"> </a>

## Shared Asynchronous Cancellation Contract

This contract applies to implementations declaring [DIS-CANCEL](volume-1.html#asynchronous-cancellation-option). It uses the `DELETE` interaction on the polling URL, following the [FHIR R4 Asynchronous Request Pattern]({{site.data.fhir.path}}async.html). The polling URL identifies the accepted work item.

### Capability and submission

An actor declaring DIS-CANCEL SHALL include one [DIS Asynchronous Cancellation Support extension](StructureDefinition-dis-cancellation-support.html) with `valueBoolean = true` on the applicable `CapabilityStatement.rest.operation` entries. Use the `submit-dis-job` client entry for the Requester and the server entry for the Manager or externally invoked Integrated actor. Use the `submit-dis-task` client entry for the Manager and the server entry for the De-Identifier. Before requesting cancellable mode, the initiator SHALL verify the peer's corresponding server declaration.

The initiator selects cancellable mode by sending both `Prefer: respond-async` and `DIS-Cancellation: required` on ITI-x1 or ITI-x3. The latter is a DIS requirement on the exchange. The receiver SHALL reject a request that uses it without `Prefer: respond-async` with HTTP 400 and an R4 `OperationOutcome`. If the receiver cannot accept cancellable work, it SHALL return HTTP 422 and an R4 `OperationOutcome` without accepting the work. On successful admission in cancellable mode, it SHALL return `202 Accepted` with both `Content-Location` and `DIS-Cancellation: enabled`. The initiator SHALL consider cancellation available only after receiving both headers. A submission without the cancellation requirement uses the ordinary submission and polling contract.

Before accepting a cancellable distributed job, the Manager SHALL verify that the job's assignments can use De-Identifiers that advertise both asynchronous task processing and cancellation. The Manager SHALL request cancellable mode for every remote assignment, including a replacement assignment, and SHALL NOT fall back to synchronous dispatch. If the required execution path becomes unavailable after job acceptance, the Manager SHALL withhold the job results and report failure through ITI-x4, or report the cancellation outcome below if it has already accepted cancellation. An acceptance response without the required confirmation may indicate that work has started. The Manager SHALL account for the assignment and SHALL NOT treat the missing confirmation as proof that dispatch failed.

### Cancellation and polling responses

The initiator SHALL send an authorized `DELETE` with an empty body to the exact `Content-Location` returned at submission. The receiver SHALL enforce cancellation authorization independently of polling authorization. It SHALL return HTTP 401 for missing or invalid credentials and HTTP 403 for an authenticated caller without cancellation permission. For an authorized caller of a polling URL whose work item was accepted without cancellable mode, it SHALL return HTTP 405 with `Allow: GET`. These responses SHALL include an R4 `OperationOutcome` without changing the work item state or disclosing cancellation details. The following responses apply to authorized cancellation requests and authorized polls of the same URL. Cancellation state responses SHALL contain `Cache-Control: no-store` and SHALL withhold all results for the work item. The receiver SHALL document its maximum pending confirmation interval and minimum terminal cancellation status retention period in the corresponding server operation's CapabilityStatement documentation. The confirmation interval starts when cancellation is accepted and the retention period starts when a terminal cancellation outcome is recorded. The receiver SHALL keep the polling URL available through both intervals.

| State or outcome | Response to cancellation request | Response to subsequent poll |
|---|---|---|
| Cancellation accepted and still pending | HTTP 202 with `DIS-Cancellation: pending` and an empty body. | HTTP 202 with `DIS-Cancellation: pending` and an empty body. |
| Cancellation confirmed | HTTP 204 with `DIS-Cancellation: cancelled` and an empty body. | HTTP 410 with `DIS-Cancellation: cancelled` and an R4 `OperationOutcome`. |
| Cancellation accepted, confirmation interval expired with work still unconfirmed | HTTP 422 with `DIS-Cancellation: unconfirmed` and an R4 `OperationOutcome`. | The same HTTP 422 outcome. |
| Work was already terminal before cancellation took effect | HTTP 409 with an R4 `OperationOutcome` describing the conflict. | The ordinary terminal response for that work item. |

{: .grid}

For pending cancellation, the receiver SHOULD include `Retry-After` in seconds. A repeated authorized `DELETE` while cancellation is pending or its outcome is retained SHALL report the recorded state without restarting work or cancellation. After the documented retention period, the ordinary expired URL response applies. An HTTP 410 or 422 without the specified `DIS-Cancellation` value SHALL NOT be treated as a cancellation outcome. An endpoint outage, missing response, authorization denial, or expired polling URL SHALL NOT be treated as proof that the work stopped.

The receiver SHALL resolve the race between accepting cancellation and making the terminal processing outcome available. If cancellation takes effect first, it SHALL prevent release of results for the work item and apply the existing cleanup requirements. If the terminal processing outcome takes effect first, cancellation leaves that outcome in place. Each actor SHALL audit cancellation requests and outcomes using the applicable DIS audit requirements.

<a name="23x1-submit-de-identification-job-iti-x1"> </a>

## 2:3.x1 Submit De-Identification Job [ITI-x1]

### 2:3.x1.1 Scope

The Submit De-Identification Job transaction is used by the De-Identification Requester to submit a de-identification job to the De-ID Manager (or Integrated De-ID Manager/De-Identifier). The submission declares the approved de-identification policy by canonical URL and version, presents evidence of the approved data request, and includes references to the processing targets. The Requester may optionally carry the JWS-signed policy content directly. The de-identification policy is a reusable knowledge artifact that may be approved for multiple independent data requests. The De-ID Manager validates the submission, verifies that the presented policy matches the policy approved in the data request authorization, compiles the policy into a payload-specific execution plan, orchestrates task execution via ITI-x3 (or executes internally for the Integrated actor), and returns de-identified output and provenance evidence. The transaction supports both synchronous and asynchronous response modes.

See the informative example of [submitting a job with an inline R5 resource and hosted DICOM inputs](examples-mixed-r5-dicom.html#job-submission).

### 2:3.x1.2 Actors Roles

Table 2:3.x1.2-1 lists the actors and their roles in this transaction.

<p id="t3.x1.2-1" class="tableTitle"><strong>Table 2:3.x1.2-1: ITI-x1 Actor Roles</strong></p>

| Actor | Role |
|-------|------|
| [De-Identification Requester](volume-1.html#de-identification-requester) | Initiates the job submission, declaring the approved policy and presenting evidence of the approved data request, and receives de-identified output and evidence |
| [De-ID Manager](volume-1.html#de-id-manager) | Receives the job request, validates the authorization and policy, orchestrates execution, and returns de-identified output and evidence |
| [Integrated De-ID Manager/De-Identifier](volume-1.html#integrated-de-id-manager-de-identifier) | Acts as Responder in place of the De-ID Manager when ITI-x1 is supported (Optional for this actor) |
{: .grid}

### 2:3.x1.3 Referenced Standards

- [HL7 FHIR R4]({{site.data.fhir.path}}) — HL7 FHIR Release 4.0.1
- [HL7 FHIR R4 RESTful API]({{site.data.fhir.path}}http.html) — FHIR RESTful interactions
- [HL7 FHIR R4 Operations]({{site.data.fhir.path}}operations.html) — FHIR operation framework
- [HL7 FHIR R4 Asynchronous Request Pattern]({{site.data.fhir.path}}async.html) — async processing pattern (when DIS-ASYNC-JOB is supported)
- [HL7 FHIR R4 Task]({{site.data.fhir.path}}task.html) — work-order request
- [HL7 FHIR R4 Parameters]({{site.data.fhir.path}}parameters.html) — successful operation result envelope
- [HL7 FHIR R4 OperationOutcome]({{site.data.fhir.path}}operationoutcome.html) — error reporting
- [HL7 FHIR R4 Provenance]({{site.data.fhir.path}}provenance.html) — de-identification evidence
- [RFC 7515](https://datatracker.ietf.org/doc/html/rfc7515) — JSON Web Signature (JWS), for `policyContent` signature validation
- [RFC 7517](https://datatracker.ietf.org/doc/html/rfc7517) — JSON Web Key (JWK), for signing key representation (applicable to `policyContent`)

### 2:3.x1.4 Interactions and Messages

Figure 2:3.x1.4-1 shows the interaction for the Submit De-Identification Job transaction. The synchronous flow is shown. In asynchronous mode (DIS-ASYNC-JOB), the Manager returns a 202 Accepted response with a job handle; the Requester retrieves output and evidence using ITI-x4.

<p><a href="dis-iti-x1-interactions.png"><img src="dis-iti-x1-interactions.png" alt="ITI-x1 submit de-identification job interaction diagram" width="636" style="max-width: 100%; height: auto;" /></a></p>

**Figure 2:3.x1.4-1: ITI-x1 Interaction Diagram**

#### 2:3.x1.4.1 Submit De-Identification Job Request Message

##### 2:3.x1.4.1.1 Trigger Events

The De-Identification Requester sends a Submit De-Identification Job Request when it requires de-identification of one or more processing targets under an approved data request. Before initiating this transaction, the Requester SHALL obtain the approved data request authorization. DIS assumes the Requester can read the [exact approved policy](volume-3.html#approved-policy-access) for each payload set.

##### 2:3.x1.4.1.2 Message Semantics

The De-Identification Requester SHALL invoke the `$submit-dis-job` operation using `POST [base]/$submit-dis-job`. The request SHALL use `Content-Type: application/fhir+json`.

The request body SHALL be a [DIS Job Task](StructureDefinition-DIS-JobTask.html) with `intent = order` and `status = requested`. The following coded inputs carry the authorization and selected data.

<p id="t3.x1.4.1.2-1" class="tableTitle"><strong>Table 2:3.x1.4.1.2-1: ITI-x1 Job Task Inputs</strong></p>

| Input code | Cardinality | Value | Description |
|------------|-------------|-------|-------------|
| `authorization` | 1..1 | `valueReference` or `valueAttachment` | Authorization evidence, either an externally hosted resource or an inline attachment with a declared content type |
| `payload-set` | 1..* | `valueAttachment` with [DIS Payload Set Metadata](StructureDefinition-dis-payload-set.html) on the input | One manifest with the set's binding, version, approved policy and any permitted supplied lookup reference |
{: .grid}

The authorization is evidence that a governance authority approved the data request, including the policy applicable to each set. Its internal structure is determined by the deployment's authorization mechanism. Each set SHALL have a unique `setId` and declare its approved policy as a versioned canonical (`Library.url|Library.version`). The optional `policyContent` extension references a contained JWS-signed policy Binary. The Manager derives the job's reversibility mode from the common mode declared by the approved policies and obtains each set's linkage scope from its policy.

To request asynchronous job processing when both actors support DIS-ASYNC-JOB, the Requester SHALL include the `Prefer: respond-async` request header per the HL7 FHIR R4 Asynchronous Request Pattern. To require job cancellation, the Requester SHALL also follow the [shared cancellation contract](#asynchronous-cancellation).

<div markdown="1" class="stu-note">
**Editorial Note:** The draft [Submit DIS Job OperationDefinition](OperationDefinition-submit-dis-job.html) describes this exchange. Its parameter definitions remain under review alongside the transaction text.
</div>

##### 2:3.x1.4.1.3 Expected Actions

The De-ID Manager (or Integrated De-ID Manager/De-Identifier) SHALL apply the [shared identifier and retry rules](#submission-retries). The following actions apply to a new submission.

The Manager SHALL obtain and validate the data request authorization. For an authorization input with a reference, the Manager resolves the referenced resource. For an inline attachment, the Manager processes the content according to the declared `contentType`. The authorization is evidence that a data governance authority approved a data request that specifies the data scope, purpose, and the de-identification policy to be applied. If the authorization is absent, expired, or does not cover the requested processing targets, the Manager SHALL reject the job with an OperationOutcome.

For each set, the Manager SHALL verify that the declared versioned canonical identifies the policy approved in the data request authorization. The mechanism for extracting the approved policy identity from the authorization is implementation-defined (it depends on the authorization format used in the deployment). A mismatch indicates the Requester is presenting a policy that was not approved for this data request; the Manager SHALL reject the job with an OperationOutcome.

The Manager SHALL obtain the policy content. When `policyContent` is present, the Manager SHALL verify the JWS signature using a signing key trusted under its configured trust model and SHALL confirm that `Library.url` and `Library.version` inside the JWS payload match the declared versioned policy canonical. When `policyContent` is absent, the Manager SHALL resolve the policy identified by the declared canonical and version by implementation-defined means (see [§3:PXX.1.4](volume-3.html#3pxx14-policy-delivery-and-validation)).

The Manager SHALL perform three-point policy content validation:

1. **Schema** — verify that the policy conforms to the applicable policy schema.
2. **Currency** — verify that the policy has not expired or been revoked.
3. **Integrity** — verify that the obtained rules are the exact content bound to the approved version under the [policy validation rules](volume-3.html#3pxx132-policy-validation). Apply the JWS verification above for carried content and the deployment's resolution trust model for Manager-resolved content.

If any point of the four-point validation fails, the Manager SHALL reject the job with an OperationOutcome describing the failure point.

The Manager SHALL verify that all approved policies declare the same reversibility mode before accepting an asynchronous job or beginning synchronous execution. If the modes differ, the Manager SHALL reject the job with an OperationOutcome before dispatching any tasks.

When reversible mode is selected, the Manager SHALL use a supplied `lookupTable` for direct-identifier mapping. When the request contains no table, the Manager SHALL create or maintain and persist the mapping needed for reversal. The Manager SHALL reject a supplied table in irreversible mode. The approved policy SHALL authorize lookup-backed replacement for the affected identifiers. The Manager SHALL reject incompatible policy and table combinations without changing the approved rules.

Before accepting a job with a supplied table, the Manager SHALL resolve and validate the [lookup document and its content](volume-3.html#3pxx5-reversible-lookup-table). It SHALL verify authorization for both metadata and content retrieval, check scope and key uniqueness, and verify coverage of identifiers available at admission. The Manager SHALL record the `masterIdentifier`, metadata version when available, and SHA-256 digest of the exact decoded bytes in protected job state. The Manager SHALL use one content snapshot throughout the job and its retries. It SHALL use version-specific URLs where supported and otherwise hold a protected snapshot. `Attachment.hash` does not replace this SHA-256 check.

An unavailable, ambiguous, unauthorized or invalid table, including changed bytes under the same `masterIdentifier`, SHALL cause rejection before acceptance or terminal job failure if detected afterward. A missing required mapping SHALL have the same result. The Manager SHALL report a failure of an accepted asynchronous job through ITI-x4. It SHALL NOT add missing entries, generate substitutes, disclose source identifiers in error responses, or release partial results. Temporary copies SHALL be deleted at job termination unless Manager retention is explicitly authorized. The Requester's authoritative table remains under the repository's custody.

The Manager SHALL verify that the same data request authorization covers every set and approves the policy named for each set. Before dispatch, the Manager SHALL verify that each set can be processed using the requested binding and version, its approved policy, and a supported manifest format. Each plan applies to one ruleSet and one payload set. For each set, the Manager compiles or validates the assigned policy for that set's binding and version. It correlates tasks, results, and evidence by `setId`.

The Manager SHALL verify that the data request authorization covers the identified processing target set, including the resources or files listed in a manifest. It SHALL check that references are resolvable and use the retrieval authorization and failure rules in [Volume 3](volume-3.html#obtaining-processing-targets).

When the policy is authored at the Semantic-Level (using semantic group references), the Manager SHALL compile the validated policy into a payload-specific execution plan for the applicable payload binding before dispatching tasks. When the policy is authored at the Syntax-Level (using concrete element paths for a specific payload family), the Manager SHALL validate that all rule targets are valid paths for the declared payload family and version, then package the rules as an execution plan for dispatch.

The Manager SHALL verify that the policy's linkage scope is authorized for the job and resolve it before dispatch. For a job-level scope it SHALL bind a unique scope identifier to the job and reuse it on retries. A supplied job-level table may provide that identifier when it can be bound to this job only. The Manager SHALL copy the resolved scope into each salted hash rule and check a supplied table against that scope.

The Manager SHALL dispatch de-identification tasks to one or more De-Identifiers via ITI-x3, or execute the plan internally if it is an Integrated De-ID Manager/De-Identifier. The Manager SHALL NOT dispatch a task to a De-Identifier whose declared capabilities are incompatible with the task's payload binding or required transformation actions.

In synchronous mode, the Manager SHALL return de-identified output and provenance evidence in the response upon completion of all tasks.

In asynchronous mode (DIS-ASYNC-JOB), the Manager SHALL return a job handle in the response. The Requester retrieves output and evidence using ITI-x4.

#### 2:3.x1.4.2 Submit De-Identification Job Response Message

##### 2:3.x1.4.2.1 Trigger Events

For synchronous processing, the Manager sends the response when the result or failure is determined. Before accepting an asynchronous job, the Manager SHALL validate the authorization, perform the four policy checks for every set, and complete the other checks this transaction requires at admission. It returns HTTP 202 on acceptance and reports subsequent processing failures through ITI-x4.

##### 2:3.x1.4.2.2 Message Semantics

The De-ID Manager (or Integrated De-ID Manager/De-Identifier) returns one of the HTTP status codes described below.

**200 OK — Synchronous success.** The response body is an HL7 FHIR R4 `Parameters` resource. Table 2:3.x1.4.2.2-1 lists the output parameters.

<p id="t3.x1.4.2.2-1" class="tableTitle"><strong>Table 2:3.x1.4.2.2-1: ITI-x1 Response Output Parameters (200 OK)</strong></p>

| Parameter | Cardinality | Type | Description |
|-----------|-------------|------|-------------|
| `payloadResult` | 1..* | Group | De-identified [payload set](#grouped-payload-parameters) with evidence for that set |
| `validationStatus` | 1..1 | code | Overall validation outcome for the job |
{: .grid}

The Manager SHALL return one `payloadResult` per submitted `setId`, with the corresponding binding, version, and result package containing the manifest and evidence. Before making a result available to the Requester, the Manager SHALL verify that all sets have completed and passed validation and that the Requester remains authorized to receive them. This requirement applies to the result response and to any manifest or result service the response references. A failed set fails the job without recipient-facing results from any set. For a distributed result set that uses multiple stages, the Manager SHALL include [staged release evidence](volume-3.html#staged-release-evidence) in the set's result package.

**202 Accepted — Asynchronous accepted (DIS-ASYNC-JOB).** The response body is empty. The `Content-Location` response header contains the polling URL for use with ITI-x4.

**400 Bad Request.** The response body is an HL7 FHIR R4 `OperationOutcome` describing the malformed request.

**401 Unauthorized / 403 Forbidden.** The response body is an HL7 FHIR R4 `OperationOutcome` describing the authorization failure.

**422 Unprocessable Entity.** The response body is an HL7 FHIR R4 `OperationOutcome` identifying the failed policy validation point, reporting that the approved policies declare different reversibility modes, or indicating that the requested asynchronous or cancellable mode is unavailable.

**500 Internal Server Error.** The response body is an HL7 FHIR R4 `OperationOutcome` describing the server error.

<div markdown="1" class="stu-note">
**Editorial Note:** The draft [Submit DIS Job OperationDefinition](OperationDefinition-submit-dis-job.html) describes this exchange. Its parameter definitions remain under review alongside the transaction text.
</div>

<a name="job-result-acceptance"> </a>

##### 2:3.x1.4.2.3 Expected Actions

Upon receipt of a Submit De-Identification Job Response, the De-Identification Requester SHALL inspect the response status.

In synchronous mode, on a successful response, the Requester SHALL apply the [result package and evidence checks](volume-3.html#result-evidence-placement) before accepting the output. For a distributed staged result, it SHALL also apply the [staged release evidence checks](volume-3.html#staged-release-evidence). On an error response, the Requester SHALL inspect the OperationOutcome and SHALL NOT treat the failed response as valid de-identified output.

In asynchronous mode (DIS-ASYNC-JOB), on a 202 Accepted response, the Requester SHALL retain the job handle and SHALL proceed to poll for output using ITI-x4.

### 2:3.x1.5 CapabilityStatement Resource

The [De-ID Manager](CapabilityStatement-DIS-Manager.html) and [Integrated De-ID Manager/De-Identifier](CapabilityStatement-DIS-Integrated.html) implementing this transaction SHALL provide a CapabilityStatement Resource as described in [ITI TF-2: Appendix Z.3](https://profiles.ihe.net/ITI/TF/Volume2/ch-Z.html#z.3-capabilitystatement-resource) indicating that the `$submit-dis-job` operation is implemented.

The [De-Identification Requester](CapabilityStatement-DIS-Requester.html) implementing this transaction SHALL provide a CapabilityStatement Resource indicating that it can invoke the `$submit-dis-job` operation.

### 2:3.x1.6 Security Considerations

See [DIS Security Considerations](volume-1.html#security-considerations).

#### 2:3.x1.6.1 Security Audit Considerations

The De-Identification Requester and the De-ID Manager (or Integrated De-ID Manager/De-Identifier) SHALL record an audit event for each ITI-x1 transaction. The audit event SHALL identify the Requester, the Manager, the policy identifier, the processing target(s), and the job outcome (success, rejection, or failure). Implementations SHOULD use [IHE Basic Audit Log Patterns (BALP)](https://profiles.ihe.net/ITI/BALP/) for structured audit event representation. Assign an opaque correlation identifier at submission so that accepted and rejected requests can both be audited. Use that identifier or a protected audit linkage to correlate later task evidence. Audit entries SHALL exclude signed URLs, confidential salts, and lookup content.

<a name="23x3-submit-de-identification-task-iti-x3"> </a>

## 2:3.x3 Submit De-Identification Task [ITI-x3]

### 2:3.x3.1 Scope

The Submit De-Identification Task transaction is used by the De-ID Manager to dispatch a de-identification task for one ruleSet to a De-Identifier. Each task conveys the compiled execution plan rules for one ruleSet, a payload set identifying the processing targets, and a protected lookup-table reference when the assigned rules require one. The De-Identifier verifies capability compatibility, applies the execution plan rules to the processing target, produces de-identified output conforming to the declared payload binding and version, and returns the output with provenance evidence. The transaction supports both synchronous and asynchronous response modes. This transaction does not apply to the Integrated De-ID Manager/De-Identifier.

See the informative example of [dispatching separate clinical and imaging tasks for one job](examples-mixed-r5-dicom.html#task-dispatch).

### 2:3.x3.2 Actors Roles

Table 2:3.x3.2-1 lists the actors and their roles in this transaction.

<p id="t3.x3.2-1" class="tableTitle"><strong>Table 2:3.x3.2-1: ITI-x3 Actor Roles</strong></p>

| Actor | Role |
|-------|------|
| [De-ID Manager](volume-1.html#de-id-manager) | Initiates the task dispatch, providing compiled execution plan rules, a processing target reference, and a lookup-table reference when required |
| [De-Identifier](volume-1.html#de-identifier) | Receives the task, verifies capability compatibility, applies the execution plan rules to the processing target, and returns de-identified output and evidence |
{: .grid}

### 2:3.x3.3 Referenced Standards

- [HL7 FHIR R4]({{site.data.fhir.path}}) — HL7 FHIR Release 4.0.1
- [HL7 FHIR R4 RESTful API]({{site.data.fhir.path}}http.html) — FHIR RESTful interactions
- [HL7 FHIR R4 Operations]({{site.data.fhir.path}}operations.html) — FHIR operation framework
- [HL7 FHIR R4 Task]({{site.data.fhir.path}}task.html) — work-order request
- [HL7 FHIR R4 Parameters]({{site.data.fhir.path}}parameters.html) — successful operation result envelope
- [HL7 FHIR R4 Library]({{site.data.fhir.path}}library.html) — execution plan carrier
- [HL7 FHIR R4 Provenance]({{site.data.fhir.path}}provenance.html) — de-identification evidence
- [HL7 FHIR R4 OperationOutcome]({{site.data.fhir.path}}operationoutcome.html) — error reporting

### 2:3.x3.4 Interactions and Messages

Figure 2:3.x3.4-1 shows the interaction for the Submit De-Identification Task transaction. The synchronous flow is shown. In asynchronous mode (DIS-ASYNC-TASK), the De-Identifier returns a 202 Accepted response with a task handle; the Manager retrieves output and evidence using ITI-x7.

<p><a href="dis-iti-x3-interactions.png"><img src="dis-iti-x3-interactions.png" alt="ITI-x3 submit de-identification task interaction diagram" width="607" style="max-width: 100%; height: auto;" /></a></p>

**Figure 2:3.x3.4-1: ITI-x3 Interaction Diagram**

#### 2:3.x3.4.1 Submit De-Identification Task Request Message

##### 2:3.x3.4.1.1 Trigger Events

The De-ID Manager sends a Submit De-Identification Task Request for each ruleSet after successfully validating the policy and compiling the execution plan. The Manager SHALL verify the De-Identifier's declared capabilities before dispatching the task and SHALL NOT dispatch a task whose payload binding or required transformation actions fall outside the De-Identifier's declared capabilities.

##### 2:3.x3.4.1.2 Message Semantics

The De-ID Manager SHALL invoke the `$submit-dis-task` operation using `POST [base]/$submit-dis-task`. The request SHALL use `Content-Type: application/fhir+json`.

The request body SHALL be a [DIS Execution Task](StructureDefinition-DIS-ExecutionTask.html) with `intent = order` and `status = requested`. The coded inputs identify the assigned set and execution instructions.

<p id="t3.x3.4.1.2-1" class="tableTitle"><strong>Table 2:3.x3.4.1.2-1: ITI-x3 Execution Task Inputs</strong></p>

| Input code | Cardinality | Value | Description |
|------------|-------------|-------|-------------|
| `payload-set` | 1..1 | `valueAttachment` with [DIS Payload Set Metadata](StructureDefinition-dis-payload-set.html) on the input | Manifest for the assigned set or subset |
| `execution-plan` | 1..1 | `valueReference` | [DIS Execution Plan Library](StructureDefinition-DIS-ExecutionPlan.html) for this ruleSet, including the [source policy identity](volume-3.html#execution-plan-source-policy) |
| `rule-set-id` | 1..1 | `valueString` | RuleSet from the source policy that this assignment executes |
| `stage-id` | 0..1 | `valueString` | Required when the source policy declares staged execution |
| `lookup-table` | 0..1 | `valueReference` | Protected lookup table restricted to the assignment |
| `reversibility-mode` | 1..1 | `valueCode` | The job's reversibility mode, either `irreversible` or `reversible` |
{: .grid}

The Manager SHALL preserve the job's `setId`, binding, and version for the assigned inputs. It MAY change the delivery of the same authorized content. The execution plan carries the policy identity. Any assigned lookup table is sent in its own protected input.

The De-ID Manager SHALL set the `reversibility-mode` input in every ITI-x3 Execution Task to the job's reversibility mode. The De-Identifier SHALL apply the supplied mode.

When using `lookup-table`, the Manager SHALL dispatch only a protected reference to a document with the entries needed for the assigned task. If the source contains additional entries, the Manager SHALL create a [task-scoped lookup document](volume-3.html#3pxx5-reversible-lookup-table) and track its correlation to the pinned source. The De-Identifier's credentials SHALL NOT grant access to the unrestricted table in that case. The Manager SHALL delete derived task artifacts at termination unless retention is explicitly authorized.

To request asynchronous task processing when both actors support DIS-ASYNC-TASK, the Manager SHALL include the `Prefer: respond-async` request header per the HL7 FHIR R4 Asynchronous Request Pattern. For an assignment in a cancellable job, the Manager SHALL also follow the [shared cancellation contract](#asynchronous-cancellation).

<div markdown="1" class="stu-note">
**Editorial Note:** The draft [Submit DIS Task OperationDefinition](OperationDefinition-submit-dis-task.html) describes this exchange. Its parameter definitions remain under review alongside the transaction text.
</div>

##### 2:3.x3.4.1.3 Expected Actions

The De-Identifier SHALL apply the [shared identifier and retry rules](#submission-retries). The following actions apply to a new submission.

Upon receipt of a Submit De-Identification Task Request, the De-Identifier SHALL perform the following actions.

The De-Identifier SHALL verify that the task's payload binding and version are within its declared capabilities. If the task specifies a payload binding or version that the De-Identifier does not support, the De-Identifier SHALL reject the task with an OperationOutcome.

The De-Identifier SHALL retrieve the assigned processing targets using the [retrieval authorization rules](volume-3.html#obtaining-processing-targets) and verify the declared payload release before transformation.

The De-Identifier SHALL apply supplied patient mappings or generate patient pseudonyms according to the execution plan. It SHALL verify that the decoded plan conforms to the [execution plan binding](volume-3.html#3pxx212-execution-plan-json-structure-and-rule-evaluation) and that its ruleSet, payload binding and payload version agree with the task. It SHALL obtain and validate the deployment-provisioned salt for each salted hash rule before transformation. A missing or invalid salt SHALL fail the task without partial output.

When the `lookup-table` input is present, the De-Identifier SHALL resolve and validate the assigned protected DocumentReference and pin its exact content as specified in Volume 3 §3:PXX.5. Retrieval or pinning failure SHALL fail the task. It SHALL use only its supplied entries for lookup-backed replacement, SHALL fail a task with a missing required entry without returning partial output, and SHALL delete all task-local copies at task termination. It SHALL NOT delete the authoritative source repository document. It SHALL NOT generate fallback mappings. The Manager SHALL withhold all job output on such a task failure.

The De-Identifier SHALL apply the execution plan rules to the processing target in full. Partial execution is not permitted. If any rule cannot be applied, the De-Identifier SHALL reject the task with an OperationOutcome and SHALL NOT produce partial output.

The De-Identifier SHALL produce de-identified output conforming to the declared payload binding and version. When a reversible Manager-managed task generates patient identifier mappings, the De-Identifier SHALL return a protected `generatedLookupTable` under Volume 3 §3:PXX.5. An irreversible task SHALL NOT return a generated lookup table. The Manager SHALL validate and retain generated mappings before job release and exclude them from recipient-facing responses.

The De-Identifier SHALL produce provenance evidence containing at minimum the nine elements in the [de-identification evidence baseline](volume-3.html#evidence-baseline). Evidence SHALL faithfully record the transformation decisions made during task execution.

The De-Identifier SHALL delete task-local copies of identity-linking material at termination. Deployment-managed salts follow the authorized scope lifecycle.

In synchronous mode, the De-Identifier SHALL return de-identified output and evidence in the response upon task completion.

In asynchronous mode (DIS-ASYNC-TASK), the De-Identifier SHALL return a task handle in the response. The Manager retrieves output and evidence using ITI-x7.

#### 2:3.x3.4.2 Submit De-Identification Task Response Message

##### 2:3.x3.4.2.1 Trigger Events

For synchronous processing, the De-Identifier sends the response when the result or failure is determined. Before accepting an asynchronous task, it SHALL validate the Task body, verify the caller's authority to submit the assignment, and check that the exchange mode, payload binding, and declared version are supported. It returns HTTP 202 on acceptance. Checks that require obtaining the execution plan or payload may continue after acceptance. It reports failures detected after acceptance through ITI-x7.

##### 2:3.x3.4.2.2 Message Semantics

The De-Identifier returns one of the HTTP status codes described below.

**200 OK — Synchronous success.** The response body is an HL7 FHIR R4 `Parameters` resource. Table 2:3.x3.4.2.2-1 lists the output parameters.

<p id="t3.x3.4.2.2-1" class="tableTitle"><strong>Table 2:3.x3.4.2.2-1: ITI-x3 Response Output Parameters (200 OK)</strong></p>

| Parameter | Cardinality | Type | Description |
|-----------|-------------|------|-------------|
| `payloadResult` | 1..1 | Group | De-identified [payload set](#grouped-payload-parameters) with evidence for that set |
| `generatedLookupTable` | 0..1 | DocumentReference | Inline DIS-LookupTable with generated patient identifier mappings. Required when reversible Manager-managed hashing generates patient mappings. Protected output to the Manager. |
| `validationStatus` | 1..1 | code | Per-task validation outcome |
{: .grid}

The De-Identifier SHALL return one `payloadResult` matching the dispatched `setId`, binding, and version, with its evidence.

**202 Accepted — Asynchronous accepted (DIS-ASYNC-TASK).** The response body is empty. The `Content-Location` response header contains the polling URL for use with ITI-x7.

**400 Bad Request.** The response body is an R4 `OperationOutcome` describing the malformed or nonconforming Execution Task.

**401 Unauthorized / 403 Forbidden.** The response body is an R4 `OperationOutcome` describing the authorization failure.

**422 Unprocessable Entity.** The response body is an HL7 FHIR R4 `OperationOutcome` indicating that the task's payload binding, payload version, or required transformation actions fall outside the De-Identifier's declared capabilities or that the requested asynchronous or cancellable mode is unavailable.

**500 Internal Server Error.** The response body is an HL7 FHIR R4 `OperationOutcome` describing the execution failure. No partial output is returned.

<div markdown="1" class="stu-note">
**Editorial Note:** The draft [Submit DIS Task OperationDefinition](OperationDefinition-submit-dis-task.html) describes this exchange. Its parameter definitions remain under review alongside the transaction text.
</div>

##### 2:3.x3.4.2.3 Expected Actions

Upon receipt of a Submit De-Identification Task Response, the De-ID Manager SHALL inspect the response status.

In synchronous mode, on a successful response, the Manager SHALL validate and retain any required protected mapping output before release. The Manager SHALL accept the de-identified output and evidence for assembly into the job response to the Requester.

On a definitive ITI-x3 rejection or processing failure, the Manager SHALL inspect the OperationOutcome and withhold job output. It SHALL report the failure on ITI-x1 for a synchronous job or through ITI-x4 for an accepted asynchronous job. An uncertain ITI-x3 submission outcome follows the [recovery rules](#submission-retries). If job cancellation has been accepted, the [job cancellation rules](#job-cancellation) apply.

In asynchronous mode (DIS-ASYNC-TASK), on a 202 Accepted response, the Manager SHALL retain the task handle and SHALL proceed to retrieve output using ITI-x7.

### 2:3.x3.5 CapabilityStatement Resource

The [De-Identifier capability requirements](CapabilityStatement-DIS-De-Identifier.html) identify the system-level operation. A De-Identifier implementing this transaction SHALL declare `$submit-dis-task` and its supported processing combinations on its implementation CapabilityStatement. Each [DIS Processing Capability](StructureDefinition-dis-processing-capability.html) instance declares one binding, release, input manifest format, result manifest format and reversibility mode, with the actions the actor supports together. The Manager SHALL match the whole combination and all required actions within a single entry before dispatch. The implementation SHALL document parameter restrictions and any separately negotiated protected transformation inputs in the CapabilityStatement documentation for the operation.

The De-ID Manager implementing this transaction SHALL provide a CapabilityStatement Resource indicating that it can invoke the `$submit-dis-task` operation.

### 2:3.x3.6 Security Considerations

See [DIS Security Considerations](volume-1.html#security-considerations).

#### 2:3.x3.6.1 Security Audit Considerations

The De-ID Manager and the De-Identifier SHALL record an audit event for each ITI-x3 transaction. The audit event SHALL identify the Manager, the De-Identifier, the ruleSet identifier, the payload binding and version, and the task outcome. The stage identifier SHALL also be recorded when the source policy declares staged execution. The audit event SHALL NOT include confidential salts or other protected transformation material. Implementations SHOULD use [IHE BALP](https://profiles.ihe.net/ITI/BALP/) for structured audit event representation.

<a name="23x4-retrieve-job-output-iti-x4"> </a>

## 2:3.x4 Retrieve Job Output [ITI-x4]

### 2:3.x4.1 Scope

The Retrieve Job Output transaction is used by the De-Identification Requester to retrieve the status and output of a previously submitted asynchronous de-identification job. The Requester polls the De-ID Manager (or Integrated De-ID Manager/De-Identifier) using the job handle received in the ITI-x1 202 Accepted response. The Manager returns the current job status, and when the job is complete, returns the de-identified output and provenance evidence. This transaction is required when the Asynchronous Job Processing Option (DIS-ASYNC-JOB) is declared.

See the informative example of [retrieving both result sets or reporting a failure of the job](examples-mixed-r5-dicom.html#results-and-release).

### 2:3.x4.2 Actors Roles

Table 2:3.x4.2-1 lists the actors and their roles in this transaction.

<p id="t3.x4.2-1" class="tableTitle"><strong>Table 2:3.x4.2-1: ITI-x4 Actor Roles</strong></p>

| Actor | Role |
|-------|------|
| [De-Identification Requester](volume-1.html#de-identification-requester) | Initiates the poll request, presenting the job handle received from ITI-x1 |
| [De-ID Manager](volume-1.html#de-id-manager) | Receives the poll request and returns job status, de-identified output, and evidence upon completion |
| [Integrated De-ID Manager/De-Identifier](volume-1.html#integrated-de-id-manager-de-identifier) | Acts as Responder in place of the De-ID Manager when ITI-x1 and DIS-ASYNC-JOB are both supported |
{: .grid}

### 2:3.x4.3 Referenced Standards

- [HL7 FHIR R4]({{site.data.fhir.path}}) — HL7 FHIR Release 4.0.1
- [HL7 FHIR R4 Asynchronous Request Pattern]({{site.data.fhir.path}}async.html) — async processing pattern
- [HL7 FHIR R4 OperationOutcome]({{site.data.fhir.path}}operationoutcome.html) — error reporting
- [HL7 Bulk Data Access IG](https://hl7.org/fhir/uv/bulkdata/) — bulk data manifest and NDJSON conventions (when processing cohort jobs)

### 2:3.x4.4 Interactions and Messages

Figure 2:3.x4.4-1 shows the interaction for the Retrieve Job Output transaction, including the three possible response states.

<p><a href="dis-iti-x4-interactions.png"><img src="dis-iti-x4-interactions.png" alt="ITI-x4 retrieve job output interaction diagram" width="734" style="max-width: 100%; height: auto;" /></a></p>

**Figure 2:3.x4.4-1: ITI-x4 Interaction Diagram**

#### 2:3.x4.4.1 Retrieve Job Output Request Message

##### 2:3.x4.4.1.1 Trigger Events

The De-Identification Requester sends a Retrieve Job Output Request to poll the status of an asynchronous job. The Requester SHALL reference the job handle received in the ITI-x1 202 Accepted response. The Requester SHOULD respect any retry-after guidance returned in a prior polling response before sending a subsequent request.

##### 2:3.x4.4.1.2 Message Semantics

The De-Identification Requester SHALL poll using `GET [Content-Location]`, where `[Content-Location]` is the URL received in the `Content-Location` response header of the ITI-x1 `202 Accepted` response.

The request body is empty.

The caller SHALL include credentials authenticating the original Requester or an explicitly authorized retrieval delegate.

##### 2:3.x4.4.1.3 Expected Actions

Upon receipt of a Retrieve Job Output Request, the De-ID Manager (or Integrated De-ID Manager/De-Identifier) SHALL return the current status of the referenced job.

For accepted cancellation, the Manager SHALL apply the [shared cancellation responses](#asynchronous-cancellation). The Manager SHALL enforce authorization on retrieval. Only the original De-Identification Requester, or an explicitly authorized delegate, SHALL be permitted to retrieve the status or output of a given job. The Manager SHALL reject unauthorized retrieval requests with an appropriate error.

When the job is still in progress, the Manager SHALL indicate in-progress status and SHOULD include retry-after guidance to help the Requester pace its polling.

When the job is complete, the Manager SHALL return the de-identified output and provenance evidence under the [polling lifecycle](#asynchronous-polling-lifecycle) and result release rules.

When the job has failed, the Manager SHALL return error information via OperationOutcome. The Manager SHALL NOT release partial output.

#### 2:3.x4.4.2 Retrieve Job Output Response Message

##### 2:3.x4.4.2.1 Trigger Events

The De-ID Manager sends a Retrieve Job Output Response upon receipt of each poll request. The response content depends on the current state of the referenced job at the time the request is processed.

##### 2:3.x4.4.2.2 Message Semantics

The De-ID Manager (or Integrated De-ID Manager/De-Identifier) uses the HTTP polling mechanics of the draft HL7 FHIR R4 Asynchronous Request Pattern. DIS defines the deferred operation response as follows.

**202 Accepted — Job in progress.** The Manager SHOULD include `Retry-After` with the recommended polling interval in seconds. The `X-Progress` response header MAY be present with a human-readable status string. The response body is empty.

**200 OK — Job complete.** The body and release rules are identical to [ITI-x1 synchronous success](#23x1422-message-semantics), including one `payloadResult` per submitted set and `validationStatus`.

**422 Unprocessable Entity — Terminal processing failure.** On an authorized poll, the responder SHALL return an R4 `OperationOutcome` when the accepted work item has failed. It SHALL withhold every result for that work item.

**Other 4xx/5xx — Polling error.** The responder SHALL return an R4 `OperationOutcome` without a result. An invalid or unauthorized poll, an expired polling URL, or an endpoint outage does not report terminal processing failure. Use HTTP 401 for missing or invalid credentials and HTTP 403 for credentials that do not authorize the poll.

##### 2:3.x4.4.2.3 Expected Actions

Upon receipt of a Retrieve Job Output Response, the De-Identification Requester SHALL inspect the response status.

On an in-progress response, the Requester SHOULD wait for the indicated retry-after period before issuing another poll request.

On a complete response, the Requester SHALL apply the same result package and evidence checks as for [ITI-x1 synchronous success](#job-result-acceptance) before accepting the output.

On an error response, the Requester SHALL inspect the OperationOutcome and SHALL NOT treat the failed response as valid de-identified output.

<a name="job-cancellation"> </a>

#### 2:3.x4.4.3 Cancel De-Identification Job

When the Requester wishes to stop a job accepted in cancellable mode, it sends the cancellation request defined in the [shared cancellation contract](#asynchronous-cancellation). The Manager SHALL accept a cancellation request only from the original Requester or an explicitly authorized cancellation delegate. The Manager SHALL check that the job was accepted in cancellable mode before applying the request.

On accepting cancellation, the Manager SHALL stop new dispatch and further local de-identification, block all job result release, and request ITI-x7 cancellation for each outstanding remote assignment for which it has a polling URL and confirmation of cancellable mode. It SHALL also account for submissions already in flight. If the polling URL and confirmation become available while an assignment may still be running, the Manager SHALL request cancellation at that URL. For a lost polling URL, the Manager SHALL use the [recovery-only request](#submission-retries) for the original assignment. It SHALL account for a recorded definitive rejection as an assignment that did not start. A missing record or an expired URL alone does not establish that the assignment is terminal.

The Manager SHALL report confirmed cancellation only after local work has stopped and each dispatched assignment has reached a known terminal state. An assignment that completed or failed before its cancellation was applied counts as terminal. An unconfirmed cancellation response does not establish a terminal task state. The Manager SHALL discard any results from such assignments and SHALL NOT expose their evidence or mappings to the Requester. If the confirmation interval expires with an unresolved assignment, the Manager SHALL report unconfirmed cancellation and continue to withhold all job results. It SHALL continue cancellation of any outstanding assignments it can still address. An Integrated actor applies the same job rules to its local work.

### 2:3.x4.5 CapabilityStatement Resource

The De-ID Manager and Integrated De-ID Manager/De-Identifier declaring DIS-ASYNC-JOB SHALL provide a CapabilityStatement Resource as described in [ITI TF-2: Appendix Z.3](https://profiles.ihe.net/ITI/TF/Volume2/ch-Z.html#z.3-capabilitystatement-resource) indicating support for the ITI-x4 polling interaction.

The De-Identification Requester declaring DIS-ASYNC-JOB SHALL provide a CapabilityStatement Resource indicating that it can perform the ITI-x4 polling interaction. Actors supporting cancellation SHALL also declare DIS-CANCEL as specified in the [shared cancellation contract](#asynchronous-cancellation).

### 2:3.x4.6 Security Considerations

See [DIS Security Considerations](volume-1.html#security-considerations).

#### 2:3.x4.6.1 Security Audit Considerations

The De-Identification Requester and the De-ID Manager (or Integrated De-ID Manager/De-Identifier) SHALL record an audit event for each ITI-x4 poll that returns a completed job. In-progress, failed, and denied polls and allowed or denied cancellation requests SHALL also generate audit events. The audit event for a completed retrieval SHALL include the job identifier and the audit correlation identifier from the de-identification evidence. Implementations SHOULD use [IHE BALP](https://profiles.ihe.net/ITI/BALP/) for structured audit event representation.

<a name="23x7-retrieve-task-output-iti-x7"> </a>

## 2:3.x7 Retrieve Task Output [ITI-x7]

### 2:3.x7.1 Scope

The Retrieve Task Output transaction is used by the De-ID Manager to retrieve the status and output of a previously dispatched asynchronous de-identification task from a De-Identifier. The Manager polls the De-Identifier using the task handle received in the ITI-x3 202 Accepted response. The De-Identifier returns the current task status, and when the task is complete, returns the de-identified output and provenance evidence. This transaction is required when the Asynchronous Task Processing Option (DIS-ASYNC-TASK) is declared. This transaction does not apply to the Integrated De-ID Manager/De-Identifier.

### 2:3.x7.2 Actors Roles

Table 2:3.x7.2-1 lists the actors and their roles in this transaction.

<p id="t3.x7.2-1" class="tableTitle"><strong>Table 2:3.x7.2-1: ITI-x7 Actor Roles</strong></p>

| Actor | Role |
|-------|------|
| [De-ID Manager](volume-1.html#de-id-manager) | Initiates the poll request, presenting the task handle received from ITI-x3 |
| [De-Identifier](volume-1.html#de-identifier) | Receives the poll request and returns task status, de-identified output, and evidence upon completion |
{: .grid}

### 2:3.x7.3 Referenced Standards

- [HL7 FHIR R4]({{site.data.fhir.path}}) — HL7 FHIR Release 4.0.1
- [HL7 FHIR R4 RESTful API]({{site.data.fhir.path}}http.html) — FHIR RESTful interactions
- [HL7 FHIR R4 Parameters]({{site.data.fhir.path}}parameters.html) — completed task result envelope
- [HL7 FHIR R4 Provenance]({{site.data.fhir.path}}provenance.html) — de-identification evidence
- [HL7 FHIR R4 OperationOutcome]({{site.data.fhir.path}}operationoutcome.html) — error reporting

### 2:3.x7.4 Interactions and Messages

Figure 2:3.x7.4-1 shows ordinary task polling for pending, completed, and failed work.

<p><a href="dis-iti-x7-interactions.png"><img src="dis-iti-x7-interactions.png" alt="ITI-x7 retrieve task output interaction diagram" width="659" style="max-width: 100%; height: auto;" /></a></p>

**Figure 2:3.x7.4-1: ITI-x7 Interaction Diagram**

#### 2:3.x7.4.1 Retrieve Task Output Request Message

##### 2:3.x7.4.1.1 Trigger Events

The De-ID Manager sends a Retrieve Task Output Request to poll the status of an asynchronous task. The Manager SHALL reference the task handle received in the ITI-x3 202 Accepted response. The Manager SHOULD respect any retry-after guidance returned in a prior polling response before sending a subsequent request.

##### 2:3.x7.4.1.2 Message Semantics

The De-ID Manager SHALL poll using `GET [Content-Location]`, where `[Content-Location]` is the URL received in the `Content-Location` response header of the ITI-x3 `202 Accepted` response.

The request body is empty.

The Manager SHALL include authorization credentials. Before disclosing task status, result, evidence, or protected lookup material, the De-Identifier SHALL verify that the credentials authorize this Manager to retrieve this task.

##### 2:3.x7.4.1.3 Expected Actions

Upon receipt of a Retrieve Task Output Request, the De-Identifier SHALL return the current status of the referenced task. For accepted cancellation, it SHALL apply the [shared cancellation responses](#asynchronous-cancellation).

When the task is still in progress, the De-Identifier SHALL indicate in-progress status and SHOULD include retry-after guidance.

When the task is complete, the De-Identifier SHALL return the de-identified output and provenance evidence and any protected `generatedLookupTable` required by ITI-x3. It SHALL apply the [polling lifecycle](#asynchronous-polling-lifecycle).

When the task has failed, the De-Identifier SHALL return error information via OperationOutcome. The De-Identifier SHALL NOT release partial output.

#### 2:3.x7.4.2 Retrieve Task Output Response Message

##### 2:3.x7.4.2.1 Trigger Events

The De-Identifier sends a Retrieve Task Output Response upon receipt of each poll request. The response content depends on the current state of the referenced task at the time the request is processed.

##### 2:3.x7.4.2.2 Message Semantics

The De-Identifier uses the HTTP polling mechanics of the draft HL7 FHIR R4 Asynchronous Request Pattern. DIS defines the deferred operation response as follows.

**202 Accepted — Task in progress.** The De-Identifier SHOULD include `Retry-After` with the recommended polling interval in seconds. The response body is empty.

**200 OK — Task complete.** The body is identical to [ITI-x3 synchronous success](#23x3422-message-semantics), including one `payloadResult`, `validationStatus`, and the protected `generatedLookupTable` when required. The Manager SHALL exclude the generated lookup table from recipient-facing job output.

**422 Unprocessable Entity — Terminal processing failure.** On an authorized poll, the responder SHALL return an R4 `OperationOutcome` when the accepted work item has failed. It SHALL withhold every result for that work item.

**Other 4xx/5xx — Polling error.** The responder SHALL return an R4 `OperationOutcome` without a result. An invalid or unauthorized poll, an expired polling URL, or an endpoint outage does not report terminal processing failure. Use HTTP 401 for missing or invalid credentials and HTTP 403 for credentials that do not authorize the poll.

##### 2:3.x7.4.2.3 Expected Actions

Upon receipt of a Retrieve Task Output Response, the De-ID Manager SHALL inspect the response status.

On an in-progress response, the Manager SHOULD wait for the indicated retry-after period before issuing another poll request.

On a complete response, if the Manager has accepted job cancellation, it SHALL apply the [job cancellation rules](#job-cancellation). Otherwise it SHALL validate and retain any required protected mapping output before release and accept the de-identified output and evidence for assembly into the job response to the Requester. The Manager SHALL NOT expose partial output to the Requester.

On an error response, the Manager SHALL inspect the OperationOutcome and any `DIS-Cancellation` header. For a cancellation outcome, it SHALL apply the [job cancellation rules](#job-cancellation). An authorization error, expired polling URL, or transient retrieval error leaves the task outcome unresolved. When ITI-x7 reports a terminal processing failure, the Manager SHALL account for the task as terminal if job cancellation has been accepted. For a terminal processing failure in a job without accepted cancellation, it SHALL withhold the job result and report the failure on ITI-x1 for a synchronous job or through ITI-x4 for an accepted asynchronous job.

#### 2:3.x7.4.3 Cancel De-Identification Task

After accepting job cancellation, the Manager uses the [shared cancellation contract](#asynchronous-cancellation) to cancel outstanding remote assignments. The De-Identifier SHALL verify that the caller is authorized to cancel the assigned task and that the task was accepted in cancellable mode. On accepting cancellation, the De-Identifier SHALL stop processing, apply the existing cleanup requirements for task-local material, and withhold task output, evidence, and generated mappings. It SHALL report confirmed cancellation only after the assigned work has stopped.

If the De-Identifier reports that an assignment was already terminal, the Manager SHALL use the ordinary authorized ITI-x7 poll to determine its terminal outcome. The Manager SHALL apply the job cancellation and release rules in [ITI-x4](#job-cancellation).

### 2:3.x7.5 CapabilityStatement Resource

The De-Identifier declaring DIS-ASYNC-TASK SHALL provide a CapabilityStatement Resource as described in [ITI TF-2: Appendix Z.3](https://profiles.ihe.net/ITI/TF/Volume2/ch-Z.html#z.3-capabilitystatement-resource) indicating support for the ITI-x7 polling interaction.

The De-ID Manager declaring DIS-ASYNC-TASK SHALL provide a CapabilityStatement Resource indicating that it can perform the ITI-x7 polling interaction. Actors supporting cancellation SHALL also declare DIS-CANCEL as specified in the [shared cancellation contract](#asynchronous-cancellation).

### 2:3.x7.6 Security Considerations

See [DIS Security Considerations](volume-1.html#security-considerations).

#### 2:3.x7.6.1 Security Audit Considerations

The De-ID Manager and the De-Identifier SHALL audit completed, failed, and denied ITI-x7 polls and allowed or denied cancellation requests. Ordinary in-progress polls SHOULD be logged and MAY be recorded at a reduced frequency. The audit event SHALL NOT include confidential salts or other protected transformation material. Implementations SHOULD use [IHE BALP](https://profiles.ihe.net/ITI/BALP/) for structured audit event representation.
