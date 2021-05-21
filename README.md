# Sovereign

Forked from [Sovereign on GitHub](https://github.com/sovereign/sovereign).

# Usage

## What You’ll Need

1.  A VPS (or bare-metal server if you wanna ball hard). My VPS is hosted at [Linode](http://www.linode.com/?r=45405878277aa04ee1f1d21394285da6b43f963b). You’ll probably want at least 512 MB of RAM between Apache, Solr, and PostgreSQL. Mine has 1024.
2.  [64-bit Debian 9 or 10](http://www.debian.org/). (You can use whatever distro you want, but deviating from Debian will require more tweaks to the playbooks. See Ansible’s different [packaging](http://docs.ansible.com/ansible/list_of_packaging_modules.html) modules.)

You do not need to acquire an SSL certificate.  The SSL certificates you need will be obtained from [Let's Encrypt](https://letsencrypt.org/) automatically when you deploy your server.

## Installation

### On the remote server

The following steps are done on the remote server by `ssh`ing into it and running these commands.

#### Install required packages

    apt-get install sudo python

#### Prep the server

For goodness sake, change the root password:

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

Ansible (the tool setting up your server) runs locally on your computer and sends commands to the remote server.

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

If you’ve just bought a new domain name, point it at [Linode’s DNS Manager](https://library.linode.com/dns-manager) or similar.
Most VPS services (and even some domain registrars) offer a managed DNS service that you can use for this at no charge.
If you’re using an existing domain that’s already managed elsewhere, you can probably just modify a few records.

Create `A` and `AAAA` or `CNAME` records which point to your server's IP address:

* `example.com`
* `mail.example.com`
* `www.example.com` (for Web hosting)
* `autoconfig.example.com` (for email client automatic configuration)
* `stats.example.com` (for web stats)
* `news.example.com` (for Selfoss)
* `cloud.example.com` (for NextCloud)
* `git.example.com` (for gitea)
* `status.example.com` (for monit)
* `matrix.example.com` (for riot)
* `social.example.com` (for mastodon)
* `comments.example.com` (for commento)
* `iot.example.com` (for grafana)
* `wiki.example.com` (for dokuwiki)

#### Run the Ansible Playbooks

First, make sure you’ve [got Ansible installed](http://docs.ansible.com/intro_installation.html#getting-ansible).
This should already be done by running the pip requirements.txt from above.

To run the whole dang thing:

    ansible-playbook -i ./hosts --ask-sudo-pass site.yml
    
If you chose to make a passwordless sudo deploy user, you can omit the `--ask-sudo-pass` argument.

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

    sudo certbot -c /etc/letsencrypt/cli.conf --cert-name DOMAIN

Then re-run the whole sovereign playbook, or at least the letsencrypt part of it.
