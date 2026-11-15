<a name="payload-bindings"> </a>

<a name="3pxx3-payload-bindings"> </a>

<a name="3pxx4-payload-bindings"> </a>

DIS uses HL7 FHIR R4 protocol resources. The selected payload binding determines the native format and version and how content is carried or resolved through the protocol. The common delivery contract applies to every payload set. The FHIR binding specifies the supported payload content.

<a name="payload-binding-framework"> </a>

<a name="payload-binding-requirements"> </a>

**Payload binding requirements.**

A payload binding defines how DIS applies to a particular format. It specifies the content model and element addressing, the mapping of DIS actions to that format, how to obtain inputs and deliver results, how to represent evidence, how to identify and validate versions and match capabilities, and how to carry or reference the data in the FHIR R4 workflow envelope. Each additional binding defines these requirements independently. The [draft DICOM and CDA bindings](draft-native-payload-bindings.html) illustrate this structure.

<a name="payload-set-delivery"> </a>

<a name="3pxx3-common-payload-set-delivery"> </a>

<a name="3pxx31-common-payload-set-delivery"> </a>

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

A job contains one or more payload sets. The same payload-set encoding applies to a single-set job. Each set uses one binding and version and carries one manifest at each exchange. Successful responses carry the manifest and evidence together in a result package. The manifest can select bundled and externally hosted content. A job can combine, for example, an inline R5 Patient and a set of separately hosted FHIR Observations. The FHIR R4 envelope carries the delivery description. The selected binding defines the native data, retrieval rules, execution plan, validation, and evidence mapping.

The [shared payload set parameters](volume-2.html#grouped-payload-parameters) define how the transactions carry a payload set.

<a name="3pxx31-manifest-formats"> </a>

<a name="3pxx311-manifest-formats"> </a>

<a name="3pxx311-manifest-formats-and-packages"> </a>

### 3:PXX.4.1.1 Manifest Formats and Packages

The `dis-resource-list` format carries an R4 DIS Resource Manifest as a standalone List or in an R4 [DIS Manifest Package](StructureDefinition-DIS-ManifestPackage.html). Serialize either as FHIR JSON or XML and declare the corresponding FHIR media type in the `manifest` attachment. These forms apply to inputs. Results carry the List inside the result package.

The `fhir-bulk-data` format uses the JSON [bulk file manifest](volume-3-fhir-delivery.html#3pxx3224-bulk-file-manifests-and-authorized-retrieval) of DIS-FHIR-Payload. It enumerates NDJSON files.

<a name="manifest-package"> </a>

Use an R4 `Bundle` of type `collection` when the manifest and its targets or indexes travel together. It SHALL contain exactly one List declaring the DIS Resource Manifest profile. Each entry in that List SHALL use either an absolute HTTPS FHIR REST reference allowed by the selected payload binding or a `urn:uuid` reference matching exactly one `Bundle.entry.fullUrl` in the same package. A standalone List SHALL use absolute HTTPS references. Only the List's selected entries determine the payload set. Other Bundle entries may support resolution under the selected binding.

A bundled R4 resource can be the target itself or a wrapper or index. Any non-R4 payload bytes included in the package SHALL be carried inside the attachment of an R4 resource. Each Bundle entry SHALL be an R4 resource.

<a name="3pxx32-authorization-and-stable-retrieval"> </a>

<a name="3pxx312-authorization-and-stable-retrieval"> </a>

### 3:PXX.4.1.2 Authorization and Stable Retrieval

The Manager SHALL verify that the job authorization covers every set, including the indexes, native objects, or files reached through its references or manifests. The retrieving actor SHALL use HTTPS and obtain credentials accepted by each endpoint. For automated FHIR REST retrieval of manifests, indexes, or payloads, apply the [FHIR retrieval authorization rules](volume-3-fhir-delivery.html#referenced-input-authorization). Other bindings define the access mechanism for their endpoints. The job authorization and credentials for reading the source serve separate purposes.

The Manager SHALL establish the authorized target set before dispatch, including any expansion of references. For ITI-x3 it SHALL bind the assigned manifest and every required input to the plan under the [assigned input verification rules](#assigned-input-verification). The Integrated actor SHALL verify the same authorized input versions for local execution. Each retry SHALL use the same authorized inputs and compiled plan version. A changed input or plan that cannot be resolved to the pinned version SHALL cause task or job failure. When publishing results by reference or manifest, the producing actor SHALL ensure the locators resolve to the intended de-identified objects and are accessible only to authorized recipients. A failed or inaccessible required set SHALL cause job failure without release of any set to the Requester.

<a name="assigned-input-verification"> </a>

<a name="3pxx313-assigned-input-verification"> </a>

### 3:PXX.4.1.3 Assigned Input Verification

The De-ID Manager SHALL establish the exact versions of the manifest and the resources, wrappers, indexes and files needed to resolve and process the assigned set. It SHALL authorize the selected content and bind those versions to the execution plan before dispatch. For a later stage, bind the authorized input to that stage's plan, including any verified output from an earlier stage that supplies its input.

The plan's [target source IRI](odrl-content.html#execution-plan-set) identifies the manifest actually assigned in the task.

- **Inline manifest.** Compute SHA-256 over the exact bytes obtained by Base64-decoding `Task.input.valueAttachment.data`. The Manager SHALL use the resulting `ni:///sha-256;` URI in each plan obligation. Encode the full digest in Base64url without padding, query or fragment, as specified for the Named Information URI in [RFC 6920](https://www.rfc-editor.org/rfc/rfc6920.html#section-3). The De-Identifier SHALL recompute the URI from the received bytes and compare it to the plan before accepting the task. The URI identifies the inline bytes and SHALL be used only for comparison. For an inline package, this check covers its inline members. Any separately retrieved content remains subject to the hosted input rules.
- **Hosted manifest.** The Manager SHALL use the exact HTTPS URL carried in `Task.input.valueAttachment.url` as each obligation's source. Before accepting the task, the De-Identifier SHALL check that the plan source equals that URL. The De-Identifier SHALL verify the retrieved manifest under the hosted input rules below before using it to resolve further content.

For each externally retrieved object required by the assignment, the Manager and De-Identifier SHALL use one of the following forms of content verification. The rule applies to a hosted manifest, FHIR resource, wrapper, index, attachment or bulk data file. It also applies when an inline or version-specific object in turn references a hosted object.

- **Trusted immutable locator.** The Manager and De-Identifier SHALL establish that the authorized service binds that locator to the exact selected version, for example a version-specific FHIR history URL or an immutable URL for a Manager-controlled snapshot. For a FHIR history read, the De-Identifier SHALL check that the resource type, logical ID and `meta.versionId` in the response match the reference. Any allowed redirect SHALL preserve the version guarantee. A URL without an established immutability guarantee requires a digest.
- **Expected digest in the plan.** The Manager SHALL include the exact request URL and the SHA-256 digest of the authorized bytes in [`dis:inputDigests`](odrl-content.html#execution-plan-set). The De-Identifier SHALL look up the digest by the original assigned URL and verify it over the received bytes after any HTTP content decoding. It SHALL compare the digest before parsing or reserializing the object. Any supplied digest SHALL be verified even when a locator is also immutable. The De-Identifier SHALL apply the existing retrieval authorization rules to the request and authorized redirects. The verified manifest and its authorized references determine retrieval, and a digest entry alone confers no retrieval authority.

The De-Identifier SHALL use the verified bytes or resource instance for subsequent resolution and transformation. It SHALL fail the task before applying transformations if any required input is missing, changed or cannot be verified. It SHALL return no partial result. The Manager SHALL withhold job output on task failure. Plan input identifiers and digests SHALL be confined to the assignment and protected like the source inputs. The job authorization remains with the Manager.

<a name="fhir-payload-binding"> </a>

<a name="fhir-payload-content-module"> </a>

<a name="3pxx1-dis-fhir-payload-content-module"> </a>

<a name="3pxx32-fhir-payload-binding"> </a>

## 3:PXX.4.2 FHIR Payload Binding

The FHIR payload binding (`DIS-FHIR-Payload`) defines how actors identify, carry, retrieve, address, and validate FHIR processing payloads. The [execution plan](volume-3-execution-plan.html#execution-plan-content) and [evidence](volume-3-evidence.html#evidence-baseline) sections define the associated task and result artifacts.

DIS-FHIR-Payload is independent of the DIS HL7 FHIR R4 protocol binding version. It supports HL7 FHIR R4 and R5 processing payloads over the same R4 protocol binding through version identification, version-safe packaging, and version-neutral element addressing.

The [FHIRPath specification](https://hl7.org/fhirpath/) defines the addressing language. The [FHIR R4 DPV category mapping](volume-3.html#fhir-r4-dpv-mapping) defines the selectors for DPV–ODRL policies. The [common delivery contract](#payload-set-delivery) defines the manifest and package used in each exchange.

- [FHIR Addressing and Processing](volume-3-fhir-addressing.html)
- [FHIR Input and Result Delivery](volume-3-fhir-delivery.html)

<a name="3pxx33-proposed-dicom-and-cda-bindings-informative"> </a>

## 3:PXX.4.3 Proposed DICOM and CDA Bindings (Informative)

The [draft DICOM and CDA bindings](draft-native-payload-bindings.html) describe proposed mappings to the FHIR R4 envelope. Conformance to this supplement uses DIS-FHIR-Payload.

<a name="mixed-payload-walkthrough"> </a>

See the [informative DPV–DICOM crosswalk](draft-native-payload-bindings.html#dicom-crosswalk-informative) and the [mixed R5 and DICOM job walkthrough](draft-native-payload-bindings.html#illustrative-mixed-fhir-and-dicom-job).
