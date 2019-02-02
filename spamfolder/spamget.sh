#!/usr/bin/env bash
cd "$(dirname $(readlink -f "$0"))"
if [ "x${SPAM_DEBUG}" != "x" ];then
    set -x
fi
SPAM_SKIP_COLLECT=${SPAM_SKIP_COLLECT-}
SPAMCOLLECT_USER=${SPAMCOLLECT_USER:-spamcollect}
SPAMCOLLECT_HOST=${SPAMCOLLECT_HOST:-}
SPAMCOLLECT_SCRIPT=${SPAMCOLLECT_SCRIPT:-/root/spamcollect.sh}
SPAMCOLLECT_PATH=${SPAMCOLLECT_PATH:-/data/spamcollect}
SPAMFOLDER="${SPAMPROGRAM_PATH:-$(pwd)/spamf}"
SPAMPROGRAM_USER=${SPAMPROGRAM_USER:-root}
SPAMPROGRAM_GROUP=${SPAMPROGRAM_GROUP:-root}
ssh_opts="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
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
cd "$(dirname "$0")"
if [ ! -e "$SPAMFOLDER" ];then
    mkdir -p "$SPAMFOLDER"
fi
if [[ -z $SPAMCOLLECT_HOST ]];then
    echo "no SPAMCOLLECT_HOST"
    exit 1
fi
chown ${SPAMPROGRAM_USER}:${SPAMPROGRAM_GROUP} $SPAMFOLDER
chmod 755 $SPAMFOLDER
if [ x"${SPAM_SKIP_COLLECT}" = "x" ];then
    vv ssh $ssh_opts \
        "$SPAMCOLLECT_USER@$SPAMCOLLECT_HOST" \
        sudo "$SPAMCOLLECT_SCRIPT"
fi
for j in custom_rules ham verified_ham verified_spam;do
    i=${SPAMFOLDER}/$j
    vv rsync -az --delete -e "ssh $ssh_opts"\
        "$SPAMCOLLECT_USER@$SPAMCOLLECT_HOST:$SPAMCOLLECT_PATH/$j/" \
        "${i}.raw/"
    chown -Rf ${SPAMPROGRAM_USER}:${SPAMPROGRAM_GROUP} "${i}.raw"
    set +x
    while read f;do
        bf=$(basename $f)
        fd="$i/${bf}"
        if [ ! -e "$i" ];then mkdir "$i";fi
        if [ ! -e "$fd" ];then
            log "Generating $fd"
            cat "$f" | sed \
                -e "/X-Spam-Flag:/d"        \
                -e "/X-Spam-Score:/d"       \
                -e "/X-Spam-Level:/d"       \
                -e "/X-Spam-Status:/d"      \
             -r -e "s/.?.?.?Spam.?.?.?//Ig" > "$fd"
        fi
    done < <( find "${i}.raw" -type f )
    while read f;do
        bf=$(basename $f)
        if [ ! -e "$i.raw/$bf" ];then rm -f "$bf" "$i.raw/$bf";fi
    done < <( find "${i}" -type f )
    if [ "x${SPAM_DEBUG}" != "x" ];then
        set -x
    fi
done
while read i;do chmod -Rf 755 $i;done < <(find $SPAMFOLDER      -type d)
while read i;do chmod -Rf 644 $i;done < <(find $SPAMFOLDER -not -type d  -and -not -perm 0644)
