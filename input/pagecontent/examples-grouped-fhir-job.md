<div markdown="1" class="stu-note">
**Informative example.** This synthetic job illustrates [UC-2 FHIR Input Preparation for Multimodal AI/ML](volume-1.html#uc-2). The job is asynchronous and each worker task is synchronous. The two policies demonstrate selected field removals. Release of real data requires a policy appropriate to the approved use and the identifying content in the input.
</div>

The cohort job has two payload sets. One contains **R4 clinical records and laboratory results** and the other contains **R5 CT-derived measurements**. The walkthrough uses a hosted Patient and a linked lab result as sample records for the first set and an inline CT measurement for the second set. Each set uses its own policy and declared FHIR version. The permit authorizes independent analysis of the CT measurements. The [illustrative FHIR and DICOM extension](draft-native-payload-bindings.html#illustrative-mixed-fhir-and-dicom-job) shows how a separate payload set could carry native CT images. The Job Task, Execution Tasks, Parameters, manifests, wrappers, and Provenance all use R4.

<a name="grouped-fhir-submission"> </a>

## Submit the Job

Send the [ITI-x1 request](Task-grouped-fhir-job-request.html) to `POST /fhir/$submit-dis-job` with `Content-Type: application/fhir+json` and `Prefer: respond-async`. Its one authorization reference identifies the permit covering both sets and their policy versions. The [hosted artifact collection](Bundle-grouped-fhir-hosted-artifacts.html) shows the permit, R4 source and result Lists, and R4 clinical resources at their example locations. The Requester sends the Job Task directly as the ITI-x1 request body.

### Payload Sets and Approved Policies

Each Job Task input names the versioned policy approved for that set. The hosted artifact collection includes both policy Libraries and the plans derived from them. Both policies use irreversible processing.

| Set | Manifest and payload | Approved policy |
|-----|----------------------|-----------------|
| `patient-r4` | A versioned HTTPS List selects specific versions of an R4 Patient and a linked hemoglobin Observation. | Syntax-Level policy `patient-name-removal` version `1.0` removes `Patient.name` in R4. |
| `imaging-measurement-r5` | An [inline R4 manifest package](Bundle-grouped-fhir-r5-input.html) contains a List and a wrapper whose attachment carries the serialized R5 Observation. | Syntax-Level policy `imaging-subject-removal` version `1.0` removes `Observation.subject` in R5. |
{: .grid}

The Manager verifies the permit, resolves and validates both policies, and establishes the authorized target sets. On acceptance, it returns `202 Accepted` with `Content-Location: https://dis.example.org/jobs/job-51`. If the acceptance response is lost, the Requester repeats the original request bytes and processing selections with `DIS-Submission: recover`. The Manager returns the same polling URL with `DIS-Submission: replayed`, and the job runs once. See [ITI-x1](volume-2.html#23x1-submit-de-identification-job-iti-x1) and the [recovery rules](volume-2.html#submission-retries).

<a name="grouped-fhir-dispatch"> </a>

## Dispatch and Complete the Tasks

Send each task to `POST /fhir/$submit-dis-task`. The task request carries one payload set and a reference to the execution plan for its declared release. Both tasks use irreversible removal. The Manager pins the versions of both hosted R4 resources and preserves the exact submitted R5 bytes in the inline package. It records both assignments under the job. The sample permit authorizes the assigned R4 worker to receive an opaque parent identifier in `Task.partOf.identifier`. The R5 task omits it. Each worker can execute its assignment using the supplied inputs. See [assignment correlation and disclosure](volume-2.html#assignment-correlation).

| Set | ITI-x3 request | ITI-x3 success response | Evidence targets |
|-----|----------------|-------------------------|------------------|
| `patient-r4` | [Execution Task for the R4 clinical set](Task-grouped-fhir-task-patient-r4.html) | [R4 Parameters result](Parameters-grouped-fhir-task-result-patient-r4.html) | Versioned HTTPS references to the result Patient and hemoglobin Observation selected by the hosted result List. |
| `imaging-measurement-r5` | [Execution Task for the R5 imaging measurement](Task-grouped-fhir-task-imaging-measurement-r5.html) | [R4 Parameters result](Parameters-grouped-fhir-task-result-imaging-measurement-r5.html) | Provenance in the [result package](Bundle-grouped-fhir-r5-output.html) targets the selected R4 wrapper by its Bundle entry URL. |
{: .grid}

Both synchronous task responses use `200 OK` and include the corresponding `payloadResult` with R4 Provenance. In the sample R4 records, a hemoglobin result of 12.4 g/dL remains linked to the de-identified Patient. In the sample R5 record, a CT lesion diameter of 28 mm is retained and the source patient reference is removed. The wrapper attachment still carries an [R5 Observation](https://hl7.org/fhir/R5/observation.html). See [ITI-x3](volume-2.html#23x3-submit-de-identification-task-iti-x3).

<a name="grouped-fhir-release"> </a>

## Retrieve the Job Result

The Requester polls `GET https://dis.example.org/jobs/job-51` with authorized credentials. A poll before completion returns `202 Accepted` with no result body. After both task results pass validation and the Manager rechecks release authorization, it returns `200 OK` with the [ITI-x4 result](Parameters-grouped-fhir-job-result.html). The response contains one `payloadResult` per submitted set, with each set's manifest and evidence. The Requester delivers both approved FHIR sets to the Secure Processing Environment outside DIS.

In the failure variant, the versioned Patient becomes inaccessible after acceptance. The imaging measurement task may already have succeeded. The Manager fails the job and returns the [example OperationOutcome](OperationOutcome-grouped-fhir-job-failure.html) with HTTP 422 on the next authorized poll. Both result sets are withheld. See [ITI-x4](volume-2.html#23x4-retrieve-job-output-iti-x4).
