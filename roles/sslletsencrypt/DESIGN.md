# Design Description for SSL Let's Encrypt Role

[Let's Encrypt](https://letsencrypt.org) (LE) is an automated certificate authority that provides free SSL certificates that are trusted by all major browsers.  LE certificates are used by Sovereign instead of purchased certificates from authorities like RapidSSL in order to reduce the out-of-pocket cost of deploying Sovereign and avoid end-user problems with self-signed certificates.

# Design approach

The Let's Encrypt service uses DNS to look up domains being registered and then contact the client to verify. For this to work, DNS records must be configured before the playbook is run the first time.

A single certificate is created using Let's Encrypt with SANs used for the subdomains.  At deploy-time, a script is used to query DNS for known subdomains, build a list of the subset that is registered, and use it when making the certificate request of Let's Encrypt.

Several packages need access to the private key. Not all are run as root. An example is Prosody (XMPP). Such users are added to the ssl-cert group, and /etc/letsencrypt is set up to allow keys to be read by ssl-cert.

Certificate renewal is done automatically using cron. The cron script must be aware of private key copies and update them as well. Services that depend on new keys must also be bounced. It is up to roles that rely on keys to modify the cron script (preferably using `lineinfile` or something similar) to accomplish this.

If you changed something that requires new domains or subdomains to be considered when generating the certificates, do not just delete the files in /etc/letsencrypt/live!
Instead, use 'sudo certbot delete -c /etc/letsencrypt/cli.conf --cert-name DOMAIN' to remove the old certificates and then re-run the sslletsencrypt role in this playbook.
