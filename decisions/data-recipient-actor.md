# Open Question: Data Recipient Actor and Push-Delivery Transaction

**Status:** Open — for F2F meeting discussion  
**Date:** 2026-11-03  
**Scope:** DIS Phase 1 actor model and connectathon testability  
**Authors:** Alan Zhang

## 1. Problem Statement

DIS Phase 1 defines three deployment models:

1. **Distributed model** — Requester → Manager → De-Identifier(s)
2. **Integrated model with external Requester** — Requester → Integrated De-ID Manager/De-Identifier
3. **Integrated standalone model** — Integrated actor operates without external transactions

Deployment model 3 (standalone) has **no wire-testable transactions** — it produces conformant output through local invocation, but there is nothing for a connectathon test partner to interact with.

Additionally, the current profile groups the De-Identification Requester with the De-Identified Data Receiver role (the Requester always receives output). There is no push-delivery path where the Manager sends de-identified output to a separate destination. Use Cases 1 and 2 describe forwarding output to a Secure Processing Environment (SPE) as a post-DIS step outside the profile.

## 2. Proposed Change

Add a new actor, **Data Recipient**, and an optional transaction initiated by the De-ID Manager (or Integrated De-ID Manager/De-Identifier) to push de-identified output to the Data Recipient.

### What this would look like

| Element | Description |
|---------|-------------|
| New actor | Data Recipient — receives de-identified output and evidence |
| New transaction | ITI-x8 (placeholder) Push De-Identified Output — initiated by Manager or Integrated actor |
| Optionality | Optional for De-ID Manager and Integrated actor; required for Data Recipient |
| Integrated standalone | Could push output via ITI-x8, making deployment model 3 wire-testable |

### Actor/transaction impact

- Actors: 4 → 5
- Transactions: 4 → 5
- New row in actors/transactions table, options table, required groupings

## 3. Arguments For

### 3.1 Connectathon testability

The Integrated standalone actor currently has no wire-testable transaction. Adding a push-delivery transaction gives it an external interface that can be tested at connectathon.

### 3.2 Real-world push-delivery pattern

UC-1 and UC-2 both describe forwarding output to an SPE after the DIS workflow completes. Bringing this inside the profile standardizes a step that implementations will need anyway.

### 3.3 Separation of concerns

The Requester initiates de-identification; the Data Recipient consumes the result. These may be different systems (e.g., a DAC submits the job but the SPE receives the output). The current model forces the Requester to act as intermediary.

## 4. Arguments Against

### 4.1 Phase 1 scope creep

Phase 1 was deliberately scoped with the Requester as Data Receiver to keep the actor model simple. Adding a new actor and transaction increases specification, implementation, and testing surface.

### 4.2 Overlap with MHD grouping

Section 1:PXX.6.3 already notes that the Requester MAY group with MHD Document Source to publish de-identified documents. A DIS-native push transaction partially overlaps with this cross-profile capability.

### 4.3 Volume 2 burden

Every new transaction requires full message semantics, error handling, security considerations, and expected actions in Volume 2. This is significant specification work.

### 4.4 Optionality complexity

Another optional transaction adds another row to every table and another condition for implementers to navigate. The option matrix is already non-trivial.

## 5. Alternatives

### 5.1 Defer to Phase 2

Keep Phase 1 as-is with Requester = Data Receiver. Add a forward-looking note that a Data Recipient actor and push-delivery transaction are planned for Phase 2. Add a use case for deployment model 2 (Integrated with external Requester via ITI-x1) to partially close the coverage gap.

### 5.2 Integrated actor with ITI-x1 use case only

Add a use case demonstrating the Integrated actor accepting ITI-x1 from an external Requester (deployment model 2). This is already wire-testable with existing transactions and does not require new actors.

### 5.3 Content-only connectathon test

Define a connectathon test that validates the Integrated standalone actor's output artifacts (de-identified Bundle + Provenance evidence) without requiring a wire transaction. This tests content conformance rather than transaction conformance.

## 6. Questions for Discussion

1. Is push-delivery in scope for Phase 1, or should it be deferred?
2. If deferred, is a content-only connectathon test sufficient for the Integrated standalone actor?
3. Should the Data Recipient be a full actor, or a role that existing actors (e.g., MHD Document Recipient) can fulfill through grouping?
4. Does the push-delivery transaction carry only the de-identified output, or also the evidence and audit references?
5. Are there jurisdictional or regulatory requirements that mandate a standardized push-delivery path (e.g., EHDS data delivery)?
