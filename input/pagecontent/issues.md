## Significant Changes

The current drafting baseline is [Volume 1](volume-1.html). Supporting content reflects four actors, four transactions, DIS-Policy and DIS-FHIR-Payload content modules, the nine core transformation actions, and independently versioned R4/R5/R6 payloads over an R4 protocol binding. R6 support remains provisional as described in Volume 1.

## Issues

### Submit an Issue

Submit and discuss profile feedback through [IHE ITI.DIS GitHub Issues](https://github.com/IHE/ITI.DIS/issues). The repository development work plan records drafting packages and dependencies; it does not establish that all bindings or tests are complete.

### Open Issues

- **Data Recipient actor and push delivery:** Volume 1 UC-5 asks the committee whether to add these to Phase 1. The current baseline groups receiving with the Requester and permits standalone Integrated processing without external DIS transactions. The proposal is not an adopted transaction or actor requirement.
- **Operation parameters:** align the FHIR R4 `processingTarget` encoding in the ITI-x1 and ITI-x3 OperationDefinitions with the delivery modes in [Volume 2](volume-2.html).
- **Binding completion:** specify the Bulk Data manifest fields, retrieval and expiry behavior, and evidence and error packaging in the payload and transaction bindings, as identified in Volume 1.
- **Conformance artifacts:** complete the remaining schemas, actor CapabilityStatements and detailed test procedures, then validate them against the current baseline.

### Closed Issues

No closed-issue history is recorded on this page. See GitHub for issue state and discussion.
