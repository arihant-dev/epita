from ecdsa import NIST256p, SigningKey


def main() -> None:
    key = SigningKey.generate(curve=NIST256p)

    with open("private_key.pem", "wb") as f:
        f.write(key.to_pem(format="pkcs8"))
    with open("public_key.pem", "wb") as f:
        f.write(key.get_verifying_key().to_pem())

    print(
        "Private and public keys have been generated and saved to 'private_key.pem' and 'public_key.pem'."
    )


if __name__ == "__main__":
    main()