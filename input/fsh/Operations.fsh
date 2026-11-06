// DIS OperationDefinitions

// ── ITI-x1 Submit De-Identification Job ─────────────────────────────────────

Instance: submit-dis-job
InstanceOf: OperationDefinition
Title: "Submit De-Identification Job"
Description: """
The Submit De-Identification Job operation is invoked by the De-Identification
Requester to submit a de-identification job to the De-ID Manager (or Integrated
De-ID Manager/De-Identifier). The Requester declares the approved policy by
canonical URL and version, presents data request authorization evidence, and
includes references to the processing targets.
"""
Usage: #definition
* url = "https://profiles.ihe.net/ITI/DIS/OperationDefinition/submit-dis-job"
* name = "SubmitDISJob"
* status = #active
* kind = #operation
* code = #submit-dis-job
* system = true
* type = false
* instance = false

// ── Input: authorization ──
* parameter[+].name = #authorization
* parameter[=].use = #in
* parameter[=].min = 1
* parameter[=].max = "1"
* parameter[=].documentation = "Data request authorization evidence; exactly one of authorization.reference or authorization.content SHALL be present."
* parameter[=].type = #BackboneElement

* parameter[=].part[+].name = #reference
* parameter[=].part[=].use = #in
* parameter[=].part[=].min = 0
* parameter[=].part[=].max = "1"
* parameter[=].part[=].documentation = "Reference to an externally hosted authorization evidence resource."
* parameter[=].part[=].type = #Reference

* parameter[=].part[+].name = #content
* parameter[=].part[=].use = #in
* parameter[=].part[=].min = 0
* parameter[=].part[=].max = "1"
* parameter[=].part[=].documentation = "Authorization evidence embedded directly; contentType declares the format."
* parameter[=].part[=].type = #Attachment

// ── Input: policy ──
* parameter[+].name = #policy
* parameter[=].use = #in
* parameter[=].min = 1
* parameter[=].max = "1"
* parameter[=].documentation = "Identifies the approved de-identification policy for this data request."
* parameter[=].type = #BackboneElement

* parameter[=].part[+].name = #url
* parameter[=].part[=].use = #in
* parameter[=].part[=].min = 1
* parameter[=].part[=].max = "1"
* parameter[=].part[=].documentation = "Canonical URL of the approved policy (Library.url)."
* parameter[=].part[=].type = #uri

* parameter[=].part[+].name = #version
* parameter[=].part[=].use = #in
* parameter[=].part[=].min = 1
* parameter[=].part[=].max = "1"
* parameter[=].part[=].documentation = "Version of the approved policy (Library.version)."
* parameter[=].part[=].type = #string

* parameter[=].part[+].name = #content
* parameter[=].part[=].use = #in
* parameter[=].part[=].min = 0
* parameter[=].part[=].max = "1"
* parameter[=].part[=].documentation = "JWS-signed policy artifact, when the Requester carries the policy content directly. Binary.contentType SHALL be application/jose."
* parameter[=].part[=].type = #Binary

// ── Input: lookupTable ──
* parameter[+].name = #lookupTable
* parameter[=].use = #in
* parameter[=].min = 0
* parameter[=].max = "1"
* parameter[=].type = #Reference
* parameter[=].targetProfile = "https://profiles.ihe.net/ITI/DIS/StructureDefinition/DIS-LookupTable"
* parameter[=].documentation = "Reference to an identified DIS Lookup Table DocumentReference. Resolve and pin its version-specific identifier and exact JSON content before processing. For tasks, expose only assigned entries through a protected scoped document. Missing entries fail the job without fallback or partial output."

// ── Input: processingTarget ──
* parameter[+].name = #processingTarget
* parameter[=].use = #in
* parameter[=].min = 1
* parameter[=].max = "*"
* parameter[=].documentation = "Reference(s) to the resource(s) to be de-identified, or embedded resource content. Supports by-reference, by-value, and by-manifest delivery modes."
* parameter[=].type = #Resource

// ── Input: payloadBinding ──
* parameter[+].name = #payloadBinding
* parameter[=].use = #in
* parameter[=].min = 1
* parameter[=].max = "1"
* parameter[=].documentation = "Payload binding identifier (e.g., DIS-FHIR-Payload)."
* parameter[=].type = #code

// ── Input: payloadVersion ──
* parameter[+].name = #payloadVersion
* parameter[=].use = #in
* parameter[=].min = 1
* parameter[=].max = "1"
* parameter[=].documentation = "HL7 FHIR version of the processing payload (e.g., R4, R5, R6)."
* parameter[=].type = #code

// ── Output: output ──
* parameter[+].name = #output
* parameter[=].use = #out
* parameter[=].min = 1
* parameter[=].max = "1"
* parameter[=].documentation = "De-identified resource(s) produced by the job."
* parameter[=].type = #Resource

// ── Output: evidence ──
* parameter[+].name = #evidence
* parameter[=].use = #out
* parameter[=].min = 1
* parameter[=].max = "*"
* parameter[=].documentation = "HL7 FHIR R4 Provenance resources recording transformation decisions."
* parameter[=].type = #Provenance

// ── Output: validationStatus ──
* parameter[+].name = #validationStatus
* parameter[=].use = #out
* parameter[=].min = 1
* parameter[=].max = "1"
* parameter[=].documentation = "Overall validation outcome for the job."
* parameter[=].type = #code


// ── ITI-x3 Submit De-Identification Task ────────────────────────────────────

Instance: submit-dis-task
InstanceOf: OperationDefinition
Title: "Submit De-Identification Task"
Description: """
The Submit De-Identification Task operation is invoked by the De-ID Manager to
dispatch a single ruleSet execution to a De-Identifier. The Manager provides
the compiled execution plan, processing targets, and operational
parameters derived from the validated policy.
"""
Usage: #definition
* url = "https://profiles.ihe.net/ITI/DIS/OperationDefinition/submit-dis-task"
* name = "SubmitDISTask"
* status = #active
* kind = #operation
* code = #submit-dis-task
* system = true
* type = false
* instance = false

// ── Input: executionPlan ──
* parameter[+].name = #executionPlan
* parameter[=].use = #in
* parameter[=].min = 1
* parameter[=].max = "1"
* parameter[=].documentation = "Reference to the Library resource containing the compiled execution plan rules for this ruleSet."
* parameter[=].type = #Reference
* parameter[=].targetProfile = "https://profiles.ihe.net/ITI/DIS/StructureDefinition/DIS-ExecutionPlan"

// ── Input: processingTarget ──
* parameter[+].name = #processingTarget
* parameter[=].use = #in
* parameter[=].min = 1
* parameter[=].max = "*"
* parameter[=].documentation = "Reference(s) to the data to be transformed."
* parameter[=].type = #Reference

// ── Input: ruleSetId ──
* parameter[+].name = #ruleSetId
* parameter[=].use = #in
* parameter[=].min = 1
* parameter[=].max = "1"
* parameter[=].documentation = "Identifier of the ruleSet from the source policy that this task executes."
* parameter[=].type = #string

// ── Input: stageId ──
* parameter[+].name = #stageId
* parameter[=].use = #in
* parameter[=].min = 0
* parameter[=].max = "1"
* parameter[=].documentation = "Stage identifier, when the source policy declares staged execution."
* parameter[=].type = #string

// ── Input: payloadBinding ──
* parameter[+].name = #payloadBinding
* parameter[=].use = #in
* parameter[=].min = 1
* parameter[=].max = "1"
* parameter[=].documentation = "Payload binding identifier."
* parameter[=].type = #code

// ── Input: payloadVersion ──
* parameter[+].name = #payloadVersion
* parameter[=].use = #in
* parameter[=].min = 1
* parameter[=].max = "1"
* parameter[=].documentation = "HL7 FHIR version of the processing payload."
* parameter[=].type = #code

// ── Input: lookupTable ──
* parameter[+].name = #lookupTable
* parameter[=].use = #in
* parameter[=].min = 0
* parameter[=].max = "1"
* parameter[=].type = #Reference
* parameter[=].targetProfile = "https://profiles.ihe.net/ITI/DIS/StructureDefinition/DIS-LookupTable"
* parameter[=].documentation = "Reference to an identified DIS Lookup Table DocumentReference. Resolve and pin its version-specific identifier and exact JSON content before processing. For tasks, expose only assigned entries through a protected scoped document. Missing entries fail the job without fallback or partial output."

// ── Input: reversibilityMode ──
* parameter[+].name = #reversibilityMode
* parameter[=].use = #in
* parameter[=].min = 1
* parameter[=].max = "1"
* parameter[=].documentation = "Reversibility mode (irreversible or reversible); derived from the policy validated in ITI-x1."
* parameter[=].type = #code

// ── Output: output ──
* parameter[+].name = #output
* parameter[=].use = #out
* parameter[=].min = 1
* parameter[=].max = "1"
* parameter[=].documentation = "De-identified resource(s) produced for this ruleSet."
* parameter[=].type = #Resource

// ── Output: generatedLookupTable (Manager only) ──
* parameter[+].name = #generatedLookupTable
* parameter[=].use = #out
* parameter[=].min = 0
* parameter[=].max = "1"
* parameter[=].type = #DocumentReference
* parameter[=].targetProfile = "https://profiles.ihe.net/ITI/DIS/StructureDefinition/DIS-LookupTable"
* parameter[=].documentation = "Inline DIS Lookup Table returned for reversible Manager-managed patient identifier hashing. Protected output to the Manager."

// ── Output: evidence ──
* parameter[+].name = #evidence
* parameter[=].use = #out
* parameter[=].min = 1
* parameter[=].max = "*"
* parameter[=].documentation = "HL7 FHIR R4 Provenance resources recording transformation decisions for this task."
* parameter[=].type = #Provenance

// ── Output: validationStatus ──
* parameter[+].name = #validationStatus
* parameter[=].use = #out
* parameter[=].min = 1
* parameter[=].max = "1"
* parameter[=].documentation = "Per-task validation outcome."
* parameter[=].type = #code
