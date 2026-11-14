## Significant Changes

The current drafting baseline is [Volume 1](volume-1.html). Supporting content reflects four actors, four transactions, policy, execution plan, FHIR payload, evidence, and lookup table specifications, the nine core transformation actions, and independently versioned R4 and R5 payloads over an R4 protocol binding.

The [ODRL content](odrl-content.html) addresses the authorization language and policy and plan formats discussed in [issue #57](https://github.com/IHE/ITI.DIS/issues/57). The issue also records the [comparison with APPC, PCF, and FHIR R4 Consent](https://github.com/IHE/ITI.DIS/issues/57#issuecomment-6866785277).

The [AES-FF1 binding](draft-encryption-based-pseudonymization.html) specifies the optional encryption method tracked in [issue #50](https://github.com/IHE/ITI.DIS/issues/50).

## Issues

### Submit an Issue

Submit and discuss profile feedback through [IHE ITI.DIS GitHub Issues](https://github.com/IHE/ITI.DIS/issues). The repository development work plan records drafting packages and dependencies; it does not establish that all bindings or tests are complete.

### Open Issues

- [FHIR R6 processing payloads](#fhir-r6-processing-payloads)
- [Data Recipient actor and push delivery](#data-recipient-and-push-delivery)
- **[DICOM and CDA binding conformance](draft-native-payload-bindings.html):** complete native policy and plan schemas, capabilities, output and evidence mappings, and cross-set linkage rules for use cases that require shared identifiers.
- [Asynchronous job and task cancellation](#asynchronous-job-and-task-cancellation)
- [IUA grouping and authorization denials](#iua-grouping-and-denial-responses)
- [Contract profiles for policy, execution plan and signed disclosure](#policy-plan-and-signed-disclosure)
- [Future policy management transaction](#future-policy-management-transaction)
- **Draft contract review:** confirm the payload set transaction contract, capability declarations, stage ordering, and release authorization. Complete detailed conformance procedures and validate them against the agreed baseline.

<a name="fhir-r6-processing-payloads"> </a>

#### FHIR R6 Processing Payloads

This supplement assesses conformance with published FHIR R4 or R5 processing payloads. Evaluate R6 processing over the same R4 workflow protocol when the R6 definitions are stable. This requires release-specific validation, semantic group mappings, capability matching, and worked examples with conformance tests.

<a name="data-recipient-and-push-delivery"> </a>

#### Data Recipient Actor and Push Delivery

In [UC-5](volume-1.html#1pxx425-use-case-5-de-identified-health-data-export-content-conformance), the standalone Integrated actor produces de-identified output through local invocation and delivers it through an implementation-defined mechanism. A Connectathon can assess content conformance by inspecting the output artifacts.

An alternative design would introduce a **Data Recipient** actor and an optional push-delivery transaction initiated by the Integrated actor (or De-ID Manager) to deliver de-identified output directly to the recipient. The proposal would have these effects.

- Give the content-conformance-only Integrated actor a wire-testable transaction, enabling connectathon testing with a test partner
- Standardize the output delivery step that UC-1, UC-2, and UC-5 currently describe as outside DIS
- Separate the job-initiation role (Requester) from the output-consumption role (Data Recipient), reflecting deployments where the exporting system and the downstream consumer are different systems

Considerations include the scope of this supplement, overlap with MHD Document Source grouping (see [Volume 1 MHD grouping](volume-1.html#1pxx63-ihe-mhd---mobile-access-to-health-documents)), additional specification and testing surface, and whether a content-only connectathon test is sufficient for the standalone Integrated actor.

**The committee is asked to discuss whether a Data Recipient actor and push-delivery transaction should be included in this supplement.**

<a name="asynchronous-job-and-task-cancellation"> </a>

#### Asynchronous Job and Task Cancellation

The [DIS-ASYNC-JOB option](volume-1.html#1pxx24-asynchronous-job-processing-option) includes cancellation through [ITI-x4](volume-2.html#job-cancellation). The Manager checks eligibility when the Requester asks to cancel. An outstanding synchronous task blocks job cancellation until its terminal outcome is known. The [DIS-ASYNC-TASK option](volume-1.html#1pxx25-asynchronous-task-processing-option) includes cancellation through [ITI-x7](volume-2.html#task-cancellation) for all accepted asynchronous tasks.

**Decisions for committee review.** Review the [draft cancellation wire contract](volume-2.html#asynchronous-cancellation), including the polling outcomes and the declared confirmation and retention intervals. The [submission recovery rules](volume-2.html#submission-retries) define a recovery-only request for a lost task acceptance. Cancellation remains unconfirmed while work is unresolved. If the responder confirms cancellation while the polling URL remains available, the draft reports the confirmed outcome at that URL.

<a name="iua-grouping-and-denial-responses"> </a>

#### IUA Grouping and Authorization Denials

The current grouping table lists Authorization Client or Resource Server for the Manager and Integrated actor. For exchanges that use IUA, the Requester presents a token to the Manager or externally invoked Integrated actor on the job leg. The distributed Manager presents a token to the De-Identifier on the task leg. [ITI-72 §3.72.4.3](https://profiles.ihe.net/ITI/IUA/) assigns HTTP 401 when token verification, scope matching, or IUA access policy enforcement fails. DIS also specifies HTTP 403 when an authenticated caller lacks permission to poll or cancel a work item.

The committee needs to confirm which IUA groupings are required on each leg, including the Manager's distinct roles and the externally invoked Integrated actor. It also needs to define how DIS distinguishes an IUA access denial from a work item authorization denial, or align the status codes for requests governed by both requirements. The denial must protect work item state, outputs, and evidence regardless of the response code.

<a name="policy-plan-and-signed-disclosure"> </a>

#### Contract Profiles for Policy, Execution Plan and Signed Disclosure

This design for review extends the [Data Request Authorization Contract](volume-3.html#data-request-authorization-contract) to the policy and execution plan. Each artifact carries its complete ODRL expression in one inline `Contract.rule.contentAttachment`. Selected Contract fields mirror the embedded rules for display and search. ITI-x1 uses the Agreement for authorization and ITI-x3 uses the compiled Set for the assigned de-identification task.

| Contract profile | ODRL content and relationship |
|---|---|
| Data Request Authorization | An issued Agreement. Each permission identifies the exact version of the policy it approves. That reference incorporates the signed policy into the authorization for the selected payload set and allows the same policy revision to be approved in multiple Agreements. |
| De-Identification Policy | A reusable Set of transformation duties. Each revision has a policy identity and version. The approval relationship is established by the permission that names the policy revision. |
| De-Identification Execution Plan | A compiled Set of transformation duties for one de-identification task. It names the exact source policy revision and binds the Manager's assignment to the De-Identifier, the payload set and manifest, and the rule set and stage where applicable. The Manager retains the link from the assignment to the exact authorization revision and permission. |

The Manager verifies both the signed Agreement and the signed policy against trusted signers, then matches the verified policy identity and version to the selected permission. It establishes that the job is covered before processing and verifies current authorization for the recipient and destination before release. The signature binding needs to protect the content and the revision identifiers used to select it. [FHIR R4 Contract rule]({{site.data.fhir.path}}contract-definitions.html#Contract.rule) and [JSON Web Signature](https://www.rfc-editor.org/rfc/rfc7515) provide mechanisms for carrying and verifying the signed content.

The execution plan acts as a subcontract for the assigned processing. The Manager records the exact authorization Contract version and the permission `uid` with the assignment. These identify the parent authorization when several grants use the same reusable policy. A profiled `Contract.supportingInfo` reference can identify the exact source policy Contract version. The profile would need to specify which assignment links are exchanged and which are retained by the Manager. The ITI-x3 assignment gives the De-Identifier the plan and the source policy identity needed for evidence. The Manager can correlate the returned task evidence with the exact plan it dispatched and the approved policy version.

The disclosed job result includes the original signed authorization and the signed policy revision or revisions applied, with the existing result evidence. The recipient's authorization covers those documents and the dataset. An issuer can provide a separately signed disclosure copy when the original contains terms the recipient is unauthorized to see. The result package keeps policy and authorization documents outside the manifest's clinical payload selection. The execution plan serves the Manager and De-Identifier and can contain concrete selectors and protected parameters.

The follow-on profile work needs to define the signed representation, version-specific policy and assignment references, and the result package entries. ITI-x1 and ITI-x3 currently bind the policy and plan to Library resources. Changing those carriers affects their profiles, examples, provenance references and conformance tests.

<a name="future-policy-management-transaction"> </a>

#### Future Policy Management Transaction

A future revision could standardize policy discovery, retrieval, and lifecycle management through a transaction such as ITI-x8. DIS uses implementation-defined mechanisms under the [policy lifecycle rules](volume-3.html#3pxx16-policy-lifecycle).

### Closed Issues

No closed-issue history is recorded on this page. See GitHub for issue state and discussion.
