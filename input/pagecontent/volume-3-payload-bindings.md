<div id="payload-delivery"> </div>
<div id="payload-bindings"> </div>
<div id="3pxx3-payload-bindings"> </div>
<div id="3pxx4-payload-bindings"> </div>

Payload Delivery specifies how DIS transaction messages carry or reference source data and de-identified results. It defines the message metadata and attachments, manifests and packages, inline and hosted delivery, and the checks receivers use to retrieve the intended payload.

<div id="payload-binding-framework"> </div>
<div id="payload-binding-requirements"> </div>

The common delivery contract applies to each payload set. The message's `payloadBinding` code identifies the payload format, and `payloadVersion` identifies its release. DIS uses FHIR R4 resources for the workflow envelope. [Execution Plan](volume-3-execution-plan.html#execution-plan-content) specifies selector compilation and processing, and [De-Identification Evidence](volume-3-evidence.html#evidence-baseline) defines Provenance and evidence coverage.

<div id="payload-set-delivery"> </div>
<div id="3pxx3-common-payload-set-delivery"> </div>
<div id="3pxx31-common-payload-set-delivery"> </div>

## 3:PXX.4.1 Common Payload Set Delivery

The [De-Identification Job profile](StructureDefinition-DIS-DeIdentificationJob.html) and [De-Identification Task profile](StructureDefinition-DIS-DeIdentificationTask.html) define the FHIR R4 `Task` request bodies for ITI-x1 and ITI-x3. They use the [DIS Work Order Input codes](CodeSystem-dis-task-input.html) for `Task.input.type`. Each `payload-set` input has one manifest attachment as `Task.input.valueAttachment` and one [DIS Payload Set Metadata extension](StructureDefinition-dis-payload-set.html) on that input.

| Subextension | Value | ITI-x1 job submission | ITI-x3 task submission |
|--------------|-------|----------|----------------|
| `setId` | string | Required, unique within the job | Required, matches the assigned job set |
| `payloadBinding` | code | Required | Required, matches the assigned job set |
| `payloadVersion` | code | Required | Required, matches the assigned job set |
| `manifestFormat` | code | Required | Required for the assigned manifest |
| `permission` | uri | Required, identifies the selected Agreement permission by its `uid` | ITI-x1 only |
| `purpose` | uri | Required, matches the selected Agreement permission’s approved purpose IRI | ITI-x1 only |
| `policy` | canonical | Required, use `Contract.url\|Contract.version` | The execution plan carries the policy identity |
| `policyContent` | Reference | Optional local reference to a contained Policy Content Binary | ITI-x1 only |
| `lookupTable` | Reference | Optional supplied lookup table for this set | Use the separate `lookup-table` input for an assigned lookup |
{: .grid}

The manifest attachment SHALL identify its content type and contain exactly one of inline `data` or an absolute HTTPS `url`. The receiving actor SHALL apply the declared binding, version and manifest format when resolving and validating the payload. Volume 2 specifies the [submission and result exchanges](volume-2.html#grouped-payload-parameters).

A job contains one or more payload sets. The same payload-set encoding applies to a single-set job. Each set uses one binding and version and carries one manifest at each exchange. Successful responses carry the manifest and evidence together in a result package. The manifest can select bundled and externally hosted content. A job can combine, for example, an inline R5 Patient and a set of separately hosted FHIR Observations. The FHIR R4 envelope carries the delivery description. The declared payload format determines which packaging and retrieval rules apply.

The [shared payload set parameters](volume-2.html#grouped-payload-parameters) define how the transactions carry a payload set.

<div id="3pxx31-manifest-formats"> </div>
<div id="3pxx311-manifest-formats"> </div>
<div id="3pxx311-manifest-formats-and-packages"> </div>

### 3:PXX.4.1.1 Manifest Formats and Packages

The `dis-resource-list` format carries an R4 DIS Resource Manifest as a standalone List or in an R4 [DIS Manifest Package](StructureDefinition-DIS-ManifestPackage.html). Serialize either as FHIR JSON or XML and declare the corresponding FHIR media type in the `manifest` attachment. These forms apply to inputs. Results carry the List inside the result package.

The `fhir-bulk-data` format uses the JSON [bulk file manifest](volume-3-fhir-delivery.html#3pxx3224-bulk-file-manifests-and-authorized-retrieval) of DIS-FHIR-Payload. It enumerates NDJSON files.

<div id="manifest-package"> </div>

Use an R4 `Bundle` of type `collection` when the manifest and its targets or indexes travel together. It SHALL contain exactly one List declaring the DIS Resource Manifest profile. Each entry in that List SHALL use either an absolute HTTPS FHIR REST reference allowed by the selected payload binding or a `urn:uuid` reference matching exactly one `Bundle.entry.fullUrl` in the same package. A standalone List SHALL use absolute HTTPS references. Only the List's selected entries determine the payload set. Other Bundle entries may support resolution under the selected binding.

A bundled R4 resource can be the target itself or a wrapper or index. Any non-R4 payload bytes included in the package SHALL be carried inside the attachment of an R4 resource. Each Bundle entry SHALL be an R4 resource.

<div id="3pxx32-authorization-and-stable-retrieval"> </div>
<div id="3pxx312-authorization-and-stable-retrieval"> </div>

### 3:PXX.4.1.2 Authorization and Stable Retrieval

The Manager SHALL verify that the job authorization covers every set, including the indexes, native objects, or files reached through its references or manifests. The retrieving actor SHALL use HTTPS and obtain credentials accepted by each endpoint. For automated FHIR REST retrieval of manifests, indexes, or payloads, apply the [FHIR retrieval authorization rules](volume-3-fhir-delivery.html#referenced-input-authorization). Other bindings define the access mechanism for their endpoints. The job authorization and credentials for reading the source serve separate purposes.

The Manager SHALL establish the authorized target set before dispatch, including any expansion of references. For ITI-x3 it SHALL bind the assigned manifest and every required input to the plan under the [assigned input verification rules](#assigned-input-verification). The Integrated actor SHALL verify the same authorized input versions for local execution. Each retry SHALL use the same authorized inputs and compiled plan version. A changed input or plan that cannot be resolved to the pinned version SHALL cause task or job failure. When publishing results by reference or manifest, the producing actor SHALL ensure the locators resolve to the intended de-identified objects and are accessible only to authorized recipients. A failed or inaccessible required set SHALL cause job failure without release of any set to the Requester.

<div id="assigned-input-verification"> </div>
<div id="3pxx313-assigned-input-verification"> </div>

### 3:PXX.4.1.3 Assigned Input Verification

The De-ID Manager SHALL establish the exact versions of the manifest and the resources, wrappers, indexes and files needed to resolve and process the assigned set. It SHALL authorize the selected content and bind those versions to the execution plan before dispatch. For a later stage, bind the authorized input to that stage's plan, including any verified output from an earlier stage that supplies its input.

The plan's [target source IRI](odrl-content.html#execution-plan-set) identifies the manifest actually assigned in the task.

- **Inline manifest.** Compute SHA-256 over the exact bytes obtained by Base64-decoding `Task.input.valueAttachment.data`. The Manager SHALL use the resulting `ni:///sha-256;` URI in each plan obligation. Encode the full digest in Base64url without padding, query or fragment, as specified for the Named Information URI in [RFC 6920](https://www.rfc-editor.org/rfc/rfc6920.html#section-3). The De-Identifier SHALL recompute the URI from the received bytes and compare it to the plan before accepting the task. The URI identifies the inline bytes and SHALL be used only for comparison. For an inline package, this check covers its inline members. Any separately retrieved content remains subject to the hosted input rules.
- **Hosted manifest.** The Manager SHALL use the exact HTTPS URL carried in `Task.input.valueAttachment.url` as each obligation's source. Before accepting the task, the De-Identifier SHALL check that the plan source equals that URL. The De-Identifier SHALL verify the retrieved manifest under the hosted input rules below before using it to resolve further content.

For each externally retrieved object required by the assignment, the Manager and De-Identifier SHALL use one of the following forms of content verification. The rule applies to a hosted manifest, FHIR resource, wrapper, index, attachment or bulk data file. It also applies when an inline or version-specific object in turn references a hosted object.

- **Trusted immutable locator.** The Manager and De-Identifier SHALL establish that the authorized service binds that locator to the exact selected version, for example a version-specific FHIR history URL or an immutable URL for a Manager-controlled snapshot. For a FHIR history read, the De-Identifier SHALL check that the resource type, logical ID and `meta.versionId` in the response match the reference. Any allowed redirect SHALL preserve the version guarantee. A URL without an established immutability guarantee requires a digest.
- **Expected digest in the plan.** The Manager SHALL include the exact request URL and the SHA-256 digest of the authorized bytes in [`dis:inputDigests`](odrl-content.html#execution-plan-set). The De-Identifier SHALL look up the digest by the original assigned URL and verify it over the received bytes after any HTTP content decoding. It SHALL compare the digest before parsing or reserializing the object. Any supplied digest SHALL be verified even when a locator is also immutable. The De-Identifier SHALL apply the existing retrieval authorization rules to the request and authorized redirects. The verified manifest and its authorized references determine retrieval, and a digest entry alone confers no retrieval authority.

The De-Identifier SHALL use the verified bytes or resource instance for subsequent resolution and transformation. It SHALL fail the task before applying transformations if any required input is missing, changed or cannot be verified. It SHALL return no partial result. The Manager SHALL withhold job output on task failure. Plan input identifiers and digests SHALL be confined to the assignment and protected like the source inputs. The job authorization remains with the Manager.

<div id="fhir-payload-binding"> </div>
<div id="fhir-payload-content-module"> </div>
<div id="3pxx1-dis-fhir-payload-content-module"> </div>
<div id="3pxx32-fhir-payload-binding"> </div>
<div id="3pxx42-fhir-payload-binding"> </div>
<div id="markdown-toc-3pxx42-fhir-payload-binding"> </div>

## 3:PXX.4.2 FHIR Payload Delivery

The `DIS-FHIR-Payload` format supports independently versioned FHIR R4 and R5 payloads over the FHIR R4 transaction protocol. Apply the [common delivery contract](#payload-set-delivery) and the release-specific rules for carrying, locating, and retrieving FHIR data.

<div id="3pxx111-version-identification"> </div>
<div id="3pxx3211-version-identification"> </div>
<div id="3pxx3211-fhir-release-and-capability-matching"> </div>
<div id="3pxx4211-fhir-release-identification"> </div>

### 3:PXX.4.2.1 FHIR Release Identification

For a FHIR set, the `payloadVersion` field declares the FHIR release of the processing payload. The De-ID Manager SHALL reject a request if the declaration is absent or specifies a release other than `R4` or `R5`. The Manager SHALL use the same declaration in ITI-x3. Source server capabilities and attachment metadata are used to check the declaration. The retrieving actor SHALL fail processing when the retrieved content or its version metadata conflicts with the declaration.

See [§3:PXX.4.2.2 FHIR Input and Result Delivery](volume-3-fhir-delivery.html) for the packaging and retrieval rules.

<div id="3pxx33-proposed-dicom-and-cda-bindings-informative"> </div>
<div id="3pxx43-proposed-dicom-and-cda-bindings-informative"> </div>
<div id="markdown-toc-3pxx43-proposed-dicom-and-cda-bindings-informative"> </div>

## 3:PXX.4.3 Proposed DICOM and CDA Delivery (Informative)

The [draft DICOM and CDA bindings](draft-native-payload-bindings.html) describe proposed delivery in the FHIR R4 envelope. Conformance to this supplement uses DIS-FHIR-Payload.

<div id="mixed-payload-walkthrough"> </div>

See the [experimental DICOM DPV Category Mapping](experimental-dicom-dpv-mapping.html) and the [mixed R5 and DICOM job walkthrough](draft-native-payload-bindings.html#illustrative-mixed-fhir-and-dicom-job).
