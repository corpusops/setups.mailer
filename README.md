DISCLAIMER - ABANDONED/UNMAINTAINED CODE / DO NOT USE
=======================================================
While this repository has been inactive for some time, this formal notice, issued on **December 10, 2024**, serves as the official declaration to clarify the situation. Consequently, this repository and all associated resources (including related projects, code, documentation, and distributed packages such as Docker images, PyPI packages, etc.) are now explicitly declared **unmaintained** and **abandoned**.

I would like to remind everyone that this project’s free license has always been based on the principle that the software is provided "AS-IS", without any warranty or expectation of liability or maintenance from the maintainer.
As such, it is used solely at the user's own risk, with no warranty or liability from the maintainer, including but not limited to any damages arising from its use.

Due to the enactment of the Cyber Resilience Act (EU Regulation 2024/2847), which significantly alters the regulatory framework, including penalties of up to €15M, combined with its demands for **unpaid** and **indefinite** liability, it has become untenable for me to continue maintaining all my Open Source Projects as a natural person.
The new regulations impose personal liability risks and create an unacceptable burden, regardless of my personal situation now or in the future, particularly when the work is done voluntarily and without compensation.

**No further technical support, updates (including security patches), or maintenance, of any kind, will be provided.**

These resources may remain online, but solely for public archiving, documentation, and educational purposes.

Users are strongly advised not to use these resources in any active or production-related projects, and to seek alternative solutions that comply with the new legal requirements (EU CRA).

**Using these resources outside of these contexts is strictly prohibited and is done at your own risk.**

This project has been transfered to Makina Corpus <freesoftware-corpus.com> ( https://makina-corpus.com ). This project and its associated resources, including published resources related to this project (e.g., from PyPI, Docker Hub, GitHub, etc.), may be removed starting **March 15, 2025**, especially if the CRA’s risks remain disproportionate.

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

