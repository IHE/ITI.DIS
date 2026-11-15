<a name="shared-contract-rules"> </a>

<a name="contract-signatures"> </a>

## Contract Signatures and Disclosure

A DIS digital signature on a Contract SHALL be carried in [`Contract.signer.signature`]({{site.data.fhir.path}}contract-definitions.html#Contract.signer.signature). A deployment determines which signatures it requires on Data Request Authorization and Policy Contracts at ITI-x1 and on Execution Plan Contracts at ITI-x3. It configures the accepted signature format, signed bytes, trusted keys and signer authority. When a signature is required, the receiving actor SHALL reject an absent or unverifiable signature and verify that the signer is authorized to sign for `Contract.signer.party`. Apply the same rules to Requester-carried and Manager-resolved policies. The [UC-4 example](examples-cloud-decision-support.html#signature-verification) illustrates one configuration.

A deployment also determines whether to make signed authorization or policy Contracts available with a job result and how to handle unavailable or restricted supporting Contracts. The Manager SHALL apply the deployment's disclosure rules together with the [current grant and recipient checks](volume-3-authorization.html#data-request-authorization) before releasing the result or any supporting Contract. When supplied as part of a result package, supporting Contracts remain outside the clinical output manifest. Transformation Provenance records processing and release evidence.
