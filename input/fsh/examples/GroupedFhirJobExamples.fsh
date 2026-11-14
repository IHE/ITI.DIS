// UC-2 mixed-version job, hosted manifests and result packages, tasks, and results.

// The job and task examples share the exact serialized attachment bytes. Update the encoded package when its corresponding fixture changes.

RuleSet: GroupedR4ResultAttachment(path)
* {path} = "eyJyZXNvdXJjZVR5cGUiOiJCdW5kbGUiLCJpZCI6Imdyb3VwZWQtZmhpci1yNC1ob3N0ZWQtcmVzdWx0IiwibWV0YSI6eyJwcm9maWxlIjpbImh0dHBzOi8vcHJvZmlsZXMuaWhlLm5ldC9JVEkvRElTL1N0cnVjdHVyZURlZmluaXRpb24vRElTLVJlc3VsdFBhY2thZ2UiXX0sInR5cGUiOiJjb2xsZWN0aW9uIiwiZW50cnkiOlt7ImZ1bGxVcmwiOiJ1cm46dXVpZDo2MzYyYjMxYy1hMzQzLTUzNTQtOWNjMy05Njc1Y2JlOTVjODUiLCJyZXNvdXJjZSI6eyJyZXNvdXJjZVR5cGUiOiJMaXN0IiwiaWQiOiJncm91cGVkLWZoaXItcjQtb3V0cHV0IiwibWV0YSI6eyJwcm9maWxlIjpbImh0dHBzOi8vcHJvZmlsZXMuaWhlLm5ldC9JVEkvRElTL1N0cnVjdHVyZURlZmluaXRpb24vRElTLVJlc291cmNlTWFuaWZlc3QiXSwidmVyc2lvbklkIjoiMSJ9LCJzdGF0dXMiOiJjdXJyZW50IiwibW9kZSI6InNuYXBzaG90IiwiZW50cnkiOlt7Iml0ZW0iOnsicmVmZXJlbmNlIjoiaHR0cHM6Ly9yZXN1bHRzLmV4YW1wbGUub3JnL2ZoaXIvcjQvUGF0aWVudC9ncm91cGVkLWZoaXItcGF0aWVudC1vdXRwdXQvX2hpc3RvcnkvMSJ9fSx7Iml0ZW0iOnsicmVmZXJlbmNlIjoiaHR0cHM6Ly9yZXN1bHRzLmV4YW1wbGUub3JnL2ZoaXIvcjQvT2JzZXJ2YXRpb24vZ3JvdXBlZC1maGlyLWhlbW9nbG9iaW4tb3V0cHV0L19oaXN0b3J5LzEifX1dfX0seyJmdWxsVXJsIjoidXJuOnV1aWQ6MDEwZDFmMTMtYTY1Ny01MDdhLTg3ZjEtNmUzMGZjYjZjNmNiIiwicmVzb3VyY2UiOnsicmVzb3VyY2VUeXBlIjoiUHJvdmVuYW5jZSIsImlkIjoiZ3JvdXBlZC1maGlyLWV2aWRlbmNlLXBhdGllbnQtcjQiLCJtZXRhIjp7InByb2ZpbGUiOlsiaHR0cHM6Ly9wcm9maWxlcy5paGUubmV0L0lUSS9ESVMvU3RydWN0dXJlRGVmaW5pdGlvbi9ESVMtRXZpZGVuY2UiXX0sInRhcmdldCI6W3sicmVmZXJlbmNlIjoiaHR0cHM6Ly9yZXN1bHRzLmV4YW1wbGUub3JnL2ZoaXIvcjQvUGF0aWVudC9ncm91cGVkLWZoaXItcGF0aWVudC1vdXRwdXQvX2hpc3RvcnkvMSJ9LHsicmVmZXJlbmNlIjoiaHR0cHM6Ly9yZXN1bHRzLmV4YW1wbGUub3JnL2ZoaXIvcjQvT2JzZXJ2YXRpb24vZ3JvdXBlZC1maGlyLWhlbW9nbG9iaW4tb3V0cHV0L19oaXN0b3J5LzEifV0sInJlY29yZGVkIjoiMjAyNi0xMS0wNlQwMzowMDowMFoiLCJhY3Rpdml0eSI6eyJjb2RpbmciOlt7InN5c3RlbSI6Imh0dHBzOi8vcHJvZmlsZXMuaWhlLm5ldC9JVEkvRElTL0NvZGVTeXN0ZW0vZGlzLWFjdGl2aXR5IiwiY29kZSI6ImRpcy10YXNrIn1dfSwicG9saWN5IjpbImh0dHBzOi8vZ292ZXJuYW5jZS5leGFtcGxlLm9yZy9maGlyL0xpYnJhcnkvZ3JvdXBlZC1maGlyLXBvbGljeS1wYXRpZW50LXI0L19oaXN0b3J5LzEiXSwiYWdlbnQiOlt7InR5cGUiOnsiY29kaW5nIjpbeyJzeXN0ZW0iOiJodHRwOi8vdGVybWlub2xvZ3kuaGw3Lm9yZy9Db2RlU3lzdGVtL3Byb3ZlbmFuY2UtcGFydGljaXBhbnQtdHlwZSIsImNvZGUiOiJwZXJmb3JtZXIifV19LCJ3aG8iOnsiaWRlbnRpZmllciI6eyJzeXN0ZW0iOiJodHRwczovL2Rpcy5leGFtcGxlLm9yZy9pZGVudGlmaWVycy93b3JrZXIiLCJ2YWx1ZSI6ImV4YW1wbGUtd29ya2VyIn19fV0sImV4dGVuc2lvbiI6W3sidXJsIjoiaHR0cHM6Ly9wcm9maWxlcy5paGUubmV0L0lUSS9ESVMvU3RydWN0dXJlRGVmaW5pdGlvbi9kaXMtb3V0Y29tZS1zdGF0dXMiLCJ2YWx1ZUNvZGUiOiJjb21wbGV0ZSJ9LHsidXJsIjoiaHR0cHM6Ly9wcm9maWxlcy5paGUubmV0L0lUSS9ESVMvU3RydWN0dXJlRGVmaW5pdGlvbi9kaXMtcnVsZXNldCIsInZhbHVlU3RyaW5nIjoicmVtb3ZlLWRpcmVjdC1saW5rIn0seyJ1cmwiOiJodHRwczovL3Byb2ZpbGVzLmloZS5uZXQvSVRJL0RJUy9TdHJ1Y3R1cmVEZWZpbml0aW9uL2Rpcy1yZXZlcnNpYmlsaXR5IiwidmFsdWVDb2RlIjoiaXJyZXZlcnNpYmxlIn0seyJ1cmwiOiJodHRwczovL3Byb2ZpbGVzLmloZS5uZXQvSVRJL0RJUy9TdHJ1Y3R1cmVEZWZpbml0aW9uL2Rpcy12YWxpZGF0aW9uLXN0YXR1cyIsInZhbHVlQ29kZSI6InZhbGlkIn0seyJ1cmwiOiJodHRwczovL3Byb2ZpbGVzLmloZS5uZXQvSVRJL0RJUy9TdHJ1Y3R1cmVEZWZpbml0aW9uL2Rpcy1hdWRpdC1jb3JyZWxhdGlvbiIsInZhbHVlSWRlbnRpZmllciI6eyJzeXN0ZW0iOiJodHRwczovL2Rpcy5leGFtcGxlLm9yZy9pZGVudGlmaWVycy9hdWRpdCIsInZhbHVlIjoiam9iLTUxLXBhdGllbnQtcjQifX1dfX1dfQ=="

RuleSet: GroupedR5ResultAttachment(path)
* {path} = "eyJyZXNvdXJjZVR5cGUiOiJCdW5kbGUiLCJpZCI6Imdyb3VwZWQtZmhpci1yNS1vdXRwdXQiLCJtZXRhIjp7InByb2ZpbGUiOlsiaHR0cHM6Ly9wcm9maWxlcy5paGUubmV0L0lUSS9ESVMvU3RydWN0dXJlRGVmaW5pdGlvbi9ESVMtUmVzdWx0UGFja2FnZSJdfSwidHlwZSI6ImNvbGxlY3Rpb24iLCJlbnRyeSI6W3siZnVsbFVybCI6InVybjp1dWlkOjBmMWM2OWY0LWIxNTUtNTFmMS05N2QwLTUxN2I0NzcxMWJiMSIsInJlc291cmNlIjp7InJlc291cmNlVHlwZSI6Ikxpc3QiLCJpZCI6Imdyb3VwZWQtZmhpci1yNS1vdXRwdXQtbGlzdCIsIm1ldGEiOnsicHJvZmlsZSI6WyJodHRwczovL3Byb2ZpbGVzLmloZS5uZXQvSVRJL0RJUy9TdHJ1Y3R1cmVEZWZpbml0aW9uL0RJUy1SZXNvdXJjZU1hbmlmZXN0Il19LCJzdGF0dXMiOiJjdXJyZW50IiwibW9kZSI6InNuYXBzaG90IiwiZW50cnkiOlt7Iml0ZW0iOnsicmVmZXJlbmNlIjoiaHR0cHM6Ly9yZXN1bHRzLmV4YW1wbGUub3JnL2ZoaXIvcjUvRGlhZ25vc3RpY1JlcG9ydC9ncm91cGVkLWZoaXItcmVwb3J0LW91dHB1dC9faGlzdG9yeS8xIiwiZXh0ZW5zaW9uIjpbeyJ1cmwiOiJodHRwczovL3Byb2ZpbGVzLmloZS5uZXQvSVRJL0RJUy9TdHJ1Y3R1cmVEZWZpbml0aW9uL2Rpcy10YXJnZXQtZmhpci12ZXJzaW9uIiwidmFsdWVDb2RlIjoiNS4wIn1dfX1dfX0seyJmdWxsVXJsIjoidXJuOnV1aWQ6OWJkZmZhYWItM2ExYy01YzI4LTg4NDMtMmY0YzM4OGMzODQyIiwicmVzb3VyY2UiOnsicmVzb3VyY2VUeXBlIjoiUHJvdmVuYW5jZSIsImlkIjoiZ3JvdXBlZC1maGlyLWV2aWRlbmNlLWltYWdpbmctcmVwb3J0LXI1IiwibWV0YSI6eyJwcm9maWxlIjpbImh0dHBzOi8vcHJvZmlsZXMuaWhlLm5ldC9JVEkvRElTL1N0cnVjdHVyZURlZmluaXRpb24vRElTLUV2aWRlbmNlIl19LCJ0YXJnZXQiOlt7InJlZmVyZW5jZSI6Imh0dHBzOi8vcmVzdWx0cy5leGFtcGxlLm9yZy9maGlyL3I1L0RpYWdub3N0aWNSZXBvcnQvZ3JvdXBlZC1maGlyLXJlcG9ydC1vdXRwdXQvX2hpc3RvcnkvMSIsImV4dGVuc2lvbiI6W3sidXJsIjoiaHR0cHM6Ly9wcm9maWxlcy5paGUubmV0L0lUSS9ESVMvU3RydWN0dXJlRGVmaW5pdGlvbi9kaXMtdGFyZ2V0LWZoaXItdmVyc2lvbiIsInZhbHVlQ29kZSI6IjUuMCJ9XX1dLCJyZWNvcmRlZCI6IjIwMjYtMTEtMDZUMDM6MDA6MDBaIiwiYWN0aXZpdHkiOnsiY29kaW5nIjpbeyJzeXN0ZW0iOiJodHRwczovL3Byb2ZpbGVzLmloZS5uZXQvSVRJL0RJUy9Db2RlU3lzdGVtL2Rpcy1hY3Rpdml0eSIsImNvZGUiOiJkaXMtdGFzayJ9XX0sInBvbGljeSI6WyJodHRwczovL2dvdmVybmFuY2UuZXhhbXBsZS5vcmcvZmhpci9MaWJyYXJ5L2dyb3VwZWQtZmhpci1wb2xpY3ktaW1hZ2luZy1yZXBvcnQtcjUvX2hpc3RvcnkvMSJdLCJhZ2VudCI6W3sidHlwZSI6eyJjb2RpbmciOlt7InN5c3RlbSI6Imh0dHA6Ly90ZXJtaW5vbG9neS5obDcub3JnL0NvZGVTeXN0ZW0vcHJvdmVuYW5jZS1wYXJ0aWNpcGFudC10eXBlIiwiY29kZSI6InBlcmZvcm1lciJ9XX0sIndobyI6eyJpZGVudGlmaWVyIjp7InN5c3RlbSI6Imh0dHBzOi8vZGlzLmV4YW1wbGUub3JnL2lkZW50aWZpZXJzL3dvcmtlciIsInZhbHVlIjoiZXhhbXBsZS13b3JrZXIifX19XSwiZXh0ZW5zaW9uIjpbeyJ1cmwiOiJodHRwczovL3Byb2ZpbGVzLmloZS5uZXQvSVRJL0RJUy9TdHJ1Y3R1cmVEZWZpbml0aW9uL2Rpcy1vdXRjb21lLXN0YXR1cyIsInZhbHVlQ29kZSI6ImNvbXBsZXRlIn0seyJ1cmwiOiJodHRwczovL3Byb2ZpbGVzLmloZS5uZXQvSVRJL0RJUy9TdHJ1Y3R1cmVEZWZpbml0aW9uL2Rpcy1ydWxlc2V0IiwidmFsdWVTdHJpbmciOiJyZW1vdmUtZGlyZWN0LWxpbmsifSx7InVybCI6Imh0dHBzOi8vcHJvZmlsZXMuaWhlLm5ldC9JVEkvRElTL1N0cnVjdHVyZURlZmluaXRpb24vZGlzLXJldmVyc2liaWxpdHkiLCJ2YWx1ZUNvZGUiOiJpcnJldmVyc2libGUifSx7InVybCI6Imh0dHBzOi8vcHJvZmlsZXMuaWhlLm5ldC9JVEkvRElTL1N0cnVjdHVyZURlZmluaXRpb24vZGlzLXZhbGlkYXRpb24tc3RhdHVzIiwidmFsdWVDb2RlIjoidmFsaWQifSx7InVybCI6Imh0dHBzOi8vcHJvZmlsZXMuaWhlLm5ldC9JVEkvRElTL1N0cnVjdHVyZURlZmluaXRpb24vZGlzLWF1ZGl0LWNvcnJlbGF0aW9uIiwidmFsdWVJZGVudGlmaWVyIjp7InN5c3RlbSI6Imh0dHBzOi8vZGlzLmV4YW1wbGUub3JnL2lkZW50aWZpZXJzL2F1ZGl0IiwidmFsdWUiOiJqb2ItNTEtaW1hZ2luZy1yZXBvcnQtcjUifX1dfX1dfQ=="

Instance: grouped-fhir-hosted-artifacts
InstanceOf: Bundle
Usage: #example
Description: "Synthetic authorization, policies, plans and hosted R4 resources used in the UC-2 mixed-version exchange."
* type = #collection
* entry[0].fullUrl = "https://source.example.org/fhir/r4/List/grouped-fhir-r4-input"
* entry[=].resource = grouped-fhir-r4-input
* entry[+].fullUrl = "https://source.example.org/fhir/r4/List/grouped-fhir-r5-input-list"
* entry[=].resource = grouped-fhir-r5-input-list
* entry[+].fullUrl = "https://source.example.org/fhir/r4/Patient/grouped-fhir-patient-input"
* entry[=].resource = grouped-fhir-patient-input
* entry[+].fullUrl = "https://results.example.org/fhir/r4/List/grouped-fhir-r4-output"
* entry[=].resource = grouped-fhir-r4-output
* entry[+].fullUrl = "https://results.example.org/fhir/r4/Patient/grouped-fhir-patient-output"
* entry[=].resource = grouped-fhir-patient-output
* entry[+].fullUrl = "https://governance.example.org/fhir/Library/grouped-fhir-policy-patient-r4"
* entry[=].resource = grouped-fhir-policy-patient-r4
* entry[+].fullUrl = "https://dis.example.org/fhir/Library/grouped-fhir-plan-patient-r4"
* entry[=].resource = grouped-fhir-plan-patient-r4
* entry[+].fullUrl = "https://governance.example.org/fhir/Library/grouped-fhir-policy-imaging-report-r5"
* entry[=].resource = grouped-fhir-policy-imaging-report-r5
* entry[+].fullUrl = "https://dis.example.org/fhir/Library/grouped-fhir-plan-imaging-report-r5"
* entry[=].resource = grouped-fhir-plan-imaging-report-r5
* entry[+].fullUrl = "https://governance.example.org/fhir/DocumentReference/grouped-fhir-permit"
* entry[=].resource = grouped-fhir-permit
* entry[+].fullUrl = "https://source.example.org/fhir/r4/Observation/grouped-fhir-hemoglobin-input"
* entry[=].resource = grouped-fhir-hemoglobin-input
* entry[+].fullUrl = "https://results.example.org/fhir/r4/Observation/grouped-fhir-hemoglobin-output"
* entry[=].resource = grouped-fhir-hemoglobin-output

Instance: grouped-fhir-job-failure
InstanceOf: OperationOutcome
Usage: #example
Description: "Terminal failure returned by the Manager when a required UC-2 payload set cannot be processed."
* issue.severity = #error
* issue.code = #not-found
* issue.diagnostics = "A required hosted resource became unavailable after job acceptance."

Instance: grouped-fhir-job-request
InstanceOf: DISDeIdentificationJob
Usage: #example
Description: "UC-2 job submission with one R4 clinical set and one R5 diagnostic report set."
* identifier.system = "https://requester.example.org/dis/job-identifiers"
* identifier.value = "grouped-fhir-job-request"
* status = #requested
* intent = #order
* code = https://profiles.ihe.net/ITI/DIS/CodeSystem/dis-work-order-type#de-identification-job
* input[authorization].valueReference = Reference(https://governance.example.org/fhir/DocumentReference/grouped-fhir-permit/_history/1)
* input[payloadSet][0].valueAttachment.contentType = #application/fhir+json
* input[payloadSet][0].valueAttachment.url = "https://source.example.org/fhir/r4/List/grouped-fhir-r4-input/_history/1"
* input[payloadSet][0].extension[payloadSet].extension[setId].valueString = "patient-r4"
* input[payloadSet][0].extension[payloadSet].extension[payloadBinding].valueCode = #DIS-FHIR-Payload
* input[payloadSet][0].extension[payloadSet].extension[payloadVersion].valueCode = #R4
* input[payloadSet][0].extension[payloadSet].extension[manifestFormat].valueCode = #dis-resource-list
* input[payloadSet][0].extension[payloadSet].extension[policy].valueCanonical = "https://governance.example.org/policies/patient-name-removal|1.0"
* input[payloadSet][1].valueAttachment.contentType = #application/fhir+json
* input[payloadSet][1].valueAttachment.url = "https://source.example.org/fhir/r4/List/grouped-fhir-r5-input-list/_history/1"
* input[payloadSet][1].extension[payloadSet].extension[setId].valueString = "imaging-report-r5"
* input[payloadSet][1].extension[payloadSet].extension[payloadBinding].valueCode = #DIS-FHIR-Payload
* input[payloadSet][1].extension[payloadSet].extension[payloadVersion].valueCode = #R5
* input[payloadSet][1].extension[payloadSet].extension[manifestFormat].valueCode = #dis-resource-list
* input[payloadSet][1].extension[payloadSet].extension[policy].valueCanonical = "https://governance.example.org/policies/imaging-report-subject-removal|1.0"

Instance: grouped-fhir-job-result
InstanceOf: Parameters
Usage: #example
Description: "Completed UC-2 job response carrying the R4 clinical and R5 diagnostic report results."
* parameter[0].name = "payloadResult"
* parameter[=].part[0].name = "setId"
* parameter[=].part[=].valueString = "patient-r4"
* parameter[=].part[+].name = "payloadBinding"
* parameter[=].part[=].valueCode = #DIS-FHIR-Payload
* parameter[=].part[+].name = "payloadVersion"
* parameter[=].part[=].valueCode = #R4
* parameter[=].part[+].name = "manifestFormat"
* parameter[=].part[=].valueCode = #dis-resource-list
* parameter[=].part[+].name = "resultPackage"
* parameter[=].part[=].valueAttachment.contentType = #application/fhir+json
* insert GroupedR4ResultAttachment(parameter[=].part[=].valueAttachment.data)
* parameter[+].name = "payloadResult"
* parameter[=].part[0].name = "setId"
* parameter[=].part[=].valueString = "imaging-report-r5"
* parameter[=].part[+].name = "payloadBinding"
* parameter[=].part[=].valueCode = #DIS-FHIR-Payload
* parameter[=].part[+].name = "payloadVersion"
* parameter[=].part[=].valueCode = #R5
* parameter[=].part[+].name = "manifestFormat"
* parameter[=].part[=].valueCode = #dis-resource-list
* parameter[=].part[+].name = "resultPackage"
* parameter[=].part[=].valueAttachment.contentType = #application/fhir+json
* insert GroupedR5ResultAttachment(parameter[=].part[=].valueAttachment.data)
* parameter[+].name = "validationStatus"
* parameter[=].valueCode = #valid

Instance: grouped-fhir-r4-hosted-result
InstanceOf: DISResultPackage
Usage: #example
* type = #collection
* entry[0].fullUrl = "urn:uuid:6362b31c-a343-5354-9cc3-9675cbe95c85"
* entry[=].resource = grouped-fhir-r4-output
* entry[+].fullUrl = "urn:uuid:010d1f13-a657-507a-87f1-6e30fcb6c6cb"
* entry[=].resource = grouped-fhir-evidence-patient-r4

Instance: grouped-fhir-r5-output
InstanceOf: DISResultPackage
Usage: #example
Description: "R4 result package selecting a hosted R5 DiagnosticReport and carrying matching Provenance."
* type = #collection
* entry[0].fullUrl = "urn:uuid:0f1c69f4-b155-51f1-97d0-517b47711bb1"
* entry[=].resource = grouped-fhir-r5-output-list
* entry[+].fullUrl = "urn:uuid:9bdffaab-3a1c-5c28-8843-2f4c388c3842"
* entry[=].resource = grouped-fhir-evidence-imaging-report-r5

Instance: grouped-fhir-task-imaging-report-r5
InstanceOf: DISDeIdentificationTask
Usage: #example
Description: "UC-2 task submission for the R5 diagnostic report set."
* identifier.system = "https://dis.example.org/dis/assignment-identifiers"
* identifier.value = "grouped-fhir-task-imaging-report-r5"
* status = #requested
* intent = #order
* code = https://profiles.ihe.net/ITI/DIS/CodeSystem/dis-work-order-type#de-identification-execution
* input[payloadSet].valueAttachment.contentType = #application/fhir+json
* input[payloadSet].valueAttachment.url = "https://source.example.org/fhir/r4/List/grouped-fhir-r5-input-list/_history/1"
* input[payloadSet].extension[payloadSet].extension[setId].valueString = "imaging-report-r5"
* input[payloadSet].extension[payloadSet].extension[payloadBinding].valueCode = #DIS-FHIR-Payload
* input[payloadSet].extension[payloadSet].extension[payloadVersion].valueCode = #R5
* input[payloadSet].extension[payloadSet].extension[manifestFormat].valueCode = #dis-resource-list
* input[executionPlan].valueReference = Reference(https://dis.example.org/fhir/Library/grouped-fhir-plan-imaging-report-r5/_history/1)
* input[ruleSetId].valueString = "remove-direct-link"
* input[reversibilityMode].valueCode = #irreversible

Instance: grouped-fhir-task-patient-r4
InstanceOf: DISDeIdentificationTask
Usage: #example
Description: "UC-2 task submission for the R4 Patient and hemoglobin Observation."
* identifier.system = "https://dis.example.org/dis/assignment-identifiers"
* identifier.value = "grouped-fhir-task-patient-r4"
* status = #requested
* partOf.identifier.system = "https://dis.example.org/identifiers/job-alias"
* partOf.identifier.value = "f6aa6d7a-c412-4739-9e6d-d279d9e58ad1"
* intent = #order
* code = https://profiles.ihe.net/ITI/DIS/CodeSystem/dis-work-order-type#de-identification-execution
* input[payloadSet].valueAttachment.contentType = #application/fhir+json
* input[payloadSet].valueAttachment.url = "https://source.example.org/fhir/r4/List/grouped-fhir-r4-input/_history/1"
* input[payloadSet].extension[payloadSet].extension[setId].valueString = "patient-r4"
* input[payloadSet].extension[payloadSet].extension[payloadBinding].valueCode = #DIS-FHIR-Payload
* input[payloadSet].extension[payloadSet].extension[payloadVersion].valueCode = #R4
* input[payloadSet].extension[payloadSet].extension[manifestFormat].valueCode = #dis-resource-list
* input[executionPlan].valueReference = Reference(https://dis.example.org/fhir/Library/grouped-fhir-plan-patient-r4/_history/1)
* input[ruleSetId].valueString = "remove-direct-link"
* input[reversibilityMode].valueCode = #irreversible

Instance: grouped-fhir-task-result-imaging-report-r5
InstanceOf: Parameters
Usage: #example
Description: "Successful synchronous task result for the UC-2 R5 diagnostic report set."
* parameter[0].name = "payloadResult"
* parameter[=].part[0].name = "setId"
* parameter[=].part[=].valueString = "imaging-report-r5"
* parameter[=].part[+].name = "payloadBinding"
* parameter[=].part[=].valueCode = #DIS-FHIR-Payload
* parameter[=].part[+].name = "payloadVersion"
* parameter[=].part[=].valueCode = #R5
* parameter[=].part[+].name = "manifestFormat"
* parameter[=].part[=].valueCode = #dis-resource-list
* parameter[=].part[+].name = "resultPackage"
* parameter[=].part[=].valueAttachment.contentType = #application/fhir+json
* insert GroupedR5ResultAttachment(parameter[=].part[=].valueAttachment.data)
* parameter[+].name = "validationStatus"
* parameter[=].valueCode = #valid

Instance: grouped-fhir-task-result-patient-r4
InstanceOf: Parameters
Usage: #example
Description: "Successful synchronous task result for the UC-2 R4 clinical set."
* parameter[0].name = "payloadResult"
* parameter[=].part[0].name = "setId"
* parameter[=].part[=].valueString = "patient-r4"
* parameter[=].part[+].name = "payloadBinding"
* parameter[=].part[=].valueCode = #DIS-FHIR-Payload
* parameter[=].part[+].name = "payloadVersion"
* parameter[=].part[=].valueCode = #R4
* parameter[=].part[+].name = "manifestFormat"
* parameter[=].part[=].valueCode = #dis-resource-list
* parameter[=].part[+].name = "resultPackage"
* parameter[=].part[=].valueAttachment.contentType = #application/fhir+json
* insert GroupedR4ResultAttachment(parameter[=].part[=].valueAttachment.data)
* parameter[+].name = "validationStatus"
* parameter[=].valueCode = #valid

Instance: grouped-fhir-evidence-imaging-report-r5
InstanceOf: DISEvidence
Usage: #inline
* id = "grouped-fhir-evidence-imaging-report-r5"
* target[0] = Reference(https://results.example.org/fhir/r5/DiagnosticReport/grouped-fhir-report-output/_history/1)
* target[0].extension[targetFhirVersion].valueCode = #5.0
* recorded = "2026-11-06T03:00:00Z"
* activity = https://profiles.ihe.net/ITI/DIS/CodeSystem/dis-activity#dis-task
* policy = "https://governance.example.org/fhir/Library/grouped-fhir-policy-imaging-report-r5/_history/1"
* agent.type = http://terminology.hl7.org/CodeSystem/provenance-participant-type#performer
* agent.who.identifier.system = "https://dis.example.org/identifiers/worker"
* agent.who.identifier.value = "example-worker"
* extension[outcomeStatus].valueCode = #complete
* extension[ruleSet].valueString = "remove-direct-link"
* extension[reversibility].valueCode = #irreversible
* extension[validationStatus].valueCode = #valid
* extension[auditCorrelation].valueIdentifier.system = "https://dis.example.org/identifiers/audit"
* extension[auditCorrelation].valueIdentifier.value = "job-51-imaging-report-r5"

Instance: grouped-fhir-evidence-patient-r4
InstanceOf: DISEvidence
Usage: #inline
* id = "grouped-fhir-evidence-patient-r4"
* target[0] = Reference(https://results.example.org/fhir/r4/Patient/grouped-fhir-patient-output/_history/1)
* target[+] = Reference(https://results.example.org/fhir/r4/Observation/grouped-fhir-hemoglobin-output/_history/1)
* recorded = "2026-11-06T03:00:00Z"
* activity = https://profiles.ihe.net/ITI/DIS/CodeSystem/dis-activity#dis-task
* policy = "https://governance.example.org/fhir/Library/grouped-fhir-policy-patient-r4/_history/1"
* agent.type = http://terminology.hl7.org/CodeSystem/provenance-participant-type#performer
* agent.who.identifier.system = "https://dis.example.org/identifiers/worker"
* agent.who.identifier.value = "example-worker"
* extension[outcomeStatus].valueCode = #complete
* extension[ruleSet].valueString = "remove-direct-link"
* extension[reversibility].valueCode = #irreversible
* extension[validationStatus].valueCode = #valid
* extension[auditCorrelation].valueIdentifier.system = "https://dis.example.org/identifiers/audit"
* extension[auditCorrelation].valueIdentifier.value = "job-51-patient-r4"

Instance: grouped-fhir-hemoglobin-input
InstanceOf: Observation
Usage: #inline
* id = "grouped-fhir-hemoglobin-input"
* meta.versionId = "1"
* status = #final
* category = http://terminology.hl7.org/CodeSystem/observation-category#laboratory
* code = http://loinc.org#718-7
* code.text = "Hemoglobin"
* subject = Reference(https://source.example.org/fhir/r4/Patient/grouped-fhir-patient-input/_history/1)
* effectiveDateTime = "2026-10-01T09:00:00Z"
* performer.type = "Organization"
* performer.display = "Synthetic clinical laboratory"
* valueQuantity = 12.4 'g/dL' "g/dL"

Instance: grouped-fhir-hemoglobin-output
InstanceOf: Observation
Usage: #inline
* id = "grouped-fhir-hemoglobin-output"
* meta.versionId = "1"
* status = #final
* category = http://terminology.hl7.org/CodeSystem/observation-category#laboratory
* code = http://loinc.org#718-7
* code.text = "Hemoglobin"
* subject = Reference(https://results.example.org/fhir/r4/Patient/grouped-fhir-patient-output/_history/1)
* effectiveDateTime = "2026-10-01T09:00:00Z"
* performer.type = "Organization"
* performer.display = "Synthetic clinical laboratory"
* valueQuantity = 12.4 'g/dL' "g/dL"

Instance: grouped-fhir-patient-input
InstanceOf: Patient
Usage: #inline
* id = "grouped-fhir-patient-input"
* meta.versionId = "1"
* active = true
* name.family = "Example"

Instance: grouped-fhir-patient-output
InstanceOf: Patient
Usage: #inline
* id = "grouped-fhir-patient-output"
* meta.versionId = "1"
* active = true

Instance: grouped-fhir-permit
InstanceOf: DocumentReference
Usage: #inline
* id = "grouped-fhir-permit"
* meta.versionId = "1"
* status = #current
* content.attachment.contentType = #application/json
* content.attachment.data = "eyJleGFtcGxlT25seSI6dHJ1ZSwicmVxdWVzdGVyIjoiZXhhbXBsZS1yZXF1ZXN0ZXIiLCJwdXJwb3NlIjoiSWxsdXN0cmF0ZSBwcmVwYXJhdGlvbiBvZiBpbmRlcGVuZGVudCBGSElSIGlucHV0cyBmb3IgbXVsdGltb2RhbCBBSS9NTCIsInBheWxvYWRzIjpbeyJzZXRJZCI6InBhdGllbnQtcjQiLCJzb3VyY2UiOiJodHRwczovL3NvdXJjZS5leGFtcGxlLm9yZy9maGlyL3I0L0xpc3QvZ3JvdXBlZC1maGlyLXI0LWlucHV0L19oaXN0b3J5LzEiLCJwb2xpY3kiOiJodHRwczovL2dvdmVybmFuY2UuZXhhbXBsZS5vcmcvcG9saWNpZXMvcGF0aWVudC1uYW1lLXJlbW92YWwiLCJwb2xpY3lWZXJzaW9uIjoiMS4wIn0seyJzZXRJZCI6ImltYWdpbmctcmVwb3J0LXI1Iiwic291cmNlIjoiaHR0cHM6Ly9zb3VyY2UuZXhhbXBsZS5vcmcvZmhpci9yNS9EaWFnbm9zdGljUmVwb3J0L2dyb3VwZWQtZmhpci1yZXBvcnQtaW5wdXQvX2hpc3RvcnkvMSIsInBvbGljeSI6Imh0dHBzOi8vZ292ZXJuYW5jZS5leGFtcGxlLm9yZy9wb2xpY2llcy9pbWFnaW5nLXJlcG9ydC1zdWJqZWN0LXJlbW92YWwiLCJwb2xpY3lWZXJzaW9uIjoiMS4wIn1dLCJwYXJlbnRKb2JBbGlhc0Rpc2Nsb3N1cmUiOnsic2V0SWQiOiJwYXRpZW50LXI0IiwicmVjaXBpZW50Ijp7InN5c3RlbSI6Imh0dHBzOi8vZGlzLmV4YW1wbGUub3JnL2lkZW50aWZpZXJzL3dvcmtlciIsInZhbHVlIjoiZXhhbXBsZS13b3JrZXIifX19"

Instance: grouped-fhir-plan-imaging-report-r5
InstanceOf: DISExecutionPlan
Usage: #inline
* id = "grouped-fhir-plan-imaging-report-r5"
* meta.versionId = "1"
* url = "https://dis.example.org/fhir/plans/imaging-report-r5"
* version = "1.0"
* name = "GroupedFHIRPlanR5"
* status = #active
* type = https://profiles.ihe.net/ITI/DIS/CodeSystem/dis-library-type#dis-execution-plan "Execution plan (payload-specific compiled rules)"
* date = "2026-11-06T03:00:00Z"
* content.contentType = #application/vnd.ihe.dis.execution-plan+json
* content.data = "eyJwbGFuVmVyc2lvbiI6IjEuMCIsInJ1bGVTZXRJZCI6InJlbW92ZS1kaXJlY3QtbGluayIsInBheWxvYWRCaW5kaW5nIjoiRElTLUZISVItUGF5bG9hZCIsInBheWxvYWRWZXJzaW9uIjoiUjUiLCJydWxlcyI6W3sicnVsZUlkIjoicmVtb3ZlLTAxIiwidGFyZ2V0IjoiRGlhZ25vc3RpY1JlcG9ydC5zdWJqZWN0IiwiYWN0aW9uIjoicmVtb3ZlIiwic291cmNlUnVsZUlkIjoicmVtb3ZlLTAxIn1dfQ=="
* relatedArtifact[sourcePolicy].resource = "https://governance.example.org/policies/imaging-report-subject-removal|1.0"
* relatedArtifact[sourcePolicy].extension[evidenceUri].valueUri = "https://governance.example.org/fhir/Library/grouped-fhir-policy-imaging-report-r5/_history/1"

Instance: grouped-fhir-plan-patient-r4
InstanceOf: DISExecutionPlan
Usage: #inline
* id = "grouped-fhir-plan-patient-r4"
* meta.versionId = "1"
* url = "https://dis.example.org/fhir/plans/patient-r4"
* version = "1.0"
* name = "GroupedFHIRPlanR4"
* status = #active
* type = https://profiles.ihe.net/ITI/DIS/CodeSystem/dis-library-type#dis-execution-plan "Execution plan (payload-specific compiled rules)"
* date = "2026-11-06T03:00:00Z"
* content.contentType = #application/vnd.ihe.dis.execution-plan+json
* content.data = "eyJwbGFuVmVyc2lvbiI6IjEuMCIsInJ1bGVTZXRJZCI6InJlbW92ZS1kaXJlY3QtbGluayIsInBheWxvYWRCaW5kaW5nIjoiRElTLUZISVItUGF5bG9hZCIsInBheWxvYWRWZXJzaW9uIjoiUjQiLCJydWxlcyI6W3sicnVsZUlkIjoicmVtb3ZlLTAxIiwidGFyZ2V0IjoiUGF0aWVudC5uYW1lIiwiYWN0aW9uIjoicmVtb3ZlIiwic291cmNlUnVsZUlkIjoicmVtb3ZlLTAxIn1dfQ=="
* relatedArtifact[sourcePolicy].resource = "https://governance.example.org/policies/patient-name-removal|1.0"
* relatedArtifact[sourcePolicy].extension[evidenceUri].valueUri = "https://governance.example.org/fhir/Library/grouped-fhir-policy-patient-r4/_history/1"

Instance: grouped-fhir-policy-imaging-report-r5
InstanceOf: DISPolicy
Usage: #inline
* id = "grouped-fhir-policy-imaging-report-r5"
* meta.versionId = "1"
* url = "https://governance.example.org/policies/imaging-report-subject-removal"
* version = "1.0"
* name = "GroupedFHIRPolicyR5"
* status = #active
* type = https://profiles.ihe.net/ITI/DIS/CodeSystem/dis-library-type#dis-policy "De-identification policy (Semantic-Level or Syntax-Level rules)"
* date = "2026-11-06T03:00:00Z"
* content.contentType = #application/vnd.ihe.dis.policy+json
* content.data = "eyJwb2xpY3lWZXJzaW9uIjoiMS4wIiwicmVwcmVzZW50YXRpb25MZXZlbCI6InN5bnRheCIsInJldmVyc2liaWxpdHlNb2RlIjoiaXJyZXZlcnNpYmxlIiwicGF5bG9hZEZhbWlseSI6ImZoaXIiLCJwYXlsb2FkVmVyc2lvbiI6IlI1IiwicnVsZVNldHMiOlt7InJ1bGVTZXRJZCI6InJlbW92ZS1kaXJlY3QtbGluayIsInJ1bGVzIjpbeyJydWxlSWQiOiJyZW1vdmUtMDEiLCJ0YXJnZXQiOiJEaWFnbm9zdGljUmVwb3J0LnN1YmplY3QiLCJhY3Rpb24iOiJyZW1vdmUifV19XX0="
* identifier.system = "https://governance.example.org/identifiers/policy"
* identifier.value = "grouped-fhir-policy-imaging-report-r5"
* publisher = "Example governance authority"
* effectivePeriod.start = "2026-01-01"
* effectivePeriod.end = "2026-12-31"

Instance: grouped-fhir-policy-patient-r4
InstanceOf: DISPolicy
Usage: #inline
* id = "grouped-fhir-policy-patient-r4"
* meta.versionId = "1"
* url = "https://governance.example.org/policies/patient-name-removal"
* version = "1.0"
* name = "GroupedFHIRPolicyR4"
* status = #active
* type = https://profiles.ihe.net/ITI/DIS/CodeSystem/dis-library-type#dis-policy "De-identification policy (Semantic-Level or Syntax-Level rules)"
* date = "2026-11-06T03:00:00Z"
* content.contentType = #application/vnd.ihe.dis.policy+json
* content.data = "eyJwb2xpY3lWZXJzaW9uIjoiMS4wIiwicmVwcmVzZW50YXRpb25MZXZlbCI6InN5bnRheCIsInJldmVyc2liaWxpdHlNb2RlIjoiaXJyZXZlcnNpYmxlIiwicGF5bG9hZEZhbWlseSI6ImZoaXIiLCJwYXlsb2FkVmVyc2lvbiI6IlI0IiwicnVsZVNldHMiOlt7InJ1bGVTZXRJZCI6InJlbW92ZS1kaXJlY3QtbGluayIsInJ1bGVzIjpbeyJydWxlSWQiOiJyZW1vdmUtMDEiLCJ0YXJnZXQiOiJQYXRpZW50Lm5hbWUiLCJhY3Rpb24iOiJyZW1vdmUifV19XX0="
* identifier.system = "https://governance.example.org/identifiers/policy"
* identifier.value = "grouped-fhir-policy-patient-r4"
* publisher = "Example governance authority"
* effectivePeriod.start = "2026-01-01"
* effectivePeriod.end = "2026-12-31"

Instance: grouped-fhir-r4-input
InstanceOf: DISResourceManifest
Usage: #inline
* id = "grouped-fhir-r4-input"
* meta.versionId = "1"
* status = #current
* mode = #snapshot
* entry[0].item = Reference(https://source.example.org/fhir/r4/Patient/grouped-fhir-patient-input/_history/1)
* entry[+].item = Reference(https://source.example.org/fhir/r4/Observation/grouped-fhir-hemoglobin-input/_history/1)

Instance: grouped-fhir-r4-output
InstanceOf: DISResourceManifest
Usage: #inline
* id = "grouped-fhir-r4-output"
* meta.versionId = "1"
* status = #current
* mode = #snapshot
* entry[0].item = Reference(https://results.example.org/fhir/r4/Patient/grouped-fhir-patient-output/_history/1)
* entry[+].item = Reference(https://results.example.org/fhir/r4/Observation/grouped-fhir-hemoglobin-output/_history/1)

Instance: grouped-fhir-r5-input-list
InstanceOf: DISResourceManifest
Usage: #inline
* id = "grouped-fhir-r5-input-list"
* meta.versionId = "1"
* status = #current
* mode = #snapshot
* entry[0].item = Reference(https://source.example.org/fhir/r5/DiagnosticReport/grouped-fhir-report-input/_history/1)
* entry[0].item.extension[targetFhirVersion].valueCode = #5.0

Instance: grouped-fhir-r5-output-list
InstanceOf: DISResourceManifest
Usage: #inline
* id = "grouped-fhir-r5-output-list"
* status = #current
* mode = #snapshot
* entry[0].item = Reference(https://results.example.org/fhir/r5/DiagnosticReport/grouped-fhir-report-output/_history/1)
* entry[0].item.extension[targetFhirVersion].valueCode = #5.0
