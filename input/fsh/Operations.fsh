// DIS OperationDefinitions

// Shared parts of payload set results.
RuleSet: DISPayloadDeliveryParts(direction)
* parameter[=].part[+].name = #setId
* parameter[=].part[=].use = #{direction}
* parameter[=].part[=].min = 1
* parameter[=].part[=].max = "1"
* parameter[=].part[=].type = #string
* parameter[=].part[=].documentation = "Job-local payload set identifier."
* parameter[=].part[+].name = #payloadBinding
* parameter[=].part[=].use = #{direction}
* parameter[=].part[=].min = 1
* parameter[=].part[=].max = "1"
* parameter[=].part[=].type = #code
* parameter[=].part[=].documentation = "Binding that governs this payload set."
* parameter[=].part[+].name = #payloadVersion
* parameter[=].part[=].use = #{direction}
* parameter[=].part[=].min = 1
* parameter[=].part[=].max = "1"
* parameter[=].part[=].type = #code
* parameter[=].part[=].documentation = "Version defined by the selected binding."
* parameter[=].part[+].name = #manifestFormat
* parameter[=].part[=].use = #{direction}
* parameter[=].part[=].min = 1
* parameter[=].part[=].max = "1"
* parameter[=].part[=].type = #code
* parameter[=].part[=].documentation = "Use dis-resource-list or fhir-bulk-data."

// ── ITI-x1 Submit De-Identification Job ─────────────────────────────────────

Instance: submit-dis-job
InstanceOf: OperationDefinition
Title: "Submit De-Identification Job"
Description: """
The Submit De-Identification Job operation is invoked by the De-Identification
Requester to submit a de-identification job to the De-ID Manager (or Integrated
De-ID Manager/De-Identifier). The Requester supplies a version-specific Data Request
Authorization Contract reference and selects a permission for each payload set. The Requester declares the approved policy by
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

* affectsState = true

// ── Input: workItem ──
* parameter[+].name = #workItem
* parameter[=].use = #in
* parameter[=].min = 1
* parameter[=].max = "1"
* parameter[=].type = #Task
* parameter[=].documentation = "The direct POST body is a Task conforming to https://profiles.ihe.net/ITI/DIS/StructureDefinition/DIS-DeIdentificationJob."

// ── Output: payloadResult ──
* parameter[+].name = #payloadResult
* parameter[=].use = #out
* parameter[=].min = 1
* parameter[=].max = "*"
* parameter[=].documentation = "Payload set with one result package containing the manifest and evidence."
* insert DISPayloadDeliveryParts(out)
* parameter[=].part[+].name = #resultPackage
* parameter[=].part[=].use = #out
* parameter[=].part[=].min = 1
* parameter[=].part[=].max = "1"
* parameter[=].part[=].type = #Attachment
* parameter[=].part[=].documentation = "One R4 DIS Result Package containing the manifest and evidence, inline or at an authorized HTTPS URL."

// ── Output: validationStatus ──
* parameter[+].name = #validationStatus
* parameter[=].use = #out
* parameter[=].min = 1
* parameter[=].max = "1"
* parameter[=].documentation = "Overall validation outcome for the job. Successful completion uses valid."
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

* affectsState = true

// ── Input: workItem ──
* parameter[+].name = #workItem
* parameter[=].use = #in
* parameter[=].min = 1
* parameter[=].max = "1"
* parameter[=].type = #Task
* parameter[=].documentation = "The direct POST body is a Task conforming to https://profiles.ihe.net/ITI/DIS/StructureDefinition/DIS-DeIdentificationTask."

// ── Output: payloadResult ──
* parameter[+].name = #payloadResult
* parameter[=].use = #out
* parameter[=].min = 1
* parameter[=].max = "1"
* parameter[=].documentation = "Payload set with one result package containing the manifest and evidence."
* insert DISPayloadDeliveryParts(out)
* parameter[=].part[+].name = #resultPackage
* parameter[=].part[=].use = #out
* parameter[=].part[=].min = 1
* parameter[=].part[=].max = "1"
* parameter[=].part[=].type = #Attachment
* parameter[=].part[=].documentation = "One R4 DIS Result Package containing the manifest and evidence, inline or at an authorized HTTPS URL."

// ── Output: generatedLookupTable (Manager only) ──
* parameter[+].name = #generatedLookupTable
* parameter[=].use = #out
* parameter[=].min = 0
* parameter[=].max = "1"
* parameter[=].type = #DocumentReference
* parameter[=].documentation = "Inline DocumentReference conforming to DIS-LookupTable, returned for reversible Manager-managed patient identifier hashing. Protected output to the Manager."

// ── Output: validationStatus ──
* parameter[+].name = #validationStatus
* parameter[=].use = #out
* parameter[=].min = 1
* parameter[=].max = "1"
* parameter[=].documentation = "Per-task validation outcome. Successful completion uses valid."
* parameter[=].type = #code
