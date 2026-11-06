// DIS Profiles

// ── DIS-Evidence ─────────────────────────────────────────────────────────────

Profile: DISEvidence
Parent: Provenance
Id: DIS-Evidence
Title: "DIS Evidence"
Description: """
DIS de-identification evidence. A Provenance resource recording the outcome,
policy reference, ruleSet identifier, reversibility state, validation result,
and audit correlation for a completed de-identification task. An optional
transformation summary records the per-element actions applied.
"""
* ^url = "https://profiles.ihe.net/ITI/DIS/StructureDefinition/DIS-Evidence"
* ^status = #active
* ^experimental = false
* extension contains
    DisOutcomeStatusExt named outcomeStatus 1..1 and
    DisRulesetExt named ruleSet 1..1 and
    DisReversibilityExt named reversibility 1..1 and
    DisValidationStatusExt named validationStatus 1..1 and
    DisAuditCorrelationExt named auditCorrelation 1..1 and
    DisTransformationSummaryExt named transformationSummary 0..1
* target 1..*
* recorded 1..1
* policy 1..*
* activity 1..1
* agent 1..*
* agent ^comment = "At least one agent entry SHALL use type coding http://terminology.hl7.org/CodeSystem/provenance-participant-type#performer to identify the De-Identifier that executed the task."


// ── DIS-Policy ───────────────────────────────────────────────────────────────

Profile: DISPolicy
Parent: Library
Id: DIS-Policy
Title: "DIS Policy"
Description: """
DIS de-identification policy artifact. A Library resource carrying a versioned
policy governing de-identification transformations. The policy rules JSON is
carried in Library.content as base64-encoded data. A policy may be delivered
inline (JWS-signed via policy.content in ITI-x1) or resolved by the De-ID
Manager from its own trust model. Policies are distinguished from execution
plans by Library.type coding dis-policy.
"""
* ^url = "https://profiles.ihe.net/ITI/DIS/StructureDefinition/DIS-Policy"
* ^status = #active
* ^experimental = false
* url 1..1
* identifier 1..*
* version 1..1
* name 1..1
* status 1..1
* type 1..1
* type = https://profiles.ihe.net/ITI/DIS/CodeSystem/dis-library-type#dis-policy "De-identification policy (Semantic-Level or Syntax-Level rules)"
* date 1..1
* publisher 1..1
* effectivePeriod 1..1
* content 1..1
* content.contentType 1..1
* content.contentType = #"application/vnd.ihe.dis.policy+json"
* content.data 1..1


// ── DIS-ExecutionPlan ─────────────────────────────────────────────────────────

Profile: DISExecutionPlan
Parent: Library
Id: DIS-ExecutionPlan
Title: "DIS Execution Plan"
Description: """
DIS execution plan artifact. A Library resource carrying a payload-specific,
compiled set of transformation rules dispatched by the De-ID Manager to a
De-Identifier via ITI-x3. Execution plans are derived from a DIS-Policy and
contain only concrete element paths — semantic group references are expanded
during compilation. Execution plans are distinguished from policies by
Library.type coding dis-execution-plan.
"""
* ^url = "https://profiles.ihe.net/ITI/DIS/StructureDefinition/DIS-ExecutionPlan"
* ^status = #active
* ^experimental = false
* url 1..1
* version 1..1
* name 1..1
* status 1..1
* type 1..1
* type = https://profiles.ihe.net/ITI/DIS/CodeSystem/dis-library-type#dis-execution-plan "Execution plan (payload-specific compiled rules)"
* date 1..1
* content 1..1
* content.contentType 1..1
* content.contentType = #"application/vnd.ihe.dis.execution-plan+json"
* content.data 1..1

// ── Persistent, referenceable lookup table ──────────────────────────────────
Profile: DISLookupTable
Parent: DocumentReference
Id: DIS-LookupTable
Title: "DIS Lookup Table"
Description: "Identified metadata for a protected reversible mapping table. Requester-supplied tables carry inline JSON or reference a protected Binary. Task-generated tables carry inline JSON and are returned to the Manager for retention."
* ^url = "https://profiles.ihe.net/ITI/DIS/StructureDefinition/DIS-LookupTable"
* ^status = #active
* ^experimental = false
* masterIdentifier 1..1
* masterIdentifier.system 1..1
* masterIdentifier.value 1..1
* identifier 1..*
* identifier.system 1..1
* identifier.value 1..1
* status 1..1
* status ^comment = "Only current documents may be selected for new jobs; superseded and entered-in-error states remain available for repository lifecycle management."
* type 1..1
* type = https://profiles.ihe.net/ITI/DIS/CodeSystem/dis-document-type#lookup-table "DIS reversible lookup table"
* extension contains DisIdentityLinkageScopeExt named identityLinkageScope 1..1
* content 1..1
* content.attachment.contentType 1..1
* content.attachment.contentType = #"application/json"
* content.attachment obeys dis-lookup-content-choice
* content.attachment.url ^comment = "If present, resolves to a protected Binary conforming to DIS-LookupTableContent. Pin metadata and exact content bytes before processing."

Invariant: dis-lookup-content-choice
Description: "Lookup table content SHALL have exactly one of inline data or a Binary URL."
Severity: #error
Expression: "data.exists() xor url.exists()"

Profile: DISLookupTableContent
Parent: Binary
Id: DIS-LookupTableContent
Title: "DIS Lookup Table Content"
Description: "Protected JSON mapping content for a DIS Lookup Table DocumentReference. JSON conforms to the DIS lookup-table schema and semantic validation rules."
* ^url = "https://profiles.ihe.net/ITI/DIS/StructureDefinition/DIS-LookupTableContent"
* ^status = #active
* ^experimental = false
* contentType = #"application/json"
* data 1..1
