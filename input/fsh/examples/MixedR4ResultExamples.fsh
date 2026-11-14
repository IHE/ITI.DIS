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
* parameter[=].part[=].valueAttachment.data = "eyJyZXNvdXJjZVR5cGUiOiJCdW5kbGUiLCJ0eXBlIjoiY29sbGVjdGlvbiIsImVudHJ5IjpbeyJmdWxsVXJsIjoidXJuOnV1aWQ6MmFkMjQzOWYtMzUyZS01MjZjLWI2YmUtMDVmN2YwOGRmZWRiIiwicmVzb3VyY2UiOnsicmVzb3VyY2VUeXBlIjoiTGlzdCIsInN0YXR1cyI6ImN1cnJlbnQiLCJtb2RlIjoic25hcHNob3QiLCJtZXRhIjp7InByb2ZpbGUiOlsiaHR0cHM6Ly9wcm9maWxlcy5paGUubmV0L0lUSS9ESVMvU3RydWN0dXJlRGVmaW5pdGlvbi9ESVMtUmVzb3VyY2VNYW5pZmVzdCJdfSwiZW50cnkiOlt7Iml0ZW0iOnsicmVmZXJlbmNlIjoidXJuOnV1aWQ6ZmI4ZjA0MTQtNmQwNy01ZDgxLTlmOWEtYWRkMmZiMTUxZDkxIn19LHsiaXRlbSI6eyJyZWZlcmVuY2UiOiJodHRwczovL3Jlc3VsdHMuZXhhbXBsZS5vcmcvZmhpci9PYnNlcnZhdGlvbi9yZXN1bHQtb2JzZXJ2YXRpb24vX2hpc3RvcnkvMSJ9fV19fSx7ImZ1bGxVcmwiOiJ1cm46dXVpZDpmYjhmMDQxNC02ZDA3LTVkODEtOWY5YS1hZGQyZmIxNTFkOTEiLCJyZXNvdXJjZSI6eyJyZXNvdXJjZVR5cGUiOiJQYXRpZW50IiwiaWQiOiJyZXN1bHQtcGF0aWVudCIsImFjdGl2ZSI6dHJ1ZX19LHsiZnVsbFVybCI6InVybjp1dWlkOjM5YjUwOGVkLWNhYWItNWMyZi1iNTM2LTMwNzBmYzZlNzYwNiIsInJlc291cmNlIjp7InJlc291cmNlVHlwZSI6IlByb3ZlbmFuY2UiLCJpZCI6Im1peGVkLWV2aWRlbmNlIiwibWV0YSI6eyJwcm9maWxlIjpbImh0dHBzOi8vcHJvZmlsZXMuaWhlLm5ldC9JVEkvRElTL1N0cnVjdHVyZURlZmluaXRpb24vRElTLUV2aWRlbmNlIl19LCJ0YXJnZXQiOlt7InJlZmVyZW5jZSI6InVybjp1dWlkOmZiOGYwNDE0LTZkMDctNWQ4MS05ZjlhLWFkZDJmYjE1MWQ5MSJ9LHsicmVmZXJlbmNlIjoiaHR0cHM6Ly9yZXN1bHRzLmV4YW1wbGUub3JnL2ZoaXIvT2JzZXJ2YXRpb24vcmVzdWx0LW9ic2VydmF0aW9uL19oaXN0b3J5LzEifV0sInJlY29yZGVkIjoiMjAyNi0xMS0wNlQwMzowMDowMFoiLCJhY3Rpdml0eSI6eyJjb2RpbmciOlt7InN5c3RlbSI6Imh0dHBzOi8vcHJvZmlsZXMuaWhlLm5ldC9JVEkvRElTL0NvZGVTeXN0ZW0vZGlzLWFjdGl2aXR5IiwiY29kZSI6ImRpcy10YXNrIn1dfSwicG9saWN5IjpbImh0dHBzOi8vZ292ZXJuYW5jZS5leGFtcGxlLm9yZy9maGlyL0NvbnRyYWN0L2dyb3VwZWQtZmhpci1wb2xpY3ktcGF0aWVudC1yNC9faGlzdG9yeS8xIl0sImFnZW50IjpbeyJ0eXBlIjp7ImNvZGluZyI6W3sic3lzdGVtIjoiaHR0cDovL3Rlcm1pbm9sb2d5LmhsNy5vcmcvQ29kZVN5c3RlbS9wcm92ZW5hbmNlLXBhcnRpY2lwYW50LXR5cGUiLCJjb2RlIjoicGVyZm9ybWVyIn1dfSwid2hvIjp7ImlkZW50aWZpZXIiOnsic3lzdGVtIjoiaHR0cHM6Ly9kaXMuZXhhbXBsZS5vcmcvaWRlbnRpZmllcnMvd29ya2VyIiwidmFsdWUiOiJpbnRlZ3JhdGVkLWZpeHR1cmUifX19XSwiZXh0ZW5zaW9uIjpbeyJ1cmwiOiJodHRwczovL3Byb2ZpbGVzLmloZS5uZXQvSVRJL0RJUy9TdHJ1Y3R1cmVEZWZpbml0aW9uL2Rpcy1vdXRjb21lLXN0YXR1cyIsInZhbHVlQ29kZSI6ImNvbXBsZXRlIn0seyJ1cmwiOiJodHRwczovL3Byb2ZpbGVzLmloZS5uZXQvSVRJL0RJUy9TdHJ1Y3R1cmVEZWZpbml0aW9uL2Rpcy1ydWxlc2V0IiwidmFsdWVTdHJpbmciOiJyZW1vdmUtZGlyZWN0LWxpbmsifSx7InVybCI6Imh0dHBzOi8vcHJvZmlsZXMuaWhlLm5ldC9JVEkvRElTL1N0cnVjdHVyZURlZmluaXRpb24vZGlzLXJldmVyc2liaWxpdHkiLCJ2YWx1ZUNvZGUiOiJpcnJldmVyc2libGUifSx7InVybCI6Imh0dHBzOi8vcHJvZmlsZXMuaWhlLm5ldC9JVEkvRElTL1N0cnVjdHVyZURlZmluaXRpb24vZGlzLXZhbGlkYXRpb24tc3RhdHVzIiwidmFsdWVDb2RlIjoidmFsaWQifSx7InVybCI6Imh0dHBzOi8vcHJvZmlsZXMuaWhlLm5ldC9JVEkvRElTL1N0cnVjdHVyZURlZmluaXRpb24vZGlzLWF1ZGl0LWNvcnJlbGF0aW9uIiwidmFsdWVJZGVudGlmaWVyIjp7InN5c3RlbSI6Imh0dHBzOi8vZGlzLmV4YW1wbGUub3JnL2lkZW50aWZpZXJzL2F1ZGl0IiwidmFsdWUiOiJqb2Itc2luZ2xlLXI0LWlubGluZSJ9fV19fV0sIm1ldGEiOnsicHJvZmlsZSI6WyJodHRwczovL3Byb2ZpbGVzLmloZS5uZXQvSVRJL0RJUy9TdHJ1Y3R1cmVEZWZpbml0aW9uL0RJUy1SZXN1bHRQYWNrYWdlIl19LCJpZCI6Im1peGVkLXI0LXJlc3VsdCJ9"
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
