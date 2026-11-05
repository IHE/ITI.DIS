# DIS Volume 1 Review — Reading Guide

This guide accompanies the four 30-minute review sessions for the IHE DIS (De-Identification Services) Profile, Volume 1.

Each session follows the IHE read-and-comment format: participants read the assigned section, then discuss. The reading highlights below identify the key design decisions and questions for each session. Feedback on any aspect of the content is welcome — the highlights are starting points, not limits.

**Profile status:** Early draft (v0.0.1-current). Volume 2 (transactions) and FSH artifacts are not yet drafted. Volume 3 (DIS-FHIR-Payload content module) is drafted but not in scope for these sessions.

---

## Session 1: Actors, Transactions & Content Modules

**Read:** Introduction (top of page) through §1:PXX.1 (end of §1:PXX.1.2.4)

**Approximate reading time:** 8–10 minutes (~2,000 words)

### Reading Highlights

1. **Protocol binding vs. payload binding** (Introduction, ¶3–4). DIS introduces two DIS-defined terms that separate the HL7 FHIR R4 transaction layer from the processing payload. The protocol binding is always HL7 FHIR R4; the payload binding is version-independent and format-extensible. This separation is the foundational architecture decision.
   - *Does the protocol/payload separation make sense? Is the terminology clear?*

2. **Four actors** (§1:PXX.1.1). DIS defines De-Identification Requester, De-ID Manager, De-Identifier, and Integrated De-ID Manager/De-Identifier. The first three form the distributed model. The Integrated actor combines Manager and De-Identifier into a single actor that internalizes ITI-x3/x7.
   - *Is the actor decomposition the right factoring for this domain?*
   - *The Integrated actor internalizes transactions rather than using IHE actor grouping — is this pattern acceptable?*

3. **Actor diagram — subgraph boundary** (Figure 1:PXX.1-1). The dashed boundary shows that the three discrete actors (Requester, Manager, De-Identifier) also map onto the Integrated actor. The Integrated actor does not use ITI-x3 or ITI-x7 on the wire.
   - *Does the diagram clearly communicate the relationship between the distributed and integrated models?*

4. **Transaction optionality for the Integrated actor** (Table 1:PXX.1-1). ITI-x1 is Optional (O) for the Integrated actor, and ITI-x4 is Conditional (C) on ITI-x1 + DIS-ASYNC-JOB. This enables standalone content conformance without any external transactions.
   - *Is Optional the right optionality for ITI-x1 on the Integrated actor?*

5. **Content modules table** (Table 1:PXX.1-2). DIS-FHIR-Payload is the only content module in Phase 1.

---

## Session 2: Options, Required Groupings & Conformance Model

**Read:** §1:PXX.2 (all subsections) through §1:PXX.3

**Approximate reading time:** 8–10 minutes (~2,000 words)

### Reading Highlights

1. **Five options** (Tables 1:PXX.2-1 and 1:PXX.2-2). Phase 1 defines five options: DIS-FHIR-Payload, DIS-ASYNC-JOB, DIS-ASYNC-TASK, DIS-IRREVERSIBLE, DIS-REVERSIBLE.
   - *Is five options the right granularity? Too many? Too few?*
   - *DIS-FHIR-Payload is required in Phase 1 but structured as an option for future extensibility (DIS-DICOM1, DIS-CDA1) — is this pattern clear?*

2. **DIS-ASYNC-JOB and DIS-ASYNC-TASK are independent** (§1:PXX.2.4, §1:PXX.2.5, and the paragraph at end of §1:PXX.2.5). A Manager can support async jobs without async tasks, or vice versa. DIS-ASYNC-TASK does not apply to the Integrated actor.
   - *Is the independence of these two options clear and justified?*

3. **DIS-IRREVERSIBLE and DIS-REVERSIBLE** (§1:PXX.2.2, §1:PXX.2.6). At least one SHALL be declared. An actor MAY declare both, with mode selected per job by the policy.
   - *Is the reversibility model clear?*

4. **Mandatory baseline** (§1:PXX.2.1). The HL7 FHIR R4 protocol binding is mandatory for all actors, not an option. Synchronous job/task processing is the baseline.

5. **Cross-version payload support** (§1:PXX.2.3.2). Four design properties: version identification, version-safe packaging, version-neutral addressing (with version-conditional path mapping at compilation), and evidence across versions.
   - *Is the cross-version approach sound? Any concerns about R6 ballot status?*

6. **Baseline execution plan** (§1:PXX.2.3.1). Phase 1 execution plans are flat, ordered rule lists in HL7 FHIR Library resources. The Composable Execution Plan (DIS-EXE1) is deferred.
   - *Is deferring composable execution plans to a future phase appropriate?*

7. **Required actor groupings** (§1:PXX.3). ATNA for all actors; IUA for Manager and Integrated actor.
   - *Any missing required groupings?*

---

## Session 3: Concepts (Policy, Conformance, Payload Framework)

**Read:** §1:PXX.4.1 Concepts (all paragraphs from "Policy-Governed De-Identification" through the Payload Binding Framework table)

**Approximate reading time:** 10–12 minutes (~1,700 words, but dense conceptual content)

### Reading Highlights

1. **Policy-governed de-identification and four policy variants** (§1:PXX.4.1, first block). The Requester acts as a courier for a signed policy. The Manager performs four-point validation (signature, schema, currency, authorization consistency). Four policy variants: inline policy, by-reference policy, registered policy identifier, named execution plan.
   - *Is the four-point validation model complete? Missing any checks?*
   - *Is the distinction between registered policies (format-neutral, need compilation) and named execution plans (format-specific, dispatched directly) clear?*

2. **Named execution plan** — the example cites DICOM PS3.15 Basic Application Level Confidentiality Profile as a plan that "does not require compilation."
   - *In practice, DICOM PS3.15 still requires option selection (Clean Pixel Data, Retain UIDs, etc.). Should the text qualify this?*

3. **Phase 1 transformation scope** — record-level actions only. Dataset-level statistical disclosure control is explicitly deferred. Bulk data cohort processing is supported but limited to record-level rules.
   - *Is the Phase 1 scope boundary clear enough?*
   - *Is "completing a Phase 1 workflow does not establish that any separately required dataset-level disclosure criteria have been met" strong enough as a disclaimer?*

4. **Consistency scope** — the `consistencyKey` identifies an authorized linkage scope. A shared key alone does not guarantee identical results; identity resolution, seed material, and derivation compatibility must also align.
   - *Is this level of detail appropriate for Volume 1, or should some move to Volume 2?*

5. **Two conformance layers** — content conformance and transaction conformance. Content conformance is the foundation. The Integrated actor in standalone mode claims content conformance only.
   - *Does this two-layer model work for IHE conformance testing and connectathon?*

6. **Payload binding framework** (informative). Six requirements any payload binding must fulfil. Table 1:PXX.4-1 shows illustrative future bindings (DIS-DICOM1, DIS-CDA1, DIS-V2-1).
   - *Is the framework general enough for DICOM and CDA? Any concerns?*
   - *Is this informative section useful at this stage, or premature?*

---

## Session 4: Use Cases, Security & Cross-Profile

**Read:** §1:PXX.4.2 Use Cases (all five), §1:PXX.5 Security Considerations, §1:PXX.6 Cross-Profile Considerations

**Approximate reading time:** 10–12 minutes (~2,900 words, but includes sequence diagrams)

### Reading Highlights

1. **Five use cases** span the profile's range:
   - **UC-1** (Cross-border epidemiological study) — async cohort, two-stage, registered policy, bulk data
   - **UC-2** (AI/ML method development) — async cohort, DICOM + HL7 FHIR, consistency scope reuse
   - **UC-3** (Clinical pathology order) — sync single-patient, pseudonymous care, reversible
   - **UC-4** (Cloud AI decision support) — sync single-patient, cloud deployment, trust boundary
   - **UC-5** (De-identified health data export) — standalone Integrated actor, content conformance only
   - *Do these five use cases adequately cover the profile's scope?*
   - *Any important use case missing?*

2. **UC-2 consistency scope reuse across formats** (§1:PXX.4.2.2). Future DICOM processing could reuse the consistency scope — but the text notes that "reusing the scope identifier alone is insufficient."
   - *Is this cross-format caveat adequate?*

3. **UC-5 open issue: Data Recipient actor** (§1:PXX.4.2.5.1, STU note). The standalone Integrated actor has no wire-testable transaction. The committee is asked whether a Data Recipient actor and push-delivery transaction should be added in Phase 1.
   - **This is the explicit committee question in the spec.** Please come prepared to discuss:
     - Does the standalone Integrated actor need a testable transaction for connectathon?
     - Would a Data Recipient actor overlap with MHD Document Source grouping?
     - Is content-only conformance testing sufficient for Phase 1?

4. **Security model** (§1:PXX.5). Six subsections: transport (ATNA/TLS), authorization (IUA/SMART), policy integrity (signed policies), reversibility material custody (Manager-only retention, seed handling), trust isolation between stages, and audit logging.
   - *Is the seed handling model (§1:PXX.5.4) clear — especially the Manager-to-De-Identifier seed sharing across trust boundaries?*
   - *Any security concerns not addressed?*

5. **Cross-profile considerations** (§1:PXX.6). IUA, ATNA/BALP, MHD, SMART Backend Services, external data permit profiles.
   - *Any missing cross-profile relationships?*
   - *The profile states it "consumes data request authorizations but does not produce them" — is this boundary clear?*
