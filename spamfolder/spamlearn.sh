#!/usr/bin/env bash
cd "$(dirname $(readlink -f "$0"))"
if [ "x${SPAM_DEBUG}" != "x" ];then
    set -x
fi
lock=${0}.lock
SPAMFOLDER="${SPAMFOLDER:-$(pwd)/spamf}"
SPAM_FULL=${SPAM_FULL-}
SPAMLEARN_MINUTES="${SPAMLEARN_MINUTES:-120}"
SPAM_SKIP_GET=${SPAM_SKIP_GET-}
SPAMS_FOLDER="${SPAMS_FOLDER:-"$SPAMS_FOLDER/verified_spam"}"
HAMS_FOLDER="${HAMS_FOLDER:-"$HAMS_FOLDER/verified_ham"}"
HOST_ANTISPAM_CLIENT=${HOST_ANTISPAM_CLIENT:-"antispam:11334"}
log() { echo "$@" >&2; }
vv() { log "$@";"$@"; }
source_envs() {
    set -o allexport
    for i in $ENV_FILES;do
        if [ -e "$i" ];then
            eval "$(cat $i\
                | egrep "^([^#=]+)=" \
                | sed   's/^\([^=]\+\)=\(.*\)$/export \1=\"\2\"/g' \
                )"
        fi
    done
    set +o allexport
}
load_env() {
	for e in $@;do if [ -e "$e" ];then source_envs "$e";break;fi;done
}
load_env .env ../.env
load_env docker.env ../docker.env
if ! (ssh -V >/dev/null 2>&1);then
    do_install=1
fi
if ! (rsync --version >/dev/null 2>&1);then
    do_install=1
fi
if ! (rspamc --help >/dev/null 2>&1);then
    do_install=1
fi
if [ "x$do_install" != "x" ];then
    DO_UPDATE=1 /bin/cops_pkgmgr_install.sh \
        openssh-client rsync rspamd-utils rspamd-client
fi
find "${lock}" -type f -mmin +15 -delete 1>/dev/null 2>&1
if [ "x${SPAMDEBUG}" != "x" ];then
    set -x
fi
if [ -e "${lock}" ];then
  echo "Locked ${0}";exit 1
fi
touch "${lock}"
cd "$(dirname "$0")"
if [ x"${SPAM_SKIP_GET}" = "x" ];then
    log "Refreshing spam database from remote"
    vv ./spamget.sh
fi
find_args="-mmin -$SPAMLEARN_MINUTES"
if [ "x$SPAM_FULL" != "x" ];then
    find_args=
fi
if [ -e "$HAMS_FOLDER" ];then
    log "Loading hams from $HAMS_FOLDER in database"
    while read f;do
        rspamc -t 3 -h $HOST_ANTISPAM_CLIENT learn_ham $f
    done < <(find "$HAMS_FOLDER" -type f $find_args )
fi
if [ -e "$SPAMS_FOLDER" ];then
    log "Loading spams from $SPAMS_FOLDER in database"
    while read f;do
        rspamc -t 3 -h $HOST_ANTISPAM_CLIENT learn_spam $f
    done < <(find "$SPAMS_FOLDER" -type f $find_args )
fi
rm -f "${lock}"
