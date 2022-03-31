#!/bin/bash

BACKEND="http://rtihardware.homelinux.com/ostools/ostools-1.17"
OS="$1"

[ "$1" == "" ] && echo "Specify OS." && exit 1
[ "$2" == "" ] && echo "Specify script name, or \"stage\"." && exit 1

if [ "$2" == "stage" ]
then
for script in `curl -ls $BACKEND/$OS/stage/ | sed 's/<a\ href=/~/g'  | grep -v colspan | cut -d~ -f2 | cut -d\" -f2 | grep -v \< | grep -v \/ | grep -v ^?`
do
  echo "Running $script ..."
  timestamp=`date +%Y%m%d%H%M%S`
  curl -s $BACKEND/$OS/stage/$script -o /tmp/.${script}.${timestamp}.tmp
  chmod +x /tmp/.${script}.${timestamp}.tmp
  /tmp/.${script}.${timestamp}.tmp 2>/dev/null
  [ "$?" != "0" ] && echo "Failed." && echo "" && exit 1
  echo "Success."
  echo ""
  rm -f /tmp/.${script}.${timestamp}.tmp
done
else
echo "Running $2 ..."
  curl -s $BACKEND/$OS/$2 -o /tmp/.${script}.${timestamp}.tmp
  chmod +x /tmp/.${script}.${timestamp}.tmp
  /tmp/.${script}.${timestamp}.tmp $3 $4 $5 $6 $7 2>/dev/null
  [ "$?" != "0" ] && echo "Failed." && echo "" && exit 1
  echo "Success."
  echo ""
  rm -f /tmp/.${script}.${timestamp}.tmp
fi
