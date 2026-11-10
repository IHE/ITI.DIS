// UC-1 Bulk FHIR cohort submission, policy, and staged result.

Instance: bulk-r4-result-of-Bundle
InstanceOf: DISResultPackage
Usage: #example
* id = "bulk-r4-result"
* type = #collection
* entry[0].fullUrl = "urn:uuid:b75fb8e1-47e9-593d-a3e0-83797715a3c7"
* entry[=].resource = bulk-manifest
* entry[+].fullUrl = "urn:uuid:f08e76ae-88a8-554a-9b3a-123c8dc56154"
* entry[=].resource = bulk-file-1
* entry[+].fullUrl = "urn:uuid:5cfceb42-65e1-5687-b7a7-8553eb2928e7"
* entry[=].resource = bulk-file-2
* entry[+].fullUrl = "urn:uuid:28f187b9-cb5c-5677-82ae-e405d318184d"
* entry[=].resource = bulk-evidence
* entry[+].fullUrl = "urn:uuid:887f26cc-3962-51c5-81bd-c7bb6c0b5aca"
* entry[=].resource = bulk-release-evidence

Instance: bulk-r4-result-of-Parameters
InstanceOf: Parameters
Usage: #example
* id = "bulk-r4-result"
* parameter[0].name = "payloadResult"
* parameter[=].part[0].name = "setId"
* parameter[=].part[=].valueString = "cohort-r4"
* parameter[=].part[+].name = "payloadBinding"
* parameter[=].part[=].valueCode = #DIS-FHIR-Payload
* parameter[=].part[+].name = "payloadVersion"
* parameter[=].part[=].valueCode = #R4
* parameter[=].part[+].name = "manifestFormat"
* parameter[=].part[=].valueCode = #fhir-bulk-data
* parameter[=].part[+].name = "resultPackage"
* parameter[=].part[=].valueAttachment.contentType = #application/fhir+json
* parameter[=].part[=].valueAttachment.data = "eyJyZXNvdXJjZVR5cGUiOiJCdW5kbGUiLCJ0eXBlIjoiY29sbGVjdGlvbiIsImVudHJ5IjpbeyJmdWxsVXJsIjoidXJuOnV1aWQ6Yjc1ZmI4ZTEtNDdlOS01OTNkLWEzZTAtODM3OTc3MTVhM2M3IiwicmVzb3VyY2UiOnsicmVzb3VyY2VUeXBlIjoiRG9jdW1lbnRSZWZlcmVuY2UiLCJpZCI6ImJ1bGstbWFuaWZlc3QiLCJzdGF0dXMiOiJjdXJyZW50IiwiY29udGVudCI6W3siYXR0YWNobWVudCI6eyJjb250ZW50VHlwZSI6ImFwcGxpY2F0aW9uL2pzb24iLCJkYXRhIjoiZXdvZ0lDSnlaWEYxYVhKbGMwRmpZMlZ6YzFSdmEyVnVJam9nZEhKMVpTd0tJQ0FpYjNWMGNIVjBJam9nV3dvZ0lDQWdld29nSUNBZ0lDQWlkSGx3WlNJNklDSlFZWFJwWlc1MElpd0tJQ0FnSUNBZ0luVnliQ0k2SUNKb2RIUndjem92TDNKbGMzVnNkSE11WlhoaGJYQnNaUzV2Y21jdlluVnNheTl2ZFhSd2RYUXRjR0YwYVdWdWRITXRNUzV1WkdwemIyNGlDaUFnSUNCOUxBb2dJQ0FnZXdvZ0lDQWdJQ0FpZEhsd1pTSTZJQ0pRWVhScFpXNTBJaXdLSUNBZ0lDQWdJblZ5YkNJNklDSm9kSFJ3Y3pvdkwzSmxjM1ZzZEhNdVpYaGhiWEJzWlM1dmNtY3ZZblZzYXk5dmRYUndkWFF0Y0dGMGFXVnVkSE10TWk1dVpHcHpiMjRpQ2lBZ0lDQjlDaUFnWFFwOUNnPT0ifX1dLCJtZXRhIjp7InByb2ZpbGUiOlsiaHR0cHM6Ly9wcm9maWxlcy5paGUubmV0L0lUSS9ESVMvU3RydWN0dXJlRGVmaW5pdGlvbi9ESVMtQnVsa1Jlc3VsdE1hbmlmZXN0Il19fX0seyJmdWxsVXJsIjoidXJuOnV1aWQ6ZjA4ZTc2YWUtODhhOC01NTRhLTliM2EtMTIzYzhkYzU2MTU0IiwicmVzb3VyY2UiOnsicmVzb3VyY2VUeXBlIjoiRG9jdW1lbnRSZWZlcmVuY2UiLCJpZCI6ImJ1bGstZmlsZS0xIiwic3RhdHVzIjoiY3VycmVudCIsImNvbnRlbnQiOlt7ImF0dGFjaG1lbnQiOnsiY29udGVudFR5cGUiOiJhcHBsaWNhdGlvbi9maGlyK25kanNvbiIsInVybCI6Imh0dHBzOi8vcmVzdWx0cy5leGFtcGxlLm9yZy9idWxrL291dHB1dC1wYXRpZW50cy0xLm5kanNvbiJ9fV0sIm1ldGEiOnsicHJvZmlsZSI6WyJodHRwczovL3Byb2ZpbGVzLmloZS5uZXQvSVRJL0RJUy9TdHJ1Y3R1cmVEZWZpbml0aW9uL0RJUy1CdWxrUmVzdWx0RmlsZSJdfX19LHsiZnVsbFVybCI6InVybjp1dWlkOjVjZmNlYjQyLTY1ZTEtNTY4Ny1iN2E3LTg1NTNlYjI5MjhlNyIsInJlc291cmNlIjp7InJlc291cmNlVHlwZSI6IkRvY3VtZW50UmVmZXJlbmNlIiwiaWQiOiJidWxrLWZpbGUtMiIsInN0YXR1cyI6ImN1cnJlbnQiLCJjb250ZW50IjpbeyJhdHRhY2htZW50Ijp7ImNvbnRlbnRUeXBlIjoiYXBwbGljYXRpb24vZmhpcituZGpzb24iLCJ1cmwiOiJodHRwczovL3Jlc3VsdHMuZXhhbXBsZS5vcmcvYnVsay9vdXRwdXQtcGF0aWVudHMtMi5uZGpzb24ifX1dLCJtZXRhIjp7InByb2ZpbGUiOlsiaHR0cHM6Ly9wcm9maWxlcy5paGUubmV0L0lUSS9ESVMvU3RydWN0dXJlRGVmaW5pdGlvbi9ESVMtQnVsa1Jlc3VsdEZpbGUiXX19fSx7ImZ1bGxVcmwiOiJ1cm46dXVpZDoyOGYxODdiOS1jYjVjLTU2NzctODJhZS1lNDA1ZDMxODE4NGQiLCJyZXNvdXJjZSI6eyJyZXNvdXJjZVR5cGUiOiJQcm92ZW5hbmNlIiwiaWQiOiJidWxrLWV2aWRlbmNlIiwibWV0YSI6eyJwcm9maWxlIjpbImh0dHBzOi8vcHJvZmlsZXMuaWhlLm5ldC9JVEkvRElTL1N0cnVjdHVyZURlZmluaXRpb24vRElTLUV2aWRlbmNlIl19LCJ0YXJnZXQiOlt7InJlZmVyZW5jZSI6InVybjp1dWlkOmYwOGU3NmFlLTg4YTgtNTU0YS05YjNhLTEyM2M4ZGM1NjE1NCJ9LHsicmVmZXJlbmNlIjoidXJuOnV1aWQ6NWNmY2ViNDItNjVlMS01Njg3LWI3YTctODU1M2ViMjkyOGU3In1dLCJyZWNvcmRlZCI6IjIwMjYtMTEtMDZUMDM6MDA6MDBaIiwiYWN0aXZpdHkiOnsiY29kaW5nIjpbeyJzeXN0ZW0iOiJodHRwczovL3Byb2ZpbGVzLmloZS5uZXQvSVRJL0RJUy9Db2RlU3lzdGVtL2Rpcy1hY3Rpdml0eSIsImNvZGUiOiJkaXMtdGFzayJ9XX0sInBvbGljeSI6WyJodHRwczovL2dvdmVybmFuY2UuZXhhbXBsZS5vcmcvZmhpci9MaWJyYXJ5L3VjMS1idWxrLWNvaG9ydC1wb2xpY3kvX2hpc3RvcnkvMSJdLCJhZ2VudCI6W3sidHlwZSI6eyJjb2RpbmciOlt7InN5c3RlbSI6Imh0dHA6Ly90ZXJtaW5vbG9neS5obDcub3JnL0NvZGVTeXN0ZW0vcHJvdmVuYW5jZS1wYXJ0aWNpcGFudC10eXBlIiwiY29kZSI6InBlcmZvcm1lciJ9XX0sIndobyI6eyJpZGVudGlmaWVyIjp7InN5c3RlbSI6Imh0dHBzOi8vZGlzLmV4YW1wbGUub3JnL2lkZW50aWZpZXJzL3dvcmtlciIsInZhbHVlIjoiZXhhbXBsZS1hZHZhbmNlZC13b3JrZXIifX19XSwiZXh0ZW5zaW9uIjpbeyJ1cmwiOiJodHRwczovL3Byb2ZpbGVzLmloZS5uZXQvSVRJL0RJUy9TdHJ1Y3R1cmVEZWZpbml0aW9uL2Rpcy1vdXRjb21lLXN0YXR1cyIsInZhbHVlQ29kZSI6ImNvbXBsZXRlIn0seyJ1cmwiOiJodHRwczovL3Byb2ZpbGVzLmloZS5uZXQvSVRJL0RJUy9TdHJ1Y3R1cmVEZWZpbml0aW9uL2Rpcy1ydWxlc2V0IiwidmFsdWVTdHJpbmciOiJnZW5lcmFsaXplLWJpcnRoLWRhdGUifSx7InVybCI6Imh0dHBzOi8vcHJvZmlsZXMuaWhlLm5ldC9JVEkvRElTL1N0cnVjdHVyZURlZmluaXRpb24vZGlzLXJldmVyc2liaWxpdHkiLCJ2YWx1ZUNvZGUiOiJpcnJldmVyc2libGUifSx7InVybCI6Imh0dHBzOi8vcHJvZmlsZXMuaWhlLm5ldC9JVEkvRElTL1N0cnVjdHVyZURlZmluaXRpb24vZGlzLXZhbGlkYXRpb24tc3RhdHVzIiwidmFsdWVDb2RlIjoidmFsaWQifSx7InVybCI6Imh0dHBzOi8vcHJvZmlsZXMuaWhlLm5ldC9JVEkvRElTL1N0cnVjdHVyZURlZmluaXRpb24vZGlzLWF1ZGl0LWNvcnJlbGF0aW9uIiwidmFsdWVJZGVudGlmaWVyIjp7InN5c3RlbSI6Imh0dHBzOi8vZGlzLmV4YW1wbGUub3JnL2lkZW50aWZpZXJzL2F1ZGl0IiwidmFsdWUiOiJleGFtcGxlLXVjMS1hZHZhbmNlZC10YXNrIn19XX19LHsiZnVsbFVybCI6InVybjp1dWlkOjg4N2YyNmNjLTM5NjItNTFjNS04MWJkLWM3YmI2YzBiNWFjYSIsInJlc291cmNlIjp7InJlc291cmNlVHlwZSI6IlByb3ZlbmFuY2UiLCJtZXRhIjp7InByb2ZpbGUiOlsiaHR0cHM6Ly9wcm9maWxlcy5paGUubmV0L0lUSS9ESVMvU3RydWN0dXJlRGVmaW5pdGlvbi9ESVMtU3RhZ2VkUmVsZWFzZUV2aWRlbmNlIl19LCJ0ZXh0Ijp7InN0YXR1cyI6ImdlbmVyYXRlZCIsImRpdiI6IjxkaXYgeG1sbnM9XCJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hodG1sXCI+PHA+VGhlIERlLUlEIE1hbmFnZXIgdmFsaWRhdGVkIGJvdGggc3RhZ2VzIGJlZm9yZSByZWxlYXNpbmcgdGhlIGNvaG9ydCBmaWxlcy48L3A+PC9kaXY+In0sInRhcmdldCI6W3sicmVmZXJlbmNlIjoidXJuOnV1aWQ6ZjA4ZTc2YWUtODhhOC01NTRhLTliM2EtMTIzYzhkYzU2MTU0In0seyJyZWZlcmVuY2UiOiJ1cm46dXVpZDo1Y2ZjZWI0Mi02NWUxLTU2ODctYjdhNy04NTUzZWIyOTI4ZTcifV0sInJlY29yZGVkIjoiMjAyNi0xMS0wNlQwMzowMDozMVoiLCJwb2xpY3kiOlsiaHR0cHM6Ly9nb3Zlcm5hbmNlLmV4YW1wbGUub3JnL2ZoaXIvTGlicmFyeS91YzEtYnVsay1jb2hvcnQtcG9saWN5L19oaXN0b3J5LzEiXSwiYWdlbnQiOlt7InR5cGUiOnsiY29kaW5nIjpbeyJzeXN0ZW0iOiJodHRwOi8vdGVybWlub2xvZ3kuaGw3Lm9yZy9Db2RlU3lzdGVtL3Byb3ZlbmFuY2UtcGFydGljaXBhbnQtdHlwZSIsImNvZGUiOiJhdXRob3IifV19LCJ3aG8iOnsiaWRlbnRpZmllciI6eyJzeXN0ZW0iOiJodHRwczovL2Rpcy5leGFtcGxlLm9yZy9pZGVudGlmaWVycy9tYW5hZ2VyIiwidmFsdWUiOiJleGFtcGxlLWRlLWlkLW1hbmFnZXIifX19XSwiZXh0ZW5zaW9uIjpbeyJ1cmwiOiJodHRwczovL3Byb2ZpbGVzLmloZS5uZXQvSVRJL0RJUy9TdHJ1Y3R1cmVEZWZpbml0aW9uL2Rpcy12YWxpZGF0ZWQtc3RhZ2UiLCJleHRlbnNpb24iOlt7InVybCI6InNlcXVlbmNlIiwidmFsdWVQb3NpdGl2ZUludCI6MX0seyJ1cmwiOiJzdGFnZUlkIiwidmFsdWVTdHJpbmciOiJwcmVsaW1pbmFyeSJ9LHsidXJsIjoicnVsZVNldElkIiwidmFsdWVTdHJpbmciOiJwc2V1ZG9ueW1pemUtcGF0aWVudCJ9XX0seyJ1cmwiOiJodHRwczovL3Byb2ZpbGVzLmloZS5uZXQvSVRJL0RJUy9TdHJ1Y3R1cmVEZWZpbml0aW9uL2Rpcy12YWxpZGF0ZWQtc3RhZ2UiLCJleHRlbnNpb24iOlt7InVybCI6InNlcXVlbmNlIiwidmFsdWVQb3NpdGl2ZUludCI6Mn0seyJ1cmwiOiJzdGFnZUlkIiwidmFsdWVTdHJpbmciOiJhZHZhbmNlZCJ9LHsidXJsIjoicnVsZVNldElkIiwidmFsdWVTdHJpbmciOiJnZW5lcmFsaXplLWJpcnRoLWRhdGUifV19XSwiaWQiOiJidWxrLXJlbGVhc2UtZXZpZGVuY2UifX1dLCJpZCI6ImJ1bGstcjQtcmVzdWx0IiwibWV0YSI6eyJwcm9maWxlIjpbImh0dHBzOi8vcHJvZmlsZXMuaWhlLm5ldC9JVEkvRElTL1N0cnVjdHVyZURlZmluaXRpb24vRElTLVJlc3VsdFBhY2thZ2UiXX19"
* parameter[+].name = "validationStatus"
* parameter[=].valueCode = #valid

Instance: uc1-bulk-cohort-job
InstanceOf: DISJobTask
Usage: #example
* identifier.system = "https://requester.example.org/dis/job-identifiers"
* identifier.value = "uc1-bulk-cohort-job"
* status = #requested
* intent = #order
* code = https://profiles.ihe.net/ITI/DIS/CodeSystem/dis-work-order-type#de-identification-job
* input[authorization].valueReference = Reference(https://governance.example.org/fhir/DocumentReference/uc1-cohort-permit/_history/1)
* input[payloadSet].valueAttachment.contentType = #application/json
* input[payloadSet].valueAttachment.url = "https://source.example.org/bulk/input-manifest.json"
* input[payloadSet].extension[payloadSet].extension[setId].valueString = "cohort-r4"
* input[payloadSet].extension[payloadSet].extension[payloadBinding].valueCode = #DIS-FHIR-Payload
* input[payloadSet].extension[payloadSet].extension[payloadVersion].valueCode = #R4
* input[payloadSet].extension[payloadSet].extension[manifestFormat].valueCode = #fhir-bulk-data
* input[payloadSet].extension[payloadSet].extension[policy].valueCanonical = "https://governance.example.org/policies/uc1-bulk-cohort|1.0"

Instance: uc1-bulk-cohort-policy
InstanceOf: DISPolicy
Usage: #example
* meta.versionId = "1"
* url = "https://governance.example.org/policies/uc1-bulk-cohort"
* version = "1.0"
* name = "UC1BulkCohortPolicy"
* status = #active
* type = https://profiles.ihe.net/ITI/DIS/CodeSystem/dis-library-type#dis-policy "De-identification policy (Semantic-Level or Syntax-Level rules)"
* date = "2026-11-06T03:00:00Z"
* publisher = "Example Data Governance Authority"
* effectivePeriod.start = "2026-01-01"
* effectivePeriod.end = "2026-12-31"
* identifier.system = "https://governance.example.org/identifiers/policy"
* identifier.value = "uc1-bulk-cohort-policy"
* content.contentType = #application/vnd.ihe.dis.policy+json
* content.data = "eyJwb2xpY3lWZXJzaW9uIjoiMS4wIiwicmVwcmVzZW50YXRpb25MZXZlbCI6InN5bnRheCIsInJldmVyc2liaWxpdHlNb2RlIjoiaXJyZXZlcnNpYmxlIiwicGF5bG9hZEZhbWlseSI6ImZoaXIiLCJwYXlsb2FkVmVyc2lvbiI6IlI0IiwiaWRlbnRpdHktbGlua2FnZS1zY29wZSI6eyJ0eXBlIjoiY3Jvc3MtY29tbXVuaXR5IiwiaWRlbnRpZmllciI6eyJzeXN0ZW0iOiJodHRwczovL3N0dWR5LmV4YW1wbGUub3JnL2lkZW50aWZpZXJzL2xpbmthZ2Utc2NvcGUiLCJ2YWx1ZSI6ImVwaS1jb2hvcnQtMjAyNiJ9fSwicnVsZVNldHMiOlt7InJ1bGVTZXRJZCI6InBzZXVkb255bWl6ZS1wYXRpZW50IiwicnVsZXMiOlt7InJ1bGVJZCI6Imhhc2gtaWRlbnRpZmllciIsInRhcmdldCI6IlBhdGllbnQuaWRlbnRpZmllciIsImFjdGlvbiI6Imhhc2giLCJwYXJhbWV0ZXJzIjp7Im1vZGUiOiJzYWx0ZWQiLCJhbGdvcml0aG0iOiJTSEEtMjU2IiwicHNldWRvbnltU3lzdGVtIjoiaHR0cHM6Ly9zdHVkeS5leGFtcGxlLm9yZy9pZGVudGlmaWVycy9wc2V1ZG9ueW0ifX0seyJydWxlSWQiOiJyZW1vdmUtbmFtZSIsInRhcmdldCI6IlBhdGllbnQubmFtZSIsImFjdGlvbiI6InJlbW92ZSJ9XX0seyJydWxlU2V0SWQiOiJnZW5lcmFsaXplLWJpcnRoLWRhdGUiLCJydWxlcyI6W3sicnVsZUlkIjoiYmlydGgteWVhciIsInRhcmdldCI6IlBhdGllbnQuYmlydGhEYXRlIiwiYWN0aW9uIjoidHJ1bmNhdGUtZGF0ZSIsInBhcmFtZXRlcnMiOnsicHJlY2lzaW9uIjoieWVhciJ9fV19XSwic3RhZ2VzIjpbeyJzdGFnZUlkIjoicHJlbGltaW5hcnkiLCJydWxlU2V0UmVmcyI6WyJwc2V1ZG9ueW1pemUtcGF0aWVudCJdfSx7InN0YWdlSWQiOiJhZHZhbmNlZCIsInJ1bGVTZXRSZWZzIjpbImdlbmVyYWxpemUtYmlydGgtZGF0ZSJdfV19"
* title = "UC-1 Bulk FHIR Cohort Policy"
* description = "Approved staged irreversible policy for the synthetic cross-border cohort."

Instance: bulk-evidence
InstanceOf: DISEvidence
Usage: #inline
* id = "bulk-evidence"
* target[0] = Reference(urn:uuid:f08e76ae-88a8-554a-9b3a-123c8dc56154)
* target[+] = Reference(urn:uuid:5cfceb42-65e1-5687-b7a7-8553eb2928e7)
* recorded = "2026-11-06T03:00:00Z"
* activity = https://profiles.ihe.net/ITI/DIS/CodeSystem/dis-activity#dis-task
* policy = "https://governance.example.org/fhir/Library/uc1-bulk-cohort-policy/_history/1"
* agent.type = http://terminology.hl7.org/CodeSystem/provenance-participant-type#performer
* agent.who.identifier.system = "https://dis.example.org/identifiers/worker"
* agent.who.identifier.value = "example-advanced-worker"
* extension[outcomeStatus].valueCode = #complete
* extension[ruleSet].valueString = "generalize-birth-date"
* extension[reversibility].valueCode = #irreversible
* extension[validationStatus].valueCode = #valid
* extension[auditCorrelation].valueIdentifier.system = "https://dis.example.org/identifiers/audit"
* extension[auditCorrelation].valueIdentifier.value = "example-uc1-advanced-task"

Instance: bulk-file-1
InstanceOf: DISBulkResultFile
Usage: #inline
* id = "bulk-file-1"
* status = #current
* content.attachment.contentType = #application/fhir+ndjson
* content.attachment.url = "https://results.example.org/bulk/output-patients-1.ndjson"

Instance: bulk-file-2
InstanceOf: DISBulkResultFile
Usage: #inline
* id = "bulk-file-2"
* status = #current
* content.attachment.contentType = #application/fhir+ndjson
* content.attachment.url = "https://results.example.org/bulk/output-patients-2.ndjson"

Instance: bulk-manifest
InstanceOf: DISBulkResultManifest
Usage: #inline
* id = "bulk-manifest"
* status = #current
* content.attachment.contentType = #application/json
* content.attachment.data = "ewogICJyZXF1aXJlc0FjY2Vzc1Rva2VuIjogdHJ1ZSwKICAib3V0cHV0IjogWwogICAgewogICAgICAidHlwZSI6ICJQYXRpZW50IiwKICAgICAgInVybCI6ICJodHRwczovL3Jlc3VsdHMuZXhhbXBsZS5vcmcvYnVsay9vdXRwdXQtcGF0aWVudHMtMS5uZGpzb24iCiAgICB9LAogICAgewogICAgICAidHlwZSI6ICJQYXRpZW50IiwKICAgICAgInVybCI6ICJodHRwczovL3Jlc3VsdHMuZXhhbXBsZS5vcmcvYnVsay9vdXRwdXQtcGF0aWVudHMtMi5uZGpzb24iCiAgICB9CiAgXQp9Cg=="

Instance: bulk-release-evidence
InstanceOf: DISStagedReleaseEvidence
Usage: #inline
* id = "bulk-release-evidence"
* target[0] = Reference(urn:uuid:f08e76ae-88a8-554a-9b3a-123c8dc56154)
* target[+] = Reference(urn:uuid:5cfceb42-65e1-5687-b7a7-8553eb2928e7)
* recorded = "2026-11-06T03:00:31Z"
* policy = "https://governance.example.org/fhir/Library/uc1-bulk-cohort-policy/_history/1"
* agent.type = http://terminology.hl7.org/CodeSystem/provenance-participant-type#author
* agent.who.identifier.system = "https://dis.example.org/identifiers/manager"
* agent.who.identifier.value = "example-de-id-manager"
* extension[validatedStage][0].extension[sequence].valuePositiveInt = 1
* extension[validatedStage][0].extension[stageId].valueString = "preliminary"
* extension[validatedStage][0].extension[ruleSetId].valueString = "pseudonymize-patient"
* extension[validatedStage][1].extension[sequence].valuePositiveInt = 2
* extension[validatedStage][1].extension[stageId].valueString = "advanced"
* extension[validatedStage][1].extension[ruleSetId].valueString = "generalize-birth-date"
* text.status = #generated
* text.div = "<div xmlns=\"http://www.w3.org/1999/xhtml\"><p>The De-ID Manager validated both stages before releasing the cohort files.</p></div>"
