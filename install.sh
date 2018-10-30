#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage: $0 <mackerel-api-key> <team-name>"
    exit 1
fi

INPUT_APIKEY=$1
TEAM_NAME="$2チーム"

BASEDIR=`echo $(cd $(dirname $0) && pwd)`
SCRIPTDIR="/var/lib/crystal-signal"

if [ ! -d ${BASEDIR}/logs ];then
  mkdir ${BASEDIR}/logs
fi

cat << EOF > ${BASEDIR}/api-key
############
# api-key ##
############

APIKEY="${INPUT_APIKEY}"
TEAM_NAME="${TEAM_NAME}"
EOF

sudo cat << EOF > ${BASEDIR}/init/VoiceOff.sh
#!/bin/bash
touch ${BASEDIR}/voiceoff
chown pi:pi ${BASEDIR}/voiceoff
${BASEDIR}/run.sh
EOF

sudo cat << EOF > ${BASEDIR}/init/VoiceOn.sh
#!/bin/bash
rm -f ${BASEDIR}/voiceoff
${BASEDIR}/run.sh
EOF

sudo \cp -f ${BASEDIR}/init/VoiceOff.sh ${SCRIPTDIR}/scripts/VoiceOff.sh
sudo \cp -f ${BASEDIR}/init/VoiceOn.sh ${SCRIPTDIR}/scripts/VoiceOn.sh
sudo \cp -f ${BASEDIR}/init/ScriptSettings.json ${SCRIPTDIR}
sudo \cp -f ${BASEDIR}/init/Settings.json ${SCRIPTDIR}

sudo chmod 755 ${SCRIPTDIR}/scripts/VoiceOff.sh
sudo chmod 755 ${SCRIPTDIR}/scripts/VoiceOn.sh

cat ${BASEDIR}/api-key
sudo cat ${SCRIPTDIR}/scripts/VoiceOff.sh
sudo cat ${SCRIPTDIR}/scripts/VoiceOn.sh
sudo cat ${SCRIPTDIR}/ScriptSettings.json
sudo cat ${SCRIPTDIR}/Settings.json

(crontab -l; echo "*/1 * * * * ${BASEDIR}/run.sh > /dev/null 2>&1") | sort | uniq | crontab -

crontab -l
