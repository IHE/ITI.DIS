# Modeling de-id job and task using FHIR R4 Task

**Status** — Discussion draft for ITI.DIS review. The current Phase 1 transaction definitions remain the conformance baseline.

## Design

Use the FHIR operation to submit work, a profiled FHIR R4 `Task` to identify and describe the work order when actors need to exchange it, and `Parameters` to carry the work order, payload and result. FHIR R4 operations accept a resource as a named parameter. The R4 workflow resource is independent of the FHIR version of the processing payload. [FHIR R4 operations](https://hl7.org/fhir/R4/operations.html#exec) · [FHIR R4 Task](https://hl7.org/fhir/R4/task.html)

| Exchange | Proposed treatment |
| --- | --- |
| **ITI-x1 Submit De-Identification Job** · De-Identification Requester → De-ID Manager | Keep the current Phase 1 request. `Parameters` groups one or more payload sets with their approved policy identities and carries one data request authorization. The Manager may represent the overall job as an internal parent Task. If a later use case requires the Requester to exchange a job work order, consider one job-level `workItem` resource parameter alongside the existing authorization and payload groups. |
| **ITI-x3 Submit De-Identification Task** · De-ID Manager → De-Identifier | If DIS standardizes a shared work order, start here. Each dispatch assigns one ruleset for one payload set. Add a `workItem` resource parameter containing a profiled execution Task. Retain the system-level `$submit-dis-task` operation and the ITI-x7 polling interaction. |

[Current submission and polling transactions](../input/pagecontent/volume-2.md)

## Candidate ITI-x3 request binding

| Element | Candidate definition |
| --- | --- |
| `workItem` | One profiled R4 `Task`, carried as `Parameters.parameter.resource`. The Manager assigns a business identifier in `Task.identifier`, using `system` and `value` to identify the logical assignment. The submitted Task has `intent = order` and `status = requested`. |
| `Task.input` for `executionPlan` | One coded input with a `valueReference` to the existing DIS Execution Plan Library. Its source policy identity and evidence URI retain their existing meanings. |
| `Task.input` for `ruleSetId` | One coded input with a `valueString` identifying the ruleset that this assignment executes. |
| `Task.input` for `stageId` | A coded input with a `valueString`, present when the source policy declares staged execution. |
| `payload` | The existing required group for one assigned payload set, including `setId`, binding, version and manifest. |
| `lookupTable` | The existing conditional, protected reference to the lookup document scoped to the assignment. |
| `reversibilityMode` | The existing required top-level parameter derived from the approved policy. |

The three coded Task inputs replace their equivalent top-level parameters in this candidate binding. The operation and Task profile would define one authoritative location per field. The submitted status means the Manager is requesting execution. The De-Identifier makes its acceptance decision after its existing checks. HL7 CDex provides a precedent for `intent = order` and `status = requested` in a Task-based data request. [FHIR R4 Task inputs](https://hl7.org/fhir/R4/task-definitions.html#Task.input) · [FHIR R4 Task statuses](https://hl7.org/fhir/R4/codesystem-task-status.html) · [HL7 CDex Task-based exchange](https://hl7.org/fhir/us/davinci-cdex/task-based-approach.html) · [DIS execution-plan source policy](../input/pagecontent/volume-3.md#execution-plan-source-policy)

## Execution and results

- **Synchronous ITI-x3.** Return the existing result, evidence and validation status in the original `200 OK`.
- **Asynchronous ITI-x3.** Return `202 Accepted` with the polling URL in `Content-Location`. The completed ITI-x7 poll returns the existing result structure.
- **Job tracking.** The Manager may persist its internal job Task for asynchronous processing or use a transient instance for synchronous processing. The ITI-x1 and ITI-x4 contracts continue to define the Requester's view of the job. An internal parent Task can group execution Tasks via `Task.partOf` where the parent reference can be resolved.
- **Stage history.** Returning a completed Task or publishing a chain of stage Tasks is a separate decision. If DIS adopts that result model, a completed Task would retain the assignment identifier so the Manager can correlate it with the dispatch and the Requester can follow the disclosed stage history. A recipient-facing representation would need its own disclosure rules for protected plan references, lookup material and intermediate data. Existing release Provenance continues to attest to the final output and validated stage sequence.

[Current task response and retrieval](../input/pagecontent/volume-2.md) · [Current result and evidence binding](../input/pagecontent/volume-3.md) · [FHIR R4 Task relationships](https://hl7.org/fhir/R4/task-definitions.html#Task.partOf)

## Decision and verification

Adopt the ITI-x3 binding if the Manager and De-Identifier need a shared, identifiable work order. If the requirement is limited to polling, the current exchange already provides that. If the requirement is limited to correlating a dispatch with its outcome, compare the smaller alternative of an explicit assignment identifier in the existing operation. A direct `POST /Task` would be a separate change to the interaction contract and lifecycle management. [HL7 R4 workflow management](https://hl7.org/fhir/R4/workflow-management.html#optiong)

Before specifying the candidate binding, agree how the identifier is scoped, how a retry of the same assignment differs from a new assignment, and how the receiver handles reuse of an identifier with different inputs. Also decide whether the identifier needs to be echoed in results or linked to evidence. The FHIR resource ID, polling URL and audit correlation identifier retain their respective roles.

If approved, update the ITI-x3 request narrative, OperationDefinition, execution Task profile and input codes, examples, and Test Plan together. Use synthetic cases to check synchronous completion and asynchronous retrieval, missing or conflicting assignment inputs, and stage and ruleset consistency with the execution plan. Where identity continuity or retry behavior becomes a requirement, test it in both delivery modes. [Current OperationDefinitions](../input/fsh/Operations.fsh) · [Current Test Plan](../input/pagecontent/testplan.md)
