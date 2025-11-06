Owasp top 10 privacy risks
- P1: inadequate data protection
    - weak encryption
    - lack of hashing/salting passwords
    - improper key management
- P2: Operator sided data leakage
    -  lack of awareness
    - poor access management
    - unnecessary copies of personal data
- P3: lack of user control
    - no opt-in/opt-out mechanisms
    - no data access or deletion options
- P4: third party data sharing
    - sharing without user consent
    - inadequate vetting of third parties
    - lack of contractual safeguards
- P5: non transparent policies , terms and conditions
    - data processing is not explained
    - conditions are too long and users do not read them
- P6: insufficient data minimization
    - collecting more data than necessary
    - retaining data longer than needed
- P7: lack of privacy by design
    - privacy not considered in system design
    - no privacy impact assessments
- P8: inadequate incident response
    - no plan for data breaches
    - failure to notify affected users
- P9: poor user authentication and session management
    - weak password policies
    - lack of multi-factor authentication
- P10: insufficient monitoring and auditing
    - no logging of data access
    - lack of regular audits for compliance


Cryptography
- Keyless Cryptography -> Hash Functions
- Secret-key Cryptography -> 
- Public-key Cryptography

CIA -> confidentiality(use encryption), integrity(use signature), authenticity(use signature)

Keyless Cryptography -> Hash Functions
- one way transformations
- simple hashes(e.g. sha and whirpool) or password hash(e.g. scrypt, bcrypt)


Secret Key Cryptography


A digital siganture is calculate from a message and private key
-EdDSA(edwards-curve Digital Signature Algorithm) or RSA(Rivest-Shamir-Aldeman)




BOB                                                     ALICE
K-private                                               K-private1
K-public                                                K-public1
K-public1                                               K-public




Confidentiality -
bob encrypt message with public key of alice          alice decrypts the message using private key of herself

bob decrypts message using private key of herself     alice encrypts the message using public key of bob


Integrity - 
signature of message is encrypted with private key of bob himself      







Data masking
- process of obfuscating original/sensitive data
- the two main categories include
    - anonymization
    - pseudonymization



Anonymization techniques, inckuding noise addition and data aggregation, may lead to a reduction in the dataset's utility
    - Randomization
        - Noise addition
        - Premutation
        - Differential privacy
    - Generalization
        - Aggregation
        - K-anonymity - for every quasi identifier there are k other entries in the data-set; preffered k -> 11; reach a record for linkability attack
        - L-diversity - the k-anonymous entries should be classified into l-diversities
        - T-closeness - how close the two records are in the data-set

Pusedonymization is used when re-identification is necessary for the purpose of processing
 - scrambling/obfuscation
 - encryption/hashing
 - subsitution/shuffling
 - tokenization
 - blurring





