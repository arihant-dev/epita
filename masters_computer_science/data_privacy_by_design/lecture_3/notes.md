### Lecture 3 Notes - Data Privacy by Design

# PET(soft): Differential Privacy
- Noise addition using a single value: epsilon(ϵ), which is a measure of how private data release(output) is
    - Higher value of ϵ means less privacy
    - Lower value of ϵ means more privacy
- Formula explaining differential privacy:
    - A randomized algorithm A gives ϵ-differential privacy if for all datasets D1 and D2 differing on at most one element, and all S ⊆ Range(A):
        - P[A(D1) ∈ S] ≤ e^ϵ * P[A(D2) ∈ S]

# PET(hard): TOR/ Panoramix
- Low latency anonymity system
    - Onion routing

- High Latency anonymity system
    - MixMaster
    - MixMinion
    - Panoramix

## Key Definitions & Roles
- Personal data OR Personally Identifiable Information(PII): Any information relating to an identified or identifiable natural person.
- Data Subject: An individual whose personal data is processed.
- Data Controller: The entity that determines the purposes and means of processing personal data.
- Data Processor: The entity that processes personal data on behalf of the controller.
- Data Protection Officer (DPO): A designated individual responsible for overseeing data protection strategy and implementation.    
- Consent: A freely given, specific, informed, and unambiguous indication of the data subject's wishes by which they signify agreement to the processing of personal data.
- Data Breach: A security incident that leads to the accidental or unlawful destruction, loss, alteration, unauthorized disclosure of, or access to personal data.

## What is Data Processing?
Any operation or set of operations performed on personal data, whether or not by automated means, such as collection, recording, organization, structuring, storage, adaptation or alteration, retrieval, consultation, use, disclosure by transmission, dissemination or otherwise making available, alignment or combination, restriction, erasure or destruction.

## DPIA (Data Protection Impact Assessment)
A process to help identify and minimize the data protection risks of a project. It is required when data processing is likely to result in a high risk to the rights and freedoms of individuals.
### When to conduct a DPIA:
- Systematic and extensive evaluation of personal aspects based on automated processing, including profiling.
- Large scale processing of special categories of data (e.g., health data, racial or ethnic origin, political opinions, religious beliefs, trade union membership, genetic data, biometric data).

## Lawful basis for processing personal data:
1. Consent of the data subject
2. Performance of a contract
3. Compliance with a legal obligation
4. Protection of vital interests
5. Performance of a task carried out in the public interest or in the exercise of official authority
6. Legitimate interests pursued by the controller or a third party, except where overridden by the interests or fundamental rights and freedoms of the data subject.

## Data Subject Rights:
- Right to be informed
- Right of access
- Right to rectification
- Right to erasure (right to be forgotten)
- Right to restrict processing
- Right to data portability
- Right to object
- Rights related to automated decision-making and profiling

## Data Protection by Design and by Default
- Data Minimization: Collect and process only the data that is necessary for the intended purpose.
- Pseudonymization: Replace identifying fields within a data record with artificial identifiers.
- Encryption: Use strong encryption methods to protect personal data both in transit and at rest.
- Access Controls: Implement strict access controls to ensure that only authorized personnel can access personal data.
- Regular Audits: Conduct regular audits and assessments to ensure compliance with data protection policies and regulations.


