<div markdown="1" class="stu-note">
**Informative example.** The Patient, authorization, signing key, endpoints, and test salt are synthetic.
</div>

A Requester submits one R4 Patient in payload set `staged-patient-r4`. The Manager assigns two asynchronous tasks to separate De-Identifiers. The preliminary worker replaces the source identifier and removes the name. The advanced worker receives only the validated intermediate Patient and reduces the birth date to its year.

### Submit and Recover the Job

Send the [Job Task](Task-staged-async-job.html) to `POST https://dis.example.org/fhir/$submit-dis-job` with `Content-Type: application/fhir+json` and `Prefer: respond-async`. The Task carries one synthetic authorization attachment and an inline manifest. Its `policyContent` reference resolves to a contained `application/jose` Binary. Decode `Binary.data` to obtain the compact JWS. The signed payload bytes are the [approved Library](Library-staged-patient.html). The Manager independently knows the authorized Library version and the URI to use in evidence.

The Manager verifies the signature with this synthetic trusted public JWK and validates the policy and authorization before accepting the job.

```json
{
  "kty": "RSA",
  "n": "oHXF9bxYCyY9TVgJjOpydUdQI2Yz87zstBlbX8OBTv5vQIdRuKiIrG2zsZZ3Iheqx_jDY3CtUlsSsnzOV7lY0iQCk-zkI_pvO4LKynmQakvI6V89NL8pBFGSfIk8evFz6_za5cRZEIK19rwds4hep4EMtO0m265LMA31IHJ3NTzI9obGvRbG6dCCIRf_Azc3Jj7J84ZFG-ZnfPQSPXZ_x4ceKm56F92F1JKnyBjfugmzsfP9Y89osykazSfGdL2_gcU5XQ62QcafwwPMjV3pEMT1gO4ULUCRtO4gmT2AnVZAy5vEXX-gzDtwT0o4Ttfko-O-x817kpKhMeuEbAP2ew",
  "e": "AQAB",
  "kid": "dis-staged-example",
  "alg": "RS256",
  "use": "sig"
}
```

The Manager returns `202 Accepted` with an empty body and `Content-Location: https://dis.example.org/jobs/staged-async-job`. If that response is lost, the Requester sends the exact original Task bytes and processing selections to the same operation, adding `DIS-Submission: recover`. The Manager returns the same URL with `DIS-Submission: replayed` and starts no second job. An authorized GET of the job URL while the job is running returns 202 without results.

### Dispatch and Poll Each Stage

For each row, the Manager submits the Execution Task to the assigned worker's `POST [base]/$submit-dis-task` with `Prefer: respond-async`. Each worker returns 202 with an empty body and its own polling URL. The Manager retrieves the task status and results through authorized ITI-x7 GET requests.

To reproduce the preliminary Patient's pseudonym, use the source identifier pair from the Job Task, the linkage scope from the signed policy, and the 16 public test salt bytes `000102030405060708090a0b0c0d0e0f` in the [patient identifier derivation](volume-3.html#3pxx123-baseline-patient-pseudonym-derivation). The advanced task preserves that pseudonym.

| Stage | ITI-x3 work order | ITI-x7 successful poll | Manager check |
|---|---|---|---|
| Preliminary | [Execution Task](Task-staged-async-preliminary-task.html) and its [versioned plan](Library-staged-async-preliminary-plan.html) | HTTP 200 and [preliminary result](Parameters-staged-async-preliminary-result.html) | Verify the result and the worker's Provenance. The intermediate Patient has the scoped pseudonym and no name. Its birth date remains `1985-07-16`. |
| Advanced | [Execution Task](Task-staged-async-advanced-task.html) and its [versioned plan](Library-staged-async-advanced-plan.html) | HTTP 200 and [advanced result](Parameters-staged-async-advanced-result.html) | The Task selects the Patient validated in the preliminary stage. Verify the advanced worker's Provenance, the unchanged pseudonym and birth year `1985`. |
{: .grid}

If the advanced worker's 202 response is lost, the Manager can send a recovery-only ITI-x3 request. It uses the original assignment identifier and bytes and recovers the original worker polling URL. The advanced assignment runs once.

### Retrieve and Verify Release

After validating both stages and confirming release authorization, the Manager returns HTTP 200 with the [job result](Parameters-staged-async-job-result.html) on an authorized ITI-x4 poll. The result preserves the set ID and carries the [final R4 result package](Bundle-staged-r4-patient-result.html). The package includes Provenance from the advanced worker and a separate Manager staged release Provenance recording both validated stages in policy order. The Requester checks these records against the approved policy before using the final Patient.

If the preliminary task fails, the Manager stops stage progression. If the advanced task fails, the Manager withholds all output, including the preliminary result. The next authorized job poll returns 422 with an OperationOutcome. See the [retry contract](volume-2.html#submission-retries) and [staged release evidence requirements](volume-3.html#staged-release-evidence).
