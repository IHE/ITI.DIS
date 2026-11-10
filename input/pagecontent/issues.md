## Significant Changes

The current drafting baseline is [Volume 1](volume-1.html). Supporting content reflects four actors, four transactions, policy, execution plan, FHIR payload, evidence, and lookup table specifications, the nine core transformation actions, and independently versioned R4/R5/R6 payloads over an R4 protocol binding. R6 support remains provisional as described in Volume 1.

## Issues

### Submit an Issue

Submit and discuss profile feedback through [IHE ITI.DIS GitHub Issues](https://github.com/IHE/ITI.DIS/issues). The repository development work plan records drafting packages and dependencies; it does not establish that all bindings or tests are complete.

### Open Issues

- [Data Recipient actor and push delivery](#data-recipient-and-push-delivery)
- **[DICOM and CDA binding conformance](draft-native-payload-bindings.html):** complete native policy and plan schemas, capabilities, output and evidence mappings, and cross-set linkage rules for use cases that require shared identifiers.
- [Asynchronous job and task cancellation](#asynchronous-job-and-task-cancellation)
- [IUA grouping and authorization denials](#iua-grouping-and-denial-responses)
- [Future policy management transaction](#future-policy-management-transaction)
- **Draft contract review:** confirm the payload set transaction contract, capability declarations, stage ordering, and release authorization. Complete detailed conformance procedures and validate them against the agreed baseline.

<a name="data-recipient-and-push-delivery"> </a>

#### Data Recipient Actor and Push Delivery

In [UC-5](volume-1.html#1pxx425-use-case-5-de-identified-health-data-export-content-conformance), the standalone Integrated actor produces de-identified output through local invocation and delivers it through an implementation-defined mechanism. A Connectathon can assess content conformance by inspecting the output artifacts.

An alternative design would introduce a **Data Recipient** actor and an optional push-delivery transaction initiated by the Integrated actor (or De-ID Manager) to deliver de-identified output directly to the recipient. The proposal would have these effects.

- Give the content-conformance-only Integrated actor a wire-testable transaction, enabling connectathon testing with a test partner
- Standardize the output delivery step that UC-1, UC-2, and UC-5 currently describe as outside DIS
- Separate the job-initiation role (Requester) from the output-consumption role (Data Recipient), reflecting deployments where the exporting system and the downstream consumer are different systems

Considerations include Phase 1 scope, overlap with MHD Document Source grouping (see [Volume 1 MHD grouping](volume-1.html#1pxx63-ihe-mhd---mobile-access-to-health-documents)), additional specification and testing surface, and whether a content-only connectathon test is sufficient for the standalone Integrated actor.

**The committee is asked to discuss whether a Data Recipient actor and push-delivery transaction should be included in Phase 1.**

<a name="asynchronous-job-and-task-cancellation"> </a>

#### Asynchronous Job and Task Cancellation

**Phase 1 editorial draft.** The draft [DIS-CANCEL option](volume-1.html#asynchronous-cancellation-option) adds optional cancellation to [ITI-x4 Retrieve Job Output](volume-2.html#23x4-retrieve-job-output-iti-x4) and [ITI-x7 Retrieve Task Output](volume-2.html#23x7-retrieve-task-output-iti-x7). Each transaction would carry a cancellation message between its existing actors. The Requester would control its job through the Manager, which would coordinate cancellation across the De-Identifiers assigned to that job. [IHE ITI-22 §3.22.4.3](https://profiles.ihe.net/ITI/TF/Volume2/ITI-22.html) is a precedent for including an optional cancellation message in an existing transaction.

| Exchange | Proposed message | Effect of acceptance |
|---|---|---|
| Requester → De-ID Manager or externally invoked Integrated actor, ITI-x4 | Send `DELETE` with an empty body to the polling URL from the ITI-x1 `Content-Location`. | The Manager stops new dispatch and blocks release of all job results. It cancels outstanding remote work or stops work locally in an Integrated actor. |
| De-ID Manager → De-Identifier, ITI-x7 | Send `DELETE` with an empty body to the polling URL from the ITI-x3 `Content-Location`. | The De-Identifier stops the assigned task and applies the existing cleanup and protected material rules at termination. |

{: .grid}

The proposed HTTP method follows the cancellation pattern in [FHIR R4 Asynchronous Request Pattern §3.1.6.3](https://hl7.org/fhir/R4/async.html). The URL identifies the accepted work for cancellation. Each receiver checks that the caller is authorized to cancel that work. The Manager accepts job cancellation only from the submitting Requester or a delegate explicitly authorized to cancel. The De-Identifier accepts task cancellation only from the Manager authorized to cancel that assignment. The actors audit the cancellation requests and outcomes under the applicable DIS audit rules.

**Eligibility.** A Requester would select cancellable processing when submitting an asynchronous job. Before accepting that job, a distributed Manager would verify that its execution can use asynchronous task dispatch with cancellation support for every remote assignment. It would use only eligible De-Identifiers for that job, including when rerouting work. A synchronous ITI-x3 exchange provides no ITI-x7 polling URL. If the Manager cannot meet the cancellation requirement, it rejects the cancellable submission before acceptance. An Integrated actor with an external Requester would handle the same job cancellation locally.

**Cancellation and completion.** A receiver returns `202 Accepted` when it has accepted a cancellation that is still in progress. Polling at the same URL would distinguish cancellation in progress, confirmed cancellation, and execution failure. A repeated authorized cancellation request reports the current cancellation outcome without starting the work again. The Manager resolves the race between accepting cancellation and making a successful result available. If cancellation takes effect first, all job outputs remain withheld, including any results from tasks that finish during cancellation. If successful completion takes effect first, the Manager reports that the job is already complete and the ordinary authorized retrieval rules apply.

After accepting cancellation, the Manager accounts for each outstanding assignment, including a task submission whose acceptance response is still in flight. It cancels tasks that are still running and discards results from tasks that have already reached a terminal state. It reports the job as cancelled once all required work has stopped or reached a known terminal state. A timeout or failed poll alone does not establish that work has stopped.

**Proposed conformance scenarios**

- Submit a cancellable asynchronous job with two tasks at different De-Identifiers. Cancel while one task is running and the other submission is awaiting a response. Verify propagation as each accepted task becomes addressable, no further dispatch, no job output, and a final cancelled outcome after both assignments reach a known terminal state.
- Repeat with a worker completing just before its cancellation request, and with the job making its successful result available just before the Requester's cancellation request. Verify that the first case withholds all job output and the second preserves ordinary authorized retrieval.
- Repeat cancellation as the original authorized caller and as a caller with polling permission only. Verify a stable cancellation outcome for the authorized retry and denial without a state change or disclosure of cancellation details for the unauthorized caller.
- Submit a cancellable job when an assignment requires synchronous dispatch or a De-Identifier without task cancellation support. Verify rejection before asynchronous acceptance. Repeat a valid cancellation with a transient downstream timeout and verify that the Manager does not report confirmed cancellation while the assignment's state is unknown.

**Decisions for committee review.** Review the [draft cancellation wire contract](volume-2.html#asynchronous-cancellation), including capability and selection signaling, the polling outcomes, and the declared confirmation and retention intervals. The [submission recovery draft](volume-2.html#submission-retries) defines a recovery-only request for a lost acceptance. Cancellation remains unconfirmed while work is unresolved. If the responder confirms cancellation while the polling URL remains available, the draft reports the confirmed outcome at that URL.

<a name="iua-grouping-and-denial-responses"> </a>

#### IUA Grouping and Authorization Denials

The current grouping table lists Authorization Client or Resource Server for the Manager and Integrated actor. For exchanges that use IUA, the Requester presents a token to the Manager or externally invoked Integrated actor on the job leg. The distributed Manager presents a token to the De-Identifier on the task leg. [ITI-72 §3.72.4.3](https://profiles.ihe.net/ITI/IUA/) assigns HTTP 401 when token verification, scope matching, or IUA access policy enforcement fails. DIS also specifies HTTP 403 when an authenticated caller lacks permission to poll or cancel a work item.

The committee needs to confirm which IUA groupings are required on each leg, including the Manager's distinct roles and the externally invoked Integrated actor. It also needs to define how DIS distinguishes an IUA access denial from a work item authorization denial, or align the status codes for requests governed by both requirements. The denial must protect work item state, outputs, and evidence regardless of the response code.

<a name="future-policy-management-transaction"> </a>

#### Future Policy Management Transaction

A future phase could standardize policy discovery, retrieval, and lifecycle management through a transaction such as ITI-x8. Phase 1 uses implementation-defined mechanisms under the [policy lifecycle rules](volume-3.html#3pxx16-policy-lifecycle).

### Closed Issues

No closed-issue history is recorded on this page. See GitHub for issue state and discussion.
