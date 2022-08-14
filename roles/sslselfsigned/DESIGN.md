# Design Description for SSL Self Signed

This generates a Certificate Authority (CA) and then a signing request (CSR), which results in the certificate for this server after signing it with our CA.

The CA cert is placed in the secret folder, you can install it eg. in Arch like this:

    sudo trust anchor --store secret/DOMAIN/sovereign-self-signed-cert/DOMAIN/etc/letsencrypt/live/DOMAIN/chain.pem

It will then automatically be picked up by browsers like Firefox and Chrome.
