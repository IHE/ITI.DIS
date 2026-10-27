
The De-Identification Services (DIS) Profile defines a standardized, policy-governed workflow for de-identification of HL7 FHIR health data. DIS enables authorized requesters to submit de-identification jobs referencing signed policy carriers and data request authorizations, and to receive de-identified output with auditable provenance evidence. The profile supports both synchronous single-patient workflows (such as clinical pseudonymization before external lab ordering or cloud AI invocation) and asynchronous multi-patient cohort workflows (such as cross-border research studies or AI/ML training dataset preparation).

DIS is a **Workflow** profile. It defines four actors, four transactions, a baseline policy execution model, an execution plan format, and a minimum evidence baseline. DIS begins after data request authorization has been established and a de-identification policy has been authorized. It does not standardize how a data permit or data-request approval is requested, approved, issued, discovered, amended, revoked, or retired.

DIS separates core workflow semantics, the FHIR protocol binding, and the processing payload binding. The DIS FHIR protocol binding (DIS-FHIR-Job, DIS-FHIR-Task, DIS-FHIR-JobStatus) uses FHIR R4 APIs and resources exclusively; it is content-neutral and can orchestrate any payload type for which a corresponding payload binding is declared. DIS-FHIR-Payload is the FHIR payload binding, supporting independently versioned FHIR R4, R5, and R6 processing payloads; support for R5 or R6 payloads does not require an R5 or R6 version of the DIS protocol binding. Additional payload bindings (e.g., DIS-DICOM1, DIS-CDA1) may be defined independently to support non-FHIR data formats within the same FHIR R4 protocol layer.

The processing payload's format and version SHALL be explicitly identified. De-Identifiers SHALL declare supported payload bindings and versions, and the Manager SHALL verify compatibility before dispatch. FHIR payloads SHALL be validated against their declared version. A FHIR payload using a different version from the R4 protocol binding SHALL be referenced or carried as explicitly identified serialized content using the payload binding's packaging rules; it SHALL NOT be embedded as a native resource of the other version in the R4 transaction envelope. Non-FHIR payloads (e.g., DICOM, CDA) SHALL be carried or referenced using their respective payload binding's packaging rules. Detailed version identification and packaging rules are specified in each payload binding.

<a name="actors-and-transactions"> </a>

## 1:PXX.1 DIS Actors, Transactions, and Content Modules

This section defines the actors, transactions, and content modules in the DIS Profile.

DIS defines two deployment models for de-identification processing:

- **Distributed model** -- the De-Identification Requester submits jobs to a De-ID Manager, which validates the policy carrier, compiles an execution plan, and dispatches tasks to one or more De-Identifiers. This model supports multi-stage execution with trust isolation between stages.
- **Integrated model** -- the Integrated De-ID Manager/De-Identifier combines policy validation, execution plan compilation, and transformation execution within a single actor. It receives jobs directly from the Requester and does not use inter-actor task dispatch.

Figure 1:PXX.1-1 shows the actors directly involved in the DIS Profile and the relevant transactions between them. The dashed boundary represents the Integrated De-ID Manager/De-Identifier, which combines the De-ID Manager and De-Identifier into a single actor. When the Integrated actor is deployed, ITI-x3 and ITI-x7 are performed internally and do not appear on the wire.

```mermaid
flowchart TB
    REQ["De-Identification Requester"]

    subgraph INT ["Integrated De-ID Manager / De-Identifier"]
        MGR["De-ID Manager"]
        DI["De-Identifier"]
    end

    REQ -->|"ITI-x1 Submit De-Identification Job"| MGR
    REQ -->|"ITI-x4 Retrieve Job Output"| MGR
    MGR -->|"ITI-x3 Submit De-Identification Task"| DI
    MGR -->|"ITI-x7 Retrieve Task Output"| DI

    style INT stroke-dasharray: 5 5
```

**Figure 1:PXX.1-1: DIS Actor Diagram**

Table 1:PXX.1-1 lists the transactions for each actor directly involved in the DIS Profile. To claim compliance with this profile, an actor SHALL support all required transactions (labeled "R") and MAY support the optional transactions (labeled "O").

<p id="tPXX.1-1" class="tableTitle"><strong>Table 1:PXX.1-1: DIS Profile - Actors and Transactions</strong></p>

| Actors | Transactions | Initiator or Responder | Optionality | Reference |
|--------|-------------|------------------------|-------------|-----------|
| De-Identification Requester | ITI-x1 Submit De-Identification Job | Initiator | R | ITI TF-2: 3.x1 |
|  | ITI-x4 Retrieve Job Output | Initiator | O (See Note 1) | ITI TF-2: 3.x4 |
| De-ID Manager | ITI-x1 Submit De-Identification Job | Responder | R | ITI TF-2: 3.x1 |
|  | ITI-x3 Submit De-Identification Task | Initiator | R | ITI TF-2: 3.x3 |
|  | ITI-x4 Retrieve Job Output | Responder | O (See Note 1) | ITI TF-2: 3.x4 |
|  | ITI-x7 Retrieve Task Output | Initiator | O (See Note 1) | ITI TF-2: 3.x7 |
| De-Identifier | ITI-x3 Submit De-Identification Task | Responder | R | ITI TF-2: 3.x3 |
|  | ITI-x7 Retrieve Task Output | Responder | O (See Note 1) | ITI TF-2: 3.x7 |
| Integrated De-ID Manager/De-Identifier | ITI-x1 Submit De-Identification Job | Responder | R | ITI TF-2: 3.x1 |
|  | ITI-x4 Retrieve Job Output | Responder | O (See Note 1) | ITI TF-2: 3.x4 |
{: .grid}

Note 1: *ITI-x4 and ITI-x7 are required when the Asynchronous Job Processing Option (DIS-ASYNC) is supported. ITI-x4 enables the Requester to poll for job output; ITI-x7 enables the Manager to retrieve task output from the De-Identifier. ITI-x7 does not apply to the Integrated De-ID Manager/De-Identifier.*

Table 1:PXX.1-2 lists the content modules defined for each actor. Each content module specifies the payload-specific rules for addressing, transformation, evidence, and packaging within a particular data format family.

<p id="tPXX.1-2" class="tableTitle"><strong>Table 1:PXX.1-2: DIS Profile - Actors and Content Modules</strong></p>

| Actors | Content Modules | Optionality | Reference |
|--------|----------------|-------------|-----------|
| De-Identification Requester | DIS-FHIR-Payload | R (See Note 4) | [3:5.9](volume-3.html#fhir-payload-content-module) |
| De-ID Manager | DIS-FHIR-Payload | R (See Note 4) | [3:5.9](volume-3.html#fhir-payload-content-module) |
| De-Identifier | DIS-FHIR-Payload | R (See Note 4) | [3:5.9](volume-3.html#fhir-payload-content-module) |
| Integrated De-ID Manager/De-Identifier | DIS-FHIR-Payload | R (See Note 4) | [3:5.9](volume-3.html#fhir-payload-content-module) |
{: .grid}

Note 4: *DIS-FHIR-Payload is the only payload binding available in Phase 1. It supports independently versioned FHIR R4, R5, and R6 processing payloads. Future content modules (e.g., DIS-DICOM1, DIS-CDA1) may be defined for additional data formats.*

### 1:PXX.1.1 Actors

The actors in this profile are described in more detail in the sections below.

<a name="de-identification-requester"> </a>

#### 1:PXX.1.1.1 De-Identification Requester

The De-Identification Requester submits de-identification jobs to the De-ID Manager, presenting a data request authorization and a signed de-identification policy carrier. In the synchronous mode, the Requester receives de-identified output and evidence inline in the ITI-x1 response. In the asynchronous mode, the Requester retrieves output via ITI-x4 polling.

In Phase 1, the De-Identification Requester is grouped with the De-Identified Data Receiver role -- the Requester receives output directly. No separate push-delivery path is standardized.

Phase 1 does not standardize how the Requester obtains a signed de-identification policy carrier. The Requester presents the carrier in ITI-x1; the mechanism by which it was obtained is an implementation-defined concern. Implementers MAY use any mechanism that produces a valid signed policy carrier, including local configuration, administrative provisioning, bilateral agreement, or integration with an external policy management system.

<a name="de-id-manager"> </a>

#### 1:PXX.1.1.2 De-ID Manager

The De-ID Manager receives de-identification jobs via ITI-x1, validates the data request authorization and de-identification policy carrier, compiles the validated policy into an execution plan, dispatches de-identification tasks to De-Identifiers via ITI-x3, and returns de-identified output and provenance evidence to the Requester.

The De-ID Manager is the sole persistent custodian of identity mappings and reversibility records. When reversible pseudonymization is enabled (DIS-REVERSIBLE), the De-ID Manager retains the identity table (cryptographic seed to patient identity mapping) and builds a pseudonym index from de-identification evidence reported by the De-Identifier at job completion. Together these two tables form the reverse-mapping chain: pseudonym to seed to patient identity. Phase 1 does not standardize re-identification transactions; however, implementations claiming DIS-REVERSIBLE SHALL retain reversibility material so that standardized re-identification can be enabled without re-processing previously de-identified data.

The De-ID Manager performs four-point validation on all policy carrier variants:

1. **Signature validity** -- the carrier's digital signature is cryptographically valid and issued by a trusted authority
2. **Schema conformance** -- the policy content conforms to the expected schema
3. **Currency** -- the policy is not expired or revoked
4. **Authorization consistency** -- the policy is consistent with the data request authorization (scope, purpose, and processing target are compatible)

For a named policy carrier, the Requester supplies the policy identifier and any required version. The De-ID Manager SHALL resolve it unambiguously to a specific, versioned, signed policy artifact and complete all four validation checks before accepting the job. If resolution is ambiguous, unavailable, or cannot produce a valid artifact, the Manager SHALL reject the request synchronously without dispatching tasks. Resolution MAY use a local registry, administrative configuration, or an external source; Phase 1 does not standardize the provisioning or resolution mechanism. Resolution of named or by-reference carriers does not introduce a policy discovery or retrieval transaction into Phase 1.

The De-Identifier receives the compiled execution plan and is not responsible for resolving the Requester's named carrier. Where execution relies on native named-policy support, the Manager SHALL verify that the De-Identifier supports the resolved policy and version before dispatch.

<a name="de-identifier"> </a>

#### 1:PXX.1.1.3 De-Identifier

The De-Identifier executes assigned de-identification tasks received via ITI-x3. It is stateless with respect to reversibility -- it receives scoped, purpose-specific seeds as required by the assigned rules, produces transformations and evidence, and retains no identity-linking material after task termination. The De-Identifier derives transformation values, such as pseudonyms or date-shift offsets, according to the execution plan and its declared capabilities. It reports pseudonyms needed for reversibility to the Manager but does not retain the seed-to-identity mapping. The Manager supplies policy, scope, and seed material; it is not required to compute pseudonyms or date-shift offsets.

A Phase 1 De-Identifier SHALL declare its capabilities, including supported payload families (at least `fhir` for DIS-FHIR-Payload), supported action families (`core`), and zero or more named standardized policies it natively supports. The declaration SHALL also identify supported transformation parameter inputs and derivation methods. Acceptance of precomputed pseudonyms or date-shift offsets is not mandatory. The De-ID Manager SHALL verify compatibility with the De-Identifier's declared capabilities before dispatching tasks via ITI-x3 and SHALL NOT dispatch an incompatible task.

<a name="integrated-de-id-manager-de-identifier"> </a>

#### 1:PXX.1.1.4 Integrated De-ID Manager/De-Identifier

The Integrated De-ID Manager/De-Identifier combines the functionality of the De-ID Manager and the De-Identifier into a single actor. It does not initiate nor accept the Submit De-Identification Task [ITI-x3] transaction.

The Integrated De-ID Manager/De-Identifier receives de-identification jobs via ITI-x1, validates the data request authorization and de-identification policy carrier, compiles the validated policy into an execution plan, executes the plan internally, and returns de-identified output and provenance evidence to the Requester. It performs all Manager obligations (policy validation, execution plan compilation, reversibility material custody) and all De-Identifier obligations (transformation execution, evidence production, capability declaration) within a single actor.

The Integrated De-ID Manager/De-Identifier is the sole persistent custodian of identity mappings and reversibility records, consistent with the De-ID Manager's custody obligations. Seeds, identity tables, pseudonym indices, and other protected transformation material remain within the integrated actor's trust boundary.

A Phase 1 Integrated De-ID Manager/De-Identifier SHALL declare its capabilities using the same structure required of a standalone De-Identifier, including supported payload families (at least `fhir` for DIS-FHIR-Payload), supported action families (`core`), and zero or more named standardized policies. The Integrated De-ID Manager/De-Identifier SHALL support DIS-BASELINE-EXEC. Multi-stage execution is performed internally; the integrated actor compiles and executes each stage in sequence without externalizing the inter-stage dispatch.

### 1:PXX.1.2 Transaction Descriptions

The transactions in this profile are summarized in the sections below.

#### 1:PXX.1.2.1 Submit De-Identification Job [ITI-x1]

This transaction allows the De-Identification Requester to present a data request authorization and a signed de-identification policy carrier, and to trigger de-identification processing. The De-ID Manager validates the authorization and policy carrier, compiles the policy into an execution plan, orchestrates task execution, and returns de-identified output and evidence. The transaction supports both synchronous (output inline) and asynchronous (job acceptance with polling URL) response modes.

The transaction SHALL reject a job when the data request authorization is missing, untrusted, expired, or inconsistent with the requested processing target. The transaction SHALL also reject a job when the de-identification policy carrier is missing, has an invalid or untrusted signature, is expired, or is inconsistent with the data request authorization. Rejection is always synchronous regardless of the requested response mode.

Before accepting a job or dispatching any task, the De-ID Manager SHALL validate the data request authorization and complete all four policy carrier checks: signature validity, schema conformance, currency, and authorization consistency. If admission validation fails or cannot be completed, the Manager SHALL return a synchronous error response and SHALL NOT accept the job or dispatch tasks. This requirement applies to both synchronous and asynchronous requests.

For an accepted asynchronous job, failures discovered during subsequent processing SHALL be reported through ITI-x4 job status. The Manager SHALL withhold de-identified output from a failed job, including when output validation fails.

For more details see the detailed [transaction description](volume-2.html).

#### 1:PXX.1.2.2 Submit De-Identification Task [ITI-x3]

This transaction allows the De-ID Manager to submit a de-identification task to a De-Identifier. The task carries a reference to a Library resource containing execution rules for the assigned stage, the processing target (or reference to prior stage output), and scoped, purpose-specific seeds when required by the assigned rules and supported parameter inputs. The De-Identifier applies the transformation rules, produces de-identified output and evidence, and returns a completed task with validation status.

When the De-ID Manager compiles multiple stages, ITI-x3 is invoked once per stage in sequence. Each invocation references a Library containing only the rules assigned to that stage -- the De-Identifier SHALL NOT have visibility into stages assigned to other instances.

For more details see the detailed [transaction description](volume-2.html).

#### 1:PXX.1.2.3 Retrieve Job Output [ITI-x4]

This transaction allows the De-Identification Requester to retrieve the status and output of a previously submitted asynchronous job. The De-ID Manager authenticates the Requester, verifies authorization for the specified job, and returns the current job status. When the job is complete, the response includes all output and evidence that would have been returned inline in a synchronous ITI-x1 response.

For more details see the detailed [transaction description](volume-2.html).

#### 1:PXX.1.2.4 Retrieve Task Output [ITI-x7]

This transaction allows the De-ID Manager to retrieve the output of a de-identification task from a De-Identifier during asynchronous job processing. When the De-ID Manager dispatches a task via ITI-x3 as part of an asynchronous job, it retrieves the completed output, evidence, and validation status via ITI-x7. This transaction is required when the Asynchronous Job Processing Option (DIS-ASYNC) is supported. It does not apply to the Integrated De-ID Manager/De-Identifier.

For more details see the detailed [transaction description](volume-2.html).

<a name="actor-options"> </a>

## 1:PXX.2 DIS Actor Options

Options that may be selected for each actor in this profile are listed in Table 1:PXX.2-1 below. Dependencies between options when applicable are specified in notes.

<p id="tPXX.2-1" class="tableTitle"><strong>Table 1:PXX.2-1: DIS Profile - Actor Options</strong></p>

| Actor | Option Name | Reference |
|-------|-------------|-----------|
| De-Identification Requester | Base De-Identification Support (DIS-BASE) | [1:PXX.2.1](#1pxx21-base-de-identification-support) |
| De-Identification Requester | FHIR Job Protocol (DIS-FHIR-Job) (See Note 2) | [1:PXX.2.5](#1pxx25-fhir-job-protocol-option) |
| De-Identification Requester | FHIR Payload (DIS-FHIR-Payload) (See Note 4) | [1:PXX.2.7](#1pxx27-fhir-payload-option) |
| De-Identification Requester | FHIR Job Status Protocol (DIS-FHIR-JobStatus) (See Note 3) | [1:PXX.2.8](#1pxx28-fhir-job-status-protocol-option) |
| De-Identification Requester | Asynchronous Job Processing (DIS-ASYNC) | [1:PXX.2.9](#1pxx29-asynchronous-job-processing-option) |
| De-ID Manager | Base De-Identification Support (DIS-BASE) | [1:PXX.2.1](#1pxx21-base-de-identification-support) |
| De-ID Manager | Baseline Execution Plan (DIS-BASELINE-EXEC) | [1:PXX.2.3](#1pxx23-baseline-execution-plan-option) |
| De-ID Manager | FHIR Job Protocol (DIS-FHIR-Job) (See Note 2) | [1:PXX.2.5](#1pxx25-fhir-job-protocol-option) |
| De-ID Manager | FHIR Task Protocol (DIS-FHIR-Task) (See Note 2) | [1:PXX.2.6](#1pxx26-fhir-task-protocol-option) |
| De-ID Manager | FHIR Payload (DIS-FHIR-Payload) (See Note 4) | [1:PXX.2.7](#1pxx27-fhir-payload-option) |
| De-ID Manager | FHIR Job Status Protocol (DIS-FHIR-JobStatus) (See Note 3) | [1:PXX.2.8](#1pxx28-fhir-job-status-protocol-option) |
| De-ID Manager | Asynchronous Job Processing (DIS-ASYNC) | [1:PXX.2.9](#1pxx29-asynchronous-job-processing-option) |
| De-ID Manager | Local Authorized Export (DIS-LOCAL-EXPORT) | [1:PXX.2.4](#1pxx24-local-authorized-export-option) |
| De-ID Manager | Irreversible De-Identification (DIS-IRREVERSIBLE) | [1:PXX.2.10](#1pxx210-irreversible-de-identification-option) |
| De-ID Manager | Reversible Pseudonymization (DIS-REVERSIBLE) | [1:PXX.2.2](#1pxx22-reversible-pseudonymization-option) |
| De-Identifier | Base De-Identification Support (DIS-BASE) | [1:PXX.2.1](#1pxx21-base-de-identification-support) |
| De-Identifier | Baseline Execution Plan (DIS-BASELINE-EXEC) | [1:PXX.2.3](#1pxx23-baseline-execution-plan-option) |
| De-Identifier | FHIR Task Protocol (DIS-FHIR-Task) (See Note 2) | [1:PXX.2.6](#1pxx26-fhir-task-protocol-option) |
| De-Identifier | FHIR Payload (DIS-FHIR-Payload) (See Note 4) | [1:PXX.2.7](#1pxx27-fhir-payload-option) |
| De-Identifier | Irreversible De-Identification (DIS-IRREVERSIBLE) | [1:PXX.2.10](#1pxx210-irreversible-de-identification-option) |
| De-Identifier | Reversible Pseudonymization (DIS-REVERSIBLE) | [1:PXX.2.2](#1pxx22-reversible-pseudonymization-option) |
| Integrated De-ID Manager/De-Identifier | Base De-Identification Support (DIS-BASE) | [1:PXX.2.1](#1pxx21-base-de-identification-support) |
| Integrated De-ID Manager/De-Identifier | Baseline Execution Plan (DIS-BASELINE-EXEC) | [1:PXX.2.3](#1pxx23-baseline-execution-plan-option) |
| Integrated De-ID Manager/De-Identifier | FHIR Job Protocol (DIS-FHIR-Job) (See Note 2) | [1:PXX.2.5](#1pxx25-fhir-job-protocol-option) |
| Integrated De-ID Manager/De-Identifier | FHIR Payload (DIS-FHIR-Payload) (See Note 4) | [1:PXX.2.7](#1pxx27-fhir-payload-option) |
| Integrated De-ID Manager/De-Identifier | FHIR Job Status Protocol (DIS-FHIR-JobStatus) (See Note 3) | [1:PXX.2.8](#1pxx28-fhir-job-status-protocol-option) |
| Integrated De-ID Manager/De-Identifier | Asynchronous Job Processing (DIS-ASYNC) | [1:PXX.2.9](#1pxx29-asynchronous-job-processing-option) |
| Integrated De-ID Manager/De-Identifier | Local Authorized Export (DIS-LOCAL-EXPORT) | [1:PXX.2.4](#1pxx24-local-authorized-export-option) |
| Integrated De-ID Manager/De-Identifier | Irreversible De-Identification (DIS-IRREVERSIBLE) | [1:PXX.2.10](#1pxx210-irreversible-de-identification-option) |
| Integrated De-ID Manager/De-Identifier | Reversible Pseudonymization (DIS-REVERSIBLE) | [1:PXX.2.2](#1pxx22-reversible-pseudonymization-option) |
{: .grid}

Note 2: *FHIR R4 protocol bindings are required for all applicable actors in Phase 1 since FHIR R4 is the only available protocol binding. The protocol binding is content-neutral and can orchestrate any payload type.*

Note 3: *FHIR Job Status Protocol is required when the Asynchronous Job Processing Option is supported.*

Note 4: *DIS-FHIR-Payload is required for all actors in Phase 1 since it is the only available payload binding. It supports independently versioned FHIR R4, R5, and R6 processing payloads. Future payload bindings (e.g., DIS-DICOM1, DIS-CDA1) may be declared alongside DIS-FHIR-Payload.*

Table 1:PXX.2-2 summarizes all Phase 1 declarations and their dependencies. Actor-specific obligations apply to each declared actor.

<p id="tPXX.2-2" class="tableTitle"><strong>Table 1:PXX.2-2: DIS Profile - Declaration Matrix</strong></p>

| Declaration | Option Name | Requester | Manager | De-Identifier | Integrated Manager/De-Identifier | Dependency / obligation |
|-------------|-------------|-----------|---------|---------------|-----------------------------------|-------------------------|
| DIS-BASE | Base De-Identification Support | Required | Required | Required | Required | Synchronous job support — the minimum operational capability for any DIS implementation. |
| DIS-BASELINE-EXEC | Baseline Execution Plan | Not applicable | Required | Required | Required | Flat, ordered rules; full DIS-EXE1 is deferred. |
| DIS-FHIR-Job | FHIR Job Protocol | Required (Note 2) | Required (Note 2) | Not applicable | Required (Note 2) | FHIR R4 protocol binding for ITI-x1 (`POST [base]/$submit-dis-job`). Content-neutral — can orchestrate any payload type. |
| DIS-FHIR-Task | FHIR Task Protocol | Not applicable | Required (Note 2) | Required (Note 2) | Not applicable | FHIR R4 protocol binding for ITI-x3 (FHIR Task REST). Does not apply to the Integrated actor. |
| DIS-FHIR-Payload | FHIR Payload | Required (Note 4) | Required (Note 4) | Required (Note 4) | Required (Note 4) | FHIR payload binding — content model, data-plane access for independently versioned FHIR R4, R5, and R6 processing payloads. |
| DIS-FHIR-JobStatus | FHIR Job Status Protocol | Conditional (Note 3) | Conditional (Note 3) | Not applicable | Conditional (Note 3) | FHIR R4 protocol binding for ITI-x4 (FHIR Asynchronous Request Pattern). Required when DIS-ASYNC is declared. |
| DIS-ASYNC | Asynchronous Job Processing | Optional | Optional | Not applicable | Optional | Both participating Requester and Manager (or Integrated actor) declare support; ITI-x4, ITI-x7, and DIS-FHIR-JobStatus are required. ITI-x7 does not apply to the Integrated actor. |
| DIS-LOCAL-EXPORT | Local Authorized Export | Not applicable | Optional | Not applicable | Optional | Manager or Integrated actor supports local authorization-to-policy mapping and all admission checks. |
| DIS-IRREVERSIBLE | Irreversible De-Identification | Not applicable | Optional | Optional | Optional | Baseline pseudonymization mode — no reversibility material is retained. At least one of DIS-IRREVERSIBLE or DIS-REVERSIBLE SHALL be declared. |
| DIS-REVERSIBLE | Reversible Pseudonymization | Not applicable | Optional | Optional | Optional | Both participating Manager and De-Identifier declare reversible pseudonymization support. The Integrated actor declares this as a single actor. At least one of DIS-IRREVERSIBLE or DIS-REVERSIBLE SHALL be declared. |
{: .grid}

Note 2: *In Phase 1, the FHIR R4 protocol bindings (DIS-FHIR-Job, DIS-FHIR-Task, DIS-FHIR-JobStatus) are required for all applicable actors since FHIR R4 is the only available protocol binding.*

Note 3: *DIS-FHIR-JobStatus is required when DIS-ASYNC is declared.*

Note 4: *In Phase 1, DIS-FHIR-Payload is required for all actors since it is the only available payload binding. It is structured as an option to support future payload bindings for additional data formats (e.g., DIS-DICOM1, DIS-CDA1). Each payload binding is independent of the protocol binding version.*

### 1:PXX.2.1 Base De-Identification Support

Base De-Identification Support (DIS-BASE) represents the minimum operational capability for any DIS implementation: synchronous de-identification job processing. All DIS actors SHALL declare DIS-BASE. This establishes support for the core workflow — the Requester submits a job via ITI-x1 and receives de-identified output and evidence inline in the response.

### 1:PXX.2.2 Reversible Pseudonymization Option

The Reversible Pseudonymization Option (DIS-REVERSIBLE) enables the De-ID Manager to retain reversibility material (identity table and pseudonym index) so that future re-identification can be performed without re-processing previously de-identified data.

When this option is supported, the De-ID Manager SHALL:

- Retain the identity table (cryptographic seed to patient identity mapping) created during policy compilation
- Build a pseudonym index from de-identification evidence reported by the De-Identifier at job completion
- Protect identity tables and pseudonym indices within its trust boundary -- these records SHALL NOT be disclosed outside the Manager's trust boundary; seed sharing with authorized De-Identifiers follows §1:PXX.5.4

A De-Identifier supporting this option SHALL produce pseudonyms that are deterministically derivable from the cryptographic seed, enabling the De-ID Manager to build its reverse-mapping chain from evidence without requiring the De-Identifier to retain any identity-linking material.

UC-3 and UC-4 illustrate authorized, implementation-defined access to the Manager's mapping service for patient association. Such access returns only the resolution result needed by the EHR and does not export the identity table or pseudonym index. Phase 1 does not standardize this interaction or introduce a re-identification transaction.

### 1:PXX.2.3 Baseline Execution Plan Option

Every Phase 1 De-ID Manager and De-Identifier SHALL support DIS-BASELINE-EXEC, which supports flat, ordered rule lists. Phase 1 execution plans SHALL NOT require policy composition, condition evaluation, cross-element constraints, conflict resolution strategies, or selector specificity rules. The full Composable Execution Plan Option (DIS-EXE1), including these features, is deferred to a future phase and is not a Phase 1 actor option.

Multi-stage processing remains supported in Phase 1. The De-ID Manager dispatches a separate DIS-BASELINE-EXEC plan for each stage through ITI-x3; each plan contains only the ordered rules assigned to that stage.

### 1:PXX.2.4 Local Authorized Export Option

The Local Authorized Export Option (DIS-LOCAL-EXPORT) enables the De-ID Manager to support clinician-initiated local export workflows where authorization derives from the clinician's local role and declared purpose rather than an external data permit. No external policy carrier acquisition is required -- the policy is pre-configured by institutional administration.

When this option is supported, the De-ID Manager SHALL map the local authorization (role and purpose) to a configured de-identification policy using the DIS-LOCAL-EXPORT bridge pattern. The configured policy SHALL be a specific, versioned, signed artifact. The De-ID Manager SHALL complete signature validity, schema conformance, currency, and authorization consistency checks before accepting the job or dispatching tasks. Administrative provisioning replaces external acquisition, not validation; failed or incomplete validation SHALL produce a synchronous error.

This option is intended for lightweight clinical workflows such as de-identified document export from a clinical workstation, where heavy external permit infrastructure is not required.

### 1:PXX.2.5 FHIR Job Protocol Option

The FHIR Job Protocol Option (DIS-FHIR-Job) provides the FHIR R4 protocol binding for the Submit De-Identification Job transaction [ITI-x1]. The Requester submits a job using `POST [base]/$submit-dis-job` with FHIR R4 Parameters. This protocol binding is content-neutral -- it can orchestrate de-identification of any payload type (FHIR, DICOM, CDA, or other formats) for which a corresponding payload binding is declared. The payload data format and version are independent of the R4 protocol binding.

The De-Identification Requester, De-ID Manager, and Integrated De-ID Manager/De-Identifier SHALL declare DIS-FHIR-Job when participating in ITI-x1 using the FHIR R4 protocol binding. In Phase 1, this option is required for all applicable actors since FHIR R4 is the only available protocol binding.

### 1:PXX.2.6 FHIR Task Protocol Option

The FHIR Task Protocol Option (DIS-FHIR-Task) provides the FHIR R4 protocol binding for the Submit De-Identification Task transaction [ITI-x3]. The De-ID Manager dispatches tasks using FHIR R4 Task REST. The task references a Library containing DIS-EXE1 rules, the processing target, and a cryptographic seed. The payload carried or referenced by the task may be any data format for which the De-Identifier declares a corresponding payload binding.

The De-ID Manager and De-Identifier SHALL declare DIS-FHIR-Task when participating in ITI-x3 using the FHIR R4 protocol binding. This option does not apply to the Integrated De-ID Manager/De-Identifier because ITI-x3 is not part of that actor's transaction set. In Phase 1, this option is required for the De-ID Manager and De-Identifier since FHIR R4 is the only available protocol binding.

### 1:PXX.2.7 FHIR Payload Option

The FHIR Payload Option (DIS-FHIR-Payload) defines the content model and data-plane access for FHIR processing payloads. This includes FHIRPath addressing, resource traversal, narrative handling, Provenance-based evidence, and FHIR REST read/write or inline by-value data-plane access. DIS-FHIR-Payload covers independently versioned FHIR R4, R5, and R6 processing payloads. The processing payload's FHIR version is independent of the R4 protocol binding version.

DIS-FHIR-Payload is one of potentially several payload binding options. Each payload binding defines format-specific content models, addressing, and data-plane access for a particular data format family. Future payload bindings (e.g., DIS-DICOM1 for DICOM, DIS-CDA1 for CDA) are developed independently and can be carried within the same FHIR R4 protocol layer. An actor MAY declare multiple payload bindings to support de-identification of different data formats.

Actors declaring DIS-FHIR-Payload SHALL also declare the applicable protocol binding options (DIS-FHIR-Job and/or DIS-FHIR-Task). In Phase 1, DIS-FHIR-Payload is required for all actors since it is the only available payload binding.

#### 1:PXX.2.7.1 Cross-Version Payload Support

DIS-FHIR-Payload supports processing payloads whose FHIR version differs from the FHIR R4 protocol binding. An R5 or R6 resource can be de-identified through R4 protocol transactions without requiring an R5 or R6 version of the protocol binding. This cross-version support rests on three design properties: explicit version identification, version-safe packaging, and version-neutral addressing.

**Version identification.** Each processing payload SHALL explicitly identify its FHIR version. De-Identifiers SHALL declare which payload FHIR versions they support. The De-ID Manager SHALL verify that the declared payload version is compatible with the assigned De-Identifier's capabilities before dispatching a task via ITI-x3. FHIR payloads SHALL be validated against their declared version, not against the R4 protocol binding version.

**Version-safe packaging.** A FHIR payload whose version differs from the R4 protocol binding SHALL be carried or referenced using the payload binding's packaging rules. It SHALL NOT be embedded as a native resource of the payload version in the R4 transaction envelope. Permitted packaging patterns include:

- **By-reference** -- the processing target identifies the resource by FHIR reference or URL, and the De-Identifier retrieves it from a source FHIR server that supports the payload version.
- **Inline attachment** -- the payload is serialized and carried as a `valueAttachment` with an explicit content type (e.g., `application/fhir+json`). The R4 transaction envelope treats it as opaque bytes.
- **Bulk Data manifest** -- the payload is referenced as NDJSON files in a manifest. Each NDJSON line is a serialized resource in the declared payload version.

De-identified output is returned or persisted using the same packaging patterns. R4 protocol resources (`Parameters`, `Task`, `Provenance`, `OperationOutcome`, `Bundle` used for workflow packaging) remain R4 regardless of the payload version.

**Version-neutral addressing.** DIS-FHIR-Payload uses FHIRPath expressions to address data elements within the processing payload. The FHIRPath addresses used by DIS execution plans and semantic group mappings (e.g., `Patient.name`, `Patient.birthDate`, `DomainResource.text`) resolve consistently across FHIR R4, R5, and R6 for the resource types and elements governed by DIS transformation actions. Execution plan rules, semantic group definitions, and Provenance transformation summaries use these version-neutral paths and do not require version-specific variants.

**Evidence across versions.** De-identification evidence is represented as R4 FHIR `Provenance` -- it is part of the protocol layer, not the payload. Provenance references de-identified output by resource URI or identifier and records transformation summaries using version-neutral FHIRPath target paths. The evidence model does not depend on the payload's FHIR version.

### 1:PXX.2.8 FHIR Job Status Protocol Option

The FHIR Job Status Protocol Option (DIS-FHIR-JobStatus) provides the FHIR R4 protocol binding for the Retrieve Job Output transaction [ITI-x4] using the FHIR Asynchronous Request Pattern (`GET` on `Content-Location` URL).

This option is required when the Asynchronous Job Processing Option (DIS-ASYNC) is supported. The De-Identification Requester and the De-ID Manager (or the Integrated De-ID Manager/De-Identifier) SHALL declare DIS-FHIR-JobStatus when they declare DIS-ASYNC.

### 1:PXX.2.9 Asynchronous Job Processing Option

The Asynchronous Job Processing Option (DIS-ASYNC) enables the De-Identification Requester and De-ID Manager to support asynchronous de-identification workflows. When a Requester sends ITI-x1 with `Prefer: respond-async` and admission validation succeeds, the De-ID Manager SHALL return HTTP `202 Accepted` with a `Content-Location` header containing a polling URL. The Requester retrieves de-identified output and evidence via ITI-x4 using the polling URL.

This option is required for multi-patient cohort workflows where processing time exceeds the request timeout. When this option is declared:

- The De-Identification Requester and the De-ID Manager (or Integrated actor) SHALL support ITI-x4 (Retrieve Job Output) for job-level polling.
- The De-ID Manager and De-Identifier SHALL support ITI-x7 (Retrieve Task Output) for task-level output retrieval. ITI-x7 does not apply to the Integrated De-ID Manager/De-Identifier.

A De-ID Manager that supports the Asynchronous Job Processing Option SHALL retain the polling endpoint for at least 24 hours after job completion. After successful retrieval, the De-ID Manager MAY return `410 Gone` for subsequent requests per local retention policy.

### 1:PXX.2.10 Irreversible De-Identification Option

The Irreversible De-Identification Option (DIS-IRREVERSIBLE) declares the baseline pseudonymization mode where no reversibility material is retained. When this option is declared, the De-ID Manager does not retain identity tables or pseudonym indices after job completion. De-identified output cannot be reversed to recover the original patient identities.

At least one of DIS-IRREVERSIBLE or DIS-REVERSIBLE SHALL be declared by the De-ID Manager, De-Identifier, and Integrated De-ID Manager/De-Identifier. An actor MAY declare both options to indicate it supports both modes, with the mode selected per job by the de-identification policy.

<a name="required-groupings"> </a>

## 1:PXX.3 DIS Required Actor Groupings

An actor from this profile (Column 1) SHALL implement all of the required transactions and/or content modules in this profile ***in addition to*** ***<u>all</u>*** of the requirements for the grouped actor (Column 2). Table 1:PXX.3-1 lists the required actor groupings.

<p id="tPXX.3-1" class="tableTitle"><strong>Table 1:PXX.3-1: DIS Profile - Required Actor Groupings</strong></p>

| DIS Actor | Actor to be grouped with | Reference | Content Bindings Reference |
|-----------|--------------------------|-----------|---------------------------|
| De-Identification Requester | ATNA / Secure Application | [ITI TF-1: 9](https://profiles.ihe.net/ITI/TF/Volume1/ch-9.html) | -- |
| De-ID Manager | ATNA / Secure Node or Secure Application | [ITI TF-1: 9](https://profiles.ihe.net/ITI/TF/Volume1/ch-9.html) | -- |
| De-ID Manager | IUA / Authorization Client or Resource Server | [ITI TF-1: 34](https://profiles.ihe.net/ITI/TF/Volume1/ch-34.html) | -- |
| De-Identifier | ATNA / Secure Node or Secure Application | [ITI TF-1: 9](https://profiles.ihe.net/ITI/TF/Volume1/ch-9.html) | -- |
| Integrated De-ID Manager/De-Identifier | ATNA / Secure Node or Secure Application | [ITI TF-1: 9](https://profiles.ihe.net/ITI/TF/Volume1/ch-9.html) | -- |
| Integrated De-ID Manager/De-Identifier | IUA / Authorization Client or Resource Server | [ITI TF-1: 34](https://profiles.ihe.net/ITI/TF/Volume1/ch-34.html) | -- |
{: .grid}

All DIS actors SHALL be grouped with ATNA Secure Node or Secure Application to ensure that all transactions are audit-logged and that communications are secured via TLS.

The De-ID Manager and the Integrated De-ID Manager/De-Identifier SHALL be grouped with IUA Authorization Client or Resource Server to ensure that system-to-system authorization is enforced for job submission (ITI-x1) and output retrieval (ITI-x4). Implementations SHOULD use SMART Backend Services for automated system-to-system workflows.

<a name="overview"> </a>

## 1:PXX.4 DIS Overview

This section shows how the transactions of the DIS Profile are combined to address the use cases.

### 1:PXX.4.1 Concepts

DIS introduces the following key concepts that provide necessary background for understanding the profile.

**Policy-Governed De-Identification.** DIS separates policy definition from policy execution. A signed de-identification policy carrier governs what transformations are applied. The De-ID Manager validates the policy and compiles it into an execution plan; the De-Identifier executes the plan. Trust is anchored in the policy carrier's digital signature, not in the Requester's identity -- the Requester acts as a courier for the signed policy.

**Staged Execution.** DIS supports multi-stage de-identification. A preliminary stage handles direct identifiers (pseudonymization, suppression). An advanced stage applies policy-specified record-level rules to quasi-identifiers, such as fixed generalization, suppression, or noise addition. The De-ID Manager dispatches one ITI-x3 task per stage. Each De-Identifier sees only its assigned stage, enforcing trust isolation between stages.

**Phase 1 Transformation Scope.** Phase 1 excludes dataset- or database-level de-identification actions, including small-cell handling, frequency-based rare-condition suppression, and generalization or other transformations requiring statistics computed across the cohort. Multi-patient cohort processing remains supported for applying record-level rules with policy-specified parameters. Multi-stage execution does not extend this action scope. Dataset-level statistical disclosure control is deferred to a future phase; completing a Phase 1 workflow does not establish that any separately required dataset-level disclosure criteria have been met.

**Bulk Data Input and Output.** Phase 1 supports both input and output for asynchronous cohort jobs using manifests referencing NDJSON files. The Requester supplies a manifest referencing prepared input files; obtaining those files through source-system export is outside DIS. The Manager returns a manifest referencing de-identified output files together with evidence references. Processing remains limited to the Phase 1 action scope described above.

Each processing payload SHALL explicitly identify its FHIR version (R4, R5, or R6), independently of the R4 protocol binding. Participating actors SHALL declare supported input/output formats and payload versions, and the Manager SHALL verify compatibility before dispatch. File retrieval SHALL require authorization. Recipient-facing manifests and files SHALL NOT contain seeds or other protected transformation material. A failed job SHALL NOT release a partial dataset; failures SHALL be reported through job status.

Exact manifest fields, file retrieval and expiry behavior, and evidence/error packaging are to be specified in the payload and transaction bindings. Adoption of Bulk Data file conventions does not by itself establish conformance to the full HL7 Bulk Data API.

**Reversibility Custody.** When reversible pseudonymization is enabled, the De-ID Manager retains the identity table and pseudonym index. The De-Identifier is stateless with respect to reversibility. Identity tables and pseudonym indices remain within the Manager's trust boundary. Scoped, purpose-specific seeds may be shared with authorized De-Identifiers in separate trust boundaries under the controls in §1:PXX.5.4.

**Consistency Scope and Transformation Material.** The `consistencyKey` identifies an authorized linkage scope, such as a research project. It is not secret seed material and SHALL NOT, by itself, enable derivation of pseudonyms or date shifts. The Manager SHALL enforce authorization to use or reuse the scope. The Manager manages the lifecycle of consistent patient- and purpose-scoped seeds; the De-Identifier derives and applies transformation values using compatible methods, versions, and policy parameters. The Manager is not required to calculate those transformation values.

A shared `consistencyKey` alone does not guarantee identical results. Consistency also depends on resolving the same patient, supplying consistent seed material, and using compatible derivation methods, versions, and parameters. Identity resolution assumptions, derivation compatibility, seed rotation, and collision handling require explicit contracts and conformance tests.

Date-shift reference dates and offsets are protected transformation parameters, not consistency keys. Deterministic derivation from purpose-specific seeds is preferred. Where a De-Identifier generates a parameter that must be reused, an explicit capability contract SHALL define its protected return to the Manager, authorized retention, and reuse in subsequent tasks. Acceptance of precomputed parameters is not mandatory for all De-Identifiers. Seed handling follows §1:PXX.5.4.

**Evidence Baseline.** Every completed de-identification task produces provenance evidence containing at minimum nine elements: evidence identifier, outcome status, workflow reference, target identifier, policy-decision reference, stage category, reversibility state, validation status, and audit correlation identifier.

**Payload Binding Framework (Informative).** DIS separates the protocol binding from the payload binding so that additional data formats can be supported without changing the protocol layer. The FHIR R4 protocol binding (DIS-FHIR-Job, DIS-FHIR-Task, DIS-FHIR-JobStatus) defines how transactions are initiated, dispatched, and polled -- it is content-neutral and carries or references payloads of any format. Each payload binding defines the format-specific rules for a particular data format family. Phase 1 defines DIS-FHIR-Payload as the initial payload binding; additional payload bindings are expected to follow the same architectural pattern.

A payload binding defines at minimum:

1. **Content model** -- how data elements within the format are identified and addressed (e.g., FHIRPath for FHIR resources, DICOM tag paths for DICOM objects, XPath or CDA document model paths for CDA documents)
2. **Transformation action mapping** -- how the DIS core transformation actions (suppression, masking, pseudonymization, generalization, etc.) are applied to the format's data structures and element types
3. **Data-plane access** -- how the processing payload is retrieved, carried, or referenced within the R4 protocol envelope (e.g., inline by-value, by-reference with authorized retrieval, or format-specific packaging such as DICOM Part 10 files or CDA XML documents)
4. **Evidence mapping** -- how de-identification evidence and provenance are represented for the format, mapping format-specific outcomes to the DIS evidence baseline
5. **Version identification** -- how the payload's format version is declared, validated, and matched against De-Identifier capabilities
6. **Packaging rules** -- how a payload in this format is carried within or referenced from the FHIR R4 transaction envelope without being embedded as a native FHIR resource

The following table illustrates how future payload bindings could extend DIS to additional data formats. These bindings are not defined in Phase 1 and are provided for informational purposes only.

| Payload Binding | Data Format | Content Model | Example Processing Targets | Packaging Approach |
|-----------------|-------------|---------------|----------------------------|-------------------|
| DIS-FHIR-Payload (Phase 1) | HL7 FHIR R4, R5, R6 | FHIRPath addressing, resource traversal, narrative handling | Patient, Bundle, Bulk Data NDJSON | Inline FHIR resources or by-reference via FHIR REST / Bulk Data manifests |
| DIS-DICOM1 (future) | DICOM | DICOM tag paths, sequence item traversal, pixel data handling | DICOM Part 10 objects, studies, series | By-reference via DICOMweb WADO-RS or as DICOM Part 10 binary attachments |
| DIS-CDA1 (future) | HL7 CDA R2 | XPath / CDA document model, section and entry traversal, narrative block handling | CDA documents (Continuity of Care, Discharge Summary, etc.) | Inline XML or by-reference as document attachments |
| DIS-V2-1 (future) | HL7 v2.x | Segment/field/component paths (e.g., PID-5, OBX-5) | HL7 v2 messages (ADT, ORU, ORM, etc.) | By-reference or inline as ER7/XML-encoded messages |
{: .grid}

An actor declares which payload bindings it supports. The De-ID Manager verifies payload binding compatibility between the Requester's job and the De-Identifier's declared capabilities before dispatching tasks. A single job uses one payload binding; the Manager does not perform cross-format transformation. An actor MAY declare multiple payload bindings to support de-identification workflows across different data format families.

Each future payload binding is developed as a self-contained specification, independent of other payload bindings. A new payload binding does not require changes to the FHIR R4 protocol binding or to previously defined payload bindings. This independence enables parallel development by different IHE domains or working groups, and allows implementations to adopt additional payload support incrementally.

### 1:PXX.4.2 Use Cases

#### 1:PXX.4.2.1 Use Case 1: Cross-Border Epidemiological Study Using IPS+

A research consortium conducts a cross-border epidemiological study combining population-based cancer-registry data with selected clinical information originally collected for healthcare delivery. The study examines incidence, treatment patterns, comorbidities, outcomes, and survival across participating jurisdictions.

##### 1:PXX.4.2.1.1 Cross-Border Epidemiological Study Use Case Description

Clinical data remain under primary-use governance when recorded or exchanged for care. Their reuse begins only after a secondary-use request has been assessed and an authorization context has been issued. The Data Access Coordinator (DAC) coordinates participating jurisdictions, resolves authorized source-data provision, and -- acting as the De-Identification Requester -- submits a DIS job to produce a cohort dataset transformed by pseudonymization and policy-specified record-level rules for subsequent delivery to a Secure Processing Environment (SPE).

The DAC submits an asynchronous ITI-x1 job with a signed policy carrier and FHIR processing targets. The De-ID Manager validates the policy and compiles a two-stage execution plan. The preliminary stage pseudonymizes direct identifiers with reversible, project-scoped pseudonyms within the authorized scope identified by `consistencyKey`, using consistent patient-scoped seeds and compatible derivation parameters to preserve longitudinal linkage. The advanced stage applies policy-specified record-level suppression and fixed quasi-identifier generalization. Small-cell handling and transformations requiring cohort statistics are outside Phase 1; any required dataset-level assessment or processing occurs outside this DIS workflow before release to the SPE. The DAC retrieves the de-identified output and evidence via ITI-x4 polling and forwards it to the SPE.

##### 1:PXX.4.2.1.2 Cross-Border Epidemiological Study Process Flow

```mermaid
sequenceDiagram
    participant DAC as De-Identification Requester<br/>(DAC)
    participant MGR as De-ID Manager
    participant DI_P as De-Identifier<br/>(Preliminary)
    participant DI_A as De-Identifier<br/>(Advanced)

    Note over DAC,MGR: Data request authorization and signed policy exist

    DAC->>MGR: ITI-x1 Submit De-Identification Job (async)
    activate MGR
    Note over MGR: Validate authorization and all four policy carrier checks
    Note over DAC,MGR: If validation fails or cannot complete: synchronous error, no acceptance or dispatch
    MGR-->>DAC: 202 Accepted + Content-Location: polling-url (validation succeeded)
    deactivate MGR

    activate MGR
    Note over MGR: Compile two-stage execution plan

    MGR->>DI_P: ITI-x3 Submit Task (preliminary: pseudonymize direct identifiers)
    activate DI_P
    DI_P-->>MGR: Transformed output + evidence
    deactivate DI_P

    MGR->>DI_A: ITI-x3 Submit Task (advanced: record-level suppression, fixed generalization)
    activate DI_A
    DI_A-->>MGR: Transformed output + evidence
    deactivate DI_A
    deactivate MGR

    DAC->>MGR: ITI-x4 GET polling-url
    activate MGR
    MGR-->>DAC: 202 Accepted + Retry-After (in-progress)
    deactivate MGR

    DAC->>MGR: ITI-x4 GET polling-url
    activate MGR
    MGR-->>DAC: 200 OK (de-identified output + evidence)
    deactivate MGR
```

**Figure 1:PXX.4.2.1.2-1: Use Case 1 - Cross-Border Epidemiological Study Process Flow**

#### 1:PXX.4.2.2 Use Case 2: Multimodal AI/ML Method Development (FHIR Input-Preparation)

An AI/ML consortium develops or validates cancer models using multimodal data -- structured clinical information, radiology, digital pathology, laboratory data, genomics, annotations, and outcomes. DIS handles the FHIR input-preparation portion of the pipeline.

##### 1:PXX.4.2.2.1 AI/ML Method Development Use Case Description

The consortium holds a data permit identifying the approved cohort, modalities, linkage requirements, and de-identification stages. The DAC acts as the De-Identification Requester and submits an asynchronous job for the structured clinical data (EHR records, laboratory results, outcome labels, annotations).

The De-ID Manager compiles a two-stage execution plan. The preliminary stage pseudonymizes direct identifiers with reversible, project-scoped pseudonyms within the authorized scope identified by `consistencyKey`, using consistent patient-scoped seeds and compatible derivation parameters. Future DICOM processing could reuse that authorized scope for clinical/imaging linkage, provided identity resolution and derivation compatibility are also established; reusing the scope identifier alone is insufficient. The advanced stage applies fixed quasi-identifier generalization and policy-specified record-level suppression to the FHIR payload. Any required dataset-level assessment or processing occurs outside this DIS workflow before release to the SPE. The DAC retrieves the de-identified FHIR output via ITI-x4 and delivers it to the SPE.

##### 1:PXX.4.2.2.2 AI/ML Method Development Process Flow

```mermaid
sequenceDiagram
    participant DAC as De-Identification Requester<br/>(DAC)
    participant MGR as De-ID Manager
    participant DI_P as De-Identifier<br/>(Preliminary)
    participant DI_A as De-Identifier<br/>(Advanced)

    Note over DAC,MGR: Data permit and signed policy exist

    DAC->>MGR: ITI-x1 Submit De-Identification Job (async, with consistencyKey)
    activate MGR
    Note over MGR: Validate authorization and all four policy carrier checks
    Note over DAC,MGR: If validation fails or cannot complete: synchronous error, no acceptance or dispatch
    MGR-->>DAC: 202 Accepted + Content-Location: polling-url (validation succeeded)
    deactivate MGR

    activate MGR
    Note over MGR: Compile two-stage execution plan

    MGR->>DI_P: ITI-x3 Submit Task (preliminary stage)
    activate DI_P
    Note over DI_P: Pseudonymize using scoped seed<br/>and agreed derivation parameters
    DI_P-->>MGR: Transformed output + evidence
    deactivate DI_P

    MGR->>DI_A: ITI-x3 Submit Task (advanced stage)
    activate DI_A
    Note over DI_A: Fixed generalization,<br/>record-level suppression
    DI_A-->>MGR: Transformed output + evidence
    deactivate DI_A
    deactivate MGR

    DAC->>MGR: ITI-x4 GET polling-url
    activate MGR
    MGR-->>DAC: 202 Accepted + Retry-After (in-progress)
    deactivate MGR

    DAC->>MGR: ITI-x4 GET polling-url
    activate MGR
    MGR-->>DAC: 200 OK (de-identified FHIR output + evidence)
    deactivate MGR

    Note over DAC: Forward FHIR output to SPE. Future DICOM linkage requires authorized scope and compatible derivation.
```

**Figure 1:PXX.4.2.2.2-1: Use Case 2 - AI/ML Method Development (FHIR Input-Preparation) Process Flow**

#### 1:PXX.4.2.3 Use Case 3: Clinical Pathology Order (Pseudonymous Care)

A hospital EHR pseudonymizes patient context before sending a laboratory order to an external pathology lab. The lab operates under a pseudonymous-care model and processes orders referencing only the pseudonym.

##### 1:PXX.4.2.3.1 Clinical Pathology Order Use Case Description

Institutional policy prohibits the external lab from seeing direct patient identifiers. The EHR acts as the De-Identification Requester and submits a synchronous ITI-x1 job with care-context authorization, a pseudonymization policy carrier, and Patient plus ServiceRequest resources.

The De-ID Manager validates the policy and compiles a single-stage execution plan. The De-Identifier replaces patient identifiers with scoped pseudonyms -- the same pseudonym is used for the same patient within the project scope, enabling longitudinal result correlation. The De-ID Manager returns the pseudonymized payload and evidence inline in the ITI-x1 response.

The De-ID Manager retains custody of the identity table and pseudonym index. To associate the returned lab result with the correct patient chart, the EHR uses an authorized, implementation-defined interaction with the Manager's mapping service. The EHR receives only the resolution result needed for this association; the identity table and pseudonym index are not exported. This interaction is outside the transactions standardized by DIS Phase 1.

##### 1:PXX.4.2.3.2 Clinical Pathology Order Process Flow

```mermaid
sequenceDiagram
    participant EHR as De-Identification Requester<br/>(EHR)
    participant MGR as De-ID Manager
    participant DI as De-Identifier

    Note over EHR,MGR: Care-context authorization and pseudonymization policy exist

    EHR->>MGR: ITI-x1 Submit De-Identification Job (sync, Patient + ServiceRequest)
    activate MGR
    Note over MGR: Validate policy carrier, compile single-stage plan

    MGR->>DI: ITI-x3 Submit Task (preliminary: reversible pseudonymization)
    activate DI
    Note over DI: Replace identifiers with scoped pseudonyms using seed
    DI-->>MGR: Pseudonymized resources + evidence
    deactivate DI

    Note over MGR: Retain identity table + pseudonym index
    MGR-->>EHR: ITI-x1 Response (pseudonymized payload + evidence)
    deactivate MGR

    Note over EHR: Send pseudonymized order to external lab
    Note over EHR: Receive lab result referencing pseudonym
    EHR->>MGR: Authorized pseudonym resolution request (implementation-defined, outside DIS Phase 1)
    MGR-->>EHR: Resolution result needed for patient association (no mapping-table export)
    Note over EHR: File lab result to patient chart
```

**Figure 1:PXX.4.2.3.2-1: Use Case 3 - Clinical Pathology Order Process Flow**

#### 1:PXX.4.2.4 Use Case 4: AI-Assisted Clinical Decision Support (Cloud Deployment)

A hospital EHR pseudonymizes patient data before transmitting to a cloud-hosted AI service for clinical decision support. The AI service operates outside the hospital trust boundary and receives only pseudonymized data.

##### 1:PXX.4.2.4.1 AI-Assisted Clinical Decision Support Use Case Description

A clinician triggers AI decision support for an active patient encounter. The EHR submits the patient's FHIR resources (Observations, Conditions, MedicationStatements, Encounters) to the on-premise De-ID Manager for reversible pseudonymization. The De-ID Manager and De-Identifier operate entirely within the hospital trust boundary -- no identifiable data or protected security material leaves the on-premise environment during the de-identification step.

The De-ID Manager returns the pseudonymized payload synchronously. The EHR transmits pseudonymized data to the cloud AI service and receives recommendations referencing the pseudonym. The EHR uses an authorized, implementation-defined interaction with the Manager's mapping service to associate the AI output with the correct patient chart. The Manager retains custody of the identity table and pseudonym index and returns only the resolution result needed for that association. This interaction is outside the transactions standardized by DIS Phase 1.

Protected security material (identity table, pseudonym index, cryptographic seeds) never leaves the hospital trust boundary.

##### 1:PXX.4.2.4.2 AI-Assisted Clinical Decision Support Process Flow

```mermaid
sequenceDiagram
    participant EHR as De-Identification Requester<br/>(EHR)
    participant MGR as De-ID Manager<br/>(on-premise)
    participant DI as De-Identifier<br/>(on-premise)
    participant AI as Cloud AI Service<br/>(external)

    Note over EHR,DI: All DIS actors within hospital trust boundary

    EHR->>MGR: ITI-x1 Submit De-Identification Job (sync, clinical resources)
    activate MGR
    Note over MGR: Validate policy, compile single-stage plan

    MGR->>DI: ITI-x3 Submit Task (preliminary: reversible pseudonymization)
    activate DI
    Note over DI: Pseudonymize within trust boundary
    DI-->>MGR: Pseudonymized resources + evidence
    deactivate DI

    Note over MGR: Retain identity table + pseudonym index on-premise
    MGR-->>EHR: ITI-x1 Response (pseudonymized payload + evidence)
    deactivate MGR

    EHR->>AI: Transmit pseudonymized data (outside DIS)
    activate AI
    AI-->>EHR: AI recommendation referencing pseudonym (outside DIS)
    deactivate AI

    EHR->>MGR: Authorized pseudonym resolution request (implementation-defined, outside DIS Phase 1)
    MGR-->>EHR: Resolution result needed for patient association (no mapping-table export)
    Note over EHR: File AI result to patient chart
```

**Figure 1:PXX.4.2.4.2-1: Use Case 4 - AI-Assisted Clinical Decision Support Process Flow**

#### 1:PXX.4.2.5 Use Case 5: Local Authorized Clinical Document Export

An authorized clinician exports a de-identified FHIR document Bundle from a clinical workstation. Authorization derives from the clinician's local role and declared purpose -- no external data permit is required.

##### 1:PXX.4.2.5.1 Local Authorized Clinical Document Export Use Case Description

A clinician initiates export of a clinical document (for example, a discharge summary for patient-mediated sharing or a document for external referral). The clinical workstation hosts an Integrated De-ID Manager/De-Identifier grouped with the De-Identification Requester. The Integrated De-ID Manager/De-Identifier maps the local authorization to a configured de-identification policy using the DIS-LOCAL-EXPORT bridge pattern. No external policy carrier acquisition is needed -- the policy is pre-configured by institutional administration.

The Integrated De-ID Manager/De-Identifier performs policy validation, compiles the execution plan, executes identifier handling per the configured policy, and produces the de-identified document Bundle with evidence -- all within a single actor. It writes the de-identified output and Provenance evidence to the export destination. An ATNA audit record is emitted recording the policy identifier, stage, outcome, and audit correlation.

This use case demonstrates that DIS supports lightweight local workflows without requiring heavy external permit infrastructure, using the Integrated De-ID Manager/De-Identifier to eliminate inter-actor transactions.

##### 1:PXX.4.2.5.2 Local Authorized Clinical Document Export Process Flow

```mermaid
sequenceDiagram
    participant CLI as Clinician
    participant WS as Clinical Workstation<br/>(grouped Requester +<br/>Integrated De-ID<br/>Manager/De-Identifier)

    CLI->>WS: Initiate document export (local action)
    activate WS
    Note over WS: DIS-LOCAL-EXPORT: Map local authorization (role + purpose) to configured signed, versioned policy
    Note over WS: Validate authorization and all four policy checks before acceptance
    Note over WS: Compile single-stage execution plan

    Note over WS: Execute de-identification internally (no ITI-x3)
    Note over WS: Produce de-identified document Bundle + evidence

    Note over WS: Write de-identified output + Provenance to export destination
    Note over WS: Emit ATNA audit record
    WS-->>CLI: Export complete
    deactivate WS
```

**Figure 1:PXX.4.2.5.2-1: Use Case 5 - Local Authorized Clinical Document Export Process Flow**

<a name="security-considerations"> </a>

## 1:PXX.5 DIS Security Considerations

See ITI TF-2: [Appendix Z.8 "Mobile Security Considerations"](https://profiles.ihe.net/ITI/TF/Volume2/ch-Z.html#z.8-mobile-security-considerations).

DIS processes health data that is identifiable at input and de-identified at output. The security architecture addresses threats arising during the transformation workflow.

### 1:PXX.5.1 Actor Grouping and Transport Security

All DIS actors SHALL be grouped with ATNA Secure Node or Secure Application ([ITI TF-1: 9](https://profiles.ihe.net/ITI/TF/Volume1/ch-9.html)). This grouping ensures that all DIS transactions are audit-logged and that communications are secured via mutual TLS. Implementations SHALL use TLS 1.2 or later for all DIS transactions.

### 1:PXX.5.2 Authorization

The De-ID Manager and the Integrated De-ID Manager/De-Identifier SHALL be grouped with IUA Authorization Client or Resource Server ([ITI TF-1: 34](https://profiles.ihe.net/ITI/TF/Volume1/ch-34.html)). System-to-system authorization for automated workflows SHOULD use SMART Backend Services with OAuth 2.0 client credentials grants. The De-ID Manager or Integrated De-ID Manager/De-Identifier SHALL verify that the Requester is authorized under the submitted data request authorization before accepting a job.

### 1:PXX.5.3 Policy Carrier Integrity

De-identification policy carriers are digitally signed. Trust is anchored in the policy carrier's signature, not in the Requester's identity -- the Requester acts as a courier. The De-ID Manager SHALL verify the signature, schema conformance, currency, and authorization consistency of every policy carrier before job execution. Policy carriers with invalid, expired, or untrusted signatures SHALL be rejected.

### 1:PXX.5.4 Reversibility Material Custody

The De-ID Manager is the sole persistent custodian of identity mappings and reversibility records (identity table and pseudonym index). These records SHALL NOT be disclosed outside the De-ID Manager's trust boundary.

Seeds SHALL contain no PII and SHALL NOT directly encode patient identity. Seeds remain protected transformation material because possession may enable linkage or reproduction of transformations. The Manager MAY transmit scoped, purpose-specific seeds to an authorized De-Identifier over a protected channel for the assigned task. The Manager and De-Identifier MAY operate in separate trust boundaries; deployment within a shared trust boundary is optional.

The De-Identifier SHALL use received seeds only for the assigned task and SHALL retain them only for the duration of task execution. It SHALL delete them when the task terminates, whether successfully or unsuccessfully, and SHALL retain no identity-linking material after termination. Seeds SHALL NOT be disclosed to data recipients or included in recipient-facing output, evidence, or logs.

Implementations deploying DIS-REVERSIBLE (Reversible Pseudonymization) SHALL implement access controls, encryption at rest, and audit logging for all reversibility material. The De-ID Manager SHALL enforce access controls preventing unauthorized access to reversibility material even by other DIS actors.

Date-shift reference dates, offsets, and other protected transformation parameters SHALL NOT be disclosed to data recipients or included in recipient-facing output, evidence, or logs. A De-Identifier SHALL retain them only for task execution and delete them at task termination. Any return to the Manager for authorized retention and reuse SHALL follow an explicit capability contract and use a protected channel. Such retention SHALL be consistent with the authorized policy and declared reversibility mode.

### 1:PXX.5.5 Trust Isolation Between Stages

When the De-ID Manager compiles a multi-stage execution plan, each De-Identifier receives only the execution rules for its assigned stage. A De-Identifier performing the advanced stage (quasi-identifier generalization, suppression) does not have access to the preliminary stage's pseudonym-to-identity mappings. This stage-scoped dispatch provides defense-in-depth: compromise of a single De-Identifier does not expose the complete identity-to-pseudonym chain.

The Integrated De-ID Manager/De-Identifier executes all stages within a single actor. Inter-stage trust isolation through separate De-Identifiers is not available in this deployment model. Implementations requiring defense-in-depth through stage-level trust boundaries SHALL use the separate De-ID Manager and De-Identifier actors.

### 1:PXX.5.6 Audit Logging

All DIS transactions SHALL generate ATNA audit events. Every completed de-identification task produces evidence containing an audit correlation identifier linking the de-identification event to the ATNA audit trail. Implementations SHOULD use IHE Basic Audit Log Patterns (BALP) for structured audit events.

<a name="other-grouping"> </a>

## 1:PXX.6 DIS Cross-Profile Considerations

### IHE IUA - Internet User Authorization

The De-ID Manager and the Integrated De-ID Manager/De-Identifier group with IUA for system-to-system authorization. IUA Authorization Client is used when these actors need to obtain tokens; IUA Resource Server is used when they validate tokens presented by the De-Identification Requester. Implementations using SMART Backend Services for automated workflows operate through the IUA framework.

### IHE ATNA / BALP - Audit Trail and Node Authentication / Basic Audit Log Patterns

All DIS actors group with ATNA for transport security and audit logging. Implementations SHOULD use BALP for structured, FHIR-based audit event representation. The audit correlation identifier in DIS de-identification evidence links de-identification events to the broader ATNA audit trail, enabling end-to-end traceability from authorization through de-identification to output delivery.

### IHE MHD - Mobile Access to Health Documents

When de-identified output is delivered to a document sharing infrastructure, the De-Identification Requester (or a downstream consumer) MAY group with MHD Document Source to publish de-identified documents. MHD provides a FHIR-native document sharing transport that complements the DIS de-identification workflow.

### SMART on FHIR Backend Services

SMART Backend Services provides the OAuth 2.0 client credentials flow used for system-to-system authorization in automated DIS workflows. This is the recommended authorization pattern for server-to-server interactions where no end-user is present (for example, asynchronous cohort de-identification jobs submitted by a Data Access Coordinator).

### External Data Permit and Data Request Profiles

DIS consumes data request authorizations but does not produce them. The data request authorization presented in ITI-x1 is obtained through mechanisms outside DIS -- including national EHDS infrastructure, institutional governance workflows, bilateral agreements, or integration with external data permit services. DIS validates the authorization but is agnostic to its origin.
