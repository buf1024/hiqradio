openssl genrsa -out ../assets/files/rsa_private.key 2048

openssl rsa -in ../assets/files/rsa_private.key -pubout -out ../assets/files/rsa_public.key