# ITI.DIS Phase 1 profile drafting work plan

Status: drafting plan revised 15 September 2026. D01–D11 are agreed; contributor assignments and schedule remain proposals. No issues or external assignments have been created.

## 1. Purpose and review baseline

This plan covers drafting the IHE ITI.DIS profile: Volume 1, transaction specifications, payload and evidence bindings, FHIR conformance artifacts, illustrative examples, and a conformance test plan. It does not include developing a prototype, actor services, simulators, or a runtime test suite. Building the IG and validating example artifacts are document-quality activities within scope; demonstrated implementation interoperability is not a drafting milestone.

Prioritize functional specification first: actors, transaction flows, policy execution, payloads and evidence. Carry the agreed authorization, custody and release boundaries into those contracts from the start. Complete detailed security/privacy text and cross-profile alignment after the functional draft stabilizes, before the integrated review package is accepted. This sequencing does not defer or weaken the agreed normative requirements.

The original review covered [README.md](README.md), [Volume 1](input/pagecontent/volume-1.md), IG configuration, FSH artifacts, issues page, and test plan. The repository provides the actor model and use cases, but Volume 2/3 navigation and several FSH artifacts still contain template material. Replace these with DIS-specific drafting outputs. This plan is an internal drafting and coordination plan, not an external standards compliance audit.

### Agreed decisions and drafting follow-up

| ID | Original finding and source | Agreed decision / remaining work | Accountable role |
|---|---|---|---|
| D01 | README defers full composition, while Volume 1 §1:52.2.3 presents DIS-EXE1 as an actor option. | **Agreed:** require DIS-EXE1-Baseline (flat, ordered rules) in Phase 1 and defer full DIS-EXE1, including policy composition, condition evaluation, cross-element constraints, conflict resolution strategies, and selector specificity rules. Retain multi-stage dispatch with a separate baseline plan per stage. README and Volume 1 aligned; schemas, examples and conformance test specifications remain drafting work. | Profile lead |
| D02 | Volume 1 §1:52.1.2.1 requires synchronous rejection of invalid authorization/policy, but UC-1/2 diagrams show validation after `202 Accepted`. | **Agreed:** validate authorization and all four policy carrier checks before asynchronous acceptance or task dispatch. Failed or incomplete admission validation returns a synchronous error without accepting the job. Report subsequent processing failures through ITI-x4 and withhold failed-job output. Volume 1 text and UC-1/2 diagrams aligned; detailed error bindings and test specifications remain drafting work. | Transaction owner |
| D03 | ITI-x3 sends a seed to the De-Identifier, while §§1:52.4.1 and 1:52.5.4 prohibit seed disclosure outside the Manager's trust boundary. | **Agreed:** permit protected sharing of scoped, purpose-specific seeds containing no PII with authorized De-Identifiers across separate trust boundaries; a shared boundary is optional. De-Identifiers derive transformation values according to declared capabilities; accepting precomputed values is not mandatory. Manager retains sole persistent custody of mappings/reversibility records. Delete task seeds at termination; exclude them from recipient-facing output, evidence and logs. README and Volume 1 aligned; derivation/binding details and test specifications remain drafting work. | Security owner |
| D04 | UC-3/4 let the EHR resolve pseudonyms, but the Manager is sole mapping custodian and re-identification transactions are deferred. | **Agreed:** UC-3/4 use an authorized, implementation-defined interaction with the Manager's mapping service, outside Phase 1 standardized transactions. The Manager retains mapping custody; the EHR receives only the resolution result needed for patient association, without mapping-table export. Volume 1 option text, use-case descriptions and diagrams aligned. | Security owner with clinical reviewer |
| D05 | README describes R4/R5 payload support; distinguish it from the FHIR 4.0.1 target for DIS-defined IG artifacts. Bulk Data direction and packaging also need definition. | **Agreed:** use FHIR R4 for initial DIS workflow APIs, resources and conformance artifacts, with independently versioned R4/R5 processing payloads. Specify payload version identification, packaging and capability matching; provide R5 payload examples/tests without requiring R5 workflow artifacts. Keep core semantics independent of future transaction bindings. README and Volume 1 aligned. Bulk Data scope is agreed in D11 below; detailed binding contracts remain to be completed. | FHIR owner |
| D06 | README defers dataset-level statistical disclosure control, while UC-1/2 describe small-cell and rare-condition handling. | **Agreed:** exclude dataset- or database-level de-identification actions from Phase 1, including small-cell handling and transformations requiring cohort statistics. Retain multi-patient workflows applying policy-specified record-level rules. Dataset-level statistical disclosure control is future-phase work; any such processing needed by UC-1/2 occurs outside the Phase 1 workflow. README and Volume 1 descriptions/diagrams aligned. | Policy owner with QRPH reviewer |
| D07 | Volume 1 describes a shared `consistencyKey` as ensuring identical pseudonyms across jobs/stages. | **Agreed:** separate the authorized linkage-scope identifier (`consistencyKey`) from secret seeds and protected transformation parameters. Manager manages scope authorization and patient-/purpose-scoped seed lifecycle; De-Identifier derives and applies values. Prefer deterministic derivation of date-shift parameters; generated parameters require an explicit capability contract for protected retention/reuse. Identity resolution, derivation/version compatibility, rotation and collisions require contracts/tests. README and Volume 1 aligned; seed handling follows D03. | Security owner with policy owner |
| D08 | Named policies require all four validation checks, but the named identifier example has no definition here; local export uses a configured policy. | **Agreed:** Manager resolves named identifiers and any required version unambiguously to a specific, versioned, signed artifact and performs all four checks before acceptance; unresolved, ambiguous or invalid policies fail synchronously. Local provisioning does not waive validation. Resolution/provisioning mechanisms remain implementation-defined, without a new Phase 1 policy transaction. De-Identifier receives the compiled plan; native policy execution requires resolved policy/version capability matching. README and Volume 1 aligned. | Policy owner |
| D09 | README conformance summary omits DIS-DEFER and DIS-LAE1; the Manager participates in deferred retrieval but has no corresponding option row in Volume 1. | **Agreed:** DIS-ASYNC applies to Requester/Manager with ITI-x4; DIS-DEFER to Manager/De-Identifier with ITI-x7; DIS-LAE1 to Manager; DIS-RP1 to Manager/De-Identifier. DIS-EXE1-Baseline is required for Manager/De-Identifier; full DIS-EXE1 remains deferred. Async jobs and deferred tasks are independent capabilities. Volume 1 declaration matrix and README aligned; binding artifacts and negative conformance test specifications remain drafting work. | Profile lead |
| D10 | README promises expansion without modification or breaking changes. | **Agreed:** additive compatibility is a design objective supported by explicit versioning and regression tests. Preserve existing contracts where possible; incompatible changes must identify affected contracts, implementation/conformance impact and migration requirements. README updated to remove unconditional future-compatibility promises. | Profile lead |

D01–D11 are agreed. The findings above record the original review baseline; agreement and prose alignment do not imply completed schemas, examples, or conformance test specifications. Bulk Data scope is agreed in D11 below; detailed binding contracts remain to be completed.

### Agreed Bulk Data scope and binding follow-up

| ID | Agreed scope | Accountable owner / reviewers | Deadline and dependency | Exit criteria |
|---|---|---|---|---|
| D11 — Bulk Data direction and packaging | **Agreed:** support both input and output for asynchronous cohort jobs using manifests referencing NDJSON files. Requester supplies prepared input references; Manager returns de-identified output and evidence references. Identify R4/R5 payload versions independently of R4 workflow resources; check declared format/version capabilities before dispatch. Require authorized file retrieval; exclude protected transformation material from recipient-facing manifests/files. Failed jobs release no partial dataset. Source-system export remains outside DIS; use of file conventions alone does not claim full HL7 Bulk Data API conformance. | FHIR owner / transaction, security and conformance contributors; profile lead records approval | Scope approved; complete binding follow-up by M2 exit, with an initial manifest outline at M0, before affected WP03/WP05/WP07 contracts freeze and before WP09 binding completion | Scope recorded in README and Volume 1. Remaining work: exact manifest fields, retrieval/expiry behavior, evidence and error packaging, concrete request/output examples, capability declarations and conformance scenarios. Affected contracts remain provisional until these details are agreed; independent synchronous RP0 work may proceed. |

Also reconcile the Requester's ATNA grouping table with the broader prose, and verify IUA role requirements and transport/audit references against authoritative specifications during security drafting. The configuration description still says three transactions; align it with the four-transaction baseline.

## 2. Contributor structure

The README identifies Alan Zhang and Lori Fourquet as profile editors. Propose that one coordinate integration and the other coordinate cross-domain review; confirm their assignments and availability before committing dates.

| Contributor role | Accountable drafting responsibility | Review / handoff |
|---|---|---|
| Profile and integration lead | Volume 1, scope, decision log, actor/option matrix, integrated draft | Second editor and affected section owners |
| Transaction contributor | ITI-x1/x3/x4/x7, state transitions, request/response contracts, errors | FHIR and conformance contributors |
| Policy and transformation contributor | Carrier resolution/validation, baseline rule semantics, transformation parameters and capability requirements | Transaction and security contributors |
| FHIR and evidence contributor | R4 workflow artifacts, R4/R5 payload binding, Bulk Data manifests, evidence and terminology | Transaction and conformance contributors |
| Security and privacy contributor | Detailed authorization, trust boundaries, seed lifecycle, audit and release requirements; cross-profile references | Profile lead and affected section owners |
| Conformance contributor | Requirement traceability, positive/negative test procedures and expected outcomes | Transaction and FHIR contributors |
| IG build and editorial contributor | Navigation, FSH compilation, artifact validation, links, diagrams and publication QA | FHIR contributor and second editor |
| Clinical/domain reviewers | QRPH reviews UC-1/2; PCC reviews UC-3/4/5; ITI coordinates architectural review | Cross-domain review lead consolidates comments |

For a smaller team, combine profile + transaction work, policy + FHIR work, and conformance + build work. Keep a different reviewer for each package. Contributors deliver drafts and review comments; no contributor is assigned to implement an actor.

## 3. Assignable drafting packages

Paths not already in the repository are proposed additions. Agree page names before creating them. Preserve package identifiers for traceability; WP03S now denotes security drafting, not implementation.

| Package | Accountable owner / reviewers | Deliverables and surfaces | Dependencies | Draft acceptance criteria |
|---|---|---|---|---|
| WP01 — Consolidate agreed baseline | Profile / section owners | README, Volume 1, issues page, proposed decision log and conformance matrix | D01–D11 | Agreed decisions reflected consistently; every declaration is mapped to actors, initiating/responding transactions, required/optional status and dependencies, including DIS-BASE, DIS-FHIR-Job, DIS-FHIR-Task, DIS-FHIR1, DIS-FHIR-JobStatus and all Phase 1 options. Define actor-specific DIS-BASE obligations for the De-Identifier, which receives tasks rather than jobs. Align README and Volume 1; remaining binding questions have owners and deadlines. |
| WP02 — Establish IG drafting structure | Build/editorial / FHIR | `sushi-config.yaml`, navigation, `input/fsh/`, build instructions | Start immediately; page names from WP01 | Template artifacts inventoried and replaced as drafts arrive; reproducible IG build; four transaction pages linked by final review; diagnostics reviewed. |
| WP03 — Draft synchronous transactions | Transaction / FHIR, conformance | Proposed `input/pagecontent/ITI-x1.md`, `ITI-x3.md`; sequence diagrams and message examples | WP01; agreed security boundaries; WP04/05 envelope coordination | Methods, endpoints, inputs, responses, identifiers, capability checks, admission rejection and execution failure behavior specified without ambiguity. |
| WP04 — Draft policy and execution baseline | Policy / transaction, FHIR | Policy/execution content, applicable schemas/FSH, positive and negative examples | WP01 and D01/D06/D07/D08 | Three carriers and all nine Core actions have explicit semantics, parameters, applicability, ordering and failure rules; cohort-statistics-dependent actions excluded. Resolve date shifting within the existing Core action model, or submit a scope-change proposal for explicit approval; do not silently add an action. Document its action identifier, parameter/derivation contract, temporal applicability, consistency behavior, failure cases and worked examples before functional contract freeze. |
| WP05 — Draft FHIR payload and evidence binding | FHIR / transaction, conformance | Volume 3 content, `input/fsh/`, proposed `input/examples/` | WP01 declaration matrix; WP03/04 shared structures; D05/D11 | Nine evidence elements mapped; R4 workflow/R4–R5 payload separation, version identification, reference integrity, capability declarations and evidence audiences specified. For every WP01 declaration, identify required FHIR profiles, operations, capability artifacts, terminology and examples as applicable, or explicitly state why no dedicated artifact is required. Cross-reference these artifacts in the actor/transaction matrix and align declaration names across README, Volume 1 and bindings. Bulk Data fields coordinated with WP09. |
| WP06 — Assemble first synchronous worked example | Transaction / policy, FHIR, conformance | Synthetic RP0 request → task → output/evidence walkthrough and rejection counterpart | First WP03–05 drafts | Every message and transition is explained and cross-referenced; artifacts validate where definitions are available; expected transformations and errors are documented. No reverse-mapping service or executable workflow required. |
| WP07 — Draft async and deferred transactions | Transaction / FHIR, conformance | Proposed `ITI-x4.md`, `ITI-x7.md`; state tables, retrieval/error examples | WP01 option matrix; shared WP03/05 contracts; D11 binding coordination | Distinguish async jobs from deferred tasks; specify supported combinations, polling, ownership, retention, retries, expiry and failure behavior. |
| WP08 — Draft reversibility and local export options | Profile / policy, PCC, security | RP0/RP1 and DIS-LAE1 obligations; UC-3/4/5 descriptions, diagrams and examples | D03/D04/D07/D08; WP03/04 drafts | Actor responsibilities and retention semantics clear; patient association remains implementation-defined and outside Phase 1 transactions; local policy validation retained. |
| WP09 — Draft cohort and Bulk Data examples | FHIR / transaction, QRPH, conformance | D11 manifest definitions, input/output examples, UC-1/2 two-stage walkthroughs, R5 payload examples | WP05/07 shared contracts; WP08 RP1 wording for UC-1/2 | Both NDJSON directions specified; authorized retrieval and no partial release documented; R4/R5 payloads covered; source export and dataset-level actions excluded. |
| WP03S — Complete security/privacy specification | Security / profile, transaction, FHIR, conformance | Volume 1 security sections, transaction security/audit sections, evidence disclosure rules and source references | Main drafting after WP03–09 functional drafts; early consultation only for questions that change interfaces | Authorization, signatures/currency, transport, seed/parameter lifecycle, mappings, audit correlation, retrieval and release controls are normative and traceable. ATNA/IUA/BALP references checked; conflicts resolved before M3 acceptance. |
| WP10 — Draft conformance plan and integrate review | Conformance / all section owners, editors | `input/pagecontent/testplan.md`, traceability matrix, review checklist and IG QA report | Scenarios begin with WP03; final review after functional and WP03S drafts | Each normative obligation has a test procedure or inspection criterion with expected outcome; actor/options and positive/negative cases covered; examples and IG checked. No runtime execution or second implementation required. |

Detailed WP03S completion is not a prerequisite for the first functional draft. Existing D02/D03/D07/D08 requirements remain constraints on drafting; questions that affect message fields, actor responsibilities or output disclosure are resolved as they arise. Security acceptance is required for M3 and final integrated review.

## 4. Drafting sequence and review gates

Use milestone order to coordinate contributors. Calendar dates and effort estimates should be set after contributor sign-up; the earlier prototype-based 10–12 week estimate is withdrawn. Formal IHE review/publication dates are agreed separately.

| Milestone | Priority and work | Acceptance gate |
|---|---|---|
| M0 — Drafting baseline | WP01 and WP02; assign section owners, settle shared names and outline D11 manifests | Agreed decisions consolidated; drafting structure and responsibilities clear; complete declaration inventory and actor/transaction obligations recorded, with required artifact drafting assigned to WP05; detailed binding questions assigned. |
| M1 — First functional draft | WP03/04/05 and WP06; start conformance scenarios | Synchronous RP0 walkthrough is internally consistent; baseline policy, payload and evidence contracts have reviewable examples. Security completion is not an M1 gate. |
| M2 — Complete functional scope | WP07/08/09; complete all action and version coverage | Four transactions, options, five use cases and both Bulk Data directions drafted. D11 fields/retrieval/evidence details resolved before affected contract freeze. Date-shift action mapping and parameter examples accepted (or an explicit scope decision recorded); all declaration-to-artifact mappings complete before M3 security review. |
| M3 — Security and conformance review | Complete WP03S and WP10 scenarios against the functional draft | Security obligations and referenced profiles reconciled; positive/negative procedures and expected outcomes trace to requirements; review findings addressed. |
| M4 — Integrated review package | Editors consolidate domain review; build/editorial contributor completes IG QA | Coherent profile draft, validated artifacts/examples, reviewed build diagnostics, resolved blocking comments and explicit remaining limitations. |

Packages may overlap when their shared contracts are stable. WP07 need not wait for a running synchronous service, and WP09 does not depend on implementation of RP1. D11 scope is agreed; its detailed packaging contract is a drafting dependency, not a new scope vote.

## 5. Conformance specification and document validation

Agree identifiers, authorization and carrier representation, execution-plan versioning, processing-target representation, job/task states, evidence envelopes and capability declarations before section drafts diverge. Maintain one canonical definition for each shared structure.

Draft procedures with actor/option, preconditions, input, observable expected behavior and pass/fail criteria for:

- Both Bulk Data directions, R4/R5 version identification over R4 workflow resources, unsupported formats/versions, unauthorized or expired retrieval, missing files and no partial dataset release.
- Missing, invalid, expired or scope-inconsistent authorization/policies, ambiguous named-policy resolution and unavailable references; rejection before acceptance or dispatch.
- Each Core action's valid/invalid parameters, selectors, ordering and applicability; fixed record-level rules rather than cohort-statistics-based processing. Include date-shift cases tied to the approved action mapping, parameters and derivation rules.
- Every declaration's actor-specific obligations and required artifacts, including De-Identifier DIS-BASE behavior, job/task bindings, payload binding and JobStatus dependencies.
- FHIR reference integrity and treatment of narrative, extensions, contained resources and attachments.
- Nine evidence elements, audience separation, audit correlation and failed-validation output withholding.
- Polling ownership, retries, expiry, interrupted processing, stage failure and independent async/deferred declarations.
- Authorized consistency scope, purpose-specific seeds, derivation/version compatibility, rotation, collisions, protected parameter reuse and deletion/disclosure requirements.
- RP0/RP1 obligations and DIS-LAE1, including the boundary around implementation-defined patient association.

These are specifications for future conformance testing, not a commitment to build or execute a runtime suite. Use synthetic examples. Compile FSH, validate examples against available definitions, check links and diagrams, and build the IG as drafting QA. Record what these checks establish: artifact validity and document consistency do not demonstrate operational interoperability or de-identification adequacy.

## 6. Contribution and integration workflow

1. Track one issue per package, split into reviewable drafting changes. Record owner, reviewer, affected sections/artifacts, dependencies and acceptance criteria.
2. Use a regular editorial meeting to resolve shared contract questions. The cross-domain lead consolidates ITI, QRPH and PCC feedback.
3. Submit PRs with normative text, matching diagrams/examples and affected conformance criteria. Mark unfinished artifacts and unresolved binding details explicitly.
4. The profile lead coordinates README, Volume 1 and shared terminology; the build/editorial contributor maintains navigation and publication structure.
5. Review functional contracts first. Request early security input only where it affects those contracts; conduct the complete security review at M3.
6. Trace each requirement to section, actor/option, artifact/example and proposed test procedure. Track drafting, review and artifact-validation status separately from future implementation results.
7. At each milestone, walk through messages and expected behavior with a reviewer who did not write the section. No prototype demonstration or independent implementation is required for acceptance.

## 7. Immediate next actions

- **Editors:** confirm section owners and reviewer assignments; agree milestone dates based on drafting availability.
- **Profile lead:** consolidate D01–D11 and record remaining binding questions; keep scope decisions separate from drafting status.
- **Transaction, policy and FHIR contributors:** draft the synchronous contracts and RP0 worked example, then expand to async/deferred, options and cohort examples.
- **FHIR owner:** outline D11 manifests at M0 and resolve detailed packaging with transaction/conformance contributors by M2, before affected contracts freeze.
- **Security owner:** preserve agreed interface constraints during functional drafting, then complete detailed WP03S text and cross-profile verification for M3.
- **Conformance contributor:** write actor-based scenarios and expected outcomes alongside the drafts.
- **Build/editorial contributor:** replace template artifacts, maintain a reproducible IG build and validate the integrated publication output.

Keep CDA, DICOM, HL7 v2, OMOP, push delivery, policy-management transactions, standardized re-identification and federation in the future-phase backlog. Prototype development and operational implementation are outside this drafting plan.
