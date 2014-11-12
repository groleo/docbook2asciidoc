#!/bin/bash

REQUIRED_BASH_VERSION=3.0.0
PROXY_HOST=
PROXY_PORT=

if [[ $BASH_VERSION < $REQUIRED_BASH_VERSION ]]; then
  echo "You must use Bash version 3 or newer to run this script"
  exit
fi

DIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

convert()
{
  if [ -n "$PROXY_HOST" -a -n "$PROXY_PORT" ]; then
    PROXY="-Dhttp.proxyHost=$PROXY_HOST -Dhttp.proxyPort=$PROXY_PORT"
  fi
  CMD="find $SCAN_DIR -name *.$EXT"
  if [ $RECURSE == "0" ]; then
    CMD="find $SCAN_DIR -maxdepth 2 -name *.$EXT"
  fi
  mkdir -p $OUT_DIR

  for xml in `$CMD` ; do
    output_filename=$OUT_DIR/`basename ${xml/.$EXT/.$OEXT}`
    echo "Processing $xml -> $output_filename"
    java $PROXY -jar $DIR/saxon9he.jar -s $xml -o $output_filename $DIR/d2a.xsl
    fname=$(basename $xml)
    mv $OUT_DIR/book-docinfo.xml $OUT_DIR/${fname%.*}-docinfo.xml
    echo
  done
}

usage()
{
cat << EOF
usage: $0 options

This script allows primitive batching of docbook to asciidoc conversion

OPTIONS:
   -s      Source directory to scan for files [default:\$PWD]
   -x      Extension of files to convert [default:'xml']
   -o      Output extension [default:'asciidoc']
   -O      Output directory [default:'output']
   -r      Enable recusive scanning [default:not recursive]
   -H      proxy Host
   -P      proxy Port

   -h      Shows this message
EOF
}

trap 'exit 0' SIGINT

if [ $# -eq 0 ]; then
  usage
  exit 0
fi

SCAN_DIR=`pwd`
RECURSE="0"
EXT="xml"
OEXT="asciidoc"
OUT_DIR="output"

while getopts “hrx:o:s:O:H:P:” OPTION

do
     case $OPTION in
         s)
             SCAN_DIR=$OPTARG
             ;;
         h)
             usage
             exit
             ;;
         r)
             RECURSE="1"
             ;;
         x)
             EXT=$OPTARG
             ;;
         o)
             OEXT=$OPTARG
             ;;
         O)
            OUT_DIR=$OPTARG
            ;;
         H)
            PROXY_HOST=$OPTARG
            ;;
         P)
            PROXY_PORT=$OPTARG
           ;;
         [?])
             usage
             exit
             ;;
     esac
done

convert
