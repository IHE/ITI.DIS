<div markdown="1" class="stu-note">
**Illustrative example only.** This walkthrough shows how the DIS workflow could be extended to de-identify payloads with different formats or syntaxes, such as HL7 FHIR and DICOM, within a single job. The current version of DIS does not formally define a DICOM payload option. The DICOM binding identifier, task, validation, and evidence in this example illustrate a proposed extension and carry no conformance requirements. See the [draft binding notes](draft-native-payload-bindings.html).
</div>

This draft walkthrough exercises ITI-x1, ITI-x3, and ITI-x4. The job is asynchronous and the two task exchanges are synchronous. The authorized recipient needs a clinical resource and an imaging set for separate analyses. Neither approved policy requires the recipient to join them by a shared pseudonym. The Manager uses `setId` to correlate work and results within the job. A `setId` identifies a payload set, rather than a patient.

The tables describe the R4 wire parameters. Each successful task and job response carries top-level `validationStatus = valid`. Example artifact URLs denote the contents described in the walkthrough.

<a name="job-submission"> </a>

## ITI-x1 Job Submission

The Requester sends `POST /fhir/$submit-dis-job` with `Content-Type: application/fhir+json` and `Prefer: respond-async`. The R4 `Parameters` carries `authorization.reference` pointing to `https://governance.example.org/fhir/DocumentReference/permit-42`. The permit covers the R5 Patient, the two selected DICOM instances, the policy and version for each set, and release to the Requester.

| Part of each `payload` group | Clinical set | Imaging set |
|--------------------------------|--------------|-------------|
| `setId.valueString` | `clinical` | `images` |
| `payloadBinding.valueCode` | `DIS-FHIR-Payload` | `DIS-DICOM1` |
| `payloadVersion.valueCode` | `R5` | `2026d` (illustrative DICOM edition code) |
| `policy.url.valueUri` | `https://governance.example.org/policies/fhir-research` | `https://governance.example.org/policies/dicom-research` |
| `policy.version.valueString` | `1.0` | `1.0` |
| `manifestFormat.valueCode` | `dis-resource-list` | `dis-resource-list` |
| `manifest.valueAttachment.contentType` | `application/fhir+json` | `application/fhir+json` |
| `manifest.valueAttachment.data` or `.url` | Base64-encoded R4 manifest package in `data` | `https://index.example.org/fhir/List/images-42/_history/1` in `url` |
{: .grid}

Use the [inline R5 package structure](volume-3.html#inline-r5-manifest-package) for the clinical set. In this walkthrough the inner attachment carries the UTF-8 JSON shown below, encoded as base64. The UUID in the List resolves to the R4 wrapper in the same package.

```json
{"resourceType":"Patient","id":"example","name":[{"family":"Sample"}],"active":true}
```

The imaging List references `https://index.example.org/fhir/ImagingStudy/study-42/_history/3`. That R4 study index selects one CT series and explicitly lists two instances. The index references `https://index.example.org/fhir/Endpoint/wado-42/_history/1` as its WADO-RS Endpoint. That Endpoint identifies the HTTPS service base `https://pacs.example.org/dicomweb`. The selected UID suffixes below are appended to the illustrative UID prefix `1.2.826.0.1.3680043.10.543.`.

| Selected DICOM item | UID suffix |
|---------------------|------------|
| Study | `1001` |
| Series | `1002` |
| SOP instance 1 | `1003` |
| SOP instance 2 | `1004` |
{: .grid}

The Manager resolves the permit and checks both policy assignments. It resolves the imaging List, index and applicable Endpoint using authorized access. It checks that the enumerated DICOM instances are within the approved scope. It preserves the submitted R5 bytes and the DICOM selection, including the resolved Endpoint and instance UIDs, in protected job state for task dispatch and retries. It checks that compatible De-Identifiers are available for both sets. On acceptance it returns an empty `202 Accepted` response with `Content-Location: https://dis.example.org/jobs/job-42`.

<a name="task-dispatch"> </a>

## ITI-x3 Task Dispatch and Execution

The Manager sends one `POST /fhir/$submit-dis-task` to the assigned De-Identifier for each set. This example uses one ruleSet per set. The R4 request carries one `payload` group with the corresponding `setId`, `payloadBinding`, `payloadVersion`, `manifestFormat`, and `manifest` fields. The separate `executionPlan`, `ruleSetId`, and `reversibilityMode` parameters identify the task instructions. Both policies select `irreversible` in this example.

| Task field | Clinical task | Imaging task |
|------------|---------------|--------------|
| `payload.setId.valueString` | `clinical` | `images` |
| `payload.manifest.valueAttachment` | Same inline manifest package and original R5 bytes | `url = https://index.example.org/fhir/List/images-42/_history/1`, with authorized access to the versioned study index and Endpoint and to the two assigned instances |
| `executionPlan.valueReference.reference` | `https://dis.example.org/fhir/Library/plan-clinical-42/_history/1` | `https://dis.example.org/fhir/Library/plan-images-42/_history/1` |
| `ruleSetId.valueString` | `clinical-direct-identifiers` | `imaging-confidentiality` |
{: .grid}

The clinical De-Identifier decodes the wrapper and checks that the payload is valid R5. It applies the approved `remove` rule to `Patient.name` and validates the resulting Patient as R5. The id `example` is synthetic and carries no patient identity. The result of this illustrative rule is:

```json
{"resourceType":"Patient","id":"example","active":true}
```

The imaging De-Identifier uses credentials accepted by the index server to read the versioned R4 resources. It obtains credentials accepted by the imaging endpoint for the separate WADO-RS requests. For each listed SOP instance it requests the native DICOM representation at `/studies/{studyUID}/series/{seriesUID}/instances/{instanceUID}`. It compares the returned Study, Series, and SOP Instance UIDs with the assigned selection. A retry uses the same two instance identifiers and does not expand to the whole study. For this example, the proposed plan calls for the DICOM Basic Application Level Confidentiality Profile with Clean Pixel Data and consistent replacement of the Study, Series and SOP Instance UIDs. The worker validates the two resulting instances, including their replacement UIDs, internal references and the selected pixel handling. See [DICOM PS3.15 Annex E](https://dicom.nema.org/medical/dicom/current/output/chtml/part15/chapter_E.html). Output UID suffixes are `2001` for the study, `2002` for the series and `2003` and `2004` for the instances.

<a name="results-and-release"> </a>

## ITI-x3 Task Results and ITI-x4 Release

Each successful synchronous task returns `200 OK` with one R4 `payloadResult` group and `validationStatus.valueCode = valid`. Each group repeats its dispatched set identifier, binding and version and uses `manifestFormat.valueCode = dis-resource-list`. Each `resultPackage` carries R4 Provenance alongside its result manifest.

| Result field | Clinical task | Imaging task |
|--------------|---------------|--------------|
| `payloadResult.resultPackage.valueAttachment` | Inline R4 Bundle whose List selects the wrapper with the de-identified R5 Patient bytes | R4 Bundle containing a List that selects the hosted result ImagingStudy and Provenance targeting that ImagingStudy |
| `Provenance.target` | Bundled `target.reference` equals the `fullUrl` of the selected R4 wrapper | Draft mapping using `target.reference = https://results.example.org/fhir/ImagingStudy/images-result-42/_history/1`. The index enumerates the exact DICOM outputs |
{: .grid}

For each evidence resource, `Provenance.id` identifies the record and `activity` codes the DIS task. `target` uses the mapping in the table. `policy` identifies the approved policy version. The DIS outcome, ruleSet, reversibility, and validation extensions carry `complete`, the dispatched `ruleSetId`, `irreversible`, and `valid` respectively. The audit correlation identifier links the record to the task's audit event. The worker also supplies `recorded` and the performer agent under the [evidence baseline](volume-3.html#3pxx4-de-identification-evidence).

The Manager correlates both results by `setId` and checks that the result manifests, objects, and evidence agree. It keeps the hosted imaging output accessible only to authorized processing actors until the job is ready to release. Once both sets pass, the Requester polls `GET https://dis.example.org/jobs/job-42` with authorized credentials. The Manager returns `200 OK` with both `payloadResult` groups in one R4 `Parameters` response. The Requester can decode the clinical result immediately and use its authorized access to retrieve the imaging result. The result index enumerates only the replacement UIDs, and the result manifests and evidence exclude source identifiers and protected transformation material.

<a name="failure-after-acceptance"> </a>

## Failure After Job Acceptance

Repeat the job with access to instance `1004` withdrawn after acceptance and before DICOM retrieval. The imaging worker can retrieve `1003` but cannot obtain the complete authorized set. Its ITI-x3 response is `500 Internal Server Error` with an `OperationOutcome` and no `payloadResult`. The clinical task may already have succeeded. The Manager marks the whole job failed and the next authorized ITI-x4 poll returns an error `OperationOutcome`. Neither the clinical result nor a partial imaging result is made available to the Requester.

<a name="cross-set-linkage"> </a>

## Cross-Set Linkage Follow-Up

The first walkthrough assumes independent result sets. A later example requiring a joint clinical and imaging analysis must define how the authorization approves a shared linkage scope, how the Manager assigns compatible pseudonymization instructions to both tasks, and how it validates linkage before release. The job-level correlation illustrated here does not supply that patient-level linkage.

## Hosted R5 Submission Variant

This ITI-x1 variant uses hosted manifests for both sets. The R5 wrapper locates the Patient through its attachment URL. The example DICOM edition is illustrative. The final DICOM option will declare its supported edition codes.

```json
{
  "resourceType": "Parameters",
  "parameter": [
    {
      "name": "authorization",
      "part": [
        {
          "name": "reference",
          "valueReference": {
            "reference": "https://governance.example.org/fhir/DocumentReference/permit-42"
          }
        }
      ]
    },
    {
      "name": "payload",
      "part": [
        { "name": "setId", "valueString": "clinical" },
        { "name": "payloadBinding", "valueCode": "DIS-FHIR-Payload" },
        { "name": "payloadVersion", "valueCode": "R5" },
        { "name": "manifestFormat", "valueCode": "dis-resource-list" },
        {
          "name": "manifest",
          "valueAttachment": {
            "contentType": "application/fhir+json",
            "url": "https://index.example.org/fhir/List/clinical-42/_history/1"
          }
        },
        {
          "name": "policy",
          "part": [
            { "name": "url", "valueUri": "https://governance.example.org/policies/fhir-research" },
            { "name": "version", "valueString": "1.0" }
          ]
        }
      ]
    },
    {
      "name": "payload",
      "part": [
        { "name": "setId", "valueString": "images" },
        { "name": "payloadBinding", "valueCode": "DIS-DICOM1" },
        { "name": "payloadVersion", "valueCode": "2026d" },
        { "name": "manifestFormat", "valueCode": "dis-resource-list" },
        {
          "name": "manifest",
          "valueAttachment": {
            "contentType": "application/fhir+json",
            "url": "https://index.example.org/fhir/List/images-42/_history/1"
          }
        },
        {
          "name": "policy",
          "part": [
            { "name": "url", "valueUri": "https://governance.example.org/policies/dicom-research" },
            { "name": "version", "valueString": "1.0" }
          ]
        }
      ]
    }
  ]
}
```

The clinical List references an R4 DIS Payload Wrapper whose attachment URL retrieves the R5 Patient. The DICOM List returned by its manifest URL has this form. Its entry resolves to a profiled R4 ImagingStudy. The study index enumerates the exact SOP instances to retrieve from the imaging service.

```json
{
  "resourceType": "List",
  "id": "images-42",
  "meta": {
    "versionId": "1",
    "profile": ["https://profiles.ihe.net/ITI/DIS/StructureDefinition/DIS-ResourceManifest"]
  },
  "status": "current",
  "mode": "snapshot",
  "entry": [
    {
      "item": {
        "reference": "https://index.example.org/fhir/ImagingStudy/study-42/_history/3"
      }
    }
  ]
}
```

The Manager validates both assignments against the permit. It dispatches the FHIR and DICOM work with separate execution plans and correlates the results using `clinical` and `images`. Once both sets pass validation, the job response has one `payloadResult` group for each of those identifiers.

<a name="offline-feasibility-check"> </a>

## Offline Feasibility Check

This check uses synthetic data for the mixed job. The imaging fixtures are DICOM Part 10 files using CT Image Storage and Explicit VR Little Endian. The source and result fixtures use separate study, series, and instance identifiers. The source inventory also includes a third instance outside the permitted selection. The walkthrough's confidentiality policy is illustrative. The check uses prepared expected results. [DICOM CT Image Storage SOP Class](https://dicom.nema.org/medical/dicom/current/output/chtml/part04/sect_B.5.html)

| Check | Observed result |
|------|-----------------|
| Job and task packaging | The R4 ITI-x1 and ITI-x3 examples match the generated OperationDefinition parameter names, value types, and cardinalities checked by the fixture. The clinical task carries the same R5 payload bytes. |
| Imaging selection | The versioned List and ImagingStudy resolve to the same two authorized SOP Instance UIDs on both passes. The check reads the selected files from offline WADO-RS multipart response fixtures. It excludes the third instance and rejects a response containing the other selected instance in place of the requested one. |
| Result and evidence resolution | The clinical evidence identifies the bundled R4 wrapper. The imaging evidence references the R4 result index, which resolves to exactly two Part 10 files with the expected replacement UIDs. |
| Failed-job response | With one required input unavailable, the failed ITI-x4 fixture contains only an OperationOutcome. A counterexample that returns only the clinical result fails the release check. |
{: .grid}

The check establishes that the draft envelope and manifest can describe this mixed exchange. Live authentication, actor interoperability, full FHIR and DICOM instance validation, and execution of the DICOM confidentiality profile remain separate verification activities.
