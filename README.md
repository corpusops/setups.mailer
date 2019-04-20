# antispam filtering gateway using ansible, docker & mailu

- This mainly uses under the hood postfix, dovecot, rspamd.
    - See [mailu](https://mailu.io/)

# Initialise your development environment

All following commands must be run only once at project installation.



## First clone

```sh
git clone --recursive https://gitlab.example.com/corpusops/setups.antispam
```

## Install docker and docker compose

if you are under debian/ubuntu/mint/centos you can do the following:

```sh
.ansible/scripts/download_corpusops.sh
.ansible/scripts/setup_corpusops.sh
```

... or follow official procedures for
  [docker](https://docs.docker.com/install/#releases) and
  [docker-compose](https://docs.docker.com/compose/install/).


## how to use
Read the playbooks, adapt the ansible inv and some ansible variables files, then launch and pray.

```sh
cp base.yml.dist base.yml
cp mydomain.com.yml mycompany.com
vim -O base.yml mycompany.com
.ansible/scripts/download_corpusops.sh
.ansible/scripts/setup_corpusops.sh
.ansible/scripts/call_ansible.sh   -vvvvv -l "prod"  -e "{cops_vars_debug: true}"  .ansible/playbooks/app.yml  -e @local/base.yml -e @local/mycompany.yml
```

