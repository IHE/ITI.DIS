<div markdown="1" class="stu-note">
**Informative proposal.** This design and the synthetic test vector support review of [issue #50](https://github.com/IHE/ITI.DIS/issues/50).
</div>

## Proposed Method

The approved de-identification policy would select deterministic encryption as an optional method under DIS-REVERSIBLE. The De-Identifier would encrypt the resolved patient business identifier, publish the pseudonym under the approved output namespace, and update references that use the identifier. The policy would select either encryption-generated pseudonyms or a supplied lookup table for those identifiers.

| Candidate | Intended use |
|---|---|
| AES-FF1 | First candidate for identifiers that must retain their alphabet and length. The approved policy selects the configuration for the identifier format. [NIST SP 800-38G](https://csrc.nist.gov/pubs/sp/800/38/g/upd1/final) |
| AES-SIV | Candidate when the receiver accepts a longer opaque identifier and needs authenticated decryption. [RFC 5297 §4](https://www.rfc-editor.org/rfc/rfc5297#section-4) |

For FF1, the policy would specify the configuration directly or reference an immutable version of a format definition. The configuration covers the AES key size, ordered alphabet, allowed lengths, rules for extracting and reconstructing formatted identifiers, output pseudonym namespace, and exact tweak derivation. Include rules for case, leading zeroes, literal prefixes, separators, and check digits where applicable. The configured format must yield outputs accepted by the receiver. Follow the published [NIST SP 800-38G](https://csrc.nist.gov/pubs/sp/800/38/g/upd1/final) and consult the [second public draft of Revision 1](https://csrc.nist.gov/pubs/sp/800/38/g/r1/2pd) for guidance, including its proposed minimum FF1 domain of one million values. Count the domain the configured transformation actually encrypts. Fixed characters add no possible values.

### Shared key provisioning and reversal

Before dispatch, the deployment would make the same scope-specific key version available to all participating De-Identifiers for encryption and to the Manager's authorized reversal process for decryption. The deployment would provision a separate key for each method. A local cryptographic module can hold the key and enforce permitted operations. Each deployment maps the method, linkage scope, and non-secret key-version identifier to its own local key handle. The handles can differ while the modules use the same underlying key bytes for that method and scope.

The Manager would verify that its authorized reversal process can use the selected key version and that each assigned De-Identifier supports the approved configuration and can encrypt with that key version. It would pin the method, configuration or its immutable reference, resolved linkage scope, non-secret key-version identifier, and output namespace in the execution plan. Assignments and retries that must link use the same effective settings. Independent De-Identifiers use the same resolved patient identity and the same tweak for FF1 or associated data for deterministic AES-SIV. Where local identifiers differ, the deployment resolves them to a common identity first. When a change would alter mappings, the deployment uses a distinct output namespace or explicitly migrates the existing linkage.

For authorized reversal, the Manager would use the matching key version and reconstruct the tweak or associated data from the pinned configuration. It retains the association between the output namespace and reversal context for the authorized reversal period. AES-SIV verifies ciphertext integrity during decryption. FF1 alone does not authenticate a pseudonym. Decryption recovers the resolved identifier. If a local chart uses a different identifier, associating it with the recovered identity requires authorized identity resolution. See [NIST SP 800-38G](https://csrc.nist.gov/pubs/sp/800/38/g/upd1/final) and [RFC 5297 §2.7](https://www.rfc-editor.org/rfc/rfc5297#section-2.7).

Encryption-based derivation would use the ordinary task result with pseudonymized output and evidence. The key and local handles stay in their protected environments. The existing [`generatedLookupTable`](volume-3.html#3pxx5-reversible-lookup-table) supports Manager-managed reversal for salted hashing. For standalone processing, the Integrated actor performs the applicable steps internally.

IHE Document Encryption (DEN) provides an informative precedent for wrapping a key for an authorized recipient and leaving provisioning of the wrapping key to the deployment. The proposed DIS flow treats provisioned keys as a precondition. [IHE DEN §5.3.2.2.4.2](https://www.ihe.net/uploadedFiles/Documents/ITI/IHE_ITI_Suppl_DEN.pdf#page=38)

The action code, policy and plan syntax, and capability declaration remain under review in [issue #50](https://github.com/IHE/ITI.DIS/issues/50).

<a name="ff1-interoperability-vector"> </a>

## Ten-Digit Decimal Example and Interoperability Vector

This example policy configuration uses forward AES-256, radix 10, and the ordered ASCII alphabet `0123456789`. It encrypts exactly ten digits with leading zeroes and publishes all ten output digits in `Identifier.value` under the configured `Identifier.system`. The receiver accepts any ten-digit output under that namespace. The example configuration identifier is `DIS-FF1-AES256-DECIMAL10-v1`.

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

## Candidate ODRL action syntax (Informative)

If the committee adopts the optional encryption method in [issue #50](https://github.com/IHE/ITI.DIS/issues/50), DIS would define `dis:encrypt` as an action on a transformation obligation under DIS-REVERSIBLE. The same action IRI would apply in policy and plan. Each refinement would use `eq` and the value form in the table. See the [DIS ODRL content binding](odrl-content.html#sets-for-policy-and-plan).

| Action refinement | De-Identification Policy | Execution Plan |
| --- | --- | --- |
| `dis:encryptionMethod` | Required method code, such as `AES-FF1`. | Same approved method. |
| `dis:configurationVersion` | Required IRI identifying an immutable configuration revision. | Same configuration revision, pinned for the assignment. |
| `dis:resolvedLinkageScope` | The policy declares the authorized linkage scope using the existing DIS scope model. | Required IRI identifying the exact resolved scope. The binding must define its mapping to the DIS scope type and identifier. |
| `dis:pseudonymSystem` | Defined in the approved configuration. | Required IRI equal to the approved output namespace. |
| `dis:keyVersion` | Selected during plan compilation under the approved scope and deployment policy. | Required non-secret identifier for the provisioned key version. |

The following is an action fragment for a compiled obligation targeting an approved patient identifier. The same structure in the policy carries the method and configuration refinements. The configuration defines the identifier format and the method-specific tweak or associated-data rules. Key bytes and local key handles remain in the protected deployments.

```json
{
  "rdf:value": {"@id": "dis:encrypt"},
  "refinement": [
    {"leftOperand": "dis:encryptionMethod", "operator": "eq", "rightOperand": "AES-FF1"},
    {"leftOperand": "dis:configurationVersion", "operator": "eq", "rightOperand": {"@id": "https://example.org/configurations/ff1-decimal10/versions/1"}},
    {"leftOperand": "dis:resolvedLinkageScope", "operator": "eq", "rightOperand": {"@id": "https://example.org/linkage-scopes/research-42"}},
    {"leftOperand": "dis:pseudonymSystem", "operator": "eq", "rightOperand": {"@id": "https://example.org/pseudonyms/research-42/v1"}},
    {"leftOperand": "dis:keyVersion", "operator": "eq", "rightOperand": "research-42-ff1-v1"}
  ]
}
```

Before dispatch, the proposed binding would require the Manager to verify configuration compatibility and key-version availability for encryption and authorized reversal. A conflict with a supplied lookup table for the same identifiers would prevent dispatch. For testing, use the existing informative FF1 vector and add an exchange case that verifies the compiled parameters, matching outputs from independent De-Identifiers, authorized reversal, and rejection when the selected key version is unavailable. [FF1 interoperability vector](draft-encryption-based-pseudonymization.html#ff1-interoperability-vector)
