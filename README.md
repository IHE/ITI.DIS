# IHE De-Identification Services (DIS) — Phase 1

**ITI.DIS** is a joint work item of the IHE [IT Infrastructure (ITI)](https://www.ihe.net/ihe_domains/it_infrastructure/), [Quality, Research, and Public Health (QRPH)](https://www.ihe.net/ihe_domains/quality_research_and_public_health/), and [Patient Care Coordination (PCC)](https://www.ihe.net/ihe_domains/patient_care_coordination/) domains, with ITI as the lead domain.

**This repository focuses on Phase 1 scope** — a complete, testable interoperability specification for policy-governed de-identification of HL7 FHIR health data. Additional payload bindings (CDA, DICOM, HL7 v2) and advanced capabilities (re-identification, push delivery, policy retrieval) are planned for future phases and do not require modification of Phase 1 specifications.

## Problem Statement

Health data sharing is expanding across clinical care, secondary research, public health, device development, and AI-enabled workflows. Organizations need to disclose data that have been transformed according to policy, but there is no standard, interoperable workflow for how that de-identification is requested, executed, validated, and delivered.

DIS addresses this by providing a governed, auditable path from authorization to delivery — reducing reliance on manual processes and local one-off agreements.

## What Phase 1 Delivers

- **Three actors** — De-ID Manager, De-Identifier, De-Identification Requester
- **Four transactions** — ITI-x1 (Submit Job), ITI-x3 (Submit Task), ITI-x4 (Retrieve Job Output), ITI-x7 (Retrieve Task Output)
- **A baseline policy execution model** — flat, ordered rule lists (DIS-EXE1-Baseline), with a separate plan for each stage in multi-stage workflows
- **A minimum de-id evidence baseline** — 9-element evidence structure carried in FHIR Provenance
- **A single FHIR payload binding (DIS-FHIR1)** — covering R4/R5 resources, Bundles, and Bulk Data
- **Synchronous and asynchronous job patterns** — inline output for single-patient workflows, deferred output with polling for multi-patient cohorts

## Use Cases

| UC | Name | Pattern | Description |
|----|------|---------|-------------|
| UC-1 | Cross-Border Epidemiological Study Using IPS+ | Async | Pseudonymized, disclosure-controlled cohort dataset for a cross-border cancer study |
| UC-2 | Multimodal AI/ML Method Development (FHIR input-preparation) | Async | De-identification of structured clinical data for a training-ready multimodal dataset |
| UC-3 | Clinical Pathology Order (Pseudonymous Care) | Sync | Pseudonymization before sending a lab order to an external pathology lab |
| UC-4 | AI-Assisted Clinical Decision Support (Cloud Deployment) | Sync | Pseudonymization before transmitting patient data to a cloud-hosted AI service |
| UC-5 | Local Authorized Clinical Document Export | Sync | Clinician-initiated export of a de-identified FHIR document Bundle |

## Architecture Overview

DIS is built on a modular, binding-neutral core architecture. Phase 1 specifies an initial FHIR R4 transaction binding against this core. The workflow resources and APIs use R4, while the data being de-identified may independently use FHIR R4 or R5. The IG configuration targets the DIS-defined FHIR artifacts; it does not restrict processing payloads to that release.

Payload version identification, packaging, and capability matching are specified separately from the transaction binding. R5 payloads are referenced or carried as explicitly identified serialized content, rather than embedded as native R5 resources in an R4 envelope. R5 processing requires version-specific examples and validation tests, not an R5 version of the DIS workflow resources. Bulk Data input/output direction and packaging remain a separate open decision.

### Actors

| Actor | Responsibility |
|-------|---------------|
| **De-ID Manager** | Receives jobs (ITI-x1), validates the de-identification policy carrier, compiles policy into execution plans, dispatches tasks to De-Identifiers (ITI-x3), returns output and evidence. Sole persistent custodian of identity mappings and reversibility records. |
| **De-Identifier** | Executes assigned de-identification tasks. Stateless with respect to reversibility — receives scoped, purpose-specific seeds as needed, derives transformation values according to declared capabilities, produces transformations and evidence, and retains no seeds or identity-linking material after task termination. |
| **De-Identification Requester** | Submits job with data request authorization and policy carrier; receives output inline (sync) or via ITI-x4 polling (async). Grouped with the De-Identified Data Receiver in Phase 1. |

The Manager may share seeds containing no PII with authorized De-Identifiers over protected channels, including across deployment trust boundaries. Seeds are protected transformation material and are not disclosed to data recipients. A shared trust boundary is optional.

### Transactions

| Transaction | Pattern | Purpose |
|-------------|---------|---------|
| **ITI-x1** Submit De-Identification Job | Request/response (sync or async) | Present authorization and policy; receive de-identified output or job acceptance |
| **ITI-x3** Submit De-Identification Task | Manager → De-Identifier | Dispatch one de-identification task; return output inline (immediate) or task acceptance (deferred) |
| **ITI-x4** Retrieve Job Output | Requester → Manager | Poll status and retrieve output for an async job |
| **ITI-x7** Retrieve Task Output | Manager → De-Identifier | Retrieve output, evidence, and validation status for a completed deferred task |

### Interaction Diagram

```
                          ┌──────────────────────┐
                          │   Data Request        │
                          │   Authorization       │
                          │   (outside DIS)       │
                          └──────────┬───────────┘
                                     │ presented in ITI-x1
                                     ▼
┌──────────────┐   ITI-x1    ┌──────────────┐   ITI-x3    ┌──────────────┐
│ De-ID        │ ──────────► │  De-ID       │ ──────────► │ De-Identifier│
│ Requester    │ ◄────────── │  Manager     │ ◄────────── │              │
│              │  (output     │              │  (output or  │              │
│              │   or job ID) │              │   acceptance)│              │
│              │   ITI-x4    │              │   ITI-x7    │              │
│              │ ──────────► │              │ ──────────► │              │
│              │ ◄────────── │              │ ◄────────── │              │
│              │  (poll +     │              │  (deferred   │              │
│              │   output)    │              │   output +   │              │
│              │              │              │   evidence)  │              │
└──────────────┘              └──────────────┘              └──────────────┘
```

## Policy Model

Phase 1 supports three policy carrier variants in ITI-x1:

| Variant | Description |
|---------|-------------|
| **Inline** | Signed policy artifact embedded directly in the request |
| **By reference** | Reference pointing to a signed policy artifact stored externally |
| **Named standardized policy** | Identifier referencing a well-known policy (e.g., `DIS-Pseudonymization/1.0.0`) |

The De-ID Manager validates every carrier for **signature validity**, **schema conformance**, **currency**, and **authorization consistency** before compiling it into a payload-specific execution plan.

### Named Standardized Policies

DIS can reference named policies defined by existing standards. Externally standardized policies such as:

| Named Policy | Defining Standard |
|---|---|
| `dicom:basic-profile` | DICOM PS 3.15 Appendix E — Basic Application Level Confidentiality Profile |
| `dicom:retain-long-full-dates` | DICOM PS 3.15 Appendix E — Retain Longitudinal Temporal Information with Full Dates Option |
| `dicom:retain-patient-chars` | DICOM PS 3.15 Appendix E — Retain Patient Characteristics Option |
| `dicom:retain-device-id` | DICOM PS 3.15 Appendix E — Retain Device Identity Option |

However, supporting DICOM including relevant named policies is out of the scope of DIS phase 1

Adopters MAY define their own named policies for use-case-specific needs (e.g., pseudonymization for multi-site research, clinical trial export, teaching files, AI training) using the Phase 1 baseline policy execution model. These are adopter-defined — DIS does not itself author named policies without a grounding standard.

## Transformation Actions

Phase 1 requires support for 9 Core actions aligned with ISO/IEC 20889:2018:

`dis:local-suppression` · `dis:masking` · `dis:retain` · `dis:pseudonymize` · `dis:rounding` · `dis:top-bottom-coding` · `dis:combine-attributes` · `dis:local-generalization` · `dis:noise-addition`

## Conformance

A conformant Phase 1 implementation declares:

- **DIS-BASE** — synchronous job support (required for all)
- **DIS-FHIR-Job** / **DIS-FHIR-Task** / **DIS-FHIR1** — FHIR protocol and payload bindings
- **DIS-ASYNC** + **DIS-FHIR-JobStatus** — additionally, if async jobs are supported
- **DIS-RP0** or **DIS-RP1** — irreversible or reversible pseudonymization mode(s)

## Standards Alignment

- **ISO/IEC 20889:2018** — De-identification technique taxonomy
- **ISO 25237:2017** — Pseudonymization guidance
- **HL7 FHIR R4** — Initial DIS workflow APIs, resources, and conformance artifacts
- **HL7 FHIR R4/R5** — Independently versioned processing payloads
- **IHE ATNA / IUA** — Security, identity, authorization, audit
- **SMART on FHIR Backend Services** — System-to-system authorization
- **W3C PROV-O** — Provenance modeling

## Phase 1 Expansion Path

Phase 1 is designed for additive expansion without breaking changes:

- **Core additions** — Policy Authority actor, ITI-x5 push delivery, ITI-x6 re-identification, full DIS-EXE1 composable policy model (policy composition, condition evaluation, cross-element constraints, conflict resolution strategies, and selector specificity rules)
- **Payload bindings** — DIS-CDA1, DIS-DICOM1, DIS-V2-1, DIS-OMOP1 (each self-contained, developed independently)
- **Advanced capabilities** — Dataset-level statistical disclosure control, cross-community federation

A system conformant to Phase 1 remains conformant when additional payload bindings or core capabilities are added.

## Contact

**Profile Editors:** Alan Zhang, Lori Fourquet

**IHE Domain:** IT Infrastructure (lead), with QRPH and PCC coordination
