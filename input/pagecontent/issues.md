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

The approved design uses three FHIR R4 Contract profiles. The binding below is draft text for the changes to ITI-x1, ITI-x3 and the job result package. Each Contract carries one complete ODRL expression in `rule.contentAttachment` with `contentType = application/ld+json` and Base64 data. The structured Contract fields are derived from the ODRL content for display and search. See [FHIR R4 Contract rules]({{site.data.fhir.path}}contract-definitions.html#Contract.rule).

| Contract profile | Required content and identity |
|---|---|
| Data Request Authorization | The issued ODRL Agreement. `Contract.identifier.value` is the Agreement revision `uid`. Each permission binds the approved scope, purpose, recipient and exact policy version. The approved policy is incorporated by that reference and can be reused by other authorizations. |
| De-Identification Policy | The reusable ODRL Set of transformation duties. `Contract.url` and `Contract.version` identify the approved business revision. `Contract.identifier.value` is the Set revision `uid`. The permission and job use the same `Contract.url\|Contract.version` value. The signed policy repository binds that value to one immutable Contract revision. |
| De-Identification Execution Plan | The compiled ODRL Set for one assigned de-identification task. `Contract.identifier.value` is the compiled Set revision `uid`. The Contract identifies the Manager and the assigned De-Identifier. The embedded Set identifies the payload set, rule set, stage when applicable, and ordered transformation duties. |

#### Signatures and ITI-x1 admission

The Requester SHALL supply the existing exact authorization Contract reference and an `authorization-signature` input with a version-specific `valueReference` to the authorization's signature Provenance. The Provenance SHALL have one target, which SHALL identify the exact authorization Contract version. For the signed policy, the Manager SHALL obtain the policy Contract and its signature Provenance together, whether the Requester supplies them or the Manager resolves the approved policy. The policy signature Provenance SHALL target the exact policy Contract version. For Requester-carried content, the proposed `policyContent` target is a contained FHIR R4 collection Bundle with the policy Contract and its signature Provenance. The same signature verification applies when the Manager obtains the pair from a trusted repository.

Each signature SHALL be a detached JWS in `Provenance.signature`, using the [FHIR R4 Signature JSON rules]({{site.data.fhir.path}}datatypes.html#Signature). Use `sigFormat = application/jose` and `targetFormat = http://hl7.org/fhir/canonicalization/json#data`. This signs the Contract, including its identifiers, version metadata and ODRL attachment, while allowing narrative rendering. The Manager SHALL verify the JWS, bind the verified signing identity to `Signature.who`, and establish that the signer is trusted to issue the authorization or policy, as applicable. An artifact with a missing or unverifiable signature cannot authorize processing. See the [FHIR R4 canonical JSON forms]({{site.data.fhir.path}}json.html#canonical) and [RFC 7515 Appendix F](https://www.rfc-editor.org/rfc/rfc7515#appendix-F).

The Manager SHALL verify the Agreement `uid`, the selected permission `uid`, and the exact signed policy URL and business version named by the permission. The Manager SHALL establish that the job's inputs and intended use are covered before processing. Before release it SHALL establish that the Agreement remains effective for the recipient and destination. A trusted authorization decision may establish scope or current status when it is bound to the exact Agreement revision and applicable job inputs or release context.

#### Execution plan and ITI-x3

The task's execution plan input SHALL reference the assigned Execution Plan Contract. The plan SHALL carry a profiled `Contract.supportingInfo` reference identifying the exact source Policy Contract version. The Manager SHALL associate the plan with the task identifier, assigned De-Identifier, exact input manifest and versions, selected permission `uid`, and exact authorization Contract version. The Manager retains the authorization link with the assignment. This identifies the parent authorization even when several authorizations approve the same policy. [FHIR R4 Contract supporting information]({{site.data.fhir.path}}contract-definitions.html#Contract.supportingInfo)

The De-Identifier SHALL confirm that the task and plan agree on the assigned parties, payload set and manifest binding, rule set and stage when present before applying the compiled Set. The De-Identifier SHALL identify the source policy version in task evidence. The Manager SHALL correlate that evidence with the exact plan it dispatched.

#### Disclosed job results

The job result delivered through ITI-x1 or ITI-x4 SHALL make available, with the dataset and result Provenance, the issued authorization Contract and each policy Contract version applied to the result, with signature Provenance for each. The result package uses Contract entries plus associated signature Provenance entries, separate from transformation Provenance. Contract entry identities SHALL let the receiver match each signature target to the exact accompanying Contract version. A result package SHALL keep these supporting entries outside the clinical output manifest. The recipient SHALL be authorized to receive the dataset and the supporting artifacts. When only a restricted copy may be disclosed, the issuer can sign a disclosure copy that identifies the original revision and its role as a disclosure copy. The Manager SHALL withhold release if it cannot supply authorized, verifiable supporting artifacts. The execution plan remains an assignment artifact between the processing actors.

#### Conformance cases for the binding

- Submit a valid signed authorization and approved signed policy. Repeat with a changed Agreement attachment, an untrusted signer, a signature targeting a different revision, or a correctly signed policy version outside the selected permission. The Manager accepts only the covered job with the exact trusted artifacts.
- Use two authorization revisions that approve the same reusable policy. Verify that each plan assignment traces to its own authorization, permission and exact source policy. Substitute a manifest or assigned De-Identifier and verify rejection before execution.
- Verify the authorized recipient can obtain the signed artifacts and check their signatures after synchronous and asynchronous disclosure. Revoke the authorization or remove the recipient's access to a required supporting artifact and verify that the Manager withholds release.

The current transaction artifacts still define the Library carriers. The next specification change is to replace them and add the signature and result package profiles, including the Requester-carried policy representation.

<a name="future-policy-management-transaction"> </a>

#### Future Policy Management Transaction

A future revision could standardize policy discovery, retrieval, and lifecycle management through a transaction such as ITI-x8. DIS uses implementation-defined mechanisms under the [policy lifecycle rules](volume-3.html#3pxx16-policy-lifecycle).

### Closed Issues

No closed-issue history is recorded on this page. See GitHub for issue state and discussion.
