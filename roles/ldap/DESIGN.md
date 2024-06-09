# LDAP

- Run this role

- Execute `sudo fusiondirectory-setup --check-ldap`
    - Answer Y, Y, admin, {{ slapd_admin_password }}, Y

- Now go to users.DOMAIN and the setup wizard should run

- Go through it and do everything it wants.

- When done, it gives you a configuration file. This should be equivalent
  to the one already on the system as .bak. So just run this command, or upload again:
  `sudo mv /etc/fusiondirectory/fusiondirectory.conf.bak /etc/fusiondirectory/fusiondirectory.conf`

- You can now login as the admin user you created.

To setup Nextcloud LDAP login, give it the following credentials:

    Username: uid=admin,ou=people,dc=DOMAIN,dc=TLD
    Password: {{ slapd_admin_password }}
    Base DN: dc=DOMAIN,dc=TLD

For LimeSurvey, use these settings:



Dokuwiki, Gitea, Jitsi and Kanboard can be configured to use LDAP automatically.
See their defaults.

## ToDo

These two steps are currently missing for full automation of the FusionDirectory Setup.

-----

Add required object classes to the LDAP base
Current

dn: dc=DOMAIN,dc=TLD
objectClass: top
objectClass: dcObject
objectClass: organization


After migration

dn: dc=DOMAIN,dc=TLD
objectClass: top
objectClass: dcObject
objectClass: organization
xxx  objectClass: gosaDepartment
xxx  ou: DOMAIN
xxx  description: DOMAIN

-----

Default ACL roles have been inserted

## Reset

To start from a fresh state:

    sudo apt-get remove slapd fusiondirectory
    echo PURGE | sudo debconf-communicate slapd
    sudo rm -rf /etc/fusiondirectory/fusiondirectory.conf
    sudo rm -rf /etc/ldap/slapd.d
    sudo rm -rf /var/backups/slapd*
    sudo rm -rf /var/lib/ldap/data.mdb
    sudo rm -rf /var/lib/ldap/lock.mdb
