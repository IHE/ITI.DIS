<a name="data-plane-access"> </a>
<a name="obtaining-processing-targets"> </a>

<a name="3pxx16-obtaining-processing-targets"> </a>

<a name="3pxx323-obtaining-processing-targets"> </a>

<a name="3pxx322-input-and-result-delivery"> </a>

<a name="3pxx422-input-and-result-delivery"> </a>

See the [FHIR Payload Binding overview](volume-3-payload-bindings.html#fhir-payload-binding).

The job request identifies the proposed processing targets. The task request identifies the data assigned to the De-Identifier. The De-Identifier returns task results in ITI-x3 or ITI-x7. The Manager returns job results in ITI-x1 or ITI-x4. Result resources retain the declared input release.

<a name="3pxx33-fhir-payload-delivery"> </a>

<a name="3pxx324-fhir-payload-delivery-summary"> </a>

<a name="3pxx3221-payload-set-delivery"> </a>

## 3:PXX.4.2.2.1 Payload Set Delivery

[Volume 2](volume-2.html#grouped-payload-parameters) defines the transaction parameters. Table 3:PXX.4.2.2-1 summarizes the delivery forms for a FHIR payload set.

<p id="fhir-input-result-delivery-table" class="tableTitle"><strong>Table 3:PXX.4.2.2-1: FHIR Input and Result Delivery</strong></p>

| Exchange | Delivery attachment |
|---|---|
| Input | `Task.input.valueAttachment` on the `payload-set` input |
| Result | `payloadResult.resultPackage` |
{: .grid}

For both exchanges, use `dis-resource-list` for bundled or hosted FHIR resources, or `fhir-bulk-data` for bulk files. A single inline R4 input uses an R4 manifest package containing the List and that resource. Its result uses a DIS Result Package. The FHIR task result uses the same manifest format as the assigned input, as specified in [ITI-x3](volume-2.html#23x3422-message-semantics). The Manager MAY repackage inline or hosted inputs at dispatch while preserving the authorized content and set identity.

<a name="3pxx112-version-safe-packaging"> </a>

<a name="3pxx3212-version-safe-packaging"> </a>

<a name="3pxx3223-version-safe-packaging-of-inline-and-hosted-resources"> </a>

## 3:PXX.4.2.2.2 Version-Safe Packaging of Inline and Hosted Resources

The DIS transaction envelope and manifest package use HL7 FHIR R4. For inline R5, carry the serialized resource in the attachment of a DIS Payload Wrapper selected by the manifest. Hosted R5 resources can use [direct release-qualified references](#direct-hosted-r5-references) or an R4 wrapper with an attachment URL. For an inline R5 example, see [the manifest package below](#inline-r5-manifest-package).

<a name="protocol-resources-remain-hl7-fhir-r4"> </a>

**Protocol Resources Remain HL7 FHIR R4**

Table 3:PXX.4.2.2-2 lists the resources that are part of the HL7 FHIR R4 protocol layer and remain HL7 FHIR R4 regardless of the payload version.

<a name="tPXX.3.2.1-2"> </a>

<p id="tPXX.3.2.2-3" class="tableTitle"><strong>Table 3:PXX.4.2.2-2: HL7 FHIR R4 Protocol Resources</strong></p>

| HL7 FHIR R4 Protocol Resource | Role |
|-------------------------------|------|
| `Task` | Request bodies for the ITI-x1 job submission and ITI-x3 task submission |
| `Parameters` | ITI-x1, ITI-x3, ITI-x4 and ITI-x7 success responses carrying results |
| `Provenance` | De-identification evidence |
| `OperationOutcome` | Error and validation reporting |
| `Bundle` | Workflow packaging (message, result collection) |
| `Contract` | Carries the [Data Request Authorization](volume-3-authorization.html#data-request-authorization-contract), [Policy Set](volume-3-policy.html#policy-contract-structure), and [Execution Plan Set](volume-3-execution-plan.html#execution-plan-format) |
| `CapabilityStatement` | Actor capability declaration |
{: .grid}

<a name="3pxx163-bulk-file-manifests"> </a>

<a name="3pxx3233-bulk-file-manifests"> </a>

<a name="resource-manifest"> </a>

<a name="resource-manifest-resolution"> </a>

<a name="fhir-resource-manifest-resolution"> </a>

<a name="3pxx3222-fhir-resource-manifest-and-wrapper-resolution"> </a>

<a name="fhir-input-manifests-and-retrieval"> </a>

## 3:PXX.4.2.2.3 Input Manifests and Retrieval

**Resource-list manifests and wrappers.**

A [DIS Resource Manifest](StructureDefinition-DIS-ResourceManifest.html) is a profiled FHIR R4 [List](https://hl7.org/fhir/R4/list.html). A standalone List uses absolute HTTPS FHIR REST references. Within a package the List may also use bundle-local references under the [manifest package rules](volume-3-payload-bindings.html#manifest-package). The manifest belongs to one payload set. The selected binding and version determine whether an entry identifies a payload resource, an R4 payload wrapper, or an R4 index.

The Manager SHALL establish the manifest's entry set before dispatch and verify that authorization covers every entry and the corresponding native content. It SHALL ensure the job and its retries resolve to the same target set. The Manager can use version-specific references or a protected snapshot of the manifest and any index resources used to resolve the targets. The Manager SHALL give the De-Identifier access only to the manifest, indexes, and payloads authorized for its task. The Integrated De-ID Manager/De-Identifier applies the same rules when processing directly.

Table 3:PXX.4.2.2-3 shows how a List entry identifies the payload.

<p id="tPXX.3.2.2-2" class="tableTitle"><strong>Table 3:PXX.4.2.2-3: FHIR Resource Manifest Resolution</strong></p>

| Binding and version | Resource selected by a List entry | Payload selected |
|---------------------|------------------------------------|------------------|
| DIS-FHIR-Payload R4 | An R4 resource, or an R4 [DIS Payload Wrapper](StructureDefinition-DIS-PayloadWrapper.html) | The resource itself or, for a wrapper, the R4 content carried or located by its attachment |
| DIS-FHIR-Payload R5 | An R4 DIS Payload Wrapper or a [release-qualified HTTPS reference](#direct-hosted-r5-references) | The R5 resource carried or located by the wrapper's attachment, or the R5 resource retrieved directly from the referenced endpoint |
{: .grid}

**Payload wrapper.** The wrapper is a profiled R4 DocumentReference with one attachment. Its `data` carries the payload bytes inline, or its `url` locates the payload at an authorized HTTPS endpoint. Exactly one SHALL be present. A FHIR wrapper SHALL use `application/fhir+json` or `application/fhir+xml`. The receiving actor SHALL retrieve or decode the payload and validate it against the containing set's binding and version. If the FHIR media-type release parameter is present, it SHALL agree with `payloadVersion`. Any HTTP negotiation for R5 occurs on retrieval of the attachment content. The manifest, package, and wrapper exchanges use R4.

The receiving actor SHALL follow the attachment only when the DocumentReference declares and conforms to the DIS Payload Wrapper profile. A DocumentReference claiming that profile but failing validation SHALL cause a set failure. To deliver a resource that itself declares the wrapper profile as a FHIR payload, serialize it inside a separate wrapper. An inline R5 DocumentReference is therefore carried as R5 bytes in the R4 wrapper, just like any other R5 resource.

<a name="direct-hosted-r5-references"> </a>

**Direct hosted R5 references.** For a FHIR resource-list payload set declared as `R5`, a List item MAY reference a hosted R5 resource directly using an absolute HTTPS FHIR [version-specific read URL](https://hl7.org/fhir/R5/http.html#vread). The item SHALL carry the [DIS Target FHIR Release extension](StructureDefinition-dis-target-fhir-version.html) with `valueCode = 5.0`. Resolve List items without the extension as R4 workflow resources or native R4 payloads, as applicable. For an R5 set, an unqualified item SHALL resolve to a conformant R4 Payload Wrapper. The extension SHALL NOT qualify an R4 wrapper or index, a bundle-local reference, or a reference in a set declared as R4. This rule defines cross-release resolution for DIS, including [evidence targets](volume-3-evidence.html#3pxx3214-evidence-representation-across-versions).

The retrieving actor SHALL use the target release to set the [FHIR media-type parameter](https://hl7.org/fhir/R5/versioning.html) on the separate GET, for example `Accept: application/fhir+json; fhirVersion=5.0`. It SHALL confirm the release using the response media-type parameter or verified FHIR server capabilities for that endpoint. If a response media-type parameter is present, it SHALL agree with the requested release. If it is absent, the actor SHALL verify that the resource endpoint serves R5 exclusively, using trusted endpoint configuration and its R5 CapabilityStatement. A multi-release endpoint SHALL identify the returned release in its response media type for this exchange. The actor SHALL verify that the resource type, logical ID, and `meta.versionId` match the URL and validate the returned resource against R5. A successful HTTP status alone does not establish the release. Apply the [authorization and stable retrieval rules](volume-3-payload-bindings.html#3pxx32-authorization-and-stable-retrieval). Reject the submission or fail the accepted work if a required input cannot be verified and retrieved. For results, apply the [result packaging checks](#fhir-result-packages-and-delivery) and [evidence target rules](volume-3-evidence.html#3pxx3214-evidence-representation-across-versions).

See the [hosted R5 input List](List-hosted-r5-input.html) and [hosted R5 result package](Bundle-hosted-r5-result.html). These artifacts illustrate the resource-list manifest and evidence for a set with `payloadBinding = DIS-FHIR-Payload` and `payloadVersion = R5`. They use illustrative URLs. The result package pairs an R4 manifest List with R4 Provenance. Both identify the same hosted R5 output revision. A receiver requests that revision as follows.

```http
GET /fhir/r5/Observation/hosted-imaging-output/_history/1
Host: results.example.org
Accept: application/fhir+json; fhirVersion=5.0
```

<a name="3pxx3224-bulk-file-manifests-and-authorized-retrieval"> </a>

**Bulk input manifests.**

For an asynchronous cohort job, the Requester supplies an HTTPS URI identifying a JSON manifest that lists prepared input files. Each line of a listed NDJSON file contains one complete resource in the declared payload release. [Volume 1](volume-1.html) defines the scope for bulk data input and output.

DIS uses the file listing conventions of the [HL7 Bulk Data Access IG STU 3](https://hl7.org/fhir/uv/bulkdata/STU3/en/export.html#response---output-manifest). For a manifest prepared for DIS, the required fields are `requiresAccessToken` (boolean) and `output` (array of file entries). Each entry SHALL identify the resource type in `type` and the file location in `url` as an absolute HTTPS URL. The manifest SHALL enumerate the complete dataset in one file listing. It may omit export-specific metadata such as `request` and `transactionTime`. The job's `payloadVersion` applies to all listed input files. A manifest with continuation links or reported export errors SHALL be rejected for processing under this binding.

<a name="referenced-input-authorization"> </a>

<a name="3pxx164-authorization-for-referenced-inputs"> </a>

<a name="3pxx3234-authorization-for-referenced-inputs"> </a>

**Authorization for referenced inputs.**

The Manager SHALL verify that the approved data request covers the processing target set, including every resource identified by a resource manifest and the dataset described by a bulk file manifest. It SHALL dispatch only references within the authorized scope. Retrieval of a resource or manifest SHALL NOT expand that scope. The data request authorization governs the full target set.

The actor making the retrieval request SHALL use HTTPS and obtain credentials valid for the specific resource or file service. For automated FHIR REST reads, the retrieving actor SHOULD use [SMART Backend Services](https://hl7.org/fhir/smart-app-launch/STU2.2/backend-services.html) with its registered client identity to obtain an access token. The source service enforces the applicable resource access restrictions. The data request authorization in ITI-x1 is evidence of approval for the job. The retrieving actor obtains credentials through the source service's access mechanism.

Authorization SHALL cover retrieval of each manifest and each resource or file listed in it. If `requiresAccessToken` is true, the retrieving actor SHALL present an access token valid at the file endpoint. Use `requiresAccessToken = false` for files accessed with signed URLs. When the file endpoint uses a signed URL as the access credential, the retrieving actor SHALL use the URL without forwarding a bearer token. The signed URL SHALL be limited to the specific file and have a bounded lifetime. A signed URL SHALL be handled as a credential. The retrieving actor SHALL send credentials only to the service for which they are valid.

The Manager SHALL reject the job if it cannot establish that the identified dataset is authorized. If a required input is missing, inaccessible, invalid or outside the authorized scope, the Manager SHALL reject the job before acceptance or fail the accepted job and withhold all job output. A De-Identifier that detects such a failure SHALL report it to the Manager using the applicable task transaction.

<a name="inline-r5-manifest-package"></a>

<a name="3pxx34-inline-r5-manifest-package-example"> </a>

<a name="3pxx325-inline-r5-manifest-package-example"> </a>

<a name="3pxx3225-inline-r5-manifest-package-example"> </a>

## 3:PXX.4.2.2.4 Inline R5 Manifest Package Example

For inline submission, serialize the [R4 manifest package](Bundle-inline-r5-manifest-package.html) as `Task.input.valueAttachment.data` on the `payload-set` input with `contentType` of `application/fhir+json`. The set declares `DIS-FHIR-Payload`, `R5`, and manifest format `dis-resource-list`. The List selects the [R4 payload wrapper](DocumentReference-inline-r5-payload-wrapper.html) by its bundle-local UUID. The wrapper attachment decodes to `{"resourceType":"Patient","id":"example"}` and is interpreted as R5.

<a name="fhir-result-packages-and-delivery"> </a>

## 3:PXX.4.2.2.5 Result Packages and Delivery

**Result manifests.** A result manifest SHALL reference only result resources or result indexes whose native targets resolve to the authorized de-identified output. The producing actor SHALL verify retrieval and identity of the referenced results before returning the manifest. Recipient-facing manifests, result indexes, and their referenced metadata SHALL exclude source identifiers and protected transformation material. Associated evidence follows the rules below.

<a name="result-evidence-placement"> </a>

**Result package and evidence placement.** Each successful job or task result SHALL carry one [DIS Result Package](StructureDefinition-DIS-ResultPackage.html) in `payloadResult.resultPackage`. This FHIR R4 collection Bundle SHALL contain the manifest and at least one DIS Evidence Provenance entry. The attachment's `data` contains the serialized Bundle, or its HTTPS `url` identifies that Bundle at an authorized endpoint. Use `application/fhir+json` or `application/fhir+xml`. The same packaging applies when the result is returned immediately or by polling. Each distributed job result set that uses multiple stages also carries [staged release evidence](volume-3-evidence.html#staged-release-evidence). The receiver SHALL identify the manifest and evidence by profile and validate their references.

| `manifestFormat` | Required package contents in addition to Provenance |
|---|---|
| `dis-resource-list` | Exactly one DIS Resource Manifest List. Its selected entries may be bundled resources or authorized HTTPS references. Apply the payload binding's wrapper or index rules. |
| `fhir-bulk-data` | Exactly one [DIS Bulk Result Manifest](StructureDefinition-DIS-BulkResultManifest.html) DocumentReference and one [DIS Bulk Result File](StructureDefinition-DIS-BulkResultFile.html) DocumentReference per listed file. The manifest carrier holds or links to the JSON file listing. File descriptors link to the listed NDJSON files. |

The List or bulk JSON manifest determines the selected output. Provenance and manifest carriers SHALL NOT be selected as clinical payload. The receiver SHALL verify that the package contents agree with the enclosing `manifestFormat`, binding and payload version, and validate evidence coverage before accepting or releasing the set. If the Manager changes how results are made available, it SHALL preserve the selected output and update the manifest and evidence targets to describe the same released set.

The [mixed R4 result package](Bundle-mixed-r4-result.html) selects a bundled Patient and a hosted Observation in the same List. The [result response](Parameters-mixed-r4-result.html) carries the package inline.

**Bulk result packages.**

For asynchronous cohort jobs, the Manager returns a bulk file manifest for the de-identified NDJSON files and supplies the associated evidence with the job result. The result package carries the manifest DocumentReference and file descriptors. The manifest carrier attachment SHALL use `application/json` and exactly one of inline `data` or an authorized HTTPS `url`. Each file descriptor attachment SHALL use `application/fhir+ndjson` and the exact HTTPS URL listed for that file in the manifest. The receiver SHALL match descriptors one to one with the manifest file URLs and reject missing, duplicate or unlisted descriptors. Extract the JSON manifest for ordinary Bulk Data file retrieval. The Manager SHALL ensure that manifest and file access expires within the authorized release window. Recipient-facing manifests and files SHALL NOT contain confidential salts or other protected transformation material. A failed job SHALL NOT release a partial dataset. The Manager SHALL report the failure through job status for an accepted asynchronous job.

<a name="bulk-result-content-identity"> </a>

**Bulk result content identity.** The producing actor is the De-Identifier for a task result and the De-ID Manager or Integrated De-ID Manager/De-Identifier for a job result. Before making a bulk result available to its receiver, the producing actor SHALL establish the exact output manifest and file versions covered by validation and evidence for that set. The manifest URL SHALL continue to resolve to that manifest version, and each file locator SHALL continue to resolve to its validated file version, for every successful retrieval of the released set. Content identity is based on the JSON and NDJSON bytes after HTTP decompression, when compression is used. A locator for a released result SHALL NOT serve substitute content, even when the replacement lists the same file URLs or contains the same FHIR resource type.

The producing actor SHALL withhold the result if it cannot establish or preserve the validated versions before release. If it detects after release that a manifest or file no longer resolves to the validated version, it SHALL prevent further access to the affected result set. It SHALL NOT renew access to a substitute version. A failed retrieval alone does not indicate that an accepted job or task has failed.

When a deployment supports renewal, the actor controlling access SHALL verify that the receiver is still authorized and that renewal is within the authorized release window. It MAY issue a new temporary download URL or credentials for the same version. The locators in the released manifest and the bytes of the manifest and files SHALL remain unchanged. The profile does not define a renewal transaction or prescribe how the deployment maintains object versions.

<a name="bulk-result-download-authorization"> </a>

**Bulk job result downloads.** The Manager SHALL ensure that services delivering a hosted result package, manifest or NDJSON file enforce the [current job release authorization](volume-3-authorization.html#job-result-recipient) on every new download request, including a range or resume request. This applies to the manifest URL, each stable file locator and every endpoint reached through a redirect. If the grant expires or is revoked, the recipient loses release authority, or current authorization cannot be established, the services SHALL deny further downloads and renewal. The final download service SHALL deny a request using an already-issued signed URL in these cases, even if the URL itself is still valid. The Manager SHALL enable signed downloads only where the complete delivery chain can enforce these rules. A finite URL lifetime is an additional limit on access.

When a selected permission specifies a result destination, the Manager SHALL ensure that each referenced endpoint and redirect for the affected result stays within that approved HTTPS service boundary. The retrieving actor SHALL check the destination before following each redirect and stop if it cannot establish that the destination is authorized. Apply this check before forwarding any credentials. The Manager SHALL ensure that a cache in the delivery chain cannot serve a protected result or a reusable access redirect in place of a current authorization check.
