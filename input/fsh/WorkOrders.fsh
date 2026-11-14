Alias: $DISWorkOrderType = https://profiles.ihe.net/ITI/DIS/CodeSystem/dis-work-order-type
Alias: $DISTaskInput = https://profiles.ihe.net/ITI/DIS/CodeSystem/dis-task-input

CodeSystem: DISWorkOrderType
Id: dis-work-order-type
Title: "DIS Work Order Types"
Description: "Identifies the two kinds of submitted DIS work orders."
* ^experimental = false
* ^caseSensitive = true
* ^content = #complete
* #de-identification-job "De-identification job"
* #de-identification-execution "De-identification task"

CodeSystem: DISTaskInput
Id: dis-task-input
Title: "DIS Work Order Inputs"
Description: "Identifies each input to a DIS work order."
* ^experimental = false
* ^caseSensitive = true
* ^content = #complete
* #authorization "Data request authorization"
* #payload-set "Payload set"
* #execution-plan "Execution plan"
* #rule-set-id "RuleSet identifier"
* #stage-id "Stage identifier"
* #reversibility-mode "Reversibility mode"
* #lookup-table "Assignment-scoped lookup table"

Extension: DISPayloadSet
Id: dis-payload-set
Title: "DIS Payload Set Metadata"
Description: "Associates the binding, version and selection format with the manifest carried by one Task input. A job input also identifies its Agreement permission, purpose, approved policy and any optional policy content or supplied lookup table."
Context: Task.input
* extension contains
    setId 1..1 and
    payloadBinding 1..1 and
    payloadVersion 1..1 and
    manifestFormat 1..1 and
    permission 0..1 and
    purpose 0..1 and
    policy 0..1 and
    policyContent 0..1 and
    lookupTable 0..1
* extension[setId].value[x] 1..1
* extension[setId].value[x] only string
* extension[payloadBinding].value[x] 1..1
* extension[payloadBinding].value[x] only code
* extension[payloadVersion].value[x] 1..1
* extension[payloadVersion].value[x] only code
* extension[manifestFormat].value[x] 1..1
* extension[manifestFormat].value[x] only code
* extension[manifestFormat].value[x] obeys dis-work-order-manifest-format
* extension[permission].value[x] 1..1
* extension[permission].value[x] only uri
* extension[permission].value[x] obeys dis-absolute-iri
* extension[purpose].value[x] 1..1
* extension[purpose].value[x] only uri
* extension[purpose].value[x] obeys dis-absolute-iri
* extension[policy].value[x] 1..1
* extension[policy].value[x] only canonical
* extension[policy].value[x] obeys dis-source-policy-version
* extension[policyContent].value[x] 1..1
* extension[policyContent].value[x] only Reference(DISSignedPolicy)
* extension[policyContent].value[x] obeys dis-work-order-local-policy
* extension[lookupTable].value[x] 1..1
* extension[lookupTable].value[x] only Reference(DISLookupTable)

Profile: DISSignedPolicy
Parent: Binary
Id: DIS-SignedPolicy
Title: "DIS Signed Policy"
Description: "Contained JWS-signed policy Library carried in a job submission."
* id 1..1
* contentType = #"application/jose" (exactly)
* data 1..1

RuleSet: DISWorkOrderSubmission
* identifier 1..1
* identifier.system 1..1
* identifier.value 1..1
* intent = #order (exactly)
* status = #requested (exactly)
* code 1..1
* output 0..0
* input ^slicing.discriminator.type = #pattern
* input ^slicing.discriminator.path = "type"
* input ^slicing.rules = #closed

RuleSet: DISWorkOrderPayloadSet
* input[payloadSet].type = $DISTaskInput#payload-set
* input[payloadSet].value[x] only Attachment
* input[payloadSet].value[x].contentType 1..1
* input[payloadSet].value[x] obeys dis-work-order-manifest-source
* input[payloadSet].extension contains DISPayloadSet named payloadSet 1..1

Profile: DISDeIdentificationJob
Parent: Task
Id: DIS-DeIdentificationJob
Title: "De-Identification Job"
Description: "FHIR R4 representation of the de-identification job submitted through ITI-x1. Each payload set identifies the applicable Agreement permission, purpose and exact approved policy version."
* insert DISWorkOrderSubmission
* code = $DISWorkOrderType#de-identification-job
* contained only DISSignedPolicy
* input contains authorization 1..1 and payloadSet 1..*
* input[authorization].type = $DISTaskInput#authorization
* input[authorization].value[x] 1..1
* input[authorization].value[x] only Reference(DISDataRequestAuthorizationContract)
* input[authorization].value[x].reference 1..1
* input[authorization] obeys dis-work-order-authorization
* insert DISWorkOrderPayloadSet
* input[payloadSet].extension[payloadSet].extension[permission] 1..1
* input[payloadSet].extension[payloadSet].extension[purpose] 1..1
* input[payloadSet].extension[payloadSet].extension[policy] 1..1
* obeys dis-work-order-unique-sets

Profile: DISDeIdentificationTask
Parent: Task
Id: DIS-DeIdentificationTask
Title: "De-Identification Task"
Description: "FHIR R4 representation of a de-identification task submitted through ITI-x3 for one ruleSet and one payload set."
* insert DISWorkOrderSubmission
* code = $DISWorkOrderType#de-identification-execution
* contained 0..0
* basedOn 0..0
* groupIdentifier 0..0
* partOf 0..1
* partOf only Reference(DISDeIdentificationJob)
* partOf.reference 0..0
* partOf.display 0..0
* partOf.identifier 1..1
* partOf.identifier.system 1..1
* partOf.identifier.value 1..1
* input contains
    payloadSet 1..1 and
    executionPlan 1..1 and
    ruleSetId 1..1 and
    stageId 0..1 and
    reversibilityMode 1..1 and
    lookupTable 0..1
* insert DISWorkOrderPayloadSet
* input[payloadSet].extension[payloadSet].extension[permission] 0..0
* input[payloadSet].extension[payloadSet].extension[purpose] 0..0
* input[payloadSet].extension[payloadSet].extension[policy] 0..0
* input[payloadSet].extension[payloadSet].extension[policyContent] 0..0
* input[payloadSet].extension[payloadSet].extension[lookupTable] 0..0
* input[executionPlan].type = $DISTaskInput#execution-plan
* input[executionPlan].value[x] only Reference(DISExecutionPlan)
* input[ruleSetId].type = $DISTaskInput#rule-set-id
* input[ruleSetId].value[x] only string
* input[stageId].type = $DISTaskInput#stage-id
* input[stageId].value[x] only string
* input[reversibilityMode].type = $DISTaskInput#reversibility-mode
* input[reversibilityMode].value[x] only code
* input[reversibilityMode].value[x] from DisReversibilityVS (required)
* input[lookupTable].type = $DISTaskInput#lookup-table
* input[lookupTable].value[x] only Reference(DISLookupTable)

Invariant: dis-work-order-manifest-source
Description: "The manifest attachment has exactly one of inline data or an absolute HTTPS URL."
Severity: #error
Expression: "(data.exists() xor url.exists()) and (url.empty() or url.startsWith('https://'))"

Invariant: dis-work-order-manifest-format
Description: "The manifest format is dis-resource-list or fhir-bulk-data."
Severity: #error
Expression: "$this = 'dis-resource-list' or $this = 'fhir-bulk-data'"

Invariant: dis-work-order-local-policy
Description: "Supplied signed policy content points to a contained Binary."
Severity: #error
Expression: "reference.matches('^#[A-Za-z0-9.-]{1,64}$')"

Invariant: dis-work-order-authorization
Description: "Authorization references the exact version of a DIS Data Request Authorization Contract using an absolute HTTPS URL."
Severity: #error
Expression: "value.ofType(Reference).reference.matches('^https://[^?# ]+/Contract/[A-Za-z0-9.-]{1,64}/_history/[A-Za-z0-9.-]{1,64}$')"

Invariant: dis-absolute-iri
Description: "The identifier is an absolute IRI."
Severity: #error
Expression: "$this.matches('^[A-Za-z][A-Za-z0-9+.-]*:[^ ]+$')"

Invariant: dis-work-order-unique-sets
Description: "Set identifiers are unique within the job."
Severity: #error
Expression: "input.extension.where(url = 'https://profiles.ihe.net/ITI/DIS/StructureDefinition/dis-payload-set').extension.where(url = 'setId').value.isDistinct()"
