#!/bin/bash

CMDNAME=`basename $0`

PRE_IFS=$IFS
IFS=$'\n'

while getopts p:t: OPT
do
  case $OPT in
    "p" ) FLG_PROJECT="TRUE" ; PROJECT_NAME="$OPTARG" ;;
      * ) echo "Usage: $CMDNAME [-p PROJECT_NAME]" 1>&2
          exit 1 ;;
  esac
done

if [ "$FLG_PROJECT" = "TRUE" ]; then
  echo $PROJECT_NAME
fi

#ターゲット名を取得

echo "Targets:"
TARGET_NAMES=`xcodebuild -project $PROJECT_NAME -list | sed -e '/ Targets/,/^$/!d' -e 's/^ *//g' -e '/^$/d' -e '3,$!d' -e '/Tests$/d'`
for name in ${TARGET_NAMES}
do
  echo $name

  SOURCE_ID=`cat $PROJECT_NAME/project.pbxproj | \
  sed -e '/^\/\* Begin PBXNativeTarget section \*\//,/\/\* End PBXNativeTarget section \*\/$/!d' \
  -e "/\/\* $name \*\//,/};$/!d" \
  -e '/buildPhases = /,/);$/!d' \
  -e '/\/\* Sources \*\//!d' \
  -e 's/\/\* Sources \*\/,//' \
  -e 's/^.\{4\}//g'`

  # echo ${#SOURCE_ID}
  # echo $SOURCE_ID

  #PBXSourcesBuildPhase sectionの取得
  cat $PROJECT_NAME/project.pbxproj \
  | sed -e '/^\/\* Begin PBXSourcesBuildPhase section \*\//,/\/\* End PBXSourcesBuildPhase section \*\/$/!d' \
  -e "/$SOURCE_ID/,/\};/!d" -e "/files/,/);/!d" \
  | sed -e "2,\$!d" -e '$d' -e 's/[0-9A-Z]\{24\} \/\* //g' -e 's/ in Sources \*\/,//g' -e 's/^.\{4\}//g' | sort > "${name}_Compile_Sources.txt"
  echo "-->${name}_Compile_Sources.txt"
done

#PBXNativeTarget sectionの取得




IFS=$PRE_IFS

exit 0
