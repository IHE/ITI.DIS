// UC-2 mixed-version job, hosted manifests and result packages, tasks, and results.

// The job and task examples share the exact serialized attachment bytes. Update the encoded package when its corresponding fixture changes.

RuleSet: GroupedR4ResultAttachment(path)
* {path} = "eyJyZXNvdXJjZVR5cGUiOiJCdW5kbGUiLCJpZCI6Imdyb3VwZWQtZmhpci1yNC1ob3N0ZWQtcmVzdWx0IiwibWV0YSI6eyJwcm9maWxlIjpbImh0dHBzOi8vcHJvZmlsZXMuaWhlLm5ldC9JVEkvRElTL1N0cnVjdHVyZURlZmluaXRpb24vRElTLVJlc3VsdFBhY2thZ2UiXX0sInR5cGUiOiJjb2xsZWN0aW9uIiwiZW50cnkiOlt7ImZ1bGxVcmwiOiJ1cm46dXVpZDo2MzYyYjMxYy1hMzQzLTUzNTQtOWNjMy05Njc1Y2JlOTVjODUiLCJyZXNvdXJjZSI6eyJyZXNvdXJjZVR5cGUiOiJMaXN0IiwiaWQiOiJncm91cGVkLWZoaXItcjQtb3V0cHV0IiwibWV0YSI6eyJwcm9maWxlIjpbImh0dHBzOi8vcHJvZmlsZXMuaWhlLm5ldC9JVEkvRElTL1N0cnVjdHVyZURlZmluaXRpb24vRElTLVJlc291cmNlTWFuaWZlc3QiXSwidmVyc2lvbklkIjoiMSJ9LCJzdGF0dXMiOiJjdXJyZW50IiwibW9kZSI6InNuYXBzaG90IiwiZW50cnkiOlt7Iml0ZW0iOnsicmVmZXJlbmNlIjoiaHR0cHM6Ly9yZXN1bHRzLmV4YW1wbGUub3JnL2ZoaXIvcjQvUGF0aWVudC9ncm91cGVkLWZoaXItcGF0aWVudC1vdXRwdXQvX2hpc3RvcnkvMSJ9fSx7Iml0ZW0iOnsicmVmZXJlbmNlIjoiaHR0cHM6Ly9yZXN1bHRzLmV4YW1wbGUub3JnL2ZoaXIvcjQvT2JzZXJ2YXRpb24vZ3JvdXBlZC1maGlyLWhlbW9nbG9iaW4tb3V0cHV0L19oaXN0b3J5LzEifX1dfX0seyJmdWxsVXJsIjoidXJuOnV1aWQ6MDEwZDFmMTMtYTY1Ny01MDdhLTg3ZjEtNmUzMGZjYjZjNmNiIiwicmVzb3VyY2UiOnsicmVzb3VyY2VUeXBlIjoiUHJvdmVuYW5jZSIsImlkIjoiZ3JvdXBlZC1maGlyLWV2aWRlbmNlLXBhdGllbnQtcjQiLCJtZXRhIjp7InByb2ZpbGUiOlsiaHR0cHM6Ly9wcm9maWxlcy5paGUubmV0L0lUSS9ESVMvU3RydWN0dXJlRGVmaW5pdGlvbi9ESVMtRXZpZGVuY2UiXX0sInRhcmdldCI6W3sicmVmZXJlbmNlIjoiaHR0cHM6Ly9yZXN1bHRzLmV4YW1wbGUub3JnL2ZoaXIvcjQvUGF0aWVudC9ncm91cGVkLWZoaXItcGF0aWVudC1vdXRwdXQvX2hpc3RvcnkvMSJ9LHsicmVmZXJlbmNlIjoiaHR0cHM6Ly9yZXN1bHRzLmV4YW1wbGUub3JnL2ZoaXIvcjQvT2JzZXJ2YXRpb24vZ3JvdXBlZC1maGlyLWhlbW9nbG9iaW4tb3V0cHV0L19oaXN0b3J5LzEifV0sInJlY29yZGVkIjoiMjAyNi0xMS0wNlQwMzowMDowMFoiLCJhY3Rpdml0eSI6eyJjb2RpbmciOlt7InN5c3RlbSI6Imh0dHBzOi8vcHJvZmlsZXMuaWhlLm5ldC9JVEkvRElTL0NvZGVTeXN0ZW0vZGlzLWFjdGl2aXR5IiwiY29kZSI6ImRpcy10YXNrIn1dfSwicG9saWN5IjpbImh0dHBzOi8vZ292ZXJuYW5jZS5leGFtcGxlLm9yZy9maGlyL0NvbnRyYWN0L2dyb3VwZWQtZmhpci1wb2xpY3ktcGF0aWVudC1yNC9faGlzdG9yeS8xIl0sImFnZW50IjpbeyJ0eXBlIjp7ImNvZGluZyI6W3sic3lzdGVtIjoiaHR0cDovL3Rlcm1pbm9sb2d5LmhsNy5vcmcvQ29kZVN5c3RlbS9wcm92ZW5hbmNlLXBhcnRpY2lwYW50LXR5cGUiLCJjb2RlIjoicGVyZm9ybWVyIn1dfSwid2hvIjp7ImlkZW50aWZpZXIiOnsic3lzdGVtIjoiaHR0cHM6Ly9kaXMuZXhhbXBsZS5vcmcvaWRlbnRpZmllcnMvd29ya2VyIiwidmFsdWUiOiJleGFtcGxlLXdvcmtlciJ9fX1dLCJleHRlbnNpb24iOlt7InVybCI6Imh0dHBzOi8vcHJvZmlsZXMuaWhlLm5ldC9JVEkvRElTL1N0cnVjdHVyZURlZmluaXRpb24vZGlzLW91dGNvbWUtc3RhdHVzIiwidmFsdWVDb2RlIjoiY29tcGxldGUifSx7InVybCI6Imh0dHBzOi8vcHJvZmlsZXMuaWhlLm5ldC9JVEkvRElTL1N0cnVjdHVyZURlZmluaXRpb24vZGlzLXJ1bGVzZXQiLCJ2YWx1ZVN0cmluZyI6InJlbW92ZS1kaXJlY3QtbGluayJ9LHsidXJsIjoiaHR0cHM6Ly9wcm9maWxlcy5paGUubmV0L0lUSS9ESVMvU3RydWN0dXJlRGVmaW5pdGlvbi9kaXMtcmV2ZXJzaWJpbGl0eSIsInZhbHVlQ29kZSI6ImlycmV2ZXJzaWJsZSJ9LHsidXJsIjoiaHR0cHM6Ly9wcm9maWxlcy5paGUubmV0L0lUSS9ESVMvU3RydWN0dXJlRGVmaW5pdGlvbi9kaXMtdmFsaWRhdGlvbi1zdGF0dXMiLCJ2YWx1ZUNvZGUiOiJ2YWxpZCJ9LHsidXJsIjoiaHR0cHM6Ly9wcm9maWxlcy5paGUubmV0L0lUSS9ESVMvU3RydWN0dXJlRGVmaW5pdGlvbi9kaXMtYXVkaXQtY29ycmVsYXRpb24iLCJ2YWx1ZUlkZW50aWZpZXIiOnsic3lzdGVtIjoiaHR0cHM6Ly9kaXMuZXhhbXBsZS5vcmcvaWRlbnRpZmllcnMvYXVkaXQiLCJ2YWx1ZSI6ImpvYi01MS1wYXRpZW50LXI0In19XX19XX0="

RuleSet: GroupedR5ResultAttachment(path)
* {path} = "eyJyZXNvdXJjZVR5cGUiOiJCdW5kbGUiLCJpZCI6Imdyb3VwZWQtZmhpci1yNS1vdXRwdXQiLCJtZXRhIjp7InByb2ZpbGUiOlsiaHR0cHM6Ly9wcm9maWxlcy5paGUubmV0L0lUSS9ESVMvU3RydWN0dXJlRGVmaW5pdGlvbi9ESVMtUmVzdWx0UGFja2FnZSJdfSwidHlwZSI6ImNvbGxlY3Rpb24iLCJlbnRyeSI6W3siZnVsbFVybCI6InVybjp1dWlkOjBmMWM2OWY0LWIxNTUtNTFmMS05N2QwLTUxN2I0NzcxMWJiMSIsInJlc291cmNlIjp7InJlc291cmNlVHlwZSI6Ikxpc3QiLCJpZCI6Imdyb3VwZWQtZmhpci1yNS1vdXRwdXQtbGlzdCIsIm1ldGEiOnsicHJvZmlsZSI6WyJodHRwczovL3Byb2ZpbGVzLmloZS5uZXQvSVRJL0RJUy9TdHJ1Y3R1cmVEZWZpbml0aW9uL0RJUy1SZXNvdXJjZU1hbmlmZXN0Il19LCJzdGF0dXMiOiJjdXJyZW50IiwibW9kZSI6InNuYXBzaG90IiwiZW50cnkiOlt7Iml0ZW0iOnsicmVmZXJlbmNlIjoiaHR0cHM6Ly9yZXN1bHRzLmV4YW1wbGUub3JnL2ZoaXIvcjUvRGlhZ25vc3RpY1JlcG9ydC9ncm91cGVkLWZoaXItcmVwb3J0LW91dHB1dC9faGlzdG9yeS8xIiwiZXh0ZW5zaW9uIjpbeyJ1cmwiOiJodHRwczovL3Byb2ZpbGVzLmloZS5uZXQvSVRJL0RJUy9TdHJ1Y3R1cmVEZWZpbml0aW9uL2Rpcy10YXJnZXQtZmhpci12ZXJzaW9uIiwidmFsdWVDb2RlIjoiNS4wIn1dfX0seyJpdGVtIjp7InJlZmVyZW5jZSI6Imh0dHBzOi8vcmVzdWx0cy5leGFtcGxlLm9yZy9maGlyL3I1L1BhdGllbnQvZ3JvdXBlZC1maGlyLXJlcG9ydC1wYXRpZW50LW91dHB1dC9faGlzdG9yeS8xIiwiZXh0ZW5zaW9uIjpbeyJ1cmwiOiJodHRwczovL3Byb2ZpbGVzLmloZS5uZXQvSVRJL0RJUy9TdHJ1Y3R1cmVEZWZpbml0aW9uL2Rpcy10YXJnZXQtZmhpci12ZXJzaW9uIiwidmFsdWVDb2RlIjoiNS4wIn1dfX1dfX0seyJmdWxsVXJsIjoidXJuOnV1aWQ6OWJkZmZhYWItM2ExYy01YzI4LTg4NDMtMmY0YzM4OGMzODQyIiwicmVzb3VyY2UiOnsicmVzb3VyY2VUeXBlIjoiUHJvdmVuYW5jZSIsImlkIjoiZ3JvdXBlZC1maGlyLWV2aWRlbmNlLWltYWdpbmctcmVwb3J0LXI1IiwibWV0YSI6eyJwcm9maWxlIjpbImh0dHBzOi8vcHJvZmlsZXMuaWhlLm5ldC9JVEkvRElTL1N0cnVjdHVyZURlZmluaXRpb24vRElTLUV2aWRlbmNlIl19LCJ0YXJnZXQiOlt7InJlZmVyZW5jZSI6Imh0dHBzOi8vcmVzdWx0cy5leGFtcGxlLm9yZy9maGlyL3I1L0RpYWdub3N0aWNSZXBvcnQvZ3JvdXBlZC1maGlyLXJlcG9ydC1vdXRwdXQvX2hpc3RvcnkvMSIsImV4dGVuc2lvbiI6W3sidXJsIjoiaHR0cHM6Ly9wcm9maWxlcy5paGUubmV0L0lUSS9ESVMvU3RydWN0dXJlRGVmaW5pdGlvbi9kaXMtdGFyZ2V0LWZoaXItdmVyc2lvbiIsInZhbHVlQ29kZSI6IjUuMCJ9XX0seyJyZWZlcmVuY2UiOiJodHRwczovL3Jlc3VsdHMuZXhhbXBsZS5vcmcvZmhpci9yNS9QYXRpZW50L2dyb3VwZWQtZmhpci1yZXBvcnQtcGF0aWVudC1vdXRwdXQvX2hpc3RvcnkvMSIsImV4dGVuc2lvbiI6W3sidXJsIjoiaHR0cHM6Ly9wcm9maWxlcy5paGUubmV0L0lUSS9ESVMvU3RydWN0dXJlRGVmaW5pdGlvbi9kaXMtdGFyZ2V0LWZoaXItdmVyc2lvbiIsInZhbHVlQ29kZSI6IjUuMCJ9XX1dLCJyZWNvcmRlZCI6IjIwMjYtMTEtMDZUMDM6MDA6MDBaIiwiYWN0aXZpdHkiOnsiY29kaW5nIjpbeyJzeXN0ZW0iOiJodHRwczovL3Byb2ZpbGVzLmloZS5uZXQvSVRJL0RJUy9Db2RlU3lzdGVtL2Rpcy1hY3Rpdml0eSIsImNvZGUiOiJkaXMtdGFzayJ9XX0sInBvbGljeSI6WyJodHRwczovL2dvdmVybmFuY2UuZXhhbXBsZS5vcmcvZmhpci9Db250cmFjdC9ncm91cGVkLWZoaXItcG9saWN5LWltYWdpbmctcmVwb3J0LXI1L19oaXN0b3J5LzEiXSwiYWdlbnQiOlt7InR5cGUiOnsiY29kaW5nIjpbeyJzeXN0ZW0iOiJodHRwOi8vdGVybWlub2xvZ3kuaGw3Lm9yZy9Db2RlU3lzdGVtL3Byb3ZlbmFuY2UtcGFydGljaXBhbnQtdHlwZSIsImNvZGUiOiJwZXJmb3JtZXIifV19LCJ3aG8iOnsiaWRlbnRpZmllciI6eyJzeXN0ZW0iOiJodHRwczovL2Rpcy5leGFtcGxlLm9yZy9pZGVudGlmaWVycy93b3JrZXIiLCJ2YWx1ZSI6ImV4YW1wbGUtd29ya2VyIn19fV0sImV4dGVuc2lvbiI6W3sidXJsIjoiaHR0cHM6Ly9wcm9maWxlcy5paGUubmV0L0lUSS9ESVMvU3RydWN0dXJlRGVmaW5pdGlvbi9kaXMtb3V0Y29tZS1zdGF0dXMiLCJ2YWx1ZUNvZGUiOiJjb21wbGV0ZSJ9LHsidXJsIjoiaHR0cHM6Ly9wcm9maWxlcy5paGUubmV0L0lUSS9ESVMvU3RydWN0dXJlRGVmaW5pdGlvbi9kaXMtcnVsZXNldCIsInZhbHVlU3RyaW5nIjoicmVtb3ZlLWRpcmVjdC1saW5rIn0seyJ1cmwiOiJodHRwczovL3Byb2ZpbGVzLmloZS5uZXQvSVRJL0RJUy9TdHJ1Y3R1cmVEZWZpbml0aW9uL2Rpcy1yZXZlcnNpYmlsaXR5IiwidmFsdWVDb2RlIjoiaXJyZXZlcnNpYmxlIn0seyJ1cmwiOiJodHRwczovL3Byb2ZpbGVzLmloZS5uZXQvSVRJL0RJUy9TdHJ1Y3R1cmVEZWZpbml0aW9uL2Rpcy12YWxpZGF0aW9uLXN0YXR1cyIsInZhbHVlQ29kZSI6InZhbGlkIn0seyJ1cmwiOiJodHRwczovL3Byb2ZpbGVzLmloZS5uZXQvSVRJL0RJUy9TdHJ1Y3R1cmVEZWZpbml0aW9uL2Rpcy1hdWRpdC1jb3JyZWxhdGlvbiIsInZhbHVlSWRlbnRpZmllciI6eyJzeXN0ZW0iOiJodHRwczovL2Rpcy5leGFtcGxlLm9yZy9pZGVudGlmaWVycy9hdWRpdCIsInZhbHVlIjoiam9iLTUxLWltYWdpbmctcmVwb3J0LXI1In19XX19XX0="

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
* entry[+].fullUrl = "https://governance.example.org/fhir/Contract/grouped-fhir-policy-patient-r4"
* entry[=].resource = grouped-fhir-policy-patient-r4
* entry[+].fullUrl = "https://dis.example.org/fhir/Contract/grouped-fhir-plan-patient-r4"
* entry[=].resource = grouped-fhir-plan-patient-r4
* entry[+].fullUrl = "https://governance.example.org/fhir/Contract/grouped-fhir-policy-imaging-report-r5"
* entry[=].resource = grouped-fhir-policy-imaging-report-r5
* entry[+].fullUrl = "https://dis.example.org/fhir/Contract/grouped-fhir-plan-imaging-report-r5"
* entry[=].resource = grouped-fhir-plan-imaging-report-r5
* entry[+].fullUrl = "https://governance.example.org/fhir/Contract/grouped-fhir-authorization-contract"
* entry[=].resource = grouped-fhir-authorization-contract
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
* input[authorization].valueReference = Reference(https://governance.example.org/fhir/Contract/grouped-fhir-authorization-contract/_history/2)
* input[payloadSet][0].valueAttachment.contentType = #application/fhir+json
* input[payloadSet][0].valueAttachment.url = "https://source.example.org/fhir/r4/List/grouped-fhir-r4-input/_history/1"
* input[payloadSet][0].extension[payloadSet].extension[setId].valueString = "patient-r4"
* input[payloadSet][0].extension[payloadSet].extension[permission].valueUri = "https://governance.example.org/permits/grouped-fhir-permit/versions/2#patient-r4"
* input[payloadSet][0].extension[payloadSet].extension[purpose].valueUri = "https://governance.example.org/purposes/multimodal-research"
* input[payloadSet][0].extension[payloadSet].extension[payloadBinding].valueCode = #DIS-FHIR-Payload
* input[payloadSet][0].extension[payloadSet].extension[payloadVersion].valueCode = #R4
* input[payloadSet][0].extension[payloadSet].extension[manifestFormat].valueCode = #dis-resource-list
* input[payloadSet][0].extension[payloadSet].extension[policy].valueCanonical = "https://governance.example.org/policies/patient-name-removal|1.0"
* input[payloadSet][1].valueAttachment.contentType = #application/fhir+json
* input[payloadSet][1].valueAttachment.url = "https://source.example.org/fhir/r4/List/grouped-fhir-r5-input-list/_history/1"
* input[payloadSet][1].extension[payloadSet].extension[setId].valueString = "imaging-report-r5"
* input[payloadSet][1].extension[payloadSet].extension[permission].valueUri = "https://governance.example.org/permits/grouped-fhir-permit/versions/2#imaging-report-r5"
* input[payloadSet][1].extension[payloadSet].extension[purpose].valueUri = "https://governance.example.org/purposes/multimodal-research"
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
* input[executionPlan].valueReference = Reference(https://dis.example.org/fhir/Contract/grouped-fhir-plan-imaging-report-r5/_history/1)
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
* input[executionPlan].valueReference = Reference(https://dis.example.org/fhir/Contract/grouped-fhir-plan-patient-r4/_history/1)
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
* target[+] = Reference(https://results.example.org/fhir/r5/Patient/grouped-fhir-report-patient-output/_history/1)
* target[=].extension[targetFhirVersion].valueCode = #5.0
* recorded = "2026-11-06T03:00:00Z"
* activity = https://profiles.ihe.net/ITI/DIS/CodeSystem/dis-activity#dis-task
* policy = "https://governance.example.org/fhir/Contract/grouped-fhir-policy-imaging-report-r5/_history/1"
* agent.type = http://terminology.hl7.org/CodeSystem/provenance-participant-type#performer
* agent.who.identifier.system = "https://dis.example.org/identifiers/worker"
* agent.who.identifier.value = "example-worker"
* extension[outcomeStatus].valueCode = #complete
* extension[ruleSet].valueString = "remove-direct-link"
* extension[reversibility].valueCode = #irreversible
* extension[validationStatus].valueCode = #valid
* extension[auditCorrelation].valueIdentifier.system = "https://dis.example.org/identifiers/audit"
* extension[auditCorrelation].valueIdentifier.value = "job-51-imaging-report-r5"

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

Instance: grouped-fhir-plan-imaging-report-r5
InstanceOf: DISExecutionPlan
Usage: #inline
* id = "grouped-fhir-plan-imaging-report-r5"
* meta.versionId = "1"
* url = "https://dis.example.org/fhir/plans/imaging-report-r5"
* version = "1.0"
* name = "GroupedFHIRPlanR5"
* status = #executable
* issued = "2026-11-06T03:00:00Z"
* identifier.value = "https://dis.example.org/fhir/plans/imaging-report-r5/versions/1.0"
* authority.identifier.system = "urn:ietf:rfc:3986"
* authority.identifier.value = "https://dis.example.org/organizations/manager"
* subject.identifier.system = "urn:ietf:rfc:3986"
* subject.identifier.value = "https://worker.example.org/organizations/de-identifier"
* rule.contentAttachment.contentType = #application/ld+json
* rule.contentAttachment.data = "eyJAY29udGV4dCI6Imh0dHBzOi8vcHJvZmlsZXMuaWhlLm5ldC9JVEkvRElTL3NjaGVtYXMvZGlzLWRwdi1vZHJsLWRyYWZ0LTEuanNvbmxkIiwiQHR5cGUiOiJTZXQiLCJ1aWQiOiJodHRwczovL2Rpcy5leGFtcGxlLm9yZy9maGlyL3BsYW5zL2ltYWdpbmctcmVwb3J0LXI1L3ZlcnNpb25zLzEuMCIsInByb2ZpbGUiOiJkaXNkcHY6RXhlY3V0aW9uUGxhbiIsImRpczpydWxlU2V0SWQiOiJyZW1vdmUtZGlyZWN0LWxpbmsiLCJkaXM6cGF5bG9hZEJpbmRpbmciOiJESVMtRkhJUi1QYXlsb2FkIiwiZGlzOnBheWxvYWRWZXJzaW9uIjoiUjUiLCJkaXM6cGF5bG9hZFNldCI6ImltYWdpbmctcmVwb3J0LXI1Iiwib2JsaWdhdGlvbiI6W3sidWlkIjoiaHR0cHM6Ly9kaXMuZXhhbXBsZS5vcmcvZmhpci9wbGFucy9pbWFnaW5nLXJlcG9ydC1yNS92ZXJzaW9ucy8xLjAjcmVtb3ZlLTAxIiwidGFyZ2V0Ijp7IkB0eXBlIjoiQXNzZXRDb2xsZWN0aW9uIiwic291cmNlIjoiaHR0cHM6Ly9zb3VyY2UuZXhhbXBsZS5vcmcvZmhpci9yNC9MaXN0L2dyb3VwZWQtZmhpci1yNS1pbnB1dC1saXN0L19oaXN0b3J5LzEiLCJyZWZpbmVtZW50Ijp7ImxlZnRPcGVyYW5kIjoiZGlzOmZoaXJQYXRoIiwib3BlcmF0b3IiOiJlcSIsInJpZ2h0T3BlcmFuZCI6IkRpYWdub3N0aWNSZXBvcnQud2hlcmUoaWQgPSAnZ3JvdXBlZC1maGlyLXJlcG9ydC1pbnB1dCcpLnN1YmplY3QifX0sImFjdGlvbiI6ImRpczpyZW1vdmUiLCJkaXM6c291cmNlUnVsZSI6eyJAaWQiOiJodHRwczovL2dvdmVybmFuY2UuZXhhbXBsZS5vcmcvcG9saWNpZXMvaW1hZ2luZy1yZXBvcnQtc3ViamVjdC1yZW1vdmFsL3ZlcnNpb25zLzEuMCNyZW1vdmUtMDEifX1dLCJkaXM6cnVsZU9yZGVyIjp7IkBsaXN0IjpbeyJAaWQiOiJodHRwczovL2Rpcy5leGFtcGxlLm9yZy9maGlyL3BsYW5zL2ltYWdpbmctcmVwb3J0LXI1L3ZlcnNpb25zLzEuMCNyZW1vdmUtMDEifV19LCJkaXNkcHY6bWFwcGluZ1JldmlzaW9uIjp7IkBpZCI6Imh0dHBzOi8vcHJvZmlsZXMuaWhlLm5ldC9JVEkvRElTL2JpbmRpbmdzL2Rpcy1maGlyLXI1LWRwdi1tYXBwaW5nLTEuanNvbmxkIn19"
* supportingInfo = Reference(https://governance.example.org/fhir/Contract/grouped-fhir-policy-imaging-report-r5/_history/1)

Instance: grouped-fhir-plan-patient-r4
InstanceOf: DISExecutionPlan
Usage: #inline
* id = "grouped-fhir-plan-patient-r4"
* meta.versionId = "1"
* url = "https://dis.example.org/fhir/plans/patient-r4"
* version = "1.0"
* name = "GroupedFHIRPlanR4"
* status = #executable
* issued = "2026-11-06T03:00:00Z"
* identifier.value = "https://dis.example.org/fhir/plans/patient-r4/versions/1.0"
* authority.identifier.system = "urn:ietf:rfc:3986"
* authority.identifier.value = "https://dis.example.org/organizations/manager"
* subject.identifier.system = "urn:ietf:rfc:3986"
* subject.identifier.value = "https://worker.example.org/organizations/de-identifier"
* rule.contentAttachment.contentType = #application/ld+json
* rule.contentAttachment.data = "eyJAY29udGV4dCI6Imh0dHBzOi8vcHJvZmlsZXMuaWhlLm5ldC9JVEkvRElTL3NjaGVtYXMvZGlzLWRwdi1vZHJsLWRyYWZ0LTEuanNvbmxkIiwiQHR5cGUiOiJTZXQiLCJ1aWQiOiJodHRwczovL2Rpcy5leGFtcGxlLm9yZy9maGlyL3BsYW5zL3BhdGllbnQtcjQvdmVyc2lvbnMvMS4wIiwicHJvZmlsZSI6ImRpc2RwdjpFeGVjdXRpb25QbGFuIiwiZGlzOnJ1bGVTZXRJZCI6InJlbW92ZS1kaXJlY3QtbGluayIsImRpczpwYXlsb2FkQmluZGluZyI6IkRJUy1GSElSLVBheWxvYWQiLCJkaXM6cGF5bG9hZFZlcnNpb24iOiJSNCIsImRpczpwYXlsb2FkU2V0IjoicGF0aWVudC1yNCIsIm9ibGlnYXRpb24iOlt7InVpZCI6Imh0dHBzOi8vZGlzLmV4YW1wbGUub3JnL2ZoaXIvcGxhbnMvcGF0aWVudC1yNC92ZXJzaW9ucy8xLjAjcmVtb3ZlLTAxIiwidGFyZ2V0Ijp7IkB0eXBlIjoiQXNzZXRDb2xsZWN0aW9uIiwic291cmNlIjoiaHR0cHM6Ly9zb3VyY2UuZXhhbXBsZS5vcmcvZmhpci9yNC9MaXN0L2dyb3VwZWQtZmhpci1yNC1pbnB1dC9faGlzdG9yeS8xIiwicmVmaW5lbWVudCI6eyJsZWZ0T3BlcmFuZCI6ImRpczpmaGlyUGF0aCIsIm9wZXJhdG9yIjoiZXEiLCJyaWdodE9wZXJhbmQiOiJQYXRpZW50Lm5hbWUifX0sImFjdGlvbiI6ImRpczpyZW1vdmUiLCJkaXM6c291cmNlUnVsZSI6eyJAaWQiOiJodHRwczovL2dvdmVybmFuY2UuZXhhbXBsZS5vcmcvcG9saWNpZXMvcGF0aWVudC1uYW1lLXJlbW92YWwvdmVyc2lvbnMvMS4wI3JlbW92ZS0wMSJ9fV0sImRpczpydWxlT3JkZXIiOnsiQGxpc3QiOlt7IkBpZCI6Imh0dHBzOi8vZGlzLmV4YW1wbGUub3JnL2ZoaXIvcGxhbnMvcGF0aWVudC1yNC92ZXJzaW9ucy8xLjAjcmVtb3ZlLTAxIn1dfSwiZGlzZHB2Om1hcHBpbmdSZXZpc2lvbiI6eyJAaWQiOiJodHRwczovL3Byb2ZpbGVzLmloZS5uZXQvSVRJL0RJUy9iaW5kaW5ncy9kaXMtZmhpci1yNC1kcHYtbWFwcGluZy0zLmpzb25sZCJ9fQ=="
* supportingInfo = Reference(https://governance.example.org/fhir/Contract/grouped-fhir-policy-patient-r4/_history/1)

Instance: grouped-fhir-policy-imaging-report-r5
InstanceOf: DISPolicy
Usage: #inline
* id = "grouped-fhir-policy-imaging-report-r5"
* meta.versionId = "1"
* url = "https://governance.example.org/policies/imaging-report-subject-removal"
* version = "1.0"
* name = "GroupedFHIRPolicyR5"
* status = #policy
* issued = "2026-11-06T03:00:00Z"
* identifier.value = "https://governance.example.org/policies/imaging-report-subject-removal/versions/1.0"
* rule.contentAttachment.contentType = #application/ld+json
* rule.contentAttachment.data = "eyJAY29udGV4dCI6Imh0dHBzOi8vcHJvZmlsZXMuaWhlLm5ldC9JVEkvRElTL3NjaGVtYXMvZGlzLWRwdi1vZHJsLWRyYWZ0LTEuanNvbmxkIiwiQHR5cGUiOiJTZXQiLCJ1aWQiOiJodHRwczovL2dvdmVybmFuY2UuZXhhbXBsZS5vcmcvcG9saWNpZXMvaW1hZ2luZy1yZXBvcnQtc3ViamVjdC1yZW1vdmFsL3ZlcnNpb25zLzEuMCIsInByb2ZpbGUiOiJkaXNkcHY6UG9saWN5IiwiZGlzOnJldmVyc2liaWxpdHlNb2RlIjoiaXJyZXZlcnNpYmxlIiwib2JsaWdhdGlvbiI6W3sidWlkIjoiaHR0cHM6Ly9nb3Zlcm5hbmNlLmV4YW1wbGUub3JnL3BvbGljaWVzL2ltYWdpbmctcmVwb3J0LXN1YmplY3QtcmVtb3ZhbC92ZXJzaW9ucy8xLjAjcmVtb3ZlLTAxIiwidGFyZ2V0Ijp7IkB0eXBlIjoiQXNzZXRDb2xsZWN0aW9uIiwic291cmNlIjoiZGlzZHB2OnBlcnNvbmFsLWluZm9ybWF0aW9uIiwicmVmaW5lbWVudCI6W3sibGVmdE9wZXJhbmQiOiJkaXNkcHY6Y2F0ZWdvcnkiLCJvcGVyYXRvciI6ImVxIiwicmlnaHRPcGVyYW5kIjp7IkBpZCI6InBkOklkZW50aWZ5aW5nIn19LHsibGVmdE9wZXJhbmQiOiJkaXNkcHY6cGVyc29uUm9sZSIsIm9wZXJhdG9yIjoiZXEiLCJyaWdodE9wZXJhbmQiOnsiQGlkIjoiZGlzZHB2OnBhdGllbnQifX0seyJsZWZ0T3BlcmFuZCI6ImRpc2Rwdjpsb2NhdGlvbiIsIm9wZXJhdG9yIjoiZXEiLCJyaWdodE9wZXJhbmQiOnsiQGlkIjoiZGlzZHB2OnN0cnVjdHVyZWQifX1dfSwiYWN0aW9uIjoiZGlzOnJlbW92ZSJ9XSwiZGlzOnJ1bGVTZXRzIjp7IkBsaXN0IjpbeyJkaXM6cnVsZVNldElkIjoicmVtb3ZlLWRpcmVjdC1saW5rIiwiZGlzOnJ1bGVPcmRlciI6eyJAbGlzdCI6W3siQGlkIjoiaHR0cHM6Ly9nb3Zlcm5hbmNlLmV4YW1wbGUub3JnL3BvbGljaWVzL2ltYWdpbmctcmVwb3J0LXN1YmplY3QtcmVtb3ZhbC92ZXJzaW9ucy8xLjAjcmVtb3ZlLTAxIn1dfX1dfX0="
* authority.identifier.system = "urn:ietf:rfc:3986"
* authority.identifier.value = "https://governance.example.org/organizations/approval-authority"
* applies.start = "2026-01-01"
* applies.end = "2026-12-31"

Instance: grouped-fhir-policy-patient-r4
InstanceOf: DISPolicy
Usage: #inline
* id = "grouped-fhir-policy-patient-r4"
* meta.versionId = "1"
* url = "https://governance.example.org/policies/patient-name-removal"
* version = "1.0"
* name = "GroupedFHIRPolicyR4"
* status = #policy
* issued = "2026-11-06T03:00:00Z"
* identifier.value = "https://governance.example.org/policies/patient-name-removal/versions/1.0"
* rule.contentAttachment.contentType = #application/ld+json
* rule.contentAttachment.data = "eyJAY29udGV4dCI6Imh0dHBzOi8vcHJvZmlsZXMuaWhlLm5ldC9JVEkvRElTL3NjaGVtYXMvZGlzLWRwdi1vZHJsLWRyYWZ0LTEuanNvbmxkIiwiQHR5cGUiOiJTZXQiLCJ1aWQiOiJodHRwczovL2dvdmVybmFuY2UuZXhhbXBsZS5vcmcvcG9saWNpZXMvcGF0aWVudC1uYW1lLXJlbW92YWwvdmVyc2lvbnMvMS4wIiwicHJvZmlsZSI6ImRpc2RwdjpQb2xpY3kiLCJkaXM6cmV2ZXJzaWJpbGl0eU1vZGUiOiJpcnJldmVyc2libGUiLCJvYmxpZ2F0aW9uIjpbeyJ1aWQiOiJodHRwczovL2dvdmVybmFuY2UuZXhhbXBsZS5vcmcvcG9saWNpZXMvcGF0aWVudC1uYW1lLXJlbW92YWwvdmVyc2lvbnMvMS4wI3JlbW92ZS0wMSIsInRhcmdldCI6eyJAdHlwZSI6IkFzc2V0Q29sbGVjdGlvbiIsInNvdXJjZSI6ImRpc2RwdjpwZXJzb25hbC1pbmZvcm1hdGlvbiIsInJlZmluZW1lbnQiOlt7ImxlZnRPcGVyYW5kIjoiZGlzZHB2OmNhdGVnb3J5Iiwib3BlcmF0b3IiOiJlcSIsInJpZ2h0T3BlcmFuZCI6eyJAaWQiOiJwZDpOYW1lIn19LHsibGVmdE9wZXJhbmQiOiJkaXNkcHY6cGVyc29uUm9sZSIsIm9wZXJhdG9yIjoiZXEiLCJyaWdodE9wZXJhbmQiOnsiQGlkIjoiZGlzZHB2OnBhdGllbnQifX0seyJsZWZ0T3BlcmFuZCI6ImRpc2Rwdjpsb2NhdGlvbiIsIm9wZXJhdG9yIjoiZXEiLCJyaWdodE9wZXJhbmQiOnsiQGlkIjoiZGlzZHB2OnN0cnVjdHVyZWQifX1dfSwiYWN0aW9uIjoiZGlzOnJlbW92ZSJ9XSwiZGlzOnJ1bGVTZXRzIjp7IkBsaXN0IjpbeyJkaXM6cnVsZVNldElkIjoicmVtb3ZlLWRpcmVjdC1saW5rIiwiZGlzOnJ1bGVPcmRlciI6eyJAbGlzdCI6W3siQGlkIjoiaHR0cHM6Ly9nb3Zlcm5hbmNlLmV4YW1wbGUub3JnL3BvbGljaWVzL3BhdGllbnQtbmFtZS1yZW1vdmFsL3ZlcnNpb25zLzEuMCNyZW1vdmUtMDEifV19fV19fQ=="
* authority.identifier.system = "urn:ietf:rfc:3986"
* authority.identifier.value = "https://governance.example.org/organizations/approval-authority"
* applies.start = "2026-01-01"
* applies.end = "2026-12-31"

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
* entry[+].item = Reference(https://source.example.org/fhir/r5/Patient/grouped-fhir-report-patient-input/_history/1)
* entry[=].item.extension[targetFhirVersion].valueCode = #5.0

Instance: grouped-fhir-r5-output-list
InstanceOf: DISResourceManifest
Usage: #inline
* id = "grouped-fhir-r5-output-list"
* status = #current
* mode = #snapshot
* entry[0].item = Reference(https://results.example.org/fhir/r5/DiagnosticReport/grouped-fhir-report-output/_history/1)
* entry[0].item.extension[targetFhirVersion].valueCode = #5.0
* entry[+].item = Reference(https://results.example.org/fhir/r5/Patient/grouped-fhir-report-patient-output/_history/1)
* entry[=].item.extension[targetFhirVersion].valueCode = #5.0
