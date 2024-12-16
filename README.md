# antispam filtering gateway using ansible, docker & mailu

DISCLAIMER
============

**UNMAINTAINED/ABANDONED CODE / DO NOT USE**

Due to the new EU Cyber Resilience Act (as European Union), even if it was implied because there was no more activity, this repository is now explicitly declared unmaintained.

The content does not meet the new regulatory requirements and therefore cannot be deployed or distributed, especially in a European context.

This repository now remains online ONLY for public archiving, documentation and education purposes and we ask everyone to respect this.

As stated, the maintainers stopped development and therefore all support some time ago, and make this declaration on December 15, 2024.

We may also unpublish soon (as in the following monthes) any published ressources tied to the corpusops project (pypi, dockerhub, ansible-galaxy, the repositories).
So, please don't rely on it after March 15, 2025 and adapt whatever project which used this code.




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

