#!/bin/bash

############
## params ##
############

BASEDIR=`echo $(cd $(dirname $0) && pwd)`
. ${BASEDIR}/env
. ${BASEDIR}/api-key
. ${BASEDIR}/pattern/color
. ${BASEDIR}/pattern/mode
. ${BASEDIR}/pattern/period
. ${BASEDIR}/pattern/ack
. ${BASEDIR}/pattern/repeat
. ${BASEDIR}/pattern/json
. ${BASEDIR}/pattern/speak
PRE_ERROR_FLAG=0

##############
## dir/file ##
##############

LOGDIR=${BASEDIR}/logs
LOGFILE=${LOGDIR}/mackerel-alerts-${NOWTIME}.log

##################
## function pre ##
##################

function get-mackerel-alerts() {
  rm -f ${LOGDIR}/*
  curl --connect-timeout ${CURL_TIMEOUT} -H "X-Api-Key:$APIKEY" "$MACKERELAPI/alerts" | python3 -m json.tool | tee ${LOGFILE} 1>&2
  echo "${PIPESTATUS[0]}"
}

function check-mackerel() {
  error_count=`cat ${LOGFILE} | grep -e '\"error\"' | wc -l`
  echo $error_count
}

#########
## pre ##
#########

function pre() {
  # check curl
  check_curl=`get-mackerel-alerts`
  if [ $check_curl -ne 0 ]; then
    PRE_ERROR_FLAG=1
    COLOR=${COLOR_ERROR_CURL}
    SPEAK=${SPEAK_ERROR_CURL}
    # debug log
    echo "error curl detection."
    echo "check_curl=$check_curl"
    return
  fi
  # check mackerel
  check_mackerel=`check-mackerel`
  if [ $check_mackerel -ne 0 ]; then
    PRE_ERROR_FLAG=1
    COLOR=${COLOR_ERROR_MACKEREL}
    SPEAK=${SPEAK_ERROR_MACKEREL}
    # debug log
    echo "error mackerel detection."
    echo "check_mackerel=$check_mackerel"
    return
  fi
}

###################
## function main ##
###################

function check-mackerel-alert-status() {
  # count without OK
  STATUS="OK"
  count=`cat ${LOGFILE} | grep -e '\"status\"' | grep -v "${STATUS}" | wc -l`
  # normal color and mode
  if [ $count -eq 0 ]; then
    COLOR=${COLOR_OK}
    MODE=${MODE_ON}
    SPEAK=${SPEAK_OK}
  else
    # error mode and period
    if [ $count -ge $TH ]; then
      MODE=${MODE_FLASH}
      PERIOD=`expr $PERIOD_BASE / $TH`
    else
      MODE=${MODE_FLASH}
      PERIOD=`expr $PERIOD_BASE / $count`
    fi
    # error color
    SPEAK="${SPEAK_ERROR}"
    STATUS="UNKNOWN"
    count=`cat ${LOGFILE} | grep -e '\"status\"' | grep -e "${STATUS}" | wc -l`
    if [ $count -ne 0 ]; then
      COLOR=${COLOR_UNKNOWN}
      SPEAK="${SPEAK_ERROR_UNKNOWN}_${count}${SPEAK_ERROR_UNIT}_${SPEAK}_"
    fi
    STATUS="WARNING"
    count=`cat ${LOGFILE} | grep -e '\"status\"' | grep -e "${STATUS}" | wc -l`
    if [ $count -ne 0 ]; then
      COLOR=${COLOR_WARNING}
      SPEAK="${SPEAK_ERROR_WARNING}_${count}${SPEAK_ERROR_UNIT}_${SPEAK}_"
    fi
    STATUS="CRITICAL"
    count=`cat ${LOGFILE} | grep -e '\"status\"' | grep -e "${STATUS}" | wc -l`
    if [ $count -ne 0 ]; then
      COLOR=${COLOR_CRITICAL}
      SPEAK="${SPEAK_ERROR_CRITICAL}_${count}${SPEAK_ERROR_UNIT}_${SPEAK}"
    fi
    SPEAK="${TEAM_NAME}_${TEAM_NAME}_${SPEAK}"
  fi
}

##########
## main ##
##########

function main() {
  # check pre error flag
  if [ $PRE_ERROR_FLAG -ne 0 ]; then
    return
  fi
  # check mackerel alert status
  check-mackerel-alert-status
}

###################
## function post ##
###################

function led() {
  if [ -f ${BASEDIR}/voiceoff ];then
    MODE=${MODE_FLASH}
    SPEAK=""
  fi
  # curl to led
  curl "$ALERTPIAPI/?mode=${MODE}&color=${COLOR}&repeat=${REPEAT}&period=${PERIOD}&ack=${ACK}&json=${JSON}&speak=${SPEAK}" | python3 -m json.tool
  # debug log
  echo "MODE=${MODE}"
  echo "COLOR=${COLOR}"
  echo "REPEAT=${REPEAT}"
  echo "PERIOD=${PERIOD}"
  echo "ACK=${ACK}"
  echo "JSON=${JSON}"
  echo "SPEAK=${SPEAK}"
}

##########
## post ##
##########

function post() {
  led
}

#########
## run ##
#########

pre
main
post

exit 0
