#!/bin/bash
# NPSTN NA v3 20210210: supports #include recursion
file=$2
if [ "$2" == "" ]
then
	file='/etc/asterisk/sip.conf'
fi
context=`awk -v RS='[' '/'$1'/{gsub(/[]]/, "", $1); print $1}' $file`
x=`echo -n "${context}" | cut -f1 -d"("`
if [ "$x" == "" ]
then
	thisscript="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
	thisscript="$thisscript/sipcontext.sh"
	files=`grep "#include" $file | cut -c 10-` # only files in /etc/asterisk/ are officially supported
	for recfile in $files
	do
		if [ "${recfile:0:1}" != "/" ]
		then
			recfile="/etc/asterisk/$recfile" # if not an absolute path, make it one, relative to sip.conf
		fi
		z=`$thisscript $1 $recfile` # recursively process sip #include files as well
		if [ "$z" != "" ]
		then
			printf '%s' $z
			break
		fi
	done
else
	printf '%s' $x
fi
