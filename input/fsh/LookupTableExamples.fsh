// Encoded content for the version-specific Binary example.
RuleSet: LookupTableExampleData(path)
* {path} = "eyJ0YWJsZUlkIjoicmVxdWVzdGVyLWV4YW1wbGUiLCJ2ZXJzaW9uIjoiMSIsImlkZW50aXR5LWxpbmthZ2Utc2NvcGUiOnsidHlwZSI6ImNyb3NzLWNvbW11bml0eSIsImlkZW50aWZpZXIiOnsic3lzdGVtIjoiaHR0cHM6Ly90cmlhbC5leGFtcGxlL2lkZW50aWZpZXJzL2xpbmthZ2Utc2NvcGUiLCJ2YWx1ZSI6IlQwMSJ9fSwiZW50cmllcyI6W3sic291cmNlU3lzdGVtIjoiaHR0cHM6Ly9ob3NwaXRhbC1hLmV4YW1wbGUvaWRlbnRpZmllcnMvbXJuIiwic291cmNlVmFsdWUiOiJBMTIzIiwidGFyZ2V0U3lzdGVtIjoiaHR0cHM6Ly90cmlhbC5leGFtcGxlL3N0dWRpZXMvVDAxL3BhcnRpY2lwYW50cyIsInRhcmdldFZhbHVlIjoiVDAxLTAwNDIifSx7InNvdXJjZVN5c3RlbSI6Imh0dHBzOi8vaG9zcGl0YWwtYS5leGFtcGxlL2lkZW50aWZpZXJzL21ybiIsInNvdXJjZVZhbHVlIjoiQzQ1NiIsInRhcmdldFN5c3RlbSI6Imh0dHBzOi8vdHJpYWwuZXhhbXBsZS9zdHVkaWVzL1QwMS9wYXJ0aWNpcGFudHMiLCJ0YXJnZXRWYWx1ZSI6IlQwMS0wMDQzIn1dfQ=="

RuleSet: LookupTableExampleMetadata(tableId, contentVersion, scopeType, scopeSystem, scopeValue)
* meta.versionId = "1"
* masterIdentifier.system = "urn:example:lookup-content-version"
* masterIdentifier.value = "{contentVersion}"
* identifier[0].system = "urn:example:lookup-table"
* identifier[0].value = "{tableId}"
* status = #current
* extension[identityLinkageScope].extension[scopeType].valueCode = #{scopeType}
* extension[identityLinkageScope].extension[scopeIdentifier].valueIdentifier.system = "{scopeSystem}"
* extension[identityLinkageScope].extension[scopeIdentifier].valueIdentifier.value = "{scopeValue}"

Instance: lookup-document-example
InstanceOf: DISLookupTable
Usage: #example
Title: "Lookup table with Binary content"
Description: "Requester-supplied trial participant identifiers carried in a version-specific Binary attachment."
* insert LookupTableExampleMetadata(requester-example, lookup-content-v1, cross-community, https://trial.example/identifiers/linkage-scope, T01)
* content.attachment.url = "https://mappings.example/fhir/Binary/lookup-content-example/_history/1"

Instance: lookup-content-example
InstanceOf: DISLookupTableContent
Usage: #example
Title: "Lookup table JSON content"
Description: "The JSON mapping content referenced by the lookup table DocumentReference."
* meta.versionId = "1"
* insert LookupTableExampleData(data)

Instance: generated-lookup-uc3
InstanceOf: DISLookupTable
Usage: #example
Title: "Generated clinical pathology lookup table"
Description: "Protected patient identifier mapping returned inline to the Manager after the reversible salted hash task."
* insert LookupTableExampleMetadata(generated-lookup-uc3, generated-lookup-uc3-v1, source-institution, https://hospital.example.org/identifiers/linkage-scope, lab-project-2026)
* content.attachment.data = "eyJ0YWJsZUlkIjoiZ2VuZXJhdGVkLWxvb2t1cC11YzMiLCJ2ZXJzaW9uIjoiMSIsImlkZW50aXR5LWxpbmthZ2Utc2NvcGUiOnsidHlwZSI6InNvdXJjZS1pbnN0aXR1dGlvbiIsImlkZW50aWZpZXIiOnsic3lzdGVtIjoiaHR0cHM6Ly9ob3NwaXRhbC5leGFtcGxlLm9yZy9pZGVudGlmaWVycy9saW5rYWdlLXNjb3BlIiwidmFsdWUiOiJsYWItcHJvamVjdC0yMDI2In19LCJlbnRyaWVzIjpbeyJzb3VyY2VTeXN0ZW0iOiJodHRwczovL2hvc3BpdGFsLmV4YW1wbGUub3JnL2lkZW50aWZpZXJzL21ybiIsInNvdXJjZVZhbHVlIjoiQTEyMyIsInRhcmdldFN5c3RlbSI6Imh0dHBzOi8vaG9zcGl0YWwuZXhhbXBsZS5vcmcvaWRlbnRpZmllcnMvcHNldWRvbnltIiwidGFyZ2V0VmFsdWUiOiI4MTYyNjEwYTE0OWU3YjY3MDA1MTNmYTNmMGNlZmY0NjMyOGUyYjU4NGZkM2QzNTFlNGQ1YzI3NzVhNDJmZjBjIn1dfQ=="
