<div markdown="1" class="stu-note">
**Informative example.** This synthetic job uses the Phase 1 DIS-FHIR-Payload binding. The example URLs identify fixtures in the guide. The two policies illustrate field removal and do not establish suitability for release of real data.
</div>

One asynchronous job submits a hosted **R4 Patient** and an inline **R5 Encounter**. Each set uses its own policy and declared release. The Manager dispatches two synchronous tasks, then releases both results through the job polling URL. The R4 and R5 fixtures represent independent records. The example requires no patient linkage across sets.

<a name="grouped-fhir-submission"> </a>

## Submit the Job

Send the [ITI-x1 request](Task-grouped-fhir-job-request.html) to `POST /fhir/$submit-dis-job` with `Content-Type: application/fhir+json` and `Prefer: respond-async`. Its one authorization reference identifies the permit covering both sets and their policy versions. The [hosted artifact collection](Bundle-grouped-fhir-hosted-artifacts.html) shows the permit, R4 source and result Lists, R4 Patient resources, and both policies and plans at their example locations. The collection is a reference for readers. The Requester sends the Job Task directly as the ITI-x1 request body.

| Set | Manifest and payload | Approved policy |
|-----|----------------------|-----------------|
| `patient-r4` | A versioned HTTPS List selects a specific version of an R4 Patient. | Syntax-Level R4 policy removes `Patient.name`. |
| `encounter-r5` | An [inline R4 manifest package](Bundle-grouped-fhir-r5-input.html) contains a List and a wrapper whose attachment carries the serialized R5 Encounter. | Syntax-Level R5 policy removes `Encounter.subject`. |
{: .grid}

The Manager verifies the permit, resolves and validates both policies, and establishes the authorized target sets. On acceptance, it returns `202 Accepted` with `Content-Location: https://dis.example.org/jobs/job-51`. See [ITI-x1](volume-2.html#23x1-submit-de-identification-job-iti-x1).

<a name="grouped-fhir-dispatch"> </a>

## Dispatch and Complete the Tasks

Send each task to `POST /fhir/$submit-dis-task`. The task request carries one payload set and a reference to the execution plan for its declared release. Both tasks use irreversible removal. The Manager uses a version-specific reference for the hosted Patient and preserves the exact submitted Encounter bytes in the inline package.

| Set | ITI-x3 request | ITI-x3 success response | Evidence target |
|-----|----------------|-------------------------|-----------------|
| `patient-r4` | [R4 task](Task-grouped-fhir-task-patient-r4.html) | [R4 task result](Parameters-grouped-fhir-task-result-patient-r4.html) | Literal reference to the versioned result Patient selected by the hosted result List. |
| `encounter-r5` | [R5 task](Task-grouped-fhir-task-encounter-r5.html) | [R5 task result](Parameters-grouped-fhir-task-result-encounter-r5.html) | Provenance inside the [result manifest package](Bundle-grouped-fhir-r5-output.html) targets the selected wrapper by its Bundle entry URL. |
{: .grid}

Both task responses use `200 OK` and include the corresponding `payloadResult` with R4 Provenance. The R5 result retains `actualPeriod` and `status: completed` after removal of `subject`. The result attachment still carries an R5 Encounter. See [FHIR R5 Encounter](https://hl7.org/fhir/R5/encounter.html) and [ITI-x3](volume-2.html#23x3-submit-de-identification-task-iti-x3).

<a name="grouped-fhir-release"> </a>

## Retrieve the Job Result

The Requester polls `GET https://dis.example.org/jobs/job-51` with authorized credentials. A poll before completion returns `202 Accepted` with no result body. After both task results pass validation, the Manager returns `200 OK` with the [ITI-x4 result](Parameters-grouped-fhir-job-result.html). The response contains one `payloadResult` per submitted set, with each set's manifest and evidence.

In the failure variant, the versioned Patient becomes inaccessible after acceptance. The Encounter task may already have succeeded. The Manager fails the job and returns the [example OperationOutcome](OperationOutcome-grouped-fhir-job-failure.html) with HTTP 422 on the next authorized poll. Both result sets are withheld. See [ITI-x4](volume-2.html#23x4-retrieve-job-output-iti-x4).
