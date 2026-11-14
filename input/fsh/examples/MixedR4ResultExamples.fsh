// Volume 3 result package with a bundled Patient and hosted Observation.

Instance: mixed-r4-result-of-Bundle
InstanceOf: DISResultPackage
Usage: #example
Title: "mixed-r4-result"
* id = "mixed-r4-result"
* type = #collection
* entry[0].fullUrl = "urn:uuid:2ad2439f-352e-526c-b6be-05f7f08dfedb"
* entry[=].resource = MixedResultManifest
* entry[+].fullUrl = "urn:uuid:fb8f0414-6d07-5d81-9f9a-add2fb151d91"
* entry[=].resource = result-patient
* entry[+].fullUrl = "urn:uuid:39b508ed-caab-5c2f-b536-3070fc6e7606"
* entry[=].resource = mixed-evidence

Instance: mixed-r4-result-of-Parameters
InstanceOf: Parameters
Usage: #example
Title: "mixed-r4-result"
* id = "mixed-r4-result"
* parameter[0].name = "payloadResult"
* parameter[=].part[0].name = "setId"
* parameter[=].part[=].valueString = "mixed-r4"
* parameter[=].part[+].name = "payloadBinding"
* parameter[=].part[=].valueCode = #DIS-FHIR-Payload
* parameter[=].part[+].name = "payloadVersion"
* parameter[=].part[=].valueCode = #R4
* parameter[=].part[+].name = "manifestFormat"
* parameter[=].part[=].valueCode = #dis-resource-list
* parameter[=].part[+].name = "resultPackage"
* parameter[=].part[=].valueAttachment.contentType = #application/fhir+json
* parameter[=].part[=].valueAttachment.data = "eyJyZXNvdXJjZVR5cGUiOiJCdW5kbGUiLCJ0eXBlIjoiY29sbGVjdGlvbiIsImVudHJ5IjpbeyJmdWxsVXJsIjoidXJuOnV1aWQ6MmFkMjQzOWYtMzUyZS01MjZjLWI2YmUtMDVmN2YwOGRmZWRiIiwicmVzb3VyY2UiOnsicmVzb3VyY2VUeXBlIjoiTGlzdCIsInN0YXR1cyI6ImN1cnJlbnQiLCJtb2RlIjoic25hcHNob3QiLCJtZXRhIjp7InByb2ZpbGUiOlsiaHR0cHM6Ly9wcm9maWxlcy5paGUubmV0L0lUSS9ESVMvU3RydWN0dXJlRGVmaW5pdGlvbi9ESVMtUmVzb3VyY2VNYW5pZmVzdCJdfSwiZW50cnkiOlt7Iml0ZW0iOnsicmVmZXJlbmNlIjoidXJuOnV1aWQ6ZmI4ZjA0MTQtNmQwNy01ZDgxLTlmOWEtYWRkMmZiMTUxZDkxIn19LHsiaXRlbSI6eyJyZWZlcmVuY2UiOiJodHRwczovL3Jlc3VsdHMuZXhhbXBsZS5vcmcvZmhpci9PYnNlcnZhdGlvbi9yZXN1bHQtb2JzZXJ2YXRpb24vX2hpc3RvcnkvMSJ9fV19fSx7ImZ1bGxVcmwiOiJ1cm46dXVpZDpmYjhmMDQxNC02ZDA3LTVkODEtOWY5YS1hZGQyZmIxNTFkOTEiLCJyZXNvdXJjZSI6eyJyZXNvdXJjZVR5cGUiOiJQYXRpZW50IiwiaWQiOiJyZXN1bHQtcGF0aWVudCIsImFjdGl2ZSI6dHJ1ZX19LHsiZnVsbFVybCI6InVybjp1dWlkOjM5YjUwOGVkLWNhYWItNWMyZi1iNTM2LTMwNzBmYzZlNzYwNiIsInJlc291cmNlIjp7InJlc291cmNlVHlwZSI6IlByb3ZlbmFuY2UiLCJpZCI6Im1peGVkLWV2aWRlbmNlIiwibWV0YSI6eyJwcm9maWxlIjpbImh0dHBzOi8vcHJvZmlsZXMuaWhlLm5ldC9JVEkvRElTL1N0cnVjdHVyZURlZmluaXRpb24vRElTLUV2aWRlbmNlIl19LCJ0YXJnZXQiOlt7InJlZmVyZW5jZSI6InVybjp1dWlkOmZiOGYwNDE0LTZkMDctNWQ4MS05ZjlhLWFkZDJmYjE1MWQ5MSJ9LHsicmVmZXJlbmNlIjoiaHR0cHM6Ly9yZXN1bHRzLmV4YW1wbGUub3JnL2ZoaXIvT2JzZXJ2YXRpb24vcmVzdWx0LW9ic2VydmF0aW9uL19oaXN0b3J5LzEifV0sInJlY29yZGVkIjoiMjAyNi0xMS0wNlQwMzowMDowMFoiLCJhY3Rpdml0eSI6eyJjb2RpbmciOlt7InN5c3RlbSI6Imh0dHBzOi8vcHJvZmlsZXMuaWhlLm5ldC9JVEkvRElTL0NvZGVTeXN0ZW0vZGlzLWFjdGl2aXR5IiwiY29kZSI6ImRpcy10YXNrIn1dfSwicG9saWN5IjpbImh0dHBzOi8vZ292ZXJuYW5jZS5leGFtcGxlLm9yZy9maGlyL0xpYnJhcnkvZ3JvdXBlZC1maGlyLXBvbGljeS1wYXRpZW50LXI0L19oaXN0b3J5LzEiXSwiYWdlbnQiOlt7InR5cGUiOnsiY29kaW5nIjpbeyJzeXN0ZW0iOiJodHRwOi8vdGVybWlub2xvZ3kuaGw3Lm9yZy9Db2RlU3lzdGVtL3Byb3ZlbmFuY2UtcGFydGljaXBhbnQtdHlwZSIsImNvZGUiOiJwZXJmb3JtZXIifV19LCJ3aG8iOnsiaWRlbnRpZmllciI6eyJzeXN0ZW0iOiJodHRwczovL2Rpcy5leGFtcGxlLm9yZy9pZGVudGlmaWVycy93b3JrZXIiLCJ2YWx1ZSI6ImludGVncmF0ZWQtZml4dHVyZSJ9fX1dLCJleHRlbnNpb24iOlt7InVybCI6Imh0dHBzOi8vcHJvZmlsZXMuaWhlLm5ldC9JVEkvRElTL1N0cnVjdHVyZURlZmluaXRpb24vZGlzLW91dGNvbWUtc3RhdHVzIiwidmFsdWVDb2RlIjoiY29tcGxldGUifSx7InVybCI6Imh0dHBzOi8vcHJvZmlsZXMuaWhlLm5ldC9JVEkvRElTL1N0cnVjdHVyZURlZmluaXRpb24vZGlzLXJ1bGVzZXQiLCJ2YWx1ZVN0cmluZyI6InJlbW92ZS1kaXJlY3QtbGluayJ9LHsidXJsIjoiaHR0cHM6Ly9wcm9maWxlcy5paGUubmV0L0lUSS9ESVMvU3RydWN0dXJlRGVmaW5pdGlvbi9kaXMtcmV2ZXJzaWJpbGl0eSIsInZhbHVlQ29kZSI6ImlycmV2ZXJzaWJsZSJ9LHsidXJsIjoiaHR0cHM6Ly9wcm9maWxlcy5paGUubmV0L0lUSS9ESVMvU3RydWN0dXJlRGVmaW5pdGlvbi9kaXMtdmFsaWRhdGlvbi1zdGF0dXMiLCJ2YWx1ZUNvZGUiOiJ2YWxpZCJ9LHsidXJsIjoiaHR0cHM6Ly9wcm9maWxlcy5paGUubmV0L0lUSS9ESVMvU3RydWN0dXJlRGVmaW5pdGlvbi9kaXMtYXVkaXQtY29ycmVsYXRpb24iLCJ2YWx1ZUlkZW50aWZpZXIiOnsic3lzdGVtIjoiaHR0cHM6Ly9kaXMuZXhhbXBsZS5vcmcvaWRlbnRpZmllcnMvYXVkaXQiLCJ2YWx1ZSI6ImpvYi1zaW5nbGUtcjQtaW5saW5lIn19XX19XSwibWV0YSI6eyJwcm9maWxlIjpbImh0dHBzOi8vcHJvZmlsZXMuaWhlLm5ldC9JVEkvRElTL1N0cnVjdHVyZURlZmluaXRpb24vRElTLVJlc3VsdFBhY2thZ2UiXX0sImlkIjoibWl4ZWQtcjQtcmVzdWx0In0="
* parameter[+].name = "validationStatus"
* parameter[=].valueCode = #valid

Instance: MixedResultManifest
InstanceOf: DISResourceManifest
Usage: #inline
* status = #current
* mode = #snapshot
* entry[0].item = Reference(urn:uuid:fb8f0414-6d07-5d81-9f9a-add2fb151d91)
* entry[+].item = Reference(https://results.example.org/fhir/Observation/result-observation/_history/1)

Instance: mixed-evidence
InstanceOf: DISEvidence
Usage: #inline
* id = "mixed-evidence"
* target[0] = Reference(urn:uuid:fb8f0414-6d07-5d81-9f9a-add2fb151d91)
* target[+] = Reference(https://results.example.org/fhir/Observation/result-observation/_history/1)
* recorded = "2026-11-06T03:00:00Z"
* activity = https://profiles.ihe.net/ITI/DIS/CodeSystem/dis-activity#dis-task
* policy = "https://governance.example.org/fhir/Contract/grouped-fhir-policy-patient-r4/_history/1"
* agent.type = http://terminology.hl7.org/CodeSystem/provenance-participant-type#performer
* agent.who.identifier.system = "https://dis.example.org/identifiers/worker"
* agent.who.identifier.value = "integrated-fixture"
* extension[outcomeStatus].valueCode = #complete
* extension[ruleSet].valueString = "remove-direct-link"
* extension[reversibility].valueCode = #irreversible
* extension[validationStatus].valueCode = #valid
* extension[auditCorrelation].valueIdentifier.system = "https://dis.example.org/identifiers/audit"
* extension[auditCorrelation].valueIdentifier.value = "job-single-r4-inline"

Instance: result-patient
InstanceOf: Patient
Usage: #inline
* id = "result-patient"
* active = true
