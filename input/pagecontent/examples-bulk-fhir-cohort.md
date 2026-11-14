<div markdown="1" class="stu-note">
**Informative example.** All data, URLs, and the test salt are synthetic. See [UC-1 Cross-Border Epidemiological Study](volume-1.html#1pxx421-use-case-1-cross-border-epidemiological-study-using-ips).
</div>

The Data Access Coordinator submits one asynchronous R4 job for an authorized research cohort. The [input manifest](examples/bulk-fhir/input-manifest.json) selects two prepared NDJSON files, [file 1](examples/bulk-fhir/input-patients-1.ndjson) and [file 2](examples/bulk-fhir/input-patients-2.ndjson), each containing one Patient. The source data have already been prepared and identity-resolved for the approved study scope.

## Approved Policy

The de-identification job references the [synthetic Data Request Authorization](DocumentReference-uc1-cohort-permit.html) and selects the permission that binds its set to the approved policy version.

The job submission declares `https://governance.example.org/policies/uc1-bulk-cohort|1.0`. The Manager resolves this [approved R4 Syntax-Level policy](Library-uc1-bulk-cohort-policy.html) through its trusted policy store and validates it against the authorization.

| Stage | Assigned ruleSet | Result |
|---|---|---|
| `preliminary` | `pseudonymize-patient` | Replace `Patient.identifier` with an irreversible salted pseudonym and remove `Patient.name`. The effective salt and approved project scope are consistent for matching source identifier pairs. |
| `advanced` | `generalize-birth-date` | Reduce `Patient.birthDate` to year precision. Preserve the pseudonyms. |
{: .grid}

To reproduce the sample output, use the source identifier pairs in the input files, the scope in the approved Library, and the 16 public test bytes `000102030405060708090a0b0c0d0e0f` in the [patient identifier derivation](volume-3.html#3pxx123-baseline-patient-pseudonym-derivation).

## Submit, Dispatch, and Retrieve

| Step | Exchange | What to verify |
|---|---|---|
| 1 | The Requester sends ITI-x1 with `Prefer: respond-async`. The [FHIR R4 `Task` for the job](Task-uc1-bulk-cohort-job.html) carries authorization and one input with `setId = cohort-r4`, `payloadBinding = DIS-FHIR-Payload`, `payloadVersion = R4`, and `manifestFormat = fhir-bulk-data`. The `application/json` attachment locates the input manifest. | The Manager validates the permit and policy before returning `202 Accepted` and the job polling URL in `Content-Location`. |
| 2 | The Manager sends ITI-x3 with `Prefer: respond-async`, the authorized `cohort-r4` set, the preliminary plan, its ruleSet and stage IDs, and `reversibility-mode = irreversible`. | The worker accepts with its own polling URL. The Manager polls that URL through ITI-x7 and validates the preliminary files and their evidence. The files contain pseudonyms and the original birth dates. |
| 3 | The Manager sends a second asynchronous ITI-x3 with the advanced plan, ruleSet and stage IDs. Its manifest selects the exact validated preliminary NDJSON files. | The Manager polls the advanced worker's URL through ITI-x7. The final files retain the pseudonyms and contain birth years. The Manager validates the final files and their evidence and rechecks release authorization. |
| 4 | The Requester polls the job URL through ITI-x4. A pending poll returns `202 Accepted`. The completed poll returns `200 OK` with the [R4 result Parameters](Parameters-bulk-r4-result.html). | The [result package](Bundle-bulk-r4-result.html) contains the [output manifest](examples/bulk-fhir/output-manifest.json), two file descriptors, the final worker's evidence, and the Manager's staged release Provenance. Both evidence records target the two final file descriptors. |
{: .grid}

The Requester verifies the policy URI and the stage order in the release record against the approved Library, then retrieves [output file 1](examples/bulk-fhir/output-patients-1.ndjson) and [output file 2](examples/bulk-fhir/output-patients-2.ndjson) using authorized access. The descriptors and manifest identify the exact file versions the Manager validated. The Requester delivers the cohort to the Secure Processing Environment outside DIS.

<a name="failure-and-optional-cancellation"> </a>

## Failure and Job Cancellation

If a required file becomes unavailable after acceptance, the Manager returns HTTP 422 with an OperationOutcome on the authorized job poll and withholds the cohort. The same applies when either stage fails.

For the cancellation variant, the Requester and Manager declare DIS-ASYNC-JOB. The Requester submits the job with `Prefer: respond-async`. The Manager and De-Identifiers declare DIS-ASYNC-TASK. The Manager submits each task with `Prefer: respond-async`, and each acceptance supplies a polling URL that also supports cancellation. If the Requester sends DELETE to the job URL while the preliminary task is running, the Manager stops new dispatch and requests cancellation at the worker's polling URL. While confirmation is pending, job polls report pending cancellation. After the Manager accounts for all assigned work, ITI-x4 reports the confirmed cancellation with HTTP 410 and withholds job output.
