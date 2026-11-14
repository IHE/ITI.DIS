<div markdown="1" class="stu-note">
**Informative example.** This synthetic job illustrates [UC-2 FHIR Input Preparation for Multimodal AI/ML](volume-1.html#uc-2). The job is asynchronous and each worker task is synchronous. The two policies demonstrate selected field removals. Release of real data requires a policy appropriate to the approved use and the identifying content in the input.
</div>

The cohort job has two payload sets. One contains **R4 clinical records and laboratory results** and the other contains a **hosted R5 CT diagnostic report**. Each set uses its own policy and declared FHIR release. The permit authorizes independent analysis of the report. The [illustrative FHIR and DICOM extension](draft-native-payload-bindings.html#illustrative-mixed-fhir-and-dicom-job) shows how a separate payload set could carry native CT images. The job and task submissions, result Parameters, manifests, and Provenance use FHIR R4.

<a name="grouped-fhir-submission"> </a>

## Submit the Job

Send the [ITI-x1 request](Task-grouped-fhir-job-request.html) to `POST /fhir/$submit-dis-job` with `Content-Type: application/fhir+json` and `Prefer: respond-async`. Its one version-specific authorization reference identifies the ODRL Agreement covering both sets. Each payload set carries the matching permission IRI and requested purpose. See the [decoded ODRL Agreement](odrl-content.html#decoded-authorization-example). Both permissions classify the approved project under ISO/TS 14265:2024 code `4.2`. The job continues to identify the project by its specific purpose IRI. The [hosted artifact collection](Bundle-grouped-fhir-hosted-artifacts.html) shows the permit, R4 manifests for both releases and the R4 clinical resources at their example locations. The Requester sends the R4 `Task` directly as the ITI-x1 request body.

The [UC-2 Data Request Authorization Contract](Contract-grouped-fhir-authorization-contract.html) carries the complete Agreement in its inline rule attachment. The de-identification job references this exact Contract version and selects one permission for each payload set. Each term shows its own approved policy version.

### Payload Sets and Approved Policies

Each payload-set input in the job submission names the versioned policy approved for that set. The hosted artifact collection includes both policy Libraries and the plans derived from them. Both policies use irreversible processing. See the [decoded Policy Set for the R4 clinical set](odrl-content.html#decoded-policy-example).

| Set | Manifest and payload | Approved policy |
|-----|----------------------|-----------------|
| `patient-r4` | A versioned HTTPS List selects specific versions of an R4 Patient and a linked hemoglobin Observation. | Semantic-Level policy `patient-name-removal` version `1.0` removes `@subject-names`. The Manager compiles the group to `Patient.name` for R4. |
| `imaging-report-r5` | A versioned R4 List uses the DIS Target FHIR Release extension to select the [hosted R5 DiagnosticReport](examples/grouped-fhir/grouped-fhir-report-input.json). | Syntax-Level policy `imaging-report-subject-removal` version `1.0` removes `DiagnosticReport.subject` in R5. |
{: .grid}

The Manager verifies the permit, resolves and validates both policies, and establishes the authorized target sets. On acceptance, it returns `202 Accepted` with `Content-Location: https://dis.example.org/jobs/job-51`. If the acceptance response is lost, the Requester repeats the original request bytes and processing selections with `DIS-Submission: recover`. The Manager returns the same polling URL with `DIS-Submission: replayed`, and the job runs once. See [ITI-x1](volume-2.html#23x1-submit-de-identification-job-iti-x1) and the [recovery rules](volume-2.html#submission-retries).

<a name="grouped-fhir-dispatch"> </a>

## Dispatch and Complete the Tasks

Send each task to `POST /fhir/$submit-dis-task`. The task request carries one payload set and a reference to the execution plan for its declared release. Both tasks use irreversible removal. See the [decoded Execution Plan Set for the R4 clinical task](odrl-content.html#decoded-plan-example). The Manager pins the two hosted R4 resources and the hosted R5 report to the revisions identified by their Lists. It records both assignments under the job. The sample permit authorizes the assigned R4 worker to receive an opaque parent identifier in `Task.partOf.identifier`. The R5 task omits it. Each worker can execute its assignment using the supplied inputs. See [assignment correlation and disclosure](volume-2.html#assignment-correlation).

| Set | ITI-x3 request | ITI-x3 success response | Evidence targets |
|-----|----------------|-------------------------|------------------|
| `patient-r4` | [Task submission for the R4 clinical set](Task-grouped-fhir-task-patient-r4.html) | [R4 Parameters result](Parameters-grouped-fhir-task-result-patient-r4.html) | Versioned HTTPS references to the result Patient and hemoglobin Observation selected by the hosted result List. |
| `imaging-report-r5` | [Task submission for the R5 diagnostic report](Task-grouped-fhir-task-imaging-report-r5.html) | [R4 Parameters result](Parameters-grouped-fhir-task-result-imaging-report-r5.html) | Provenance in the [result package](Bundle-grouped-fhir-r5-output.html) and its R4 result List both use the same release-qualified reference to the [hosted R5 output report](examples/grouped-fhir/grouped-fhir-report-output.json). |
{: .grid}

Both synchronous task responses use `200 OK` and include the corresponding `payloadResult` with R4 Provenance. In the sample R4 records, a hemoglobin result of 12.4 g/dL remains linked to the de-identified Patient. The R5 report retains the 28 mm CT lesion finding in its conclusion. The policy removes the source patient reference. The Manager and Requester verify the hosted output by resolving the exact report revision identified in both the result List and Provenance. See [ITI-x3](volume-2.html#23x3-submit-de-identification-task-iti-x3).

The R5 worker retrieves the input report with a separate GET. The manifest itself is retrieved as R4. Both URLs in this illustration represent authorized endpoints.

```http
GET /fhir/r5/DiagnosticReport/grouped-fhir-report-input/_history/1
Host: source.example.org
Accept: application/fhir+json; fhirVersion=5.0
```

See the [direct hosted R5 retrieval rules](volume-3.html#direct-hosted-r5-references).

<a name="grouped-fhir-release"> </a>

## Retrieve the Job Result

The Requester polls `GET https://dis.example.org/jobs/job-51` with authorized credentials. A poll before completion returns `202 Accepted` with no result body. After both task results pass validation and the Manager rechecks release authorization, it returns `200 OK` with the [ITI-x4 result](Parameters-grouped-fhir-job-result.html). The response contains one `payloadResult` per submitted set, with each set's manifest and evidence. The Requester delivers both approved FHIR sets to the Secure Processing Environment outside DIS.

In the failure variant, the versioned Patient becomes inaccessible after acceptance. The diagnostic report task may already have succeeded. The Manager fails the job and returns the [example OperationOutcome](OperationOutcome-grouped-fhir-job-failure.html) with HTTP 422 on the next authorized poll. Both result sets are withheld. See [ITI-x4](volume-2.html#23x4-retrieve-job-output-iti-x4).

## Job Cancellation

If the Requester sends an authorized DELETE before either synchronous task is dispatched, the Manager can accept cancellation and prevent dispatch. While a synchronous task is outstanding, the same request receives HTTP 409 with an OperationOutcome and the job continues. After those tasks reach known terminal states, the Requester can try again while the job is still active. See [job cancellation](volume-2.html#job-cancellation).
