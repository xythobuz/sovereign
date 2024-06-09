# Sovereign

Forked from [Sovereign on GitHub](https://github.com/sovereign/sovereign).
This is a set of ansible roles to setup your own little private Cloud on a VPS.

I removed a bunch of roles from the upstream version, added new ones, and made it compatible with more recent versions of Debian.
Ubuntu is no longer supported, simply because I just use Debian.

I also added the ability for full-fledged user-management using OpenLDAP and FusionDirectory.
It automatically creates E-Mail inboxes for LDAP users, as well as allowing login using LDAP credentials on most roles / services.
This is optional, however.
You can also use statically configured credentials, which is enough for single-user setups.

| Program       | Domain     | Status | Debian 9 | Debian 10 | Debian 11 | LDAP Auth |
| ------------- | ---------- | ------ | -------- | --------- | --------- | --------- |
| Website       | www        | ✔️      | ✔️        | ✔️         | ✔️         | N/A       |
| Lets Encrypt  | -          | ✔️      | ✔️        | ✔️         | ✔️         | N/A       |
| Webmail       | mail       | ✔️      | ✔️        | ✔️         | ✔️         | ❓        |
| E-Mail Config | autoconfig | ✔️      | ✔️        | ✔️         | ✔️         | N/A       |
| monit         | status     | ✔️      | ✔️        | ✔️         | ✔️         | ❌        |
| OpenVPN       | -          | ✔️      | ✔️        | ❓        | ❓        | ❓        |
| Fathom        | stats      | ✔️      | ✔️        | ✔️         | ✔️         | ❌        |
| commento      | comments   | ✔️      | ✔️        | ✔️         | ✔️         | ❓        |
| ZNC           | -          | ✔️      | ✔️        | ❓        | ❓        | ❓        |
| gitea         | git        | ✔️      | ✔️        | ✔️         | ✔️         | ❓        |
| dokuwiki      | wiki       | ✔️      | ❓       | ✔️         | ✔️         | ✔️         |
| kanboard      | kanboard   | ✔️      | ❓       | ✔️         | ✔️         | ✔️         |
| jitsi         | jitsi      | ✔️      | ❓       | ✔️         | ✔️         | ✔️         |
| rocket.chat   | chat       | ❓     | ❓       | ✔️         | ❓        | ❓        |
| NextCloud     | cloud      | ✔️      | ✔️        | (❓)      | ✔️         | ✔️         |
| LimeSurvey    | survey     | ✔️      | (❓)     | ✔️         | ✔️         | ❓        |
| matrix / riot | matrix     | ❌     | ✔️        | ❓        | ❓        | ❓        |
| mastodon      | social     | ❌     | ✔️        | ❓        | ❓        | ❓        |
| LDAP          | users      | ❓     | ❓       | ❓        | ✔️         | ✔️         |
| Self-Signed   | -          | ✔️      | ❓       | ✔️         | ❓        | N/A       |
| grafana       | iot        | ✔️      | ❓       | ✔️         | ❓        | ❓        |
| Selfoss       | news       | ❌     | ✔️        | ❓        | ❓        | ❓        |
| gPodder       | gpodder    | ✔️     | ❓        | ❓        | ✔️        | ❌        |

You don't have to setup all roles, simply select the subset you require.
Please take a look inside the respective folders of the roles, they often contain a `DESIGN.md` file explaining the intricacies of the specific software or its configuration.

# Usage

## Installation

### On the remote server

Install dependencies and change the root password:

    apt-get install sudo python
    passwd

Create a user account for Ansible to do its thing through:

    useradd deploy
    passwd deploy
    mkdir /home/deploy

Authorize your ssh key if you want passwordless ssh login (optional):

    mkdir /home/deploy/.ssh
    chmod 700 /home/deploy/.ssh
    nano /home/deploy/.ssh/authorized_keys
    chmod 400 /home/deploy/.ssh/authorized_keys
    chown deploy:deploy /home/deploy -R

Or, in short:

    ssh-copy-id -i ~/.ssh/id_ecdsa deploy@hostname

Also, enable passwordless sudo for the deploy user:

    echo 'deploy ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/deploy

Your new account will be automatically set up for passwordless `sudo`.
Or you can just add your `deploy` user to the sudo group.

    adduser deploy sudo

### On your local machine

#### Software

Download this repository somewhere on your machine, either through `Clone or Download > Download ZIP` above, `wget`, or `git` as below.
Also install the dependencies for password generation as well as ansible itself.

    git clone https://github.com/xythobuz/sovereign.git
    cd sovereign
    sudo pip install -r ./requirements.txt

Or, if you're on Arch, instead of using pip, install the required stuff manually:

    sudo pacman -Syu ansible python-jmespath python-passlib

#### Configure your installation

Modify the settings in the `group_vars/sovereign` folder to your liking.
If you want to see how they’re used in context, just search for the corresponding string.
All of the variables in `group_vars/sovereign` must be set for sovereign to function.

Finally, replace the `host.example.net` in the file `hosts`.
If your SSH daemon listens on a non-standard port, add a colon and the port number after the IP address.
In that case you also need to add your custom port to the task `Set firewall rules for web traffic and SSH` in the file `roles/common/tasks/ufw.yml`.

#### Set up DNS

Create `A` and `AAAA` or `CNAME` records which point to your server's IP address for the subdomains used with the programs you selected.

#### Run the Ansible Playbooks

To run the whole thing:

    ansible-playbook -i ./hosts --ask-sudo-pass --key-file KEY site.yml

If you chose to make a passwordless sudo deploy user, you can omit the `--ask-sudo-pass` argument.
If you don't need to specify an ssh key to connect to the host, leave out `--key-file KEY` part, otherwise replace `KEY` with the path to the key you want to use.
Append eg. `-l testing` to only run for the hosts in the testing group.

#### Finish DNS set-up

Create an `MX` record for `example.com` which assigns `mail.example.com` as the domain’s mail server.
To ensure your emails pass DKIM checks you need to add a `txt` record.
The name field will be `mail._domainkey.EXAMPLE.COM.`
The value field contains the public key used by DKIM.
The exact value needed can be found in the file `/var/lib/rspamd/dkim/EXAMPLE.COM.mail.txt`.
For DMARC you'll also need to add a `txt` record.
The name field should be `_dmarc.EXAMPLE.COM` and the value should be `v=DMARC1; p=reject`.
We will also add a `txt` record for SPF. This is now legacy, but some providers need it, so we provide an empty policy.

For my DNS provider, that zonefile looks like this:

    @               IN MX 10 mail
    @               IN TXT   "v=spf1 a:mail.example.com ?all"
    _dmarc          IN TXT   "v=DMARC1; p=reject;"
    mail._domainkey IN TXT   "v=DKIM1; k=rsa; p=INSERT_PUBLIC_KEY_HERE"

Correctly set up reverse DNS for your server and make sure to validate that it’s all working,
for example by sending an email to <a href="mailto:check-auth@verifier.port25.com">check-auth@verifier.port25.com</a>
and reviewing the report that will be emailed back to you.

#### Miscellaneous Configuration

Sign in to the ZNC web interface and set things up to your liking.
It isn’t exposed through the firewall, so you must first set up an SSH tunnel:

    ssh deploy@example.com -L 6643:localhost:6643

Then proceed to http://localhost:6643 in your web browser.
The same goes for the RSpamD web interface on port 11334.

To access the gitea admin CLI, execute it like this:

    sudo -u git /usr/local/bin/gitea admin create-user --admin --config /etc/gitea/app.ini --name USERNAME --password PASSWORD --email MAIL

To re-new the LetsEncrypt certificates, for example after adding a new role that needs another subdomain, call:

    sudo certbot delete -c /etc/letsencrypt/cli.conf --cert-name DOMAIN

Then re-run the whole sovereign playbook, or at least the letsencrypt part of it.

To access your Postgres database, use:

    sudo -u postgres psql

Then use commands like `\l`, `\c database`, `\dt` or SQL statements.
