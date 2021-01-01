# Help

## Warning

**This application did not go through any security assessment. It should not be trusted to encrypt any information which has strong security requirements**

## Encrypting a file
Type a password in the password text box.
The password must have at least 8 chars and must be composed by upper and lower letters, symbols and numbers.
Abem will encrypt the contents of the file together with its name as metadata.
After the encryption is finished, you will be asked to save the encrypted content in a file.

## Decrypting a file
Type a password in the password text box.
If the password is correct and the ciphertext has not been modified, the file will be decrypted and you will be asked to save it using the original filename.

## Algorithms

Abem uses the library [libsodium](https://github.com/jedisct1/libsodium).
Concretely it uses the **Argon2id** to derive the encryption key and the
**XSalsa20 with Poly1305 MAC** for the symmetric authenticated encryption.
Keep into account that by now, the application needs to load the file to encrypt
completely in memory to perform both encryption and decryption operations.
