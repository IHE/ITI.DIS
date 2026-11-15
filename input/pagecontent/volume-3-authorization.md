<div id="data-request-authorization"> </div>
<div id="3pxx6-data-request-authorization"> </div>
<div id="3pxx1-data-request-authorization"> </div>

This section defines the organizational grant, how the De-ID Manager establishes coverage for a job, and who may receive the result. [ITI-x1](volume-2.html#23x1-submit-de-identification-job-iti-x1) specifies admission and [ITI-x4](volume-2.html#23x4-retrieve-job-output-iti-x4) specifies asynchronous retrieval.

<div id="data-request-authorization-contract"> </div>
<div id="3pxx61-data-request-authorization-contract"> </div>

## 3:PXX.1.1 Data Request Authorization Contract

The [DIS Data Request Authorization Contract](StructureDefinition-DIS-DataRequestAuthorizationContract.html) carries the organizational grant used by ITI-x1. The Requester SHALL supply an absolute HTTPS FHIR version-specific reference ending in `/Contract/{id}/_history/{vid}`. The Manager SHALL verify that the resolved Contract's `id` and `meta.versionId` match the reference, and that a trusted authority issued the embedded Agreement for the stated assigner. An amended Agreement SHALL have a new `uid` and a new version-specific reference. The same `uid` SHALL identify the same issued Agreement bytes. See the [decoded ODRL Agreement example](examples-odrl.html#decoded-authorization-example). Apply the [shared Contract signature rules](volume-3-contract-rules.html#contract-signatures).

The Contract SHALL carry one `rule.contentAttachment` with `contentType` set to `application/ld+json` and the complete issued [DIS ODRL Agreement](odrl-content.html#odrl-authorization) in `data` as Base64-encoded UTF-8 JSON-LD. The attachment SHALL omit `url`. The Contract publisher SHALL protect the Contract, its narrative, and its search results under the authorization governing discovery of the embedded Agreement. See [FHIR R4 Contract.rule]({{site.data.fhir.path}}contract-definitions.html#Contract.rule).

The publisher SHALL derive the mirrored fields from the embedded Agreement revision and verify the following mappings before making the Contract available for submission, display or search.

| Contract element | Source and interpretation |
| --- | --- |
| `identifier` | Agreement revision `uid`, with `system = urn:ietf:rfc:3986`. |
| `title` | Display title supplied by the publisher. |
| `authority` | The common Agreement assigner as an Organization reference. Use the assigner IRI in `Reference.identifier.value` with `system = urn:ietf:rfc:3986`. A literal Organization reference may also be supplied when it identifies the same organization. |
| `issued` | Issuance timestamp when supplied by the issuing authority. |
| `term.identifier` | One term per Agreement permission, keyed by the permission `uid` using `system = urn:ietf:rfc:3986`. |
| [DIS Permission Validity](StructureDefinition-dis-permission-validity.html) on `term` | Exact `inclusiveStart` and `exclusiveEnd` from the permission. The extension preserves the Agreement's exclusive upper bound. FHIR R4 `Period.end` is inclusive. |
| `term.offer.party` | One Organization reference with role `requester` for the assignee and one with role `result-recipient` for the authorized recipient. Use the same IRI identifier form as for `authority`. |
| [DIS Approved Purpose](StructureDefinition-dis-approved-purpose.html) on `term` | Exact approved purpose IRI. |
| [DIS Purpose Classification](StructureDefinition-dis-purpose-classification.html) on `term` | One Coding for each distinct ISO classification code when supplied in the permission. Copy the system, edition, and code. |
| [DIS Approved Policy Version](StructureDefinition-dis-approved-policy-version.html) on `term` | Exact approved policy URL and version joined by a vertical bar. |

The publisher SHALL verify that each Agreement permission has exactly one matching term and that each mirrored field agrees with that permission. The publisher SHALL correct a Contract that fails verification before making it available for use. The Manager SHALL verify that `Contract.identifier.value` matches the embedded Agreement's `uid`. The Contract narrative or a client display MAY summarize the approved scope and conditions for authorized readers.

The Manager SHALL use the embedded Agreement to evaluate the job's authorization. The Contract fields that mirror the Agreement support display and search.

FHIR R4 defines [Contract search parameters]({{site.data.fhir.path}}contract.html#search) including `identifier`, `authority`, and `issued`. If the server indexes the logical Organization identifier for `authority`, declare the supported search behavior. Queries on mirrored permission terms, such as approved purpose or policy revision, require separately defined and advertised search parameters. A query that matches a combination of permission fields would need to correlate those fields within the same term.

See the [UC-2 Contract example](Contract-grouped-fhir-authorization-contract.html), the [readable Agreement](examples-odrl.html#decoded-authorization-example), and the [Contract verification checks](testplan.html#authorization-contract-validation).

<div id="grant-validation-and-scope"> </div>

## 3:PXX.1.2 Grant Validation and Approved Scope

Before acceptance or synchronous processing the Manager SHALL establish that the grant is currently effective. The Manager SHALL use a trusted status source for the exact Agreement revision. The method for obtaining status is deployment-defined. The Manager SHALL establish current effectiveness independently of the historical Contract and its `status`. If status cannot be established, or if the grant is expired, revoked or superseded, the Manager SHALL deny the job. The Manager SHALL check current authorization again before releasing the result, evidence or download access, including on retries and asynchronous retrieval.

For each payload set, the Manager SHALL validate the selected permission against the authenticated Requester or authorized delegate, the purpose of the submission, the declared binding and release, the selected policy canonical and version, and the approved data scope. The Manager SHALL establish coverage for the exact manifest and versions of its inputs, either by verifying the selection against authoritative scope criteria or by verifying trusted preparation evidence that binds the Agreement revision, permission, manifest and input versions. The methods of evaluating source-specific criteria and conveying preparation evidence depend on the deployment. The Manager SHALL deny processing if coverage cannot be established. The grant SHALL NOT be inferred from service credentials or from the selected transformation policy. An optional [purpose classification](odrl-content.html#purpose-classification) records the issuer’s ISO/TS 14265:2024 classification. The Manager SHALL evaluate the specific approved purpose IRI in the Agreement.

<div id="job-result-recipient"> </div>
<div id="result-recipient-eligibility"> </div>

## 3:PXX.1.3 Result Recipient Eligibility and Release

Before accepting an asynchronous job or beginning synchronous processing, the Manager SHALL establish that all selected permissions use the same recipient organization IRI and that the chosen processing mode provides an eligible caller for the complete result.

- **Synchronous job.** The authenticated submitting caller SHALL be authorized to receive the complete result on behalf of the recipient organization.
- **Asynchronous job.** The Manager SHALL establish that the original Requester or an explicitly authorized retrieval delegate is authorized to receive the complete result on behalf of the recipient organization. The Manager uses deployment-defined trusted information to establish the caller's authority and any delegation. Agreement recipient status alone grants no access to the job.

If either admission check fails, the Manager SHALL return HTTP 403 with an R4 `OperationOutcome` before accepting the job or dispatching work. Each admitted job has one release audience across all of its sets.

Before returning or enabling access to a result, the Manager SHALL verify that the grant is still effective and that the actual caller remains entitled to receive every set on behalf of that recipient organization. Apply this check to synchronous responses, recovery and replay of synchronous results, and asynchronous retrieval. The Manager SHALL enforce all applicable destination restrictions on direct and referenced access. When a result service controls retrieval, the Manager SHALL ensure that the service enforces those restrictions and current release authorization. If the caller fails a release check, withhold every set, its evidence and download access from that caller.
