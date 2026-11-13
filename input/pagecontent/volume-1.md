
The De-Identification Services (DIS) Profile defines a standardized, policy-governed workflow for de-identification of HL7 FHIR health data. DIS enables authorized requesters to submit de-identification jobs declaring approved de-identification policies and presenting data request authorization evidence, and to receive de-identified output with auditable provenance evidence. The profile supports both synchronous single-patient workflows (such as clinical pseudonymization before external lab ordering or cloud AI invocation) and asynchronous multi-patient cohort workflows (such as cross-border research studies or AI/ML training dataset preparation).

DIS is a **Workflow** profile. It defines four actors, four transactions, a baseline policy execution model, an execution plan format, and a minimum evidence baseline. DIS begins after a data request has been approved — including approval of the de-identification policy to be applied — and the data request authorization has been issued. It does not standardize how a data request is submitted, reviewed, approved, issued, discovered, amended, revoked, or retired.

DIS separates the mandatory HL7 FHIR R4 **protocol binding** from the processing **payload binding**. These are DIS-defined terms: the protocol binding is the HL7 FHIR version used for transaction APIs and workflow resources; the payload binding is the format-specific content model for the data being de-identified. The protocol binding uses HL7 FHIR R4 APIs and resources exclusively for job submission, task dispatch, and status reporting; it is content-neutral and can orchestrate any payload type for which a corresponding payload binding is declared. DIS-FHIR-Payload is the HL7 FHIR payload binding, supporting independently versioned HL7 FHIR R4 and R5 processing payloads over the same R4 protocol binding. Additional payload bindings (e.g., DIS-DICOM1, DIS-CDA1) may be defined independently to support non-FHIR data formats within the same HL7 FHIR R4 protocol layer.

Each processing payload explicitly identifies its format and version. De-Identifiers declare supported payload bindings and versions, and the Manager verifies compatibility before dispatch. Payloads whose version differs from the HL7 FHIR R4 protocol binding are carried or referenced using the payload binding's packaging rules rather than embedded as native resources in the HL7 FHIR R4 transaction envelope. Detailed version identification, packaging rules, and normative requirements are specified in the applicable actor, option, and transaction sections.

<a name="actors-and-transactions"> </a>

<a name="1pxx1-dis-actors-transactions-and-content-modules"> </a>

## 1:PXX.1 DIS Actors, Transactions, and Content Responsibilities

This section defines the actors, transactions, and content responsibilities in the DIS Profile.

DIS defines three deployment models for de-identification processing:

- **Distributed model** -- the De-Identification Requester submits jobs to a De-ID Manager, which validates the policy, compiles an execution plan, and dispatches tasks to one or more De-Identifiers. This model supports staged execution with trust isolation between stages.
- **Integrated model with external Requester** -- the Integrated De-ID Manager/De-Identifier accepts jobs via ITI-x1, combines policy validation, execution plan compilation, and transformation execution within a single actor, and returns output to the Requester. The Integrated actor performs task processing internally.
- **Integrated standalone model** -- the Integrated De-ID Manager/De-Identifier operates without external transactions, producing conformant de-identified output and evidence through local invocation. This model supports lightweight workflows such as clinician-initiated document export (see [Use Case 5](#1pxx425-use-case-5-de-identified-health-data-export-content-conformance)).

Figure 1:PXX.1-1 shows the actors directly involved in the DIS Profile and the relevant transactions between them. The outer boundary represents the Integrated De-ID Manager/De-Identifier, which combines the De-ID Manager and De-Identifier into a single actor. ITI-x3 and ITI-x7 apply only to the distributed model.

<p><a href="dis-actors-and-transactions.png"><img src="dis-actors-and-transactions.png" alt="DIS actors and transactions" width="517" style="max-width: 100%; height: auto;" /></a></p>

**Figure 1:PXX.1-1: DIS Actor Diagram**

Table 1:PXX.1-1 lists the transactions for each actor directly involved in the DIS Profile. To claim compliance with this profile, an actor SHALL support all required transactions (labeled "R") and MAY support the optional transactions. Transactions labeled "C" (Conditional) are required when the corresponding option is declared.

<p id="tPXX.1-1" class="tableTitle"><strong>Table 1:PXX.1-1: DIS Profile - Actors and Transactions</strong></p>

| Actors | Transactions | Initiator or Responder | Optionality | Reference |
|--------|-------------|------------------------|-------------|-----------|
| De-Identification Requester | ITI-x1 Submit De-Identification Job | Initiator | R | ITI TF-2: 3.x1 |
|  | ITI-x4 Retrieve Job Output | Initiator | C (See Note 1) | ITI TF-2: 3.x4 |
| De-ID Manager | ITI-x1 Submit De-Identification Job | Responder | R | ITI TF-2: 3.x1 |
|  | ITI-x3 Submit De-Identification Task | Initiator | R | ITI TF-2: 3.x3 |
|  | ITI-x4 Retrieve Job Output | Responder | C (See Note 1) | ITI TF-2: 3.x4 |
|  | ITI-x7 Retrieve Task Output | Initiator | C (See Note 1) | ITI TF-2: 3.x7 |
| De-Identifier | ITI-x3 Submit De-Identification Task | Responder | R | ITI TF-2: 3.x3 |
|  | ITI-x7 Retrieve Task Output | Responder | C (See Note 1) | ITI TF-2: 3.x7 |
| Integrated De-ID Manager/De-Identifier | ITI-x1 Submit De-Identification Job | Responder | O (See Note 2) | ITI TF-2: 3.x1 |
|  | ITI-x4 Retrieve Job Output | Responder | C (See Note 1, Note 2) | ITI TF-2: 3.x4 |
{: .grid}

Note 1: *ITI-x4 is required when the Asynchronous Job Processing Option (DIS-ASYNC-JOB) is supported. ITI-x7 is required when the Asynchronous Task Processing Option (DIS-ASYNC-TASK) is supported. ITI-x4 enables the Requester to poll for job status and output. ITI-x7 enables the Manager to poll the De-Identifier for task status and output. ITI-x7 does not apply to the Integrated De-ID Manager/De-Identifier.*

Note 2: *The Integrated De-ID Manager/De-Identifier MAY operate standalone without external transactions (content conformance only). When ITI-x1 is supported, the Integrated actor accepts jobs from an external De-Identification Requester. ITI-x4 is required when both ITI-x1 and DIS-ASYNC-JOB are supported.*

Table 1:PXX.1-2 summarizes each actor's required content responsibilities. All actors SHALL support the FHIR payload binding (`DIS-FHIR-Payload`) for their respective roles. Table 1:PXX.1-1 defines which transactions apply.

<p id="tPXX.1-2" class="tableTitle"><strong>Table 1:PXX.1-2: DIS Profile - Actors and Content Responsibilities</strong></p>

| Actor | Required content responsibilities | Volume 3 specifications |
|-------|-----------------------------------|-------------------------|
| De-Identification Requester | Reads the approved policy and identifies it by canonical URL and version. May carry the approved policy content as permitted by ITI-x1. Supplies or identifies the FHIR processing targets and receives output and evidence. | [Policy](volume-3.html#de-identification-policy), [FHIR payload binding](volume-3.html#fhir-payload-binding), [evidence](volume-3.html#evidence-baseline) |
| De-ID Manager | Resolves and validates the approved policy, prepares the execution plan, assigns the FHIR processing targets, and assembles and releases the validated output and evidence. | [Policy](volume-3.html#de-identification-policy), [execution plan](volume-3.html#execution-plan-content), [FHIR payload binding](volume-3.html#fhir-payload-binding), [evidence](volume-3.html#evidence-baseline) |
| De-Identifier | Receives and applies the compiled execution plan to the assigned FHIR targets. Produces de-identified output and evidence. | [Execution plan](volume-3.html#execution-plan-content), [FHIR payload binding](volume-3.html#fhir-payload-binding), [evidence](volume-3.html#evidence-baseline) |
| Integrated De-ID Manager/De-Identifier | Validates the approved policy, prepares and applies the execution plan, and produces validated FHIR output and evidence. The same content requirements apply to standalone operation. | [Policy](volume-3.html#de-identification-policy), [execution plan](volume-3.html#execution-plan-content), [FHIR payload binding](volume-3.html#fhir-payload-binding), [evidence](volume-3.html#evidence-baseline) |
{: .grid}

The [reversible lookup table specification](volume-3.html#3pxx5-reversible-lookup-table) applies where the selected reversible pseudonymization arrangement requires a table. The FHIR payload binding supports independently versioned R4 and R5 payloads.

### 1:PXX.1.1 Actors

The actors in this profile are described in more detail in the sections below.

<a name="de-identification-requester"> </a>

#### 1:PXX.1.1.1 De-Identification Requester

The De-Identification Requester submits a de-identification job to the De-ID Manager with the authorization and each selected payload set with its approved policy canonical and version. In synchronous mode, the Requester receives the result for each payload set in the ITI-x1 response, either as an inline result package or as an authorized HTTPS URL to retrieve it. In asynchronous mode, the Requester polls for job status and results via ITI-x4.

DIS does not standardize how the Requester obtains or discovers a de-identification policy. The Requester declares the approved policy for each payload set by canonical URL and version in ITI-x1. Implementers MAY use any mechanism that produces a valid policy, including local configuration, administrative provisioning, bilateral agreement, or integration with an external policy management system.

<a name="de-id-manager"> </a>

#### 1:PXX.1.1.2 De-ID Manager

The De-ID Manager receives de-identification jobs via ITI-x1, validates the data request authorization and verifies that each payload set's policy matches the policy approved in the authorization, prepares an execution plan for each assigned ruleSet and payload set, dispatches de-identification tasks to De-Identifiers via ITI-x3, and returns de-identified output and provenance evidence to the Requester.

The De-ID Manager retains persistent custody of Manager-managed identity mappings and reversibility records; a Requester may retain and supply its own lookup table for reversible jobs (§1:PXX.2.2). Whether these records are persisted depends on the declared reversibility mode (see [1:PXX.2.2](#1pxx22-reversible-pseudonymization-option) and [1:PXX.2.6](#1pxx26-irreversible-de-identification-option)). See [1:PXX.4.1](#1pxx41-concepts) for the policy model, four-point validation, and policy variants. See [1:PXX.5.4](#1pxx54-reversibility-material-custody) for custody obligations.

<a name="de-identifier"> </a>

#### 1:PXX.1.1.3 De-Identifier

The De-Identifier executes assigned de-identification tasks received via ITI-x3. It applies supplied lookup mappings or derives pseudonyms and other transformation values under the execution plan. Its deployment manages the confidential salts for scoped patient identifier hashing. The Manager validates authorization and scope, and retains mappings when required for reversal. For reversible Manager-managed patient hashing, the De-Identifier returns the generated mappings in a protected DIS Lookup Table. It deletes task-local mapping material at task termination. The Integrated actor performs both roles internally.

A De-Identifier SHALL declare its capabilities, including supported payload families (at least `fhir` for DIS-FHIR-Payload), supported action families (`core` — the base set of [FHIR transformation actions](volume-3.html#transformation-actions) defined for DIS-FHIR-Payload and classified per ISO/IEC 20889:2018, including element removal, value replacement, hashing, date truncation, date shifting, numeric rounding, string truncation, and narrative redaction), supported transformation parameter inputs, and derivation methods. Acceptance of precomputed pseudonyms or date-shift offsets is not mandatory. The De-ID Manager SHALL verify compatibility with the De-Identifier's declared capabilities before dispatching tasks via ITI-x3 and SHALL NOT dispatch an incompatible task.

<a name="integrated-de-id-manager-de-identifier"> </a>

#### 1:PXX.1.1.4 Integrated De-ID Manager/De-Identifier

The Integrated De-ID Manager/De-Identifier combines the functionality of the De-ID Manager and the De-Identifier into a single actor. The Integrated actor performs task processing internally.

The Integrated De-ID Manager/De-Identifier validates de-identification policies, compiles validated policy into execution plans, executes the plans internally, and produces de-identified output and provenance evidence. It performs all Manager obligations (policy validation, execution plan compilation, reversibility material custody) and all De-Identifier obligations (transformation execution, evidence production, capability declaration) within a single actor.

The Integrated De-ID Manager/De-Identifier MAY operate standalone without external transactions, producing conformant de-identified output and evidence through local invocation. When ITI-x1 is supported, the Integrated actor accepts jobs from an external De-Identification Requester and delivers results through the synchronous ITI-x1 response or through ITI-x4 polling when both participants support DIS-ASYNC-JOB and the Requester asks for asynchronous processing.

The Integrated De-ID Manager/De-Identifier follows the same mapping arrangements and custody obligations as the De-ID Manager, including locally supplied lookup tables in standalone mode. Whether these records are persisted depends on the declared reversibility mode. Manager-managed persistent mappings remain within the integrated actor's trust boundary; supplied lookup tables follow §1:PXX.2.2.

An Integrated De-ID Manager/De-Identifier SHALL declare its capabilities using the same structure required of a standalone De-Identifier, including supported payload families (at least `fhir` for DIS-FHIR-Payload), supported action families (`core`), supported transformation parameter inputs, and derivation methods. Staged execution is performed internally; the integrated actor compiles and executes each ruleSet (and stage, when staging is declared) in sequence without externalizing the dispatch.

### 1:PXX.1.2 Transaction Descriptions

The transactions in this profile are summarized in the sections below.

#### 1:PXX.1.2.1 Submit De-Identification Job [ITI-x1]

The Requester submits a de-identification job with the data request authorization and identifies the approved policy for each payload set. The De-ID Manager or Integrated actor validates the submission and orchestrates processing. In synchronous mode, the response returns one result per payload set, with each result package delivered inline or by authorized HTTPS URL. In asynchronous mode, acceptance provides a polling URL for ITI-x4.

For more details see the detailed [transaction description](volume-2.html#23x1-submit-de-identification-job-iti-x1).

#### 1:PXX.1.2.2 Submit De-Identification Task [ITI-x3]

The De-ID Manager dispatches a de-identification task to a De-Identifier with the execution plan for one ruleSet applied to one payload set. In synchronous mode, the De-Identifier returns the result package inline or by authorized HTTPS URL. In asynchronous mode, acceptance provides a polling URL for ITI-x7.

For more details see the detailed [transaction description](volume-2.html#23x3-submit-de-identification-task-iti-x3).

#### 1:PXX.1.2.3 Retrieve Job Output [ITI-x4]

This transaction is used by the De-Identification Requester to retrieve the status and output of a previously submitted asynchronous job. The Requester can also request cancellation of an accepted asynchronous job.

For more details see the detailed [transaction description](volume-2.html#23x4-retrieve-job-output-iti-x4).

#### 1:PXX.1.2.4 Retrieve Task Output [ITI-x7]

The De-ID Manager polls the De-Identifier for the status of an accepted asynchronous task and retrieves its output and evidence when available. With DIS-CANCEL, the Manager can also request cancellation of a task accepted in cancellable mode. This transaction is required when the Asynchronous Task Processing Option (DIS-ASYNC-TASK) is supported. It does not apply to the Integrated De-ID Manager/De-Identifier.

For more details see the detailed [transaction description](volume-2.html#23x7-retrieve-task-output-iti-x7).

<a name="actor-options"> </a>

## 1:PXX.2 DIS Actor Options

Options that may be selected for each actor in this profile are listed in Table 1:PXX.2-1 below. Dependencies between options when applicable are specified in notes. See [Mandatory Baseline](#1pxx21-mandatory-baseline) for requirements that apply independently of the actor options.

<p id="tPXX.2-1" class="tableTitle"><strong>Table 1:PXX.2-1: DIS Profile - Actor Options</strong></p>

| Actor | Option Name | Reference |
|-------|-------------|-----------|
| De-Identification Requester | Asynchronous Job Processing (DIS-ASYNC-JOB) | [1:PXX.2.4](#1pxx24-asynchronous-job-processing-option) |
| De-ID Manager | Asynchronous Job Processing (DIS-ASYNC-JOB) | [1:PXX.2.4](#1pxx24-asynchronous-job-processing-option) |
| De-ID Manager | Asynchronous Task Processing (DIS-ASYNC-TASK) | [1:PXX.2.5](#1pxx25-asynchronous-task-processing-option) |
| De-ID Manager | Asynchronous Task Cancellation (DIS-CANCEL) | [1:PXX.2.7](#asynchronous-cancellation-option) |
| De-ID Manager | Irreversible De-Identification (DIS-IRREVERSIBLE) | [1:PXX.2.6](#1pxx26-irreversible-de-identification-option) |
| De-ID Manager | Reversible Pseudonymization (DIS-REVERSIBLE) | [1:PXX.2.2](#1pxx22-reversible-pseudonymization-option) |
| De-Identifier | Asynchronous Task Processing (DIS-ASYNC-TASK) | [1:PXX.2.5](#1pxx25-asynchronous-task-processing-option) |
| De-Identifier | Asynchronous Task Cancellation (DIS-CANCEL) | [1:PXX.2.7](#asynchronous-cancellation-option) |
| De-Identifier | Irreversible De-Identification (DIS-IRREVERSIBLE) | [1:PXX.2.6](#1pxx26-irreversible-de-identification-option) |
| De-Identifier | Reversible Pseudonymization (DIS-REVERSIBLE) | [1:PXX.2.2](#1pxx22-reversible-pseudonymization-option) |
| Integrated De-ID Manager/De-Identifier | Asynchronous Job Processing (DIS-ASYNC-JOB) | [1:PXX.2.4](#1pxx24-asynchronous-job-processing-option) |
| Integrated De-ID Manager/De-Identifier | Irreversible De-Identification (DIS-IRREVERSIBLE) | [1:PXX.2.6](#1pxx26-irreversible-de-identification-option) |
| Integrated De-ID Manager/De-Identifier | Reversible Pseudonymization (DIS-REVERSIBLE) | [1:PXX.2.2](#1pxx22-reversible-pseudonymization-option) |
{: .grid}

Table 1:PXX.2-2 summarizes the options and their applicability per actor.

<p id="tPXX.2-2" class="tableTitle"><strong>Table 1:PXX.2-2: DIS Profile - Option Matrix</strong></p>

| Option | Requester | Manager | De-Identifier | Integrated Manager/De-Identifier | Dependency / obligation |
|--------|-----------|---------|---------------|-----------------------------------|-------------------------|
| DIS-ASYNC-JOB | Optional | Optional | Not applicable | Optional | Asynchronous job processing. Both participating Requester and Manager (or Integrated actor) support ITI-x4 polling and job cancellation. For the Integrated actor, DIS-ASYNC-JOB requires ITI-x1. |
| DIS-ASYNC-TASK | Not applicable | Optional | Optional | Not applicable | Asynchronous task processing. Both participating Manager and De-Identifier declare support; ITI-x7 required. Not applicable to the Integrated actor. |
| DIS-CANCEL | Not applicable | Optional | Optional | Not applicable | Adds task cancellation to ITI-x7 and requires DIS-ASYNC-TASK. |
| DIS-IRREVERSIBLE | Not applicable | See Note 2 | See Note 2 | See Note 2 | Processing without a DIS-maintained reverse mapping. |
| DIS-REVERSIBLE | Not applicable | See Note 2 | See Note 2 | See Note 2 | Supports Manager-managed mappings and Requester-supplied lookup tables. |
{: .grid}

Note 2: *The De-ID Manager, De-Identifier, and Integrated De-ID Manager/De-Identifier SHALL each declare at least one of DIS-IRREVERSIBLE or DIS-REVERSIBLE and MAY declare both. Each job uses one mode across all payload sets and tasks. In distributed processing, the Manager selects De-Identifiers that support the job's mode.*

### 1:PXX.2.1 Mandatory Baseline

All DIS actors SHALL support the [HL7 FHIR payload binding](#1pxx23-hl7-fhir-payload-binding) (`DIS-FHIR-Payload`) for their respective roles.

External DIS transactions SHALL use the HL7 FHIR R4 protocol binding. Synchronous job processing via ITI-x1 applies to the De-Identification Requester, De-ID Manager, and externally invoked Integrated De-ID Manager/De-Identifier. Synchronous task dispatch via ITI-x3 applies to the De-ID Manager and De-Identifier. The associated workflow resources use R4 (`Task` for submissions, `Parameters` for result responses, `Bundle` for result packages, `Provenance` for evidence, and `OperationOutcome` for errors). The Integrated actor may operate standalone under [content conformance](#1pxx41-concepts) through local invocation.

### 1:PXX.2.2 Reversible Pseudonymization Option

The Reversible Pseudonymization Option (DIS-REVERSIBLE) requires the De-ID Manager (or Integrated De-ID Manager/De-Identifier) to support both Manager-managed mappings and Requester-supplied lookup tables. These are two arrangements within one option, selected by whether the reversible job includes a lookup table.

When reversible mode is selected for a job, the Manager SHALL:

- **No lookup table supplied:** validate and retain the generated lookup table or equivalent identity records needed for authorized reversal before releasing job output. Manager-managed mappings remain under the Manager's persistent custody.
- **Lookup table supplied:** resolve the supplied reference to a persistent identified lookup-table resource, pin its exact content for the job, and validate and use the Requester's lookup table for direct identifiers requiring reversible mapping. The supplied mappings are authoritative for that job; the Manager SHALL NOT substitute generated pseudonyms or add missing entries. Persistent retention by the Manager is not required. Temporary copies SHALL be deleted at job termination unless retention is explicitly authorized.
- For a Requester-supplied table, verify that each direct identifier requiring mapping has exactly one applicable entry. Missing or ambiguous entries SHALL cause synchronous rejection when discovered before acceptance. If discovered after asynchronous acceptance, the Manager SHALL mark the job failed. In either case, no partial output SHALL be released.
- Require the approved policy to authorize lookup-backed replacement for the affected direct identifiers. A supplied table SHALL NOT override a hash or fixed-value rule; incompatible policy/table combinations SHALL be rejected without silently rewriting the approved policy.
- Require the De-Identifier to apply patient identifier mappings consistently and protect lookup tables as sensitive identity-linking material.

A De-Identifier declaring DIS-REVERSIBLE SHALL support task-scoped lookup-backed replacement as well as deterministic pseudonym derivation for Manager-managed mappings. The Manager SHALL supply only the entries required by the assigned task over a protected channel. The De-Identifier SHALL use them only for that task and delete them at task termination. Lookup-backed replacement uses the existing `replace` action; the action set is unchanged. See Volume 3 for the lookup-table content binding.

UC-3 and UC-4 illustrate authorized, implementation-defined access to the Manager's mapping service for patient association. Such access returns only the resolution result needed by the EHR and does not export the identity table or pseudonym index. DIS does not standardize this interaction or introduce a re-identification transaction.

<a name="1pxx23-hl7-fhir-payload-option"> </a>

### 1:PXX.2.3 HL7 FHIR Payload Binding

The mandatory HL7 FHIR payload binding (`DIS-FHIR-Payload`) defines the content model and baseline execution plan. It specifies FHIRPath addressing, resource traversal, narrative handling, Provenance-based evidence, inline submission, authorized retrieval of referenced inputs, and result delivery. It covers independently versioned HL7 FHIR R4 and R5 processing payloads. Actors declare the releases they support. See [Volume 3](volume-3.html#fhir-payload-binding) for the binding requirements.

Future payload bindings could define format-specific content and processing rules for other data formats over the same HL7 FHIR R4 protocol. See [Open Issues](issues.html#additional-payload-binding-conformance).

#### 1:PXX.2.3.1 Baseline Execution Plan

DIS-FHIR-Payload defines a baseline execution plan model for HL7 FHIR payloads: flat, ordered rule lists carried as HL7 FHIR Library resources. The Library resource serves as a metadata-rich knowledge artifact carrier; the execution plan content is a DIS-specific format carried within `Library.content` and is not CQL or another pre-existing Library content type. Baseline execution plans SHALL NOT require policy composition, condition evaluation, cross-element constraints, conflict resolution strategies, or selector specificity rules. The full Composable Execution Plan (DIS-EXE1), including these features, is outside the scope of this supplement.

The De-ID Manager dispatches a separate execution plan for each ruleSet through ITI-x3. When the policy declares stages, the Manager groups ruleSet dispatch by stage ordering. When stages are absent, the Manager follows the single-stage execution rules in [Volume 3](volume-3.html#3pxx13-policy-rules-json-structure).

The execution plan model is payload-specific. Each payload binding defines its own execution plan structure appropriate to its data standard. The policy layer, not the execution plan, serves as the cross-payload abstraction for de-identification requirements.

#### 1:PXX.2.3.2 Cross-Version Payload Support

DIS-FHIR-Payload supports processing payloads whose HL7 FHIR version differs from the HL7 FHIR R4 protocol binding. Through the same R4 transactions, actors can submit HL7 FHIR R5 processing payloads. This cross-version support rests on four design properties:

- **Version identification** -- each processing payload SHALL explicitly identify its HL7 FHIR version. De-Identifiers SHALL declare which payload versions they support, and the Manager SHALL verify compatibility before dispatch. HL7 FHIR payloads SHALL be validated against their declared version.
- **Version-safe packaging** -- an HL7 FHIR payload whose version differs from the HL7 FHIR R4 protocol binding is carried or referenced using the payload binding's packaging rules. It SHALL NOT be embedded as a native resource of the payload version in the HL7 FHIR R4 transaction envelope. Packaging patterns are specified in the [FHIR payload binding](volume-3.html#fhir-payload-binding).
- **Version-neutral policy targets** -- Semantic-Level policies use common semantic group codes. The Manager resolves each code to FHIRPath selectors for the declared payload release during compilation. Volume 3 defines the [Semantic Group Binding](volume-3.html#3pxx3213-semantic-group-bindings).
- **Evidence across versions** -- de-identification evidence is represented as HL7 FHIR R4 Provenance (protocol layer, not payload). The evidence model does not depend on the payload's HL7 FHIR version.

HL7 FHIR R4 protocol resources (`Task`, `Parameters`, `Provenance`, `OperationOutcome`, `Bundle` used for workflow packaging) remain HL7 FHIR R4 regardless of the payload version.

### 1:PXX.2.4 Asynchronous Job Processing Option

The Asynchronous Job Processing Option (DIS-ASYNC-JOB) enables the De-Identification Requester and De-ID Manager (or Integrated actor) to support asynchronous job-level workflows. The Requester submits an asynchronous ITI-x1 request and uses ITI-x4 to poll for job status and retrieve de-identified output and evidence.

Both the participating Requester and Manager (or Integrated actor) SHALL declare DIS-ASYNC-JOB and SHALL support ITI-x4 (Retrieve Job Output). The Integrated actor SHALL support ITI-x1 when declaring DIS-ASYNC-JOB. This option is required for multi-patient cohort workflows where processing time exceeds the request timeout. HTTP-level message semantics are specified in the ITI-x1 and ITI-x4 [transaction descriptions](volume-2.html).

Support for DIS-ASYNC-JOB includes the ITI-x4 job cancellation interaction. The Requester SHALL support sending an authorized cancellation request. The Manager and externally invoked Integrated actor SHALL handle authorized cancellation requests. The Manager SHALL reject cancellation of an active job while any dispatched non-cancellable assignment is outstanding, including one awaiting acknowledgement. Once those assignments reach known terminal states, they no longer block cancellation. If the Manager accepts cancellation, it SHALL stop new dispatch and local work, withhold job results, and cancel outstanding cancellable assignments. The Integrated actor handles its local work. See the [job cancellation requirements](volume-2.html#job-cancellation).

### 1:PXX.2.5 Asynchronous Task Processing Option

The Asynchronous Task Processing Option (DIS-ASYNC-TASK) enables the De-ID Manager and De-Identifier to support asynchronous task-level workflows. For an asynchronous ITI-x3 exchange, the De-ID Manager uses ITI-x7 (Retrieve Task Output) to poll for task status and retrieve output and evidence upon successful completion.

Both the participating De-ID Manager and De-Identifier SHALL declare DIS-ASYNC-TASK and SHALL support ITI-x7. This option does not apply to the Integrated De-ID Manager/De-Identifier.

Ordinary async job and task processing can be selected independently. A Manager may support async jobs without async tasks, or async tasks without async jobs.

### 1:PXX.2.6 Irreversible De-Identification Option

The Irreversible De-Identification Option (DIS-IRREVERSIBLE) requires that, when irreversible mode is selected for a job, the Manager SHALL NOT create or persist a reverse-mapping table and SHALL NOT retain identity tables or pseudonym indices after job completion. The De-Identifier generates and applies one-way pseudonyms under the authorized derivation contract and deletes task-local secrets and linking material at termination. Supplied reversible lookup tables are not permitted in this mode.

Irreversible mode denotes the absence of a DIS-maintained reverse-mapping capability; it does not guarantee that individuals cannot be identified through other information. Retained derivation secrets may permit reproduction and matching against candidate identities. The authorized policy SHALL specify the consistency scope. The De-Identifier’s deployment manages the salt version and protected retention within the authorized scope. It SHALL retire job-scoped material at job termination so that it cannot be used for another job. Material retained for authorized cross-job consistency SHALL be protected, scoped and destroyed when the authorized retention period ends. Such retention SHALL NOT include a patient-to-pseudonym index and SHALL be disclosed as a limitation of the irreversible-mode claim.

At least one of DIS-IRREVERSIBLE or DIS-REVERSIBLE SHALL be declared by the De-ID Manager, De-Identifier, and Integrated De-ID Manager/De-Identifier. An actor MAY declare both options to indicate it supports both modes.

Each job SHALL use one reversibility mode for all its payload sets and de-identification tasks. Different payload sets MAY use different approved policies. All policies used in the job SHALL declare the same reversibility mode.

<a name="asynchronous-cancellation-option"> </a>

<a name="1pxx27-asynchronous-cancellation-option"> </a>

### 1:PXX.2.7 Asynchronous Task Cancellation Option

The Asynchronous Task Cancellation Option (DIS-CANCEL) enables the De-ID Manager to cancel a de-identification task accepted in cancellable mode through ITI-x7. Both the Manager and De-Identifier SHALL declare DIS-ASYNC-TASK and DIS-CANCEL before the Manager requests cancellable mode for a task. See the [task cancellation requirements](volume-2.html#task-cancellation).

<a name="required-groupings"> </a>

## 1:PXX.3 DIS Required Actor Groupings

An actor from this profile (Column 1) SHALL implement all applicable transaction and content requirements in this profile ***in addition to*** ***<u>all</u>*** of the requirements for the grouped actor (Column 2). Table 1:PXX.3-1 lists the required actor groupings.

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

DIS actors SHALL use the ATNA groupings specified in Table 1:PXX.3-1. The Requester groups with Secure Application. The Manager, De-Identifier, and Integrated actor each group with Secure Node or Secure Application.

The De-ID Manager and the Integrated De-ID Manager/De-Identifier SHALL be grouped with IUA Authorization Client or Resource Server to ensure that system-to-system authorization is enforced for job submission (ITI-x1) and output retrieval (ITI-x4). Implementations SHOULD use SMART Backend Services for automated system-to-system workflows.

<a name="overview"> </a>

## 1:PXX.4 DIS Overview

This section shows how the transactions of the DIS Profile are combined to address the use cases.

### 1:PXX.4.1 Concepts

DIS introduces the following key concepts that provide necessary background for understanding the profile.

<a name="job-and-execution-task"></a>

#### 1:PXX.4.1.1 De-Identification Job and De-Identification Task

- **De-Identification Job.** The overall de-identification work authorized for one request. It covers all selected payload sets, each with its own approved policy version, and includes coordinating the assignments and validating the results for release. The Requester submits an external job through ITI-x1 with the data request authorization.
- **De-Identification Task.** An assignment within a job that applies one ruleSet to one payload set or subset using one execution plan. When a policy declares stages, each assigned ruleSet belongs to one stage, which determines its place in the execution order. In distributed processing, the De-ID Manager dispatches the task through ITI-x3. The Integrated actor performs assignments locally.

After accepting a de-identification job for distributed processing, the De-ID Manager creates one or more de-identification tasks. In UC-2, one job selects two payload sets, each with one ruleSet. The Manager creates one task for the R4 clinical and laboratory records and another for the R5 CT measurements. The Manager dispatches each task to its assigned De-Identifier and assembles both validated results for the original job. [UC-2 worked example](examples-grouped-fhir-job.html)

The Manager tracks which job, set, ruleSet, and stage each assignment belongs to. It uses that association to validate results, coordinate cancellation, and link audit records. A De-Identifier receives the information needed for its assignment. See the [assignment correlation and disclosure rules](volume-2.html#assignment-correlation).

The ITI-x1 job submission uses a FHIR R4 `Task` resource conforming to the [De-Identification Job profile](StructureDefinition-DIS-DeIdentificationJob.html). The ITI-x3 task submission uses a FHIR R4 `Task` resource conforming to the [De-Identification Task profile](StructureDefinition-DIS-DeIdentificationTask.html). Each payload set declares its processing payload release independently, as described in [Cross-Version Payload Support](#1pxx232-cross-version-payload-support).

#### 1:PXX.4.1.2 Policy, Payload, and Evidence

**Policy-Governed De-Identification.** DIS separates policy approval from policy execution. DIS assumes the De-Identification Requester can read the exact approved policy through an implementation-defined mechanism. The Requester declares the approved policy's canonical URL and version for each payload set. The De-ID Manager checks that both the declaration and the policy rules match the data request authorization. The Requester may carry the JWS-signed policy in `policyContent` or let the Manager resolve the declared version through its trust model.

The De-ID Manager validates all policies:

1. **Authorization consistency** -- the declared policy URL and version match the policy approved in the data request authorization
2. **Integrity** -- when the Requester carries policy content, the JWS signature is cryptographically valid and issued by a trusted authority, and the Library's canonical URL and version match the declared values. When the Manager resolves the policy itself, it uses its resolution trust model. In both cases the Manager verifies that the rules are the exact content bound to the approved policy version.
3. **Schema conformance** -- the policy content conforms to the expected schema
4. **Currency** -- the policy is not expired or revoked

A de-identification policy is a reusable knowledge artifact. The same policy may be approved for multiple independent data requests. The data request authorization is the per-request evidence that a data governance authority approved a specific data request — including identification of the de-identification policy to be applied. The authorization binds each set to its approved policy version. Applying changed rules or a different version requires approval for the data request.

Every ITI-x1 request declares the approved policy for each payload set by canonical URL and version. The Requester may also carry the policy content for each set.

- **Policy content carried (`policyContent` present)** -- the job submission carries the JWS-signed policy Library in a contained `Binary` resource referenced by the set. The Manager verifies the JWS signature and confirms the Library's canonical URL and version match the declared values. The Requester obtains the signed artifact through its implementation-defined mechanism.
- **Policy content resolved by Manager (`policyContent` absent)** -- the Manager resolves the declared policy version by implementation-defined means.

A policy may be authored at the Semantic-Level or the Syntax-Level. A Semantic-Level policy uses semantic group references (`@subject-identifiers`, `@dates`, etc.) and is format-neutral -- it can be reused across data formats and use cases. Before execution, the Manager compiles it into a payload-specific execution plan. A Syntax-Level policy uses concrete element paths (FHIRPath, DICOM tags, etc.) for a specific payload family and version -- it is directly executable after validation. Both levels go through the same four-point validation. Both are approved by the joint privacy team.

**RuleSets and Staged Execution.** DIS organizes de-identification rules into ruleSets -- named groups of rules with shared data-semantic character. A policy contains one or more ruleSets. Optionally, a policy may declare stages that reference ruleSet IDs to define execution ordering and trust isolation boundaries. When stages are declared, a preliminary stage typically handles direct identifiers (hashing, removal), and an advanced stage applies policy-specified record-level rules to quasi-identifiers. For each payload set, the De-ID Manager dispatches one ITI-x3 task per assigned ruleSet and follows the declared stage ordering when stages are present. Each De-Identifier receives its assigned plan and authorized stage inputs. Volume 3 defines how validated results move between stages. For a distributed payload set that uses multiple stages, the Manager records the validated execution in [staged release evidence](volume-3.html#staged-release-evidence) associated with the final result.

**De-Identification Technique Classification.** DIS transformation actions are classified per ISO/IEC 20889:2018 *Privacy enhancing data de-identification terminology and classification of techniques*. Each DIS action code carries an ISO/IEC 20889 `technique` attribute tracing the action to its §9 classification. DIS actions are concrete operational instructions (what the De-Identifier does); ISO techniques are the classification framework. Action design is informed by the RSNA CTP DICOM Anonymizer function patterns. Table 1:PXX.4-2 maps the core actions to their ISO technique classification.

<p id="tPXX.4-2" class="tableTitle"><strong>Table 1:PXX.4-2: Core Transformation Actions — ISO/IEC 20889 Classification</strong></p>

| ISO/IEC 20889 §9 Category | ISO Technique | DIS Action | Function |
|---|---|---|---|
| §9.3 Suppression | Local suppression (§9.3.3) | `remove` | `(element) → ∅` |
| §9.3 Suppression | Local suppression (§9.3.3) | `redact` | `(narrative) → ∅` |
| §9.3 Suppression / §9.4 Pseudonymization | Masking (§9.3.2) / lookup-table pseudonymization (§9.4.3.2) | `replace` | Fixed replacement or authoritative lookup-backed replacement |
| §9.4 Pseudonymization | Hashing (§9.4.3.3) | `hash` | `(value, mode, algorithm, scope?) → digest` |
| §9.6 Generalization | Rounding (§9.6.2) | `truncate-date` | `(date, precision) → truncated` |
| §9.6 Generalization | Rounding (§9.6.2) | `round` | `(value, step) → binned` |
| §9.6 Generalization | Generalization (§9.6) | `truncate` | `(value, length) → shortened` |
| §9.7 Randomization | Noise addition (§9.7.2) | `date-shift` | `(date, scope, maxDays) → shifted` |
| — | — | `keep` | `(element) → element` |
{: .grid}

ISO/IEC 20889 categories outside the scope of this supplement include statistical tools (§9.1 — sampling, aggregation), cryptographic tools (§9.2 — deterministic/format-preserving/homomorphic encryption), anatomization (§9.5), randomization techniques beyond noise addition (§9.7.3 — permutation, §9.7.4 — microaggregation), synthetic data (§9.8), and the formal privacy measurement models (§10 — k-anonymity, l-diversity, t-closeness, differential privacy). Lookup-table-based pseudonymization (ISO §9.4.3.2 — pseudonyms independent of identifying attributes) is supported through lookup-backed `replace` under DIS-REVERSIBLE.

**Transformation Scope.** DIS excludes dataset- or database-level de-identification techniques, including small-cell handling, frequency-based rare-condition suppression, and transformations requiring statistics computed across the cohort (ISO/IEC 20889 §9.1 statistical tools, §9.7.4 microaggregation, §10 formal privacy measurement models). Multi-patient cohort processing remains supported for applying record-level rules with policy-specified parameters. Staged execution does not extend this action scope. Dataset-level statistical disclosure control is outside this supplement; completing a DIS workflow does not establish that any separately required dataset-level disclosure criteria have been met.

**Resource Manifest Input and Output.** A [DIS Resource Manifest](volume-3.html#resource-manifest) uses an R4 List to enumerate targets for one payload set. For FHIR the entries reference the target resources. The draft DICOM and CDA bindings illustrate how entries can reference R4 indexes to the native content. A manifest can identify inputs or de-identified results.

**Bulk Data Input and Output.** DIS supports both input and output for asynchronous cohort jobs using manifests referencing NDJSON files. The Requester supplies a manifest referencing prepared input files; obtaining those files through source-system export is outside DIS. The Manager returns a manifest referencing de-identified output files together with evidence references. Processing remains limited to the action scope described above.

Each processing payload SHALL explicitly identify its HL7 FHIR version (R4 or R5), independently of the HL7 FHIR R4 protocol binding. Participating actors SHALL declare supported input/output formats and payload versions, and the Manager SHALL verify compatibility before dispatch. File retrieval SHALL require authorization. Recipient-facing manifests and files SHALL NOT contain confidential salts or other protected transformation material. A failed job SHALL NOT release a partial dataset; failures SHALL be reported through job status.

Volume 3 specifies [input manifest fields and retrieval authorization](volume-3.html#obtaining-processing-targets). Volume 2 defines the DIS transactions for returning task and job results.

**Reversibility Custody.** When reversible pseudonymization is selected without a supplied lookup table, the De-ID Manager retains the mapping needed for reversal. With a Requester-supplied table, the Manager uses that table without mandatory persistent retention. The De-Identifier is stateless with respect to reversibility. Manager-managed persistent mappings remain within the Manager's trust boundary; task-scoped entries may be shared as specified in §1:PXX.2.2.

**Consistency Scope and Transformation Material.** The approved policy declares the authorized `identity-linkage-scope`. A `job` scope is limited to one job and its tasks and retries. A `source-institution` scope supports authorized reuse across jobs of one source institution. A `cross-community` scope supports authorized reuse across participating communities. Source-institution and cross-community policies identify the scope with an identifier system and value. The Manager validates authorization and resolves a job-level scope to a stable job-specific identifier. The Manager copies the resolved scope into each salted `hash` rule.

The De-Identifier’s deployment generates or provisions distinct confidential salts per scope and salt version. Workers that must agree use the same effective salt and version. The De-Identifier follows the exact encoding in [Volume 3](volume-3.html#3pxx123-patient-identifier-pseudonymization). Matching results depend on the same source identifier system and value, scope, and salt. A change of salt defines a new derivation context.

Cross-community identity resolution, scope authorization, and coordination of the effective salt, version and lifecycle are deployment prerequisites outside DIS. Implementations claiming cross-community consistency SHALL establish those prerequisites. Supplied lookup tables use their authorized mappings under §1:PXX.2.2.

Date-shift reference dates and offsets are protected transformation parameters, not consistency keys. Deterministic derivation from purpose-specific seeds is preferred. Where a De-Identifier generates a parameter that SHALL be reused, an explicit capability contract SHALL define its protected return to the Manager, authorized retention, and reuse in subsequent tasks. Acceptance of precomputed parameters is not mandatory for all De-Identifiers. Protected transformation parameters follow §1:PXX.5.4.

**Evidence Baseline.** Every completed de-identification task produces provenance evidence containing at minimum nine elements: evidence identifier, outcome status, workflow reference, target identifier, policy-decision reference, ruleSet identifier, reversibility state, validation status, and audit correlation identifier.

**Conformance Layers.** DIS defines two conformance layers:

- **Content conformance.** The Integrated actor validates the approved policy, prepares and applies the execution plan, and produces output and provenance evidence that satisfy the applicable FHIR payload and evidence requirements. The Integrated De-ID Manager/De-Identifier is the actor for content conformance claims. It MAY operate standalone without external transactions, producing conformant output through local invocation.
- **Transaction conformance** -- actors participate in external DIS transactions (ITI-x1, ITI-x3, ITI-x4, ITI-x7). Transaction conformance applies when actors communicate over standardized interfaces. The distributed model (Requester, Manager, De-Identifier) requires transaction conformance. The Integrated actor adds transaction conformance when it supports ITI-x1 (and optionally ITI-x4).

Content conformance is the foundation. An Integrated actor operating standalone claims content conformance only. When the Integrated actor also supports ITI-x1, it claims both content and transaction conformance. In the distributed model, the De-ID Manager and De-Identifier each claim transaction conformance for their respective transactions; the Manager is responsible for ensuring that the combined output achieves content conformance.

**Payload Binding Framework.** DIS separates the mandatory HL7 FHIR R4 protocol binding from the payload binding so that additional data formats can be supported without changing the protocol layer. The protocol binding defines how transactions are initiated, dispatched, and polled -- it is content-neutral and carries or references payloads of any format. Each payload binding defines the format-specific rules for a particular data format family. This supplement defines DIS-FHIR-Payload. Additional payload bindings could follow the same architectural pattern.

**Jobs with multiple payload sets.** A job can include several sets under one data request authorization, for example two FHIR sets with different releases or approved policies. Each set has a job-local identifier and declares its own payload binding, version, manifest, and approved policy. The Manager dispatches tasks for individual sets and returns the validated results together. Where outputs depend on consistent identifiers across sets, the selected bindings and policies must define the linkage and validation contract before the Manager accepts the job.

Each payload set uses the [common manifest contract](volume-3.html#payload-set-delivery) for bundled or hosted content. Each binding defines how manifest entries resolve to native payloads. The payload set encoding applies even when the job contains only one set.

A payload binding defines at minimum:

1. **Content model** -- how data elements within the format are identified and addressed (e.g., FHIRPath for HL7 FHIR resources, DICOM tag paths for DICOM objects, XPath or CDA document model paths for CDA documents)
2. **Transformation action mapping** -- how the DIS core transformation actions (removal, replacement, hashing, rounding, truncation, etc.) are applied to the format's data structures and element types
3. **Processing targets and results** -- how actors obtain processing inputs and deliver results, including inline content and authorized retrieval of referenced resources or files
4. **Evidence mapping** -- how de-identification evidence and provenance are represented for the format, mapping format-specific outcomes to the DIS evidence baseline
5. **Version identification** -- how the payload's format version is declared, validated, and matched against De-Identifier capabilities
6. **Packaging rules** -- how a payload in this format is carried within or referenced from the HL7 FHIR R4 transaction envelope without being embedded as a native HL7 FHIR resource

The [draft DICOM and CDA examples](draft-native-payload-bindings.html) are informative and illustrate how this framework can support additional data formats.

An actor declares which payload bindings it supports. The De-ID Manager verifies payload binding compatibility between the Requester's job and the De-Identifier's declared capabilities before dispatching tasks. Each payload set uses one binding and version. The Manager dispatches and validates each set under its declared binding. The framework can accommodate additional data format families as their bindings are defined.

Each future payload binding is developed as a self-contained specification, independent of other payload bindings. A new payload binding does not require changes to the HL7 FHIR R4 protocol binding or to previously defined payload bindings. This independence enables parallel development by different IHE domains or working groups, and allows implementations to adopt additional payload support incrementally.

### 1:PXX.4.2 Use Cases

<p id="tPXX.4-3" class="tableTitle"><strong>Table 1:PXX.4-3 — Use Cases and Worked Examples</strong></p>

| Use case | What it demonstrates |
|----------|----------------------|
| [UC-1 — Cross-Border Epidemiological Study](#1pxx421-use-case-1-cross-border-epidemiological-study-using-ips) | Two-stage asynchronous Bulk FHIR processing, irreversible pseudonymization, staged release Provenance, and job cancellation. [Worked example](examples-bulk-fhir-cohort.html) |
| [UC-2 — Multimodal AI/ML Input Preparation](#uc-2) | Separate R4 clinical and lab data and R5 CT measurements in one asynchronous job, with synchronous worker tasks and recovery of a lost acceptance. [Worked example](examples-grouped-fhir-job.html) |
| [UC-3 — Clinical Pathology Order](#1pxx423-use-case-3-clinical-pathology-order-pseudonymous-care) | Synchronous reversible pseudonymization with a Manager-resolved Semantic-Level policy, preserving the order’s link to the patient. [Worked example](examples-reversible-pathology.html) |
| [UC-4 — Cloud Decision Support](#1pxx424-use-case-4-ai-assisted-clinical-decision-support-cloud-deployment) | Synchronous reversible pseudonymization with a requester-carried, JWS-signed Syntax-Level policy, versioned input references, and hospital-side mapping custody. [Worked example](examples-cloud-decision-support.html) |
| [UC-5 — Local Clinical Export](#1pxx425-use-case-5-de-identified-health-data-export-content-conformance) | Standalone de-identification of a FHIR document using a local policy, with Provenance and audit correlation. [Worked example](examples-standalone-export.html) |
{: .grid}

#### 1:PXX.4.2.1 Use Case 1: Cross-Border Epidemiological Study Using IPS+

A research consortium conducts a cross-border epidemiological study combining population-based cancer-registry data with selected clinical information originally collected for healthcare delivery. The study examines incidence, treatment patterns, comorbidities, outcomes, and survival across participating jurisdictions. In this use case, IPS+ means the International Patient Summary (IPS) together with the additional clinical and registry records authorized for the study. [International Patient Summary Implementation Guide](https://hl7.org/fhir/uv/ips/2.0.1/en/index.html)

##### 1:PXX.4.2.1.1 Cross-Border Epidemiological Study Use Case Description

Clinical data remain under primary-use governance when recorded or exchanged for care. Their reuse begins only after a secondary-use request has been assessed and an authorization context has been issued. The Data Access Coordinator (DAC) coordinates participating jurisdictions, resolves authorized source-data provision, and -- acting as the De-Identification Requester -- submits a DIS job to produce a cohort dataset transformed by pseudonymization and policy-specified record-level rules for subsequent delivery to a Secure Processing Environment (SPE).

The DAC submits an asynchronous de-identification job through ITI-x1 with the data request authorization, the approved policy canonical and version, and a Bulk FHIR manifest that selects the prepared cohort. The Manager resolves that exact policy version from its trusted policy store and validates it against the authorization before accepting the job. It compiles a separate plan for each of the two assigned ruleSets.

The preliminary ruleSet pseudonymizes direct identifiers with irreversible, project-scoped pseudonyms within the authorized scope identified by `identity-linkage-scope`, using the same authorized scope and deployment-provisioned salt version to preserve linkage for matching source identifier pairs within the de-identified dataset. The advanced ruleSet applies policy-specified record-level transformations such as reducing birth dates to year precision. Small-cell handling and transformations requiring cohort statistics are outside DIS; any required dataset-level assessment or processing occurs outside this DIS workflow before release to the SPE.

Because DIS-IRREVERSIBLE is declared, the De-ID Manager does not retain identity tables or pseudonym indices after job completion. No DIS reverse-mapping service is maintained; this does not exclude identification through auxiliary information or reproduction using retained derivation secrets.

Each stage has one assigned ruleSet. The Manager dispatches the corresponding asynchronous de-identification task through ITI-x3 and polls the assigned De-Identifier through ITI-x7. The Manager validates the preliminary output before dispatching the advanced task with that validated input. It validates the final output, rechecks release authorization, and records staged release Provenance. The DAC retrieves the cohort and its evidence through ITI-x4, then forwards the cohort to the SPE outside the DIS exchange.

The [UC-1 Bulk FHIR cohort example](examples-bulk-fhir-cohort.html) shows both stages, release evidence, NDJSON delivery, and a job cancellation variant.

##### 1:PXX.4.2.1.2 Cross-Border Epidemiological Study Process Flow

<p><a href="dis-uc1-cross-border-study.png"><img src="dis-uc1-cross-border-study.png" alt="Cross-border epidemiological study process flow" width="784" style="max-width: 100%; height: auto;" /></a></p>

**Figure 1:PXX.4.2.1.2-1: Use Case 1 - Cross-Border Epidemiological Study Process Flow**

<a name="1pxx422-use-case-2-multimodal-aiml-method-development-hl7-fhir-input-preparation"></a>

<a name="uc-2"></a>

#### 1:PXX.4.2.2 Use Case 2: FHIR Input Preparation for Multimodal AI/ML

An AI/ML consortium prepares a lung cancer cohort for model development or validation. The approved data include clinical records, laboratory results, and structured CT measurements. DIS prepares these FHIR inputs for the cohort release. Native DICOM processing is outside the scope of this supplement. The [illustrative FHIR and DICOM extension](draft-native-payload-bindings.html#illustrative-mixed-fhir-and-dicom-job) shows how a future binding could add a separate native imaging payload set to the same job.

##### 1:PXX.4.2.2.1 AI/ML Method Development Use Case Description

The consortium holds a data permit identifying the approved cohort, inputs, purposes, policies, and linkage requirements. Acting as the De-Identification Requester, the DAC submits one asynchronous de-identification job through ITI-x1 with two FHIR payload sets. One set declares R4 and selects clinical records and laboratory results. The other declares R5 and carries CT-derived measurements as [R5 Observation](https://hl7.org/fhir/R5/observation.html) resources. The DIS requests, responses, and evidence use R4 for both sets.

The Manager validates the permit and both approved policies before accepting the job and returning a polling URL. Each set uses one ruleSet. The R4 policy removes `Patient.name` and preserves links from the laboratory results to the output Patient. The R5 policy retains the CT measurements and removes the patient reference because the permit authorizes those measurements for independent analysis. The job selects irreversible processing. A `setId` correlates each set with its task and result within the job.

The Manager dispatches a synchronous de-identification task through ITI-x3 for each set and validates both results. The job remains asynchronous at the Requester–Manager interface. If the acceptance response is lost, the DAC can recover the original polling URL using the same submission and the recovery header. After rechecking release authorization, the Manager makes both sets and their evidence available through ITI-x4. The DAC delivers the approved FHIR output to the SPE outside DIS.

The [UC-2 mixed-version FHIR example](examples-grouped-fhir-job.html) shows submission recovery, a task and policy for each payload version, and release of both results.

##### 1:PXX.4.2.2.2 AI/ML Method Development Process Flow

<p><a href="dis-uc2-ai-ml-development.png"><img src="dis-uc2-ai-ml-development.png" alt="Multimodal AI and ML FHIR input preparation process flow" width="784" style="max-width: 100%; height: auto;" /></a></p>

**Figure 1:PXX.4.2.2.2-1: Use Case 2 - FHIR Input Preparation for Multimodal AI/ML Process Flow**

#### 1:PXX.4.2.3 Use Case 3: Clinical Pathology Order (Pseudonymous Care)

A hospital EHR pseudonymizes patient context before sending a laboratory order to an external pathology lab. The lab operates under a pseudonymous-care model and processes orders referencing only the pseudonym.

##### 1:PXX.4.2.3.1 Clinical Pathology Order Use Case Description

Institutional policy prohibits the external lab from seeing direct patient identifiers. The EHR submits a synchronous de-identification job through ITI-x1 with care-context authorization, the canonical and version of a hospital-approved Semantic-Level policy, and an inline manifest package selecting the `Patient` and `ServiceRequest`. The Manager resolves the declared policy version from its institutional policy store.

The Manager validates the authorization and policy, then dispatches a synchronous de-identification task through ITI-x3 with the compiled plan for one ruleSet. The De-Identifier assigns a scoped pseudonym and preserves the `ServiceRequest.subject` link to the pseudonymized `Patient`. Matching source identifier pairs yield the same pseudonym when the worker uses the same authorized scope, effective salt, and salt version. The EHR uses that consistency to correlate later lab results. The Manager returns the pseudonymized result package and evidence inline through ITI-x1.

The De-Identifier returns the generated lookup table to the Manager, which validates and retains the mapping before release. The EHR sends the pseudonymized order to the lab. When the result comes back with the pseudonym, the EHR uses an authorized, implementation-defined resolution interaction to associate it with the correct chart. The Manager provides only the resolution result needed for that association. The lab exchange and resolution occur outside DIS.

The [reversible pathology example](examples-reversible-pathology.html) illustrates the Manager-managed mapping and evidence flow.

##### 1:PXX.4.2.3.2 Clinical Pathology Order Process Flow

<p><a href="dis-uc3-clinical-pathology.png"><img src="dis-uc3-clinical-pathology.png" alt="Pseudonymous clinical pathology order process flow" width="784" style="max-width: 100%; height: auto;" /></a></p>

**Figure 1:PXX.4.2.3.2-1: Use Case 3 - Clinical Pathology Order Process Flow**

#### 1:PXX.4.2.4 Use Case 4: AI-Assisted Clinical Decision Support (Cloud Deployment)

A hospital EHR pseudonymizes patient data before transmitting to a cloud-hosted AI service for clinical decision support. The AI service operates outside the hospital trust boundary and receives only pseudonymized data.

##### 1:PXX.4.2.4.1 AI-Assisted Clinical Decision Support Use Case Description

A clinician triggers AI decision support for an active encounter. The EHR submits a synchronous de-identification job through ITI-x1 to the on-premise Manager with a requester-carried, signed Syntax-Level R4 policy and its approved canonical and version. A versioned HTTPS manifest selects the `Patient` and the authorized linked clinical resources, such as `Observation` and `Encounter`. The Manager verifies the signature and the approved policy identity. The Manager dispatches a synchronous de-identification task through ITI-x3 to an on-premise De-Identifier. The output clinical references remain linked to the pseudonymized `Patient`.

The De-Identifier returns the output and evidence to the Manager. When it generates patient mappings, it also returns the protected `generatedLookupTable`. The Manager validates and retains the mappings before releasing the pseudonymized result and evidence to the EHR through ITI-x1. The EHR sends the pseudonymized clinical data to the cloud service outside DIS and receives recommendations referencing the pseudonym.

The EHR uses an authorized, implementation-defined interaction with the Manager's mapping service to associate the AI output with the correct patient chart. The Manager retains custody of the identity table and pseudonym index and returns only the resolution result needed for that association. This interaction is outside the transactions standardized by DIS.

The identity table, pseudonym index, and confidential salts remain inside the hospital trust boundary. The [UC-4 cloud decision support example](examples-cloud-decision-support.html) shows the signed policy, the versioned manifest, and the hospital-side mapping and evidence flow.

##### 1:PXX.4.2.4.2 AI-Assisted Clinical Decision Support Process Flow

<p><a href="dis-uc4-cloud-decision-support.png"><img src="dis-uc4-cloud-decision-support.png" alt="Cloud-based clinical decision support process flow" width="784" style="max-width: 100%; height: auto;" /></a></p>

**Figure 1:PXX.4.2.4.2-1: Use Case 4 - AI-Assisted Clinical Decision Support Process Flow**

#### 1:PXX.4.2.5 Use Case 5: De-Identified Health Data Export (Content Conformance)

An authorized clinician exports a de-identified HL7 FHIR document from a clinical workstation. The Integrated De-ID Manager/De-Identifier operates standalone without DIS external transactions, producing output that satisfies the approved policy and the FHIR payload and evidence requirements.

##### 1:PXX.4.2.5.1 De-Identified Health Data Export Use Case Description

A clinician initiates export of a clinical document (for example, a discharge summary for patient-mediated sharing or a document for external referral). The clinical workstation hosts an Integrated De-ID Manager/De-Identifier operating standalone. The Integrated actor maps the clinician's local authorization (role and declared purpose) to a locally configured de-identification policy. No external data permit or policy acquisition is needed -- the policy is pre-configured by institutional administration and identified by a local URI.

The Integrated De-ID Manager/De-Identifier validates the policy, compiles a plan for one ruleSet, and executes it locally. It validates the de-identified document Bundle and its references and checks the Provenance before writing the output to the export destination. It emits an ATNA audit record containing the policy identifier, ruleSet, outcome, and audit correlation.

This use case demonstrates standalone content conformance. The Integrated actor validates the policy, applies the execution plan, and produces output and evidence that satisfy the FHIR payload and evidence requirements. Invocation and export occur locally.

The [standalone clinical export example](examples-standalone-export.html) illustrates the local policy, exported document, and Provenance. The [Data Recipient and push delivery proposal](issues.html#data-recipient-and-push-delivery) is an open issue.

##### 1:PXX.4.2.5.2 De-Identified Health Data Export Process Flow

<p><a href="dis-uc5-local-export.png"><img src="dis-uc5-local-export.png" alt="Standalone de-identified health data export process flow" width="721" style="max-width: 100%; height: auto;" /></a></p>

**Figure 1:PXX.4.2.5.2-1: Use Case 5 - De-Identified Health Data Export Process Flow**

<a name="security-considerations"> </a>

## 1:PXX.5 DIS Security Considerations

See ITI TF-2: [Appendix Z.8 "Mobile Security Considerations"](https://profiles.ihe.net/ITI/TF/Volume2/ch-Z.html#z.8-mobile-security-considerations).

DIS processes health data that is identifiable at input and de-identified at output. The security architecture addresses threats arising during the transformation workflow.

In this profile, a **trust boundary** is the set of systems, processes, and storage under a single administrative authority's security control, within which data can move without crossing an external interface. Two actors share a trust boundary when they operate under the same administrative authority and enforce equivalent security policies; they are in separate trust boundaries when different administrative authorities control them or when they are connected only through external network interfaces. Trust boundary determination is a deployment decision.

### 1:PXX.5.1 Actor Grouping and Transport Security

The [required actor grouping table](#required-groupings) identifies the ATNA role for each DIS actor. Implementations SHALL use mutually authenticated TLS 1.2 or later for all DIS transactions. Apply [ATNA Authenticate Node](https://profiles.ihe.net/ITI/TF/Volume2/ITI-19.html) for peer authentication and the DIS transaction rules for action and data authorization.

### 1:PXX.5.2 Authorization

The De-ID Manager and the Integrated De-ID Manager/De-Identifier SHALL be grouped with IUA Authorization Client or Resource Server ([ITI TF-1: 34](https://profiles.ihe.net/ITI/TF/Volume1/ch-34.html)). System-to-system authorization for automated workflows SHOULD use SMART Backend Services with OAuth 2.0 client credentials grants. The De-ID Manager or Integrated De-ID Manager/De-Identifier SHALL verify that the Requester is authorized under the submitted data request authorization before accepting a job. The [shared transaction authorization rules](volume-2.html#transaction-authorization) apply to submission, recovery, polling, cancellation, and result release.

### 1:PXX.5.3 Policy Integrity

The De-ID Manager or Integrated De-ID Manager/De-Identifier SHALL verify authorization consistency, integrity, schema conformance, and currency of the policy for every payload set before accepting an asynchronous job or starting synchronous execution. When the Requester carries policy content (`policyContent`), the Manager SHALL verify the JWS signature and confirm the Library's canonical URL and version match the declared policy canonical and version. When the Manager resolves the policy itself, integrity is established by the Manager's resolution trust model (administrative provisioning, mutual TLS, or other mechanisms appropriate to the deployment). Authorization consistency means the declared policy URL and version match the approval. The Manager SHALL verify that the policy rules match the exact content bound to the approved version in either delivery mode. Policies that fail any validation point SHALL be rejected.

### 1:PXX.5.4 Reversibility Material Custody

The De-ID Manager is the persistent custodian of Manager-managed identity mappings and reversibility records (identity table and pseudonym index). A Requester may retain its own supplied lookup table. When reversible mode is selected without a supplied lookup table, the Manager SHALL persist these records. With a supplied table, the Requester may retain its authoritative copy and Manager persistence is not required. When irreversible mode is selected, the Manager SHALL NOT retain mapping records after job completion. De-Identifiers SHALL NOT persist mappings. Manager-managed records SHALL NOT be exported as complete tables; only task-scoped entries may be shared for authorized execution. Supplied lookup tables and task-scoped entries SHALL NOT appear in recipient-facing output, evidence, logs or errors. Missing-entry errors SHALL NOT disclose the source identifier. All temporary copies SHALL be deleted at job/task termination, respectively, unless Manager retention is explicitly authorized.

Salts for patient identifier hashing SHALL remain within the authorized De-Identifier deployment and SHALL be protected as transformation material. Deployment-managed salts follow the authorized scope lifecycle. The Manager and De-Identifier MAY operate in separate trust boundaries. Confidential salts SHALL be excluded from recipient output, evidence and logs.

Implementations deploying DIS-REVERSIBLE (Reversible Pseudonymization) SHALL implement access controls, encryption at rest, and audit logging for all reversibility material. The De-ID Manager SHALL enforce access controls preventing unauthorized access to reversibility material even by other DIS actors. Authorized task-scoped mapping access is limited to the assigned transformation.

Date-shift reference dates, offsets, and other protected transformation parameters SHALL NOT be disclosed to data recipients or included in recipient-facing output, evidence, or logs. A De-Identifier SHALL retain them only for task execution and delete them at task termination. Any return to the Manager for authorized retention and reuse SHALL follow an explicit capability contract and use a protected channel. Such retention SHALL be consistent with the authorized policy and declared reversibility mode.

### 1:PXX.5.5 Trust Isolation Between Stages

When the De-ID Manager compiles a staged execution plan, each De-Identifier receives only the execution plan for its assigned ruleSet(s) within a given stage. A De-Identifier performing the advanced stage (quasi-identifier rounding, removal) does not have access to the preliminary stage's pseudonym-to-identity mappings. This stage-scoped dispatch limits each De-Identifier to its assigned transformations and necessary linking material. A De-Identifier applying pseudonyms can observe the source-to-output associations during its task; staging does not prevent their exposure if that worker is compromised during execution.

The Integrated De-ID Manager/De-Identifier executes all ruleSets within a single actor. Inter-stage trust isolation through separate De-Identifiers is not available in this deployment model. Implementations requiring defense-in-depth through stage-level trust boundaries SHALL use the separate De-ID Manager and De-Identifier actors.

### 1:PXX.5.6 Audit Logging

DIS actors SHALL record ATNA audit events according to the transaction-specific requirements in Volume 2. Only ordinary in-progress ITI-x7 polling may be logged at a reduced frequency under that transaction's rules. Every completed de-identification task produces evidence containing an audit correlation identifier linking the de-identification event to the ATNA audit trail. Implementations SHOULD use IHE Basic Audit Log Patterns (BALP) for structured audit events.

<a name="other-grouping"> </a>

## 1:PXX.6 DIS Cross-Profile Considerations

### 1:PXX.6.1 IHE IUA - Internet User Authorization

The [required actor grouping table](#required-groupings) defines the current IUA grouping requirements. On an exchange using IUA, the Authorization Client presents the access token and the Resource Server validates it and enforces the applicable access policy. [ITI-72](https://profiles.ihe.net/ITI/IUA/) defines how the client presents the token and how the server checks it. The [open security decision](issues.html#iua-grouping-and-denial-responses) records the remaining actor-role and denial-response alignment.

### 1:PXX.6.2 IHE ATNA / BALP - Audit Trail and Node Authentication / Basic Audit Log Patterns

All DIS actors group with ATNA for transport security and audit logging. Implementations SHOULD use BALP for structured, HL7 FHIR-based audit event representation. The audit correlation identifier in DIS de-identification evidence links de-identification events to the broader ATNA audit trail, enabling end-to-end traceability from authorization through de-identification to output delivery.

### 1:PXX.6.3 IHE MHD - Mobile Access to Health Documents

When de-identified output is delivered to a document sharing infrastructure, the De-Identification Requester (or a downstream consumer) MAY group with MHD Document Source to publish de-identified documents. MHD provides an HL7 FHIR-native document sharing transport that complements the DIS de-identification workflow.

### 1:PXX.6.4 SMART on FHIR Backend Services

SMART Backend Services provides the OAuth 2.0 client credentials flow used for system-to-system authorization in automated DIS workflows. This is the recommended authorization pattern for server-to-server interactions where no end-user is present (for example, asynchronous cohort de-identification jobs submitted by a Data Access Coordinator).

### 1:PXX.6.5 External Data Permit and Data Request Profiles

DIS consumes data request authorizations but does not produce them. The data request authorization presented in ITI-x1 is evidence that a data governance authority approved a data request — including what data is needed, the purpose, and the de-identification policy to be applied. This authorization is obtained through mechanisms outside DIS — including national EHDS infrastructure, institutional governance workflows, bilateral agreements, or integration with external data permit services. DIS validates the authorization and verifies that the presented policy matches the policy approved in the authorization, but is agnostic to the authorization's origin.
