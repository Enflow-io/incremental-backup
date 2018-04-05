#!/bin/bash
# ------------------------------------------------------------------
# [Enflow.io] Backepr
#          Description
#          in OSX you may need: brew install gnu-tar --with-default-names

# ------------------------------------------------------------------

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
    tar \
        --create \
        --no-check-device \
        --file=./snapshots/`date +%s`.tar \
        --listed-incremental=./snapshots/index \
        --verbose \
        ./to_backup
}

function command_restore() {
    UPTO="$param.tar"
    #UPTO="1522934331.tar"
    for a in `ls -1 ./snapshots/*.tar` 
    do 
    tar \
            --extract \
            --listed-incremental=./snapshots/index \
            --file=$a \
            --directory=./restored

    # echo $a
    # echo ./snapshots/${UPTO}
    if [ $a == ./snapshots/${UPTO} ]
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