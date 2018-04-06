#!/bin/bash
# ------------------------------------------------------------------
# [Enflow.io] Backepr
#          Description
#          in OSX you may need: brew install gnu-tar --with-default-names

# ------------------------------------------------------------------


# Settings

# What to backup
# Ex: TO_BACKUP="$HOME/some-path", TO_BACKUP=~/path
TO_BACKUP="$HOME/test-inc-backup/to_backup"
WHERE_TO_BACKUP="${TO_BACKUP}/../backup"
SNAPSHOTS="${WHERE_TO_BACKUP}/snapshots"
INDEX="${SNAPSHOTS}/index"

WHERE_TO_RESTORE="${WHERE_TO_BACKUP}/../restored"

# /Settigns


SUBJECT="Enflow.io backup script"
VERSION=0.1.0
USAGE="Usage: ./backuper backup \
  ./backuper restore 1522936382
"

# --- Option processing --------------------------------------------
while getopts ":vh" optname
  do
    case "$optname" in
      "v")
        echo "Version $VERSION"
        exit 0;
        ;;
      "h")
        echo $USAGE
        exit 0;
        ;;
      "?")
        echo "Unknown option $OPTARG"
        exit 0;
        ;;
      ":")
        echo "No argument value for option $OPTARG"
        exit 0;
        ;;
      *)
        echo "Unknown error while processing options"
        exit 0;
        ;;
    esac
  done

shift $(($OPTIND - 1))

cmd=$1
param=$2
command="command_$1"

# -----------------------------------------------------------------
LOCK_FILE=/tmp/${SUBJECT}.lock

if [ -f "$LOCK_FILE" ]; then
echo "Script is already running"
exit
fi

# -----------------------------------------------------------------
trap "rm -f $LOCK_FILE" EXIT
touch $LOCK_FILE 

# -----------------------------------------------------------------
function command_backup {
    mkdir -p $SNAPSHOTS
    tar \
        --create \
        --no-check-device \
        --file=${SNAPSHOTS}/`date +%s`.tar \
        --listed-incremental=$INDEX \
        --verbose \
        $TO_BACKUP

    echo 'Backup is done!'
}

function command_restore() {
    UPTO="$param.tar"
    mkdir -p $WHERE_TO_RESTORE
    for a in `ls -1 $SNAPSHOTS/*.tar` 
    do 
        tar \
                --extract \
                --listed-incremental=$INDEX \
                --file=$a \
                --directory=$WHERE_TO_RESTORE

        # [ $a == "${SNAPSHOTS}/${UPTO}" ] && BOOL=0 || BOOL=1
        # echo $BOOL
        if [ $a == "$SNAPSHOTS/${UPTO}" ]
        then
        break
        fi
    done

}

# -----------------------------------------------------------------
# -----------------------------------------------------------------
if [ -n "$(type -t ${command})" ] && [ "$(type -t ${command})" = function ]; then 
   ${command}
else 
   echo "'${cmd}' is NOT a command"; 
fi