This volume contains the DIS Profile transaction specifications. Each section defines the scope, actor roles, interaction model, and expected actor behaviors for one transaction. The transaction tables define the R4 message contract.

The following transactions are specified in this volume:

- [Submit De-Identification Job \[ITI-x1\]](#23x1-submit-de-identification-job-iti-x1)
- [Submit De-Identification Task \[ITI-x3\]](#23x3-submit-de-identification-task-iti-x3)
- [Retrieve Job Output \[ITI-x4\]](#23x4-retrieve-job-output-iti-x4)
- [Retrieve Task Output \[ITI-x7\]](#23x7-retrieve-task-output-iti-x7)

<a name="grouped-payload-parameters"> </a>

## Shared Payload Set Parameters

Every job uses the same payload set encoding, including jobs with only one set. The POST requests and successful HTTP 200 responses use R4 `Parameters`. The polling GET requests have no body.

| Transaction | Input | Successful response |
|---|---|---|
| ITI-x1 Submit Job | One `authorization` and one or more `payload` groups. Each group includes its policy and may include an authorized lookup reference. | HTTP 200 with one `payloadResult` per submitted set and one `validationStatus`, or HTTP 202 with `Content-Location` and an empty body for an accepted async job. |
| ITI-x3 Submit Task | Exactly one assigned `payload` group, one `executionPlan`, one `ruleSetId`, one `reversibilityMode`, and a `stageId` for staged execution. A protected task-scoped `lookupTable` applies when assigned. | HTTP 200 with one `payloadResult` and one `validationStatus`, plus a protected `generatedLookupTable` when required, or HTTP 202 with `Content-Location` and an empty body for an accepted async task. |
| ITI-x4 Retrieve Job Output | Authorized GET of the job polling URL. | HTTP 200 with the same body as synchronous ITI-x1 success. HTTP 202 indicates processing is pending and carries no result. |
| ITI-x7 Retrieve Task Output | Authorized GET of the task polling URL. | HTTP 200 with the same body as synchronous ITI-x3 success. HTTP 202 indicates processing is pending and carries no result. |
{: .grid}

The receiver SHALL reject a submission that includes `processingTarget`, `resourceManifest`, or another top-level parameter outside the applicable request table with HTTP 400 and an OperationOutcome. The `policy` and `lookupTable` parts appear only in ITI-x1 inputs. Successful results carry evidence inside the result package. `validationStatus` is `valid` on successful completion. Failure responses carry an OperationOutcome and no result. A POST without `Prefer: respond-async` selects synchronous processing. A receiver SHALL reject an async request if the applicable option is unsupported. The bulk-file cohort binding requires async job selection. Task mode is selected independently.

Encode each `payload` or `payloadResult` as a named `Parameters.parameter` with the following `part` entries. Each `payload` SHALL carry one `manifest`. Each `payloadResult` SHALL carry one `resultPackage` and SHALL omit outer `manifest` and `evidence` parts. Both groups SHALL declare `manifestFormat`. See [Volume 3](volume-3.html#payload-set-delivery) for manifest formats and target resolution.

| Part | Cardinality | Encoding | Meaning |
|------|-------------|----------|---------|
| `setId` | 1..1 | `valueString` | Nonempty job-local identifier, reused in task inputs and results |
| `payloadBinding` | 1..1 | `valueCode` | Binding that governs the set |
| `payloadVersion` | 1..1 | `valueCode` | Version defined by that binding |
| `manifest` | 1..1 in `payload` only | `valueAttachment` | Input manifest with `contentType` and exactly one of inline `data` or an absolute HTTPS `url` |
| `resultPackage` | 1..1 in `payloadResult` only | `valueAttachment` | [R4 DIS Result Package](volume-3.html#result-evidence-placement) containing the manifest and evidence. Use a FHIR media type and exactly one of inline `data` or an absolute HTTPS `url` identifying the package. |
| `manifestFormat` | 1..1 | `valueCode` | Use `dis-resource-list` or `fhir-bulk-data` |
| `policy` | 1..1 in ITI-x1 only | Nested `part` | One `url` as `valueUri`, one `version` as `valueString`, and optional JWS `content` as a Binary resource with `contentType = application/jose` |
| `lookupTable` | 0..1 | `valueReference` | Optional in ITI-x1 when the binding supports a supplied lookup table |
{: .grid}

The Manager SHALL preserve set identity, binding, and version when changing how manifest entries are made available. Where a task processes a subset, its delivery description SHALL identify that subset. Before releasing job results, the Manager SHALL validate all output sets and any cross-set relationships required by the authorization and approved policies. A job that requires cross-set linkage SHALL be rejected if the selected bindings and policies cannot provide and validate that linkage.

See the [single R4 Patient exchange](examples-single-r4-patient.html) for the smallest synchronous case and the [informative job with R4 and R5 payload sets](examples-grouped-fhir-job.html) for complete submission, dispatch, and result examples.

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
- [HL7 FHIR R4 Parameters]({{site.data.fhir.path}}parameters.html) — input/output resource for operations
- [HL7 FHIR R4 OperationOutcome]({{site.data.fhir.path}}operationoutcome.html) — error reporting
- [HL7 FHIR R4 Provenance]({{site.data.fhir.path}}provenance.html) — de-identification evidence
- [RFC 7515](https://datatracker.ietf.org/doc/html/rfc7515) — JSON Web Signature (JWS), for `policy.content` signature validation
- [RFC 7517](https://datatracker.ietf.org/doc/html/rfc7517) — JSON Web Key (JWK), for signing key representation (applicable to `policy.content`)

### 2:3.x1.4 Interactions and Messages

Figure 2:3.x1.4-1 shows the interaction for the Submit De-Identification Job transaction. The synchronous flow is shown. In asynchronous mode (DIS-ASYNC-JOB), the Manager returns a 202 Accepted response with a job handle; the Requester retrieves output and evidence using ITI-x4.

<p><a href="dis-iti-x1-interactions.png"><img src="dis-iti-x1-interactions.png" alt="ITI-x1 submit de-identification job interaction diagram" width="636" style="max-width: 100%; height: auto;" /></a></p>

**Figure 2:3.x1.4-1: ITI-x1 Interaction Diagram**

#### 2:3.x1.4.1 Submit De-Identification Job Request Message

##### 2:3.x1.4.1.1 Trigger Events

The De-Identification Requester sends a Submit De-Identification Job Request when it requires de-identification of one or more processing targets under an approved data request. Before initiating this transaction, the Requester SHALL obtain the approved data request authorization. DIS assumes the Requester can read the [exact approved policy](volume-3.html#approved-policy-access) for each payload set.

##### 2:3.x1.4.1.2 Message Semantics

The De-Identification Requester SHALL invoke the `$submit-dis-job` operation using `POST [base]/$submit-dis-job`. The request SHALL use `Content-Type: application/fhir+json`.

The request body SHALL be an HL7 FHIR R4 `Parameters` resource. Table 2:3.x1.4.1.2-1 lists the input parameters.

<p id="t3.x1.4.1.2-1" class="tableTitle"><strong>Table 2:3.x1.4.1.2-1: ITI-x1 Request Input Parameters</strong></p>

| Parameter | Cardinality | Type | Description |
|-----------|-------------|------|-------------|
| `payload` | 1..* | Group | One [payload set](#grouped-payload-parameters) per input set, including its approved policy and any set-specific lookup table |
| `authorization` | 1..1 | BackboneElement | Data request authorization evidence; exactly one variant SHALL be present |
| `authorization.reference` | 0..1 | Reference | Reference to an externally hosted authorization evidence resource |
| `authorization.content` | 0..1 | Attachment | Authorization evidence embedded directly; `contentType` declares the format |
{: .grid}

Exactly one of `authorization.reference` or `authorization.content` SHALL be present. The authorization is evidence that a data governance authority approved a data request, including identification of the approved de-identification policy. DIS does not define the authorization's internal structure — it is determined by the authorization mechanism used in the deployment (e.g., EHDS data permit, institutional governance approval, bilateral agreement). The De-ID Manager is configured to understand the authorization format and extract the approved policy identity from it.

`policy.url` and `policy.version` are required within each policy group. They declare the canonical identity of the policy approved for this data request. The De-ID Manager validates these against the data request authorization (see authorization consistency below).

`policy.content` is optional. When present, the Requester carries the JWS-signed policy Library directly in the request, and the Manager SHALL verify the JWS signature and confirm that `Library.url` and `Library.version` inside the JWS payload match the declared `policy.url` and `policy.version`. When `policy.content` is absent, the Manager resolves the declared policy version by implementation-defined means.


The `reversibilityMode` and `identity-linkage-scope` are carried inside the policy artifact (see [§3:PXX.1.3](volume-3.html#3pxx13-policy-rules-json-structure)) and are not duplicated as transaction parameters. The De-ID Manager extracts these values from the validated policy content. A de-identification policy is a reusable knowledge artifact: the same policy may be approved for and referenced by multiple independent data requests.

The Requester SHALL send one or more `payload` groups. The `setId` values SHALL be unique within the job. Each group SHALL declare its binding and version, supply one manifest, and include a `policy` part with the approved canonical URL and version. A group MAY carry `policy.content` or a `lookupTable` reference under the existing policy and lookup table rules for its binding. The same policy may be named in more than one group if approved and applicable to each. The request SHALL omit the top-level `policy`, `lookupTable`, `payloadBinding`, `payloadVersion`, `processingTarget`, and `resourceManifest` parameters.

To request asynchronous job processing when both actors support DIS-ASYNC-JOB, the Requester SHALL include the `Prefer: respond-async` request header per the HL7 FHIR R4 Asynchronous Request Pattern.

<div markdown="1" class="stu-note">
**Editorial Note:** The draft [Submit DIS Job OperationDefinition](OperationDefinition-submit-dis-job.html) describes this exchange. Its parameter definitions remain under review alongside the transaction text.
</div>

##### 2:3.x1.4.1.3 Expected Actions

Upon receipt of a Submit De-Identification Job Request, the De-ID Manager (or Integrated De-ID Manager/De-Identifier) SHALL perform the following actions.

The Manager SHALL obtain and validate the data request authorization. When `authorization.reference` is present, the Manager resolves the referenced resource. When `authorization.content` is present, the Manager processes the embedded attachment according to the declared `contentType`. The authorization is evidence that a data governance authority approved a data request that specifies the data scope, purpose, and the de-identification policy to be applied. If the authorization is absent, expired, or does not cover the requested processing targets, the Manager SHALL reject the job with an OperationOutcome.

The Manager SHALL verify that the declared `policy.url` and `policy.version` identify the policy approved in the data request authorization. The mechanism for extracting the approved policy identity from the authorization is implementation-defined (it depends on the authorization format used in the deployment). A mismatch indicates the Requester is presenting a policy that was not approved for this data request; the Manager SHALL reject the job with an OperationOutcome.

The Manager SHALL obtain the policy content. When `policy.content` is present, the Manager SHALL verify the JWS signature using a signing key trusted under its configured trust model and SHALL confirm that `Library.url` and `Library.version` inside the JWS payload match the declared `policy.url` and `policy.version`. When `policy.content` is absent, the Manager SHALL resolve the policy identified by the declared `policy.url` and `policy.version` by implementation-defined means (see [§3:PXX.1.4](volume-3.html#3pxx14-policy-delivery-and-validation)).

The Manager SHALL perform three-point policy content validation:

1. **Schema** — verify that the policy conforms to the applicable policy schema.
2. **Currency** — verify that the policy has not expired or been revoked.
3. **Integrity** — verify that the obtained rules are the exact content bound to the approved version under the [policy validation rules](volume-3.html#3pxx132-policy-validation). Apply the JWS verification above for carried content and the deployment's resolution trust model for Manager-resolved content.

If any point of the four-point validation fails, the Manager SHALL reject the job with an OperationOutcome describing the failure point.

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

The De-ID Manager sends a Submit De-Identification Job Response upon completion of job execution and output assembly. In asynchronous mode, the Manager sends the response immediately after accepting the job, before execution completes.

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

**422 Unprocessable Entity.** The response body is an HL7 FHIR R4 `OperationOutcome` identifying which of the four policy validation points (authorization consistency, integrity, schema conformance, currency) failed.

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
- [HL7 FHIR R4 Parameters]({{site.data.fhir.path}}parameters.html) — task request and result envelope
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

The request body SHALL be an HL7 FHIR R4 `Parameters` resource. Table 2:3.x3.4.1.2-1 lists the input parameters.

<p id="t3.x3.4.1.2-1" class="tableTitle"><strong>Table 2:3.x3.4.1.2-1: ITI-x3 Request Input Parameters</strong></p>

| Parameter | Cardinality | Type | Description |
|-----------|-------------|------|-------------|
| `payload` | 1..1 | Group | One [payload set](#grouped-payload-parameters) identifying the inputs assigned to this task |
| `executionPlan` | 1..1 | Reference(Library) | Reference to the Library resource containing the compiled rules for this ruleSet and the [source policy identity](volume-3.html#execution-plan-source-policy). Rules are carried in `Library.content` |
| `ruleSetId` | 1..1 | string | Identifier of the ruleSet from the source policy that this task executes |
| `stageId` | 0..1 | string | Stage identifier, when the source policy declares staged execution |
| `lookupTable` | 0..1 | Reference(DocumentReference) | Protected identified table restricted to the task; use a derived document for a subset, with its own identifiers and pinned content (Volume 3 §3:PXX.5). |
| `reversibilityMode` | 1..1 | code | `irreversible` or `reversible`; derived from the approved policy for the assigned set |
{: .grid}

Each task SHALL carry exactly one `payload` group with the job's `setId`, binding, and version for the assigned inputs. The Manager MAY change how the manifest and its entries are hosted or bundled when dispatching the same authorized content. The task group SHALL omit `policy` and `lookupTable` parts. The Manager carries the compiled plan and any assigned lookup table in their existing task parameters. It SHALL omit top-level `payloadBinding`, `payloadVersion`, `processingTarget`, and `resourceManifest`.

The `reversibilityMode` in ITI-x3 is derived from the approved policy for the assigned set. The De-ID Manager passes the policy-determined mode to the De-Identifier as an operational instruction; the De-Identifier does not independently select the mode.

When using `lookupTable`, the Manager SHALL dispatch only a protected reference to a document with the entries needed for the assigned task. If the source contains additional entries, the Manager SHALL create a [task-scoped lookup document](volume-3.html#3pxx5-reversible-lookup-table) and track its correlation to the pinned source. The De-Identifier's credentials SHALL NOT grant access to the unrestricted table in that case. The Manager SHALL delete derived task artifacts at termination unless retention is explicitly authorized.

To request asynchronous task processing when both actors support DIS-ASYNC-TASK, the Manager SHALL include the `Prefer: respond-async` request header per the HL7 FHIR R4 Asynchronous Request Pattern.

<div markdown="1" class="stu-note">
**Editorial Note:** The draft [Submit DIS Task OperationDefinition](OperationDefinition-submit-dis-task.html) describes this exchange. Its parameter definitions remain under review alongside the transaction text.
</div>

##### 2:3.x3.4.1.3 Expected Actions

Upon receipt of a Submit De-Identification Task Request, the De-Identifier SHALL perform the following actions.

The De-Identifier SHALL verify that the task's payload binding and version are within its declared capabilities. If the task specifies a payload binding or version that the De-Identifier does not support, the De-Identifier SHALL reject the task with an OperationOutcome.

The De-Identifier SHALL retrieve the assigned processing targets using the [retrieval authorization rules](volume-3.html#obtaining-processing-targets) and verify the declared payload release before transformation.

The De-Identifier SHALL apply supplied patient mappings or generate patient pseudonyms according to the execution plan. It SHALL verify that the decoded plan conforms to the [execution plan binding](volume-3.html#3pxx212-execution-plan-json-structure-and-rule-evaluation) and that its ruleSet, payload binding and payload version agree with the task. It SHALL obtain and validate the deployment-provisioned salt for each salted hash rule before transformation. A missing or invalid salt SHALL fail the task without partial output.

When `lookupTable` is present, the De-Identifier SHALL resolve and validate the assigned protected DocumentReference and pin its exact content as specified in Volume 3 §3:PXX.5. Retrieval or pinning failure SHALL fail the task. It SHALL use only its supplied entries for lookup-backed replacement, SHALL fail a task with a missing required entry without returning partial output, and SHALL delete all task-local copies at task termination. It SHALL NOT delete the authoritative source repository document. It SHALL NOT generate fallback mappings. The Manager SHALL withhold all job output on such a task failure.

The De-Identifier SHALL apply the execution plan rules to the processing target in full. Partial execution is not permitted. If any rule cannot be applied, the De-Identifier SHALL reject the task with an OperationOutcome and SHALL NOT produce partial output.

The De-Identifier SHALL produce de-identified output conforming to the declared payload binding and version. When a reversible Manager-managed task generates patient identifier mappings, the De-Identifier SHALL return a protected `generatedLookupTable` under Volume 3 §3:PXX.5. An irreversible task SHALL NOT return a generated lookup table. The Manager SHALL validate and retain generated mappings before job release and exclude them from recipient-facing responses.

The De-Identifier SHALL produce provenance evidence containing at minimum the nine elements in the [de-identification evidence baseline](volume-3.html#evidence-baseline). Evidence SHALL faithfully record the transformation decisions made during task execution.

The De-Identifier SHALL delete task-local copies of identity-linking material at termination. Deployment-managed salts follow the authorized scope lifecycle.

In synchronous mode, the De-Identifier SHALL return de-identified output and evidence in the response upon task completion.

In asynchronous mode (DIS-ASYNC-TASK), the De-Identifier SHALL return a task handle in the response. The Manager retrieves output and evidence using ITI-x7.

#### 2:3.x3.4.2 Submit De-Identification Task Response Message

##### 2:3.x3.4.2.1 Trigger Events

The De-Identifier sends a Submit De-Identification Task Response upon completion of task execution. In asynchronous mode, the De-Identifier sends the response immediately after accepting the task, before execution completes.

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

**422 Unprocessable Entity.** The response body is an HL7 FHIR R4 `OperationOutcome` indicating that the task's payload binding, payload version, or required transformation actions fall outside the De-Identifier's declared capabilities.

**500 Internal Server Error.** The response body is an HL7 FHIR R4 `OperationOutcome` describing the execution failure. No partial output is returned.

<div markdown="1" class="stu-note">
**Editorial Note:** The draft [Submit DIS Task OperationDefinition](OperationDefinition-submit-dis-task.html) describes this exchange. Its parameter definitions remain under review alongside the transaction text.
</div>

##### 2:3.x3.4.2.3 Expected Actions

Upon receipt of a Submit De-Identification Task Response, the De-ID Manager SHALL inspect the response status.

In synchronous mode, on a successful response, the Manager SHALL validate and retain any required protected mapping output before release. The Manager SHALL accept the de-identified output and evidence for assembly into the job response to the Requester. On an error response, the Manager SHALL inspect the OperationOutcome, SHALL NOT incorporate partial output into the job result, and SHALL report the failure to the Requester via the ITI-x1 response.

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

The Requester SHALL include authorization credentials consistent with those presented in the original ITI-x1 submission.

##### 2:3.x4.4.1.3 Expected Actions

Upon receipt of a Retrieve Job Output Request, the De-ID Manager (or Integrated De-ID Manager/De-Identifier) SHALL return the current status of the referenced job.

The Manager SHALL enforce authorization on retrieval. Only the original De-Identification Requester, or an explicitly authorized delegate, SHALL be permitted to retrieve the status or output of a given job. The Manager SHALL reject unauthorized retrieval requests with an appropriate error.

When the job is still in progress, the Manager SHALL indicate in-progress status and SHOULD include retry-after guidance to help the Requester pace its polling.

When the job is complete, the Manager SHALL return the de-identified output and provenance evidence. The Manager SHALL retain completed job output for a minimum retention period sufficient for the Requester to retrieve it; the specific duration is implementation-defined in Phase 1.

When the job has failed, the Manager SHALL return error information via OperationOutcome. The Manager SHALL NOT release partial output.

#### 2:3.x4.4.2 Retrieve Job Output Response Message

##### 2:3.x4.4.2.1 Trigger Events

The De-ID Manager sends a Retrieve Job Output Response upon receipt of each poll request. The response content depends on the current state of the referenced job at the time the request is processed.

##### 2:3.x4.4.2.2 Message Semantics

The De-ID Manager (or Integrated De-ID Manager/De-Identifier) returns one of three HTTP status codes per the HL7 FHIR R4 Asynchronous Request Pattern.

**202 Accepted — Job in progress.** The `Retry-After` response header contains the recommended polling interval in seconds. The `X-Progress` response header MAY be present with a human-readable status string. The response body is empty.

**200 OK — Job complete.** The body and release rules are identical to [ITI-x1 synchronous success](#23x1422-message-semantics), including one `payloadResult` per submitted set and `validationStatus`.

**422 Unprocessable Entity — Terminal processing failure.** On an authorized poll, the responder SHALL return an R4 `OperationOutcome` when the accepted work item has failed. It SHALL withhold every result for that work item.

**Other 4xx/5xx — Polling error.** The responder SHALL return an R4 `OperationOutcome` without a result. An invalid or unauthorized poll, an expired polling URL, or an endpoint outage does not report terminal processing failure. Use HTTP 401 for missing or invalid credentials and HTTP 403 for credentials that do not authorize the poll.

##### 2:3.x4.4.2.3 Expected Actions

Upon receipt of a Retrieve Job Output Response, the De-Identification Requester SHALL inspect the response status.

On an in-progress response, the Requester SHOULD wait for the indicated retry-after period before issuing another poll request.

On a complete response, the Requester SHALL apply the same result package and evidence checks as for [ITI-x1 synchronous success](#job-result-acceptance) before accepting the output.

On an error response, the Requester SHALL inspect the OperationOutcome and SHALL NOT treat the failed response as valid de-identified output.

### 2:3.x4.5 CapabilityStatement Resource

The De-ID Manager and Integrated De-ID Manager/De-Identifier declaring DIS-ASYNC-JOB SHALL provide a CapabilityStatement Resource as described in [ITI TF-2: Appendix Z.3](https://profiles.ihe.net/ITI/TF/Volume2/ch-Z.html#z.3-capabilitystatement-resource) indicating support for the ITI-x4 polling interaction.

The De-Identification Requester declaring DIS-ASYNC-JOB SHALL provide a CapabilityStatement Resource indicating that it can perform the ITI-x4 polling interaction.

### 2:3.x4.6 Security Considerations

See [DIS Security Considerations](volume-1.html#security-considerations).

#### 2:3.x4.6.1 Security Audit Considerations

The De-Identification Requester and the De-ID Manager (or Integrated De-ID Manager/De-Identifier) SHALL record an audit event for each ITI-x4 poll that returns a completed job. In-progress and denied polling requests SHALL also generate audit events. The audit event for a completed retrieval SHALL include the job identifier and the audit correlation identifier from the de-identification evidence. Implementations SHOULD use [IHE BALP](https://profiles.ihe.net/ITI/BALP/) for structured audit event representation.

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

Figure 2:3.x7.4-1 shows the interaction for the Retrieve Task Output transaction, including the three possible response states.

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

Upon receipt of a Retrieve Task Output Request, the De-Identifier SHALL return the current status of the referenced task.

When the task is still in progress, the De-Identifier SHALL indicate in-progress status and SHOULD include retry-after guidance.

When the task is complete, the De-Identifier SHALL return the de-identified output and provenance evidence, and, when required by the ITI-x3 output rules, the protected `generatedLookupTable` for the Manager.

When the task has failed, the De-Identifier SHALL return error information via OperationOutcome. The De-Identifier SHALL NOT release partial output.

#### 2:3.x7.4.2 Retrieve Task Output Response Message

##### 2:3.x7.4.2.1 Trigger Events

The De-Identifier sends a Retrieve Task Output Response upon receipt of each poll request. The response content depends on the current state of the referenced task at the time the request is processed.

##### 2:3.x7.4.2.2 Message Semantics

The De-Identifier returns one of three HTTP status codes per the HL7 FHIR R4 Asynchronous Request Pattern.

**202 Accepted — Task in progress.** The `Retry-After` response header contains the recommended polling interval in seconds. The response body is empty.

**200 OK — Task complete.** The body is identical to [ITI-x3 synchronous success](#23x3422-message-semantics), including one `payloadResult`, `validationStatus`, and the protected `generatedLookupTable` when required. The Manager SHALL exclude the generated lookup table from recipient-facing job output.

**422 Unprocessable Entity — Terminal processing failure.** On an authorized poll, the responder SHALL return an R4 `OperationOutcome` when the accepted work item has failed. It SHALL withhold every result for that work item.

**Other 4xx/5xx — Polling error.** The responder SHALL return an R4 `OperationOutcome` without a result. An invalid or unauthorized poll, an expired polling URL, or an endpoint outage does not report terminal processing failure. Use HTTP 401 for missing or invalid credentials and HTTP 403 for credentials that do not authorize the poll.

##### 2:3.x7.4.2.3 Expected Actions

Upon receipt of a Retrieve Task Output Response, the De-ID Manager SHALL inspect the response status.

On an in-progress response, the Manager SHOULD wait for the indicated retry-after period before issuing another poll request.

On a complete response, the Manager SHALL validate and retain any required protected mapping output before release. The Manager SHALL accept the de-identified output and evidence for assembly into the job response to the Requester. The Manager SHALL NOT expose partial output to the Requester.

On an error response, the Manager SHALL inspect the OperationOutcome. An authorization or transient polling error does not establish a terminal task failure. If the response reports terminal task failure, the Manager SHALL withhold the job result and report the failure through ITI-x1 or ITI-x4, as applicable.

### 2:3.x7.5 CapabilityStatement Resource

The De-Identifier declaring DIS-ASYNC-TASK SHALL provide a CapabilityStatement Resource as described in [ITI TF-2: Appendix Z.3](https://profiles.ihe.net/ITI/TF/Volume2/ch-Z.html#z.3-capabilitystatement-resource) indicating support for the ITI-x7 polling interaction.

The De-ID Manager declaring DIS-ASYNC-TASK SHALL provide a CapabilityStatement Resource indicating that it can perform the ITI-x7 polling interaction.

### 2:3.x7.6 Security Considerations

See [DIS Security Considerations](volume-1.html#security-considerations).

#### 2:3.x7.6.1 Security Audit Considerations

The De-ID Manager and the De-Identifier SHALL record an audit event for each ITI-x7 poll that returns a completed task. Polling requests that return in-progress status SHOULD be logged but MAY be recorded at a reduced frequency. The audit event SHALL NOT include confidential salts or other protected transformation material. Implementations SHOULD use [IHE BALP](https://profiles.ihe.net/ITI/BALP/) for structured audit event representation.
