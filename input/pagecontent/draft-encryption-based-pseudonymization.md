This section defines the optional AES-FF1 method under DIS-REVERSIBLE for the FHIR payload binding. See [Volume 3](volume-3.html#encryption-based-patient-pseudonymization) and [issue #50](https://github.com/IHE/ITI.DIS/issues/50).

## Configuration

The approved policy SHALL use `dis:encrypt` for a patient business identifier and reference an immutable configuration revision. The Manager and De-Identifier SHALL obtain the same configuration by trusted deployment provisioning or resolution. The configuration revision IRI SHALL use HTTPS with a host and a nonempty path. It SHALL omit query and fragment components. A change to any field requires a new revision IRI.

| Configuration field | Requirement |
| --- | --- |
| `method` | String `AES-FF1`. Use FF1 with forward AES as specified in [NIST SP 800-38G](https://csrc.nist.gov/pubs/sp/800/38/g/upd1/final). |
| `keyBits` | Integer `128`, `192`, or `256`. |
| `alphabet` | Ordered string of two or more distinct printable ASCII characters. Its character order defines the FF1 symbol indices and its length defines the radix. |
| `length` | Fixed positive length of the whole identifier value. The alphabet size raised to this length SHALL be at least 1,000,000. Use integer arithmetic for FF1 boundary calculations. |
| `sourceSystem` | Absolute IRI of the resolved common patient identifier system. |
| `pseudonymSystem` | Absolute IRI of the approved output identifier system, distinct from the source system. |
| `tweakContextId` | Nonblank string uniquely bound to this configuration revision and shared by all participants. |

The configuration SHALL conform to the algorithm's length and tweak limits. The input SHALL match the configured source system, alphabet, and length. Preserve case and leading zeroes and encrypt the entire identifier value. The output uses the same alphabet and length and the configured pseudonym system. The receiving system must accept every value in that output domain. Identifiers that require special handling for embedded check digits, formatting literals, or restricted value ranges are outside this binding.

To derive the tweak, SHA-256 hash the compact UTF-8 JSON array of six strings in this order: configuration tweak context ID, resolved scope type, resolved scope identifier system, resolved scope identifier value, configured source system, and pseudonym system. Use the [DIS compact JSON serialization rules](volume-3.html#3pxx123-patient-identifier-pseudonymization). Pass the 32 raw digest bytes to FF1. Every participant SHALL preserve the exact strings used to derive the tweak.

## Dispatch and reversal

Before job acceptance or synchronous processing, the Manager SHALL authorize the scope, validate the configured method and output namespace, select a non-secret immutable key-version identifier, and establish that its authorized reversal process can decrypt and every chosen De-Identifier can encrypt with the same scope-specific key version. Use an FF1 key dedicated to this method and authorized scope. Key provisioning and the protected confirmation of key availability are deployment-defined. Capability advertising identifies supported configurations and does not establish key availability.

The Manager SHALL pin the configuration revision, resolved scope, pseudonym system, and key version for assignments and retries. The De-Identifier SHALL validate those values against the configuration and its local encryption authorization before accepting a task or beginning synchronous processing. It SHALL fail an assignment with an unavailable or unauthorized key, a configuration mismatch, or a selected identifier outside the configured input domain. The De-Identifier SHALL update affected FHIR identifier references under the [reference integrity rules](volume-3.html#3pxx22-fhir-reference-integrity).

Before release, the Manager SHALL retain the protected association of the output pseudonym system to the configuration revision, resolved scope, and key version for the authorized reversal period. Assign a distinct output pseudonym system when any input to the mapping changes, including key rotation or a different scope. For an authorized reversal, the Manager SHALL establish the pseudonym's provenance and trusted output context, then reconstruct the tweak and use the matching key to recover the resolved identifier. FF1 decryption produces a value for every ciphertext in its domain. A successful decryption alone cannot establish a patient association. Mapping the resolved identifier to a local chart requires authorized identity resolution.

The De-Identifier SHALL NOT return a generated lookup table for identifiers transformed with FF1. Apply the usual generated-table requirements to any separate salted-hash rules requiring authorized reversal. Key bytes and local key handles SHALL stay in the protected deployment and SHALL NOT appear in a plan, result, evidence, log, or error. A De-Identifier's access SHALL permit only the assigned encryption operations. An Integrated actor applies the applicable checks internally.

<a name="ff1-interoperability-vector"> </a>

## Ten-Digit Decimal Example and Interoperability Vector

This informative example configuration uses forward AES-256, radix 10, and the ordered ASCII alphabet `0123456789`. It encrypts exactly ten digits with leading zeroes and publishes all ten output digits in `Identifier.value` under the configured `Identifier.system`. The receiver accepts any ten-digit output under that namespace. The configuration tweak context ID is `DIS-FF1-AES256-DECIMAL10-v1`.

For this example, derive the 32-byte tweak as SHA-256 of the compact UTF-8 serialization of the JSON array below. The array contains the configuration identifier, resolved scope type, scope identifier system and value, resolved common identifier system, and output pseudonym namespace in that order. Use the compact string-escaping rules in [Volume 3, Patient Identifier Pseudonymization](volume-3.html#3pxx123-patient-identifier-pseudonymization). Preserve the supplied strings exactly and pass the raw digest bytes to FF1.

Use public test key bytes `000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f` (hex) and this exact context array, with no trailing newline in the hashed input.

```json
["DIS-FF1-AES256-DECIMAL10-v1","source-institution","https://example.org/dis/scopes","cohort-01","https://example.org/mrn","https://example.org/dis/pseudonyms/cohort-01-v1"]
```

| Value | Expected result |
|---|---|
| SHA-256 tweak (hex) | `2f320550d509d115496dc7d13089c00ae25816a11b10724dc7752c0091c9cb97` |
| Resolved input identifier value | `0000000014` |
| Output `Identifier.system` | `https://example.org/dis/pseudonyms/cohort-01-v1` |
| Output `Identifier.value` | `0863301760` |

### Configuration and ODRL examples

The example configuration revision IRI is `https://example.org/configurations/ff1-decimal10/versions/1`.

```json
{
  "method": "AES-FF1",
  "keyBits": 256,
  "alphabet": "0123456789",
  "length": 10,
  "sourceSystem": "https://example.org/mrn",
  "pseudonymSystem": "https://example.org/dis/pseudonyms/cohort-01-v1",
  "tweakContextId": "DIS-FF1-AES256-DECIMAL10-v1"
}
```

The reversible policy declares the source-institution linkage scope at the Set level and uses this action fragment.

```json
{
  "rdf:value": {"@id": "dis:encrypt"},
  "refinement": [
    {"leftOperand": "dis:encryptionMethod", "operator": "eq", "rightOperand": "AES-FF1"},
    {"leftOperand": "dis:configurationVersion", "operator": "eq", "rightOperand": {"@id": "https://example.org/configurations/ff1-decimal10/versions/1"}}
  ]
}
```

The compiled plan binds the action to the patient business identifier selector and includes the resolved scope and key version.

```json
{
  "rdf:value": {"@id": "dis:encrypt"},
  "refinement": [
    {"leftOperand": "dis:encryptionMethod", "operator": "eq", "rightOperand": "AES-FF1"},
    {"leftOperand": "dis:configurationVersion", "operator": "eq", "rightOperand": {"@id": "https://example.org/configurations/ff1-decimal10/versions/1"}},
    {"leftOperand": "dis:identity-linkage-scope", "operator": "eq", "rightOperand": {"@type": "@json", "@value": {"type": "source-institution", "identifier": {"system": "https://example.org/dis/scopes", "value": "cohort-01"}}}},
    {"leftOperand": "dis:pseudonymSystem", "operator": "eq", "rightOperand": {"@id": "https://example.org/dis/pseudonyms/cohort-01-v1"}},
    {"leftOperand": "dis:keyVersion", "operator": "eq", "rightOperand": "cohort-01-ff1-v1"}
  ]
}
```
