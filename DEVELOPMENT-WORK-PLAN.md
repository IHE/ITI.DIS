# ITI.DIS Phase 1 development work plan

Status: proposal for contributor discussion, 14 September 2026. Role assignments below are proposed responsibilities, not confirmed commitments. No issues or external assignments have been created.

## 1. Recommendation and review baseline

Develop Phase 1 through small capability slices that each deliver specification text, FHIR artifacts, executable examples, and conformance checks. Assign one accountable owner per work package, with a different contributor reviewing its contract. Avoid dividing the work only by volume: transaction, payload, security, and testing decisions need to advance together.

The primary review covers [README.md](README.md) and [Volume 1](input/pagecontent/volume-1.md). A supporting repository inspection covered the IG configuration, FSH artifacts, issues page, and test plan. This is an internal consistency and development-readiness review, not an external standards compliance audit.

The draft provides a useful foundation: three actors, four transactions, policy validation before processing, staged execution, a nine-element evidence baseline, and five motivating use cases. However, these are design commitments rather than demonstrated interoperability. Volume 2 and Volume 3 navigation still points to placeholders; `input/fsh/capability.fsh` and `input/fsh/observationLaugh.fsh` contain template artifacts; the test plan and issues page contain TODOs. No DIS prototype or executable DIS conformance suite was found in this checkout. Locate any separately maintained implementation before deciding to create one.

### Agreed decisions and implementation follow-up

| ID | Original finding and source | Agreed decision / remaining work | Accountable role |
|---|---|---|---|
| D01 | README defers full composition, while Volume 1 §1:52.2.3 presents DIS-EXE1 as an actor option. | **Agreed:** require DIS-EXE1-Baseline (flat, ordered rules) in Phase 1 and defer full DIS-EXE1, including policy composition, condition evaluation, cross-element constraints, conflict resolution strategies, and selector specificity rules. Retain multi-stage dispatch with a separate baseline plan per stage. README and Volume 1 aligned; schemas, examples, implementation and conformance checks remain planned work. | Profile lead |
| D02 | Volume 1 §1:52.1.2.1 requires synchronous rejection of invalid authorization/policy, but UC-1/2 diagrams show validation after `202 Accepted`. | **Agreed:** validate authorization and all four policy carrier checks before asynchronous acceptance or task dispatch. Failed or incomplete admission validation returns a synchronous error without accepting the job. Report subsequent processing failures through ITI-x4 and withhold failed-job output. Volume 1 text and UC-1/2 diagrams aligned; detailed error bindings and tests remain planned work. | Transaction owner |
| D03 | ITI-x3 sends a seed to the De-Identifier, while §§1:52.4.1 and 1:52.5.4 prohibit seed disclosure outside the Manager's trust boundary. | **Agreed:** permit protected sharing of scoped, purpose-specific seeds containing no PII with authorized De-Identifiers across separate trust boundaries; a shared boundary is optional. De-Identifiers derive transformation values according to declared capabilities; accepting precomputed values is not mandatory. Manager retains sole persistent custody of mappings/reversibility records. Delete task seeds at termination; exclude them from recipient-facing output, evidence and logs. README and Volume 1 aligned; derivation/binding details and tests remain planned work. | Security owner |
| D04 | UC-3/4 let the EHR resolve pseudonyms, but the Manager is sole mapping custodian and re-identification transactions are deferred. | **Agreed:** UC-3/4 use an authorized, implementation-defined interaction with the Manager's mapping service, outside Phase 1 standardized transactions. The Manager retains mapping custody; the EHR receives only the resolution result needed for patient association, without mapping-table export. Volume 1 option text, use-case descriptions and diagrams aligned. | Security owner with clinical reviewer |
| D05 | README describes R4/R5 payload support; distinguish it from the FHIR 4.0.1 target for DIS-defined IG artifacts. Bulk Data direction and packaging also need definition. | **Agreed:** use FHIR R4 for initial DIS workflow APIs, resources and conformance artifacts, with independently versioned R4/R5 processing payloads. Specify payload version identification, packaging and capability matching; provide R5 payload examples/tests without requiring R5 workflow artifacts. Keep core semantics independent of future transaction bindings. README and Volume 1 aligned. Bulk Data direction and packaging remain a separate open decision. | FHIR owner |
| D06 | README defers dataset-level statistical disclosure control, while UC-1/2 describe small-cell and rare-condition handling. | **Agreed:** exclude dataset- or database-level de-identification actions from Phase 1, including small-cell handling and transformations requiring cohort statistics. Retain multi-patient workflows applying policy-specified record-level rules. Dataset-level statistical disclosure control is future-phase work; any such processing needed by UC-1/2 occurs outside the Phase 1 workflow. README and Volume 1 descriptions/diagrams aligned. | Policy owner with QRPH reviewer |
| D07 | Volume 1 describes a shared `consistencyKey` as ensuring identical pseudonyms across jobs/stages. | **Agreed:** separate the authorized linkage-scope identifier (`consistencyKey`) from secret seeds and protected transformation parameters. Manager manages scope authorization and patient-/purpose-scoped seed lifecycle; De-Identifier derives and applies values. Prefer deterministic derivation of date-shift parameters; generated parameters require an explicit capability contract for protected retention/reuse. Identity resolution, derivation/version compatibility, rotation and collisions require contracts/tests. README and Volume 1 aligned; seed handling follows D03. | Security owner with policy owner |
| D08 | Named policies require all four validation checks, but the named identifier example has no definition here; local export uses a configured policy. | **Agreed:** Manager resolves named identifiers and any required version unambiguously to a specific, versioned, signed artifact and performs all four checks before acceptance; unresolved, ambiguous or invalid policies fail synchronously. Local provisioning does not waive validation. Resolution/provisioning mechanisms remain implementation-defined, without a new Phase 1 policy transaction. De-Identifier receives the compiled plan; native policy execution requires resolved policy/version capability matching. README and Volume 1 aligned. | Policy owner |
| D09 | README conformance summary omits DIS-DEFER and DIS-LAE1; the Manager participates in deferred retrieval but has no corresponding option row in Volume 1. | **Agreed:** DIS-ASYNC applies to Requester/Manager with ITI-x4; DIS-DEFER to Manager/De-Identifier with ITI-x7; DIS-LAE1 to Manager; DIS-RP1 to Manager/De-Identifier. DIS-EXE1-Baseline is required for Manager/De-Identifier; full DIS-EXE1 remains deferred. Async jobs and deferred tasks are independent capabilities. Volume 1 declaration matrix and README aligned; binding artifacts and negative conformance tests remain planned work. | Profile lead |
| D10 | README promises expansion without modification or breaking changes. | **Agreed:** additive compatibility is a design objective supported by explicit versioning and regression tests. Preserve existing contracts where possible; incompatible changes must identify affected contracts, implementation/conformance impact and migration requirements. README updated to remove unconditional future-compatibility promises. | Profile lead |

D01–D10 are agreed. The findings above record the original review baseline; agreement and prose alignment do not imply completed schemas, implementation, or conformance tests. Bulk Data direction and packaging remain a separate open decision.

Also reconcile the Requester's ATNA grouping table with the broader prose, and verify IUA role requirements and transport/audit references against authoritative specifications during security drafting. The configuration description still says three transactions; align it with the four-transaction baseline.

## 2. Contributor structure

Use named people only after they accept a role. The README identifies Alan Zhang and Lori Fourquet as profile editors; a practical proposal is for one to act as integration lead and the other as cross-domain review lead, with the split agreed between them.

| Contributor role | Owns | Required reviewer / handoff |
|---|---|---|
| Profile and integration lead (proposed: one existing editor) | Scope, Volume 1, decision log, actor/option matrix, integrated milestone acceptance | Other editor and affected technical owner |
| Transaction contributor | ITI-x1/x3/x4/x7 contracts, state machines, errors and retrieval behavior | FHIR owner and prototype contributor |
| Policy and transformation contributor | Carrier validation, DIS-EXE1-Baseline, action semantics, compiler contract | Security owner and De-Identifier implementer |
| FHIR and evidence contributor | Protocol/payload bindings, profiles, terminology, examples, Provenance mappings and capabilities | Transaction owner and test contributor |
| Security and privacy contributor | Authorization, custody, consistency scope, evidence audiences, audit and release controls | Profile lead and implementation contributor |
| Implementation contributor(s) | Requester harness, Manager orchestration and De-Identifier; reproducible demonstrations | Contract owners and test contributor |
| Conformance and build contributor | Traceability, independent assertions, negative fixtures, IG build and publication QA | FHIR owner and second editor |
| Clinical/domain reviewers (QRPH and PCC; ITI coordinates) | UC-1/2 research realism; UC-3/4 care correlation; UC-5 local export | Cross-domain review lead consolidates decisions |

For a smaller team, combine transaction + profile work, FHIR + policy work, and test + build work; retain independent review for security decisions and conformance results. If two implementers are available, give one the Manager/Requester and one the De-Identifier so the transaction boundary is exercised independently. Domain reviewers can contribute at milestone reviews rather than continuously.

## 3. Assignable work packages

Existing paths are linked below. Other paths are proposed additions; editors should agree the page naming before contributors create them.

| Package | Lead / reviewers | Deliverables and files | Dependencies | Completion criteria |
|---|---|---|---|---|
| WP01 — Freeze Phase 1 contract | Profile / all contract owners | Update README and Volume 1; replace placeholder decisions in `input/pagecontent/issues.md`; add `docs/decisions/` and `docs/conformance-matrix.md` | None | D01–D10 resolved or explicitly deferred with an owner; no unresolved decision blocks the first slice; every option has actor obligations. |
| WP02 — Establish build and artifact layout | Build / FHIR | `sushi-config.yaml`, IG navigation, `input/fsh/`, proposed CI workflow and build instructions | Can start immediately; final names from WP01 | Repeatable IG build; inventory and replace template material; four transaction page links resolve; diagnostics reviewed and exceptions documented. |
| WP03 — Define synchronous transactions | Transaction / FHIR, implementation | Proposed `input/pagecontent/ITI-x1.md`, `ITI-x3.md`; request/response and error examples | WP01 admission and baseline decisions | Define methods, endpoints, cardinalities, authorization inputs, immediate completion, failures, identifiers and correlation. Invalid admission never accepts or dispatches work. |
| WP04 — Define policy and execution baseline | Policy / security, implementation | Proposed policy/execution content pages, schemas under `schemas/` where appropriate, FSH and valid/invalid fixtures | WP01 scope and carrier decisions | All three carrier variants have validation rules; all nine Core actions have parameters, selector/order semantics, applicability and failure behavior. Unsupported rules never silently succeed. |
| WP05 — Define FHIR payload and evidence | FHIR / transaction, security, tests | Replace content placeholder with DIS-FHIR1 and protocol bindings; `input/fsh/`, proposed `input/examples/` | Shared envelope decisions from WP03/04 | Each of nine evidence elements has location, type, cardinality and test; define evidence audiences, reference integrity, resource/Bundle handling, narrative/extensions/attachments, and R4/R5 processing-payload differences, explicit version identification, packaging and capability matching; retain R4 workflow artifacts. |
| WP06 — Implement first complete slice | Implementation / WP03–05 owners, tests | Locate existing prototype or add `prototype/`; synthetic UC-3 fixture and Requester harness | WP03–05 first stable contracts; security review | Run sync ITI-x1 → ITI-x3 → inline payload/evidence. Compare expected transformations and references; fail invalid authorization/policy and failed validation. Label partial action coverage honestly. |
| WP07 — Add async job and deferred task behavior | Transaction + implementation; transaction owner accountable / tests | Proposed `ITI-x4.md`, `ITI-x7.md`; state-transition tables, examples and prototype updates | WP06; WP01 option matrix | Exercise async jobs with immediate tasks and async jobs with deferred tasks; define sync-job/deferred-task compatibility; test polling, ownership, failure, retention, retrieval retries and expiry. |
| WP08 — Implement reversibility and local export options | Security / policy, PCC, implementation | Volume 1 clarifications, RP0/RP1 and DIS-LAE1 content, protected fixtures and prototype updates | D03/04/07/08, WP06 | Show scope-stable pseudonyms, cross-scope separation, RP0/RP1 retention differences and authorized local export. No forbidden material in requester evidence, errors or logs; no new re-identification transaction. |
| WP09 — Complete cohort and version coverage | FHIR + implementation; FHIR owner accountable / QRPH, tests | UC-1/2 two-stage fixtures, Bulk Data binding/tests, R5 payload examples and validation tests using the R4 transaction binding | WP07; D05/06 | Stage two consumes stage-one output using record-level rules only; no cohort-statistics-dependent actions are dispatched; downstream failure blocks release; demonstrate declared Bulk Data directions and both promised processing payload versions, or formally revise scope before release. |
| WP10 — Conformance and review package | Tests / all owners, editors | Replace `input/pagecontent/testplan.md`; proposed `tests/`, traceability matrix, build reports and reviewer checklist | Starts with WP03; completes after WP07–09 | Every normative obligation has an assertion or documented inspection procedure; all declared options have positive/negative coverage; second implementation or independent simulator exercises each actor boundary. |

Security is a dependency of every slice, not a late audit. WP08 adds option-specific behavior after the baseline has working authorization, protected transport, admission checks and evidence handling.

## 4. Delivery sequence and milestone gates

The following is an indicative 10–12 week sequence assuming the core roles have regular availability. It is not a committed estimate; re-estimate after the first executable slice and contributor sign-up. Formal IHE review/publication dates must be agreed separately.

| Milestone | Indicative window | Work and safe parallelism | Gate |
|---|---|---|---|
| M0 — Agreed baseline | Weeks 1–2 | WP01 decisions; WP02 build cleanup in parallel; domain reviewers validate use-case boundaries | Approved scope, contributor roster, shared identifiers/envelopes, and decision log. |
| M1 — Synchronous interoperability | Weeks 3–5 | WP03/04/05 drafting in parallel against agreed contracts; WP06 implementation and WP10 tests follow incremental fixtures | One synthetic UC-3-style job passes end to end; admission and release failures are demonstrated; evidence validates. Full conformance is not claimed yet. |
| M2 — Long-running and optional workflows | Weeks 6–8 | WP07 async/deferred flow; WP08 reversibility/local export after their decisions close; continue action coverage | UC-3/4 correlation boundaries and UC-5 export are reviewed; unauthorized retrieval and deferred failures are tested; option declarations match behavior. |
| M3 — Cohorts and complete binding coverage | Weeks 9–10 | WP09 two-stage cohorts, Bulk Data and R5 payload processing over R4 transactions; complete WP04 action coverage | UC-1/2 fixtures pass; all nine required actions and retained version/payload claims have evidence. |
| M4 — Review-ready package | Weeks 11–12 | WP10 independent interoperability run; editors integrate domain comments and publication cleanup | Traceable requirements, reproducible test report, clean/reviewed IG diagnostics, resolved blockers, and documented limitations. |

Critical path: scope and trust decisions → shared transaction/policy/evidence contracts → synchronous slice → asynchronous/deferred slice → cohort coverage → integrated review. R5 payload processing and Bulk Data work may start earlier once the FHIR owner freezes their contracts; neither should be treated as an unplanned final-week addition.

## 5. Shared contracts and tests

Before implementers diverge, agree job/task identifiers, authorization representation, signed-carrier representation, execution-plan versioning, processing-target representation, completion/validation states, and evidence envelopes. Resolve capability advertisement and compatibility checks before dispatch. Keep one canonical schema or FHIR definition for each shared structure; do not let each contributor invent a local variant.

The first conformance backlog should include:

- Missing, expired, untrusted or scope-inconsistent authorization; invalid policy signature/schema/currency; unsupported named policy; unavailable by-reference policy. Verify no acceptance or dispatch on admission failure.
- Valid and invalid cases for each Core action, including unsupported selectors and parameter combinations. Specify randomness and reproducibility requirements for noise without implying a differential-privacy guarantee from noise addition alone.
- Valid FHIR structure and preserved intended references after transformation; residual identifiers in narrative, extensions, contained resources and attachments handled according to an explicit supported-content policy.
- All nine evidence elements; task/job and audit correlation; failed validation prevents output release. Separate Manager-only mapping evidence from requester-facing provenance.
- Wrong Requester polling a job, wrong Manager retrieving a task, duplicate submissions/retries, interrupted processing, downstream-stage failure, output retrieval retries and expiry. Define expected behavior before writing assertions.
- Stable pseudonyms within the approved scope, separation between scopes, identity resolution, derivation/version compatibility, rotation and collision behavior; verify that consistencyKey alone cannot derive transformations. Test protected parameter retention/reuse contracts and absence of seed, mapping or protected-parameter leakage in recipient-facing responses and logs.
- Async job support independently of deferred task support. Reconcile the 24-hour polling retention requirement with permitted `410 Gone` after successful retrieval, including response-loss behavior.

Schema validity alone does not establish de-identification adequacy. Test reports should distinguish FHIR validity, workflow conformance, transformation correctness, and policy-specific disclosure validation. Use only synthetic data in shared examples and CI.

## 6. Contribution and integration workflow

1. Open one issue per package, then split it into reviewable capability changes. Each issue records the accountable owner, reviewer, source requirement/decision, affected files, dependencies, concrete output and acceptance tests.
2. Use a weekly contract/decision meeting for unresolved cross-owner questions. Record decisions and rejected alternatives in the repository; editors coordinate ITI, QRPH and PCC feedback.
3. Use short PRs that include the changed contract, matching example, test or inspection procedure, and affected conformance-matrix rows. A prose-only exploratory draft is allowed, but is marked incomplete until aligned artifacts exist.
4. Make the profile lead the integration owner for README, Volume 1, navigation and shared terminology. Contributors propose changes to those shared files through their package PRs; avoid competing rewrites.
5. Require affected contract-owner review for interface changes and security review for custody, authorization or evidence changes. Keep implementation convenience from silently changing normative behavior.
6. Track each requirement with a stable ID linked to section, actor/option, artifact, test, result and open issue. Do not equate a merged PR with completed interoperability evidence.
7. At each milestone, demonstrate the synthetic workflow, review failed/unsupported cases, and update the declared capability coverage. Before M4, use an independent simulator or second implementation so shared prototype assumptions are exposed.

## 7. Immediate next actions

- **Editors:** agree the two editorial roles, invite contributors to the technical roles, and adopt or revise this plan.
- **Profile lead:** carry the agreed D01–D10 decisions into transaction, binding and conformance work; resolve the separate open Bulk Data direction/packaging decision and remaining detailed contracts.
- **Build contributor:** establish a reproducible baseline build and list template artifacts to replace; check whether a prototype exists in another maintained repository.
- **Transaction, policy and FHIR owners:** jointly publish the first sync request/task/evidence fixture and its rejection counterpart; then draft their respective contracts in parallel.
- **Implementation and test owners:** implement and independently verify that fixture as M1, with explicit coverage gaps for later milestones.

Keep CDA, DICOM, HL7 v2, OMOP, push delivery, policy-management transactions, standardized re-identification and federation in a separate future-phase backlog. Future work may reuse the frozen core contracts, but should not delay the Phase 1 interoperability demonstration.
