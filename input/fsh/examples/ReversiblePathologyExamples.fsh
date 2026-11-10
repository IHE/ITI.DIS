// UC-3 requester-supplied mapping and task-scoped lookup examples.

Instance: pathology-supplied-lookup
InstanceOf: DISLookupTable
Usage: #example
Description: "Requester-supplied lookup table used in the reversible pathology example."
* meta.versionId = "1"
* status = #current
* masterIdentifier.system = "urn:example:lookup-content-version"
* masterIdentifier.value = "pathology-supplied-lookup-v1"
* identifier.system = "urn:example:lookup-table"
* identifier.value = "pathology-supplied-lookup"
* type = https://profiles.ihe.net/ITI/DIS/CodeSystem/dis-document-type#lookup-table "DIS reversible lookup table"
* extension[identityLinkageScope].extension[scopeType].valueCode = #source-institution
* extension[identityLinkageScope].extension[scopeIdentifier].valueIdentifier.system = "https://hospital.example.org/identifiers/linkage-scope"
* extension[identityLinkageScope].extension[scopeIdentifier].valueIdentifier.value = "lab-project-2026"
* content.attachment.contentType = #application/json
* content.attachment.data = "eyJ0YWJsZUlkIjoicGF0aG9sb2d5LXN1cHBsaWVkLWxvb2t1cCIsInZlcnNpb24iOiIxIiwiaWRlbnRpdHktbGlua2FnZS1zY29wZSI6eyJ0eXBlIjoic291cmNlLWluc3RpdHV0aW9uIiwiaWRlbnRpZmllciI6eyJzeXN0ZW0iOiJodHRwczovL2hvc3BpdGFsLmV4YW1wbGUub3JnL2lkZW50aWZpZXJzL2xpbmthZ2Utc2NvcGUiLCJ2YWx1ZSI6ImxhYi1wcm9qZWN0LTIwMjYifX0sImVudHJpZXMiOlt7InNvdXJjZVN5c3RlbSI6Imh0dHBzOi8vaG9zcGl0YWwuZXhhbXBsZS5vcmcvaWRlbnRpZmllcnMvbXJuIiwic291cmNlVmFsdWUiOiJBMTIzIiwidGFyZ2V0U3lzdGVtIjoiaHR0cHM6Ly9ob3NwaXRhbC5leGFtcGxlLm9yZy9pZGVudGlmaWVycy9wc2V1ZG9ueW0iLCJ0YXJnZXRWYWx1ZSI6ImxhYi1zdXBwbGllZC0wMDQyIn0seyJzb3VyY2VTeXN0ZW0iOiJodHRwczovL2hvc3BpdGFsLmV4YW1wbGUub3JnL2lkZW50aWZpZXJzL21ybiIsInNvdXJjZVZhbHVlIjoiQjQ1NiIsInRhcmdldFN5c3RlbSI6Imh0dHBzOi8vaG9zcGl0YWwuZXhhbXBsZS5vcmcvaWRlbnRpZmllcnMvcHNldWRvbnltIiwidGFyZ2V0VmFsdWUiOiJsYWItc3VwcGxpZWQtMDA0MyJ9XX0="

Instance: pathology-task-lookup
InstanceOf: DISLookupTable
Usage: #example
Description: "Task-specific subset of the requester-supplied lookup table used in the reversible pathology example."
* meta.versionId = "1"
* status = #current
* masterIdentifier.system = "urn:example:lookup-content-version"
* masterIdentifier.value = "pathology-task-lookup-v1"
* identifier.system = "urn:example:lookup-table"
* identifier.value = "pathology-task-lookup"
* type = https://profiles.ihe.net/ITI/DIS/CodeSystem/dis-document-type#lookup-table "DIS reversible lookup table"
* extension[identityLinkageScope].extension[scopeType].valueCode = #source-institution
* extension[identityLinkageScope].extension[scopeIdentifier].valueIdentifier.system = "https://hospital.example.org/identifiers/linkage-scope"
* extension[identityLinkageScope].extension[scopeIdentifier].valueIdentifier.value = "lab-project-2026"
* content.attachment.contentType = #application/json
* content.attachment.data = "eyJ0YWJsZUlkIjoicGF0aG9sb2d5LXRhc2stbG9va3VwIiwidmVyc2lvbiI6IjEiLCJpZGVudGl0eS1saW5rYWdlLXNjb3BlIjp7InR5cGUiOiJzb3VyY2UtaW5zdGl0dXRpb24iLCJpZGVudGlmaWVyIjp7InN5c3RlbSI6Imh0dHBzOi8vaG9zcGl0YWwuZXhhbXBsZS5vcmcvaWRlbnRpZmllcnMvbGlua2FnZS1zY29wZSIsInZhbHVlIjoibGFiLXByb2plY3QtMjAyNiJ9fSwiZW50cmllcyI6W3sic291cmNlU3lzdGVtIjoiaHR0cHM6Ly9ob3NwaXRhbC5leGFtcGxlLm9yZy9pZGVudGlmaWVycy9tcm4iLCJzb3VyY2VWYWx1ZSI6IkExMjMiLCJ0YXJnZXRTeXN0ZW0iOiJodHRwczovL2hvc3BpdGFsLmV4YW1wbGUub3JnL2lkZW50aWZpZXJzL3BzZXVkb255bSIsInRhcmdldFZhbHVlIjoibGFiLXN1cHBsaWVkLTAwNDIifV19"
* relatesTo.code = #transforms
* relatesTo.target = Reference(https://mappings.example.org/fhir/DocumentReference/pathology-supplied-lookup/_history/1)
