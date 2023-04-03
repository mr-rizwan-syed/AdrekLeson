#!/bin/bash
#title:         AdrekLeson.sh
#description:   Automated and Modular Shell Script to Automate Security Active Vulnerability Scan
#author:        mr-rizwan-syed
#version:       1.0.1
#==============================================================================
RED=`tput setaf 1`
GREEN=`tput setaf 2`
RESET=`tput sgr0`

function trap_ctrlc ()
{
    echo "Ctrl-C caught...performing clean up"

    echo "Doing cleanup"
    trap "kill 0" EXIT
    exit 2
}

trap "trap_ctrlc" 4


matchandreplace="$(pwd)/MISC/MatchandReplace"
xssparams="$(pwd)/MISC/xssparams.txt"
ssrfparams="$(pwd)/MISC/ssrfparams.txt"


if [ -d $matchandreplace ]
then
	echo -e
	echo -e "[${RED}I${RESET}] MatchandReplace already exists...${RESET}"
else
	git clone https://github.com/Leoid/MatchandReplace.git MISC/MatchandReplace
fi


usage(){
echo "~~~~~~~~~~~"
  echo " U S A G E"
  echo "~~~~~~~~~~~"
  echo "Usage: ./adrekleson.sh [option]"
  echo "  options:"
  echo "    -s    : Specify Colloaborator Host here, This will create ssrfregex.json"
  echo "    -x    : Specify XSS Payload here, This will create xssregex.json"
  echo ""
  exit
}

xsshuntermnr(){
	if [ -n "$xsshunter" ]; then
  		echo XSSSSSSSSSSSS $xsshunter
        	python3 MISC/MatchandReplace/generate.py -f MISC/xssparams.txt -c "Blind XSS Params" --rule "request_param_name" --replace "$xsshunter" -x --output xssregex.json
	fi
}

ssrfcollabmnr(){
        echo SSRFFFFFFFFFF $collabhost

	if [ -n "$collabhost" ]; then
                echo SSRFFFFFFFFFF $collabhost
                python3 MISC/MatchandReplace/generate.py -f MISC/ssrfparams.txt -c "SSRF Params" --rule "request_param_name" --replace "$collabhost" -x --output ssrfregex.json
	fi
}

sendtoproxy(){
	if [[ ${setproxy} == true ]];then
		echo $proxy
		if [ -n "$allurls" ]; then
                	echo $allurls
			parallel -j50 -k curl -k {} --proxy $proxy < $allurls
        	fi
	fi
}

while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      usage
      shift 
      ;;
    -x|--xss)
      xsshunter="$2"
      xsshuntermnr
      shift 
      ;;
    -s|--ssrf)
      collabhost="$2"
      ssrfcollabmnr
      shift
      ;;
    -p|--proxy)
      proxy="$2"
      setproxy=true
      shift
      ;;
    -u|--allurls)
      allurls="$2"
      sendtoproxy
      shift
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift 
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

if [[ -n $1 ]]; then
    usage
fi


