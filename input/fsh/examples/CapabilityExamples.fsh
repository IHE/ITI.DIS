RuleSet: ExampleCoreActions(combination)
* extension[{combination}].extension[+].url = "action"
* extension[{combination}].extension[=].valueCode = #remove
* extension[{combination}].extension[+].url = "action"
* extension[{combination}].extension[=].valueCode = #replace
* extension[{combination}].extension[+].url = "action"
* extension[{combination}].extension[=].valueCode = #keep
* extension[{combination}].extension[+].url = "action"
* extension[{combination}].extension[=].valueCode = #hash
* extension[{combination}].extension[+].url = "action"
* extension[{combination}].extension[=].valueCode = #truncate-date
* extension[{combination}].extension[+].url = "action"
* extension[{combination}].extension[=].valueCode = #date-shift
* extension[{combination}].extension[+].url = "action"
* extension[{combination}].extension[=].valueCode = #round
* extension[{combination}].extension[+].url = "action"
* extension[{combination}].extension[=].valueCode = #truncate
* extension[{combination}].extension[+].url = "action"
* extension[{combination}].extension[=].valueCode = #redact

Instance: example-async-de-identifier
InstanceOf: CapabilityStatement
Usage: #example
Title: "De-Identifier supporting asynchronous and cancellable tasks"
Description: "Synthetic deployment supporting asynchronous and cancellable ITI-x3 work with core FHIR actions in irreversible and reversible combinations and an optional AES-FF1 configuration."
* status = #draft
* date = "2026-11-11"
* kind = #instance
* implementation.description = "Illustrative DIS De-Identifier"
* implementation.url = "https://de-id.example.org/fhir"
* fhirVersion = #4.0.1
* format[0] = #json
* extension[0].url = Canonical(DISProcessingCapability)
* extension[0].extension[0].url = "binding"
* extension[0].extension[0].valueCode = #DIS-FHIR-Payload
* extension[0].extension[1].url = "release"
* extension[0].extension[1].valueCode = #R4
* extension[0].extension[2].url = "inputFormat"
* extension[0].extension[2].valueCode = #dis-resource-list
* extension[0].extension[3].url = "resultFormat"
* extension[0].extension[3].valueCode = #dis-resource-list
* extension[0].extension[4].url = "reversibilityMode"
* extension[0].extension[4].valueCode = #irreversible
* insert ExampleCoreActions(0)
* extension[1].url = Canonical(DISProcessingCapability)
* extension[1].extension[0].url = "binding"
* extension[1].extension[0].valueCode = #DIS-FHIR-Payload
* extension[1].extension[1].url = "release"
* extension[1].extension[1].valueCode = #R4
* extension[1].extension[2].url = "inputFormat"
* extension[1].extension[2].valueCode = #dis-resource-list
* extension[1].extension[3].url = "resultFormat"
* extension[1].extension[3].valueCode = #dis-resource-list
* extension[1].extension[4].url = "reversibilityMode"
* extension[1].extension[4].valueCode = #reversible
* insert ExampleCoreActions(1)
* extension[1].extension[+].url = "action"
* extension[1].extension[=].valueCode = #encrypt
* extension[1].extension[+].url = "encryptionConfiguration"
* extension[1].extension[=].valueUri = "https://example.org/configurations/ff1-decimal10/versions/1"
* rest[0].mode = #server
* rest[0].security.service[0] = http://profiles.ihe.net/fhir/ihe.securityTypes/CodeSystem/securityTypes#IUA
* rest[0].operation[0].name = "submit-dis-task"
* rest[0].operation[0].definition = Canonical(submit-dis-task)
* rest[0].operation[0].documentation = "Terminal polling outcomes and submission replay records are each retained for at least 24 hours. The maximum pending cancellation interval is 10 minutes. Cancellation outcomes are retained for at least 24 hours. Both R4 list combinations support deterministic date-shift using the deployment’s provisioned derive-offset method, version 1, a job or source-institution scope, and the patient business identifier pair. The maximum supported maxOffsetDays is 365. The reversible combination supports supplied lookup mappings and salted hashing with Manager-managed mappings."
* rest[0].operation[0].extension[0].url = Canonical(DISAsyncSupport)
* rest[0].operation[0].extension[0].valueBoolean = true
