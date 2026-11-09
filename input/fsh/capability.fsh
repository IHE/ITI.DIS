// Actor conformance requirements. Deployments declare supported combinations
// on their implementation CapabilityStatement.
Extension: DISProcessingCapability
Id: dis-processing-capability
Title: "DIS Processing Capability"
Description: "One compatible payload binding, release, input manifest format, result manifest format, and reversibility mode. The actions listed are supported together for that combination."
* ^context[0].type = #element
* ^context[0].expression = "CapabilityStatement"
* value[x] 0..0
* extension contains
    binding 1..1 and
    release 1..1 and
    inputFormat 1..1 and
    resultFormat 1..1 and
    reversibilityMode 1..1 and
    action 1..*
* extension[binding].value[x] 1..1
* extension[binding].value[x] only code
* extension[release].value[x] 1..1
* extension[release].value[x] only code
* extension[inputFormat].value[x] 1..1
* extension[inputFormat].value[x] only code
* extension[resultFormat].value[x] 1..1
* extension[resultFormat].value[x] only code
* extension[reversibilityMode].value[x] 1..1
* extension[reversibilityMode].value[x] only code
* extension[action].value[x] 1..1
* extension[action].value[x] only code

RuleSet: DISCapabilityRequirements(actor)
* name = "{actor}"
* status = #draft
* kind = #requirements
* date = "2026-11-07"
* fhirVersion = #4.0.1
* format = #json

Instance: DIS-Requester
InstanceOf: CapabilityStatement
Usage: #definition
Title: "DIS De-Identification Requester"
* insert DISCapabilityRequirements(DISRequester)
* description = "The Requester submits a DIS Job Task directly to the ITI-x1 operation. When it declares DIS-ASYNC-JOB, it also polls the job URL using ITI-x4."
* rest[0].mode = #client
* rest[0].operation[0].name = "submit-dis-job"
* rest[0].operation[0].definition = Canonical(submit-dis-job)

Instance: DIS-Manager
InstanceOf: CapabilityStatement
Usage: #definition
Title: "DIS De-ID Manager"
* insert DISCapabilityRequirements(DISManager)
* description = "The Manager receives a direct DIS Job Task body in ITI-x1 and submits a direct DIS Execution Task body in ITI-x3. With DIS-ASYNC-JOB it serves ITI-x4 polling, and with DIS-ASYNC-TASK it initiates ITI-x7 polling."
* rest[0].mode = #server
* rest[0].operation[0].name = "submit-dis-job"
* rest[0].operation[0].definition = Canonical(submit-dis-job)
* rest[1].mode = #client
* rest[1].operation[0].name = "submit-dis-task"
* rest[1].operation[0].definition = Canonical(submit-dis-task)

Instance: DIS-De-Identifier
InstanceOf: CapabilityStatement
Usage: #definition
Title: "DIS De-Identifier"
* insert DISCapabilityRequirements(DISDeIdentifier)
* description = "The De-Identifier receives a direct DIS Execution Task body in ITI-x3 and publishes its compatible processing capabilities. With DIS-ASYNC-TASK it serves ITI-x7 polling."
* rest[0].mode = #server
* rest[0].operation[0].name = "submit-dis-task"
* rest[0].operation[0].definition = Canonical(submit-dis-task)

Instance: DIS-Integrated
InstanceOf: CapabilityStatement
Usage: #definition
Title: "DIS Integrated De-ID Manager/De-Identifier"
* insert DISCapabilityRequirements(DISIntegrated)
* description = "Standalone operation claims content conformance. When external submission is supported, the Integrated actor declares the ITI-x1 server operation and accepts a direct DIS Job Task body. With DIS-ASYNC-JOB it serves ITI-x4 polling."
* rest[0].mode = #server
* rest[0].operation[0].name = "submit-dis-job"
* rest[0].operation[0].definition = Canonical(submit-dis-job)
