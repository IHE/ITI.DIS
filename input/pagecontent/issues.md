## Significant Changes

The current drafting baseline is [Volume 1](volume-1.html). Supporting content reflects four actors, four transactions, policy, execution plan, FHIR payload, evidence, and lookup table specifications, the nine core transformation actions, and independently versioned R4 and R5 payloads over an R4 protocol binding.

The [ODRL content](odrl-content.html) addresses the authorization language and policy and plan formats discussed in [issue #57](https://github.com/IHE/ITI.DIS/issues/57). The issue also records the [comparison with APPC, PCF, and FHIR R4 Consent](https://github.com/IHE/ITI.DIS/issues/57#issuecomment-6866785277).

## Issues

### Submit an Issue

Submit and discuss profile feedback through [IHE ITI.DIS GitHub Issues](https://github.com/IHE/ITI.DIS/issues). The repository development work plan records drafting packages and dependencies; it does not establish that all bindings or tests are complete.

### Open Issues

- [FHIR R6 processing payloads](#fhir-r6-processing-payloads)
- [Key-based reversible pseudonymization](#key-based-reversible-pseudonymization)
- [Data Recipient actor and push delivery](#data-recipient-and-push-delivery)
- **[DICOM and CDA binding conformance](draft-native-payload-bindings.html):** complete native policy and plan schemas, capabilities, output and evidence mappings, and cross-set linkage rules for use cases that require shared identifiers.
- [Asynchronous job and task cancellation](#asynchronous-job-and-task-cancellation)
- [IUA grouping and authorization denials](#iua-grouping-and-denial-responses)
- [Future policy management transaction](#future-policy-management-transaction)
- **Draft contract review:** confirm the payload set transaction contract, capability declarations, stage ordering, and release authorization. Complete detailed conformance procedures and validate them against the agreed baseline.

<a name="fhir-r6-processing-payloads"> </a>

#### FHIR R6 Processing Payloads

This supplement assesses conformance with published FHIR R4 or R5 processing payloads. Evaluate R6 processing over the same R4 workflow protocol when the R6 definitions are stable. This requires release-specific validation, semantic group mappings, capability matching, and worked examples with conformance tests.

<a name="key-based-reversible-pseudonymization"> </a>

#### Key-Based Reversible Pseudonymization

The [proposed DIS-REVERSIBLE method](draft-encryption-based-pseudonymization.html) uses deterministic encryption to generate patient pseudonyms. Independent De-Identifiers must produce the same pseudonym for the same resolved identity within the authorized linkage scope. The deployment provisions the matching scope-specific key version before dispatch so the De-Identifiers can encrypt and the Manager can decrypt when authorized. [Issue #50](https://github.com/IHE/ITI.DIS/issues/50) tracks the binding, key provisioning assumptions, and conformance tests.

For the proposed FF1 method, the published NIST SP 800-38G defines the algorithm. The February 2025 second public draft of Revision 1 is an informative reference for policy authors, including its proposed minimum FF1 domain of one million values. [NIST SP 800-38G](https://csrc.nist.gov/pubs/sp/800/38/g/upd1/final) · [NIST SP 800-38G Rev. 1, second public draft](https://csrc.nist.gov/pubs/sp/800/38/g/r1/2pd)

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

<a name="future-policy-management-transaction"> </a>

#### Future Policy Management Transaction

A future revision could standardize policy discovery, retrieval, and lifecycle management through a transaction such as ITI-x8. DIS uses implementation-defined mechanisms under the [policy lifecycle rules](volume-3.html#3pxx16-policy-lifecycle).

### Closed Issues

No closed-issue history is recorded on this page. See GitHub for issue state and discussion.
