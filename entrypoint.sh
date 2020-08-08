#!/bin/sh

function usage() {
  echo "usage : [cmd] -t GIT_TOKEN -u ORG/USER_NAME [-m mode] [-h]"
  echo ' -t: scm token to clone with'
  echo ' -u: user name'
  echo ' -o: organization name'
  echo ' -s: type of scm used, github, gitlab or bitbucket (default github)'
  echo ' -b: branch left checked out for each repo cloned (default master)'
}

function checkuser() {
      if [[ ! -z ${USER} ]];then
        echo "Only set username or organization name"
        exit 1
      fi
}

TOKEN=
USER=
MODE=
SERVICE=github
BRANCH=master
while getopts ":t:u:o:m:s:ht" opt; do
  case ${opt} in
    t)
      TOKEN=${OPTARG}
      ;;
    u)
      checkuser
      USER=${OPTARG}
      MODE=user
      ;;
    o)
      checkuser
      USER=${OPTARG}
      MODE=org
      ;;
    s)
      SERVICE=${OPTARG}
      ;;
    b)
      BRANCH=${OPTARG}
      ;;
    h)
      usage
      exit 0
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage
      exit 1
      ;;
  esac
done

if [ -z "${TOKEN}" ]; then
  echo "require -t TOKEN"
  exit 1
fi

if [ -z "${USER}" ]; then
  echo "require -u or -o"
  exit 1
fi

ghorg clone "${USER}" -t "${TOKEN}" -c "${MODE}" -s "${SERVICE}" -b "${BRANCH}"  -p /root/git

for f in `\find /root/git/ -type d -name ".git"`; do
  echo "Start scanning ${f%/.git}"
  shhgit -local ${f%/.git}
done