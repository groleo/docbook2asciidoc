#! /bin/bash

usage()
{
cat << EOF
usage: $0 OPTIONS

This script allows primitive batching of docbook to asciidoc conversion

OPTIONS:
   -s      Source directory to scan for files [default:\$PWD]
   -x      Extension of files to convert [default:'xml']
   -o      Output extension [default:'asciidoc']
   -O      Output directory [default:'output']
   -r      Enable recusive scanning [default:not recursive]
   -F      Source file to scan
   -T      Target file to output
   -H      proxy Host
   -P      proxy Port

   -h      Shows this message
EOF
}


convert_file() {
    input=$1
    output=$2
    echo "Processing $input -> $output"
    java $PROXY -jar $DIR/saxon9he.jar -s $input -o $output $DIR/d2a.xsl
    fname=$(basename $input)
    dname=$(dirname $output)
    mv $dname/book-docinfo.xml $dname/${fname%.*}-docinfo.xml
}

convert_dir()
{
  CMD="find $SCAN_DIR -name *.$EXT"
  if [ $RECURSE == "0" ]; then
    CMD="find $SCAN_DIR -maxdepth 2 -name *.$EXT"
  fi
  mkdir -p $OUT_DIR

  for xml in `$CMD` ; do
    convert_file $xml $OUT_DIR/`basename ${xml/.$EXT/.$OEXT}`
    echo
  done
}

if [ $# -eq 0 ]; then
  usage
  exit 0
fi

PROXY_HOST=
PROXY_PORT=
FROM=
TO=
DIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
SCAN_DIR=`pwd`
RECURSE="0"
EXT="xml"
OEXT="asciidoc"
OUT_DIR="output"

while getopts “hrx:o:s:O:H:P:F:T:” OPTION

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
         F)
            FROM=$OPTARG
           ;;
         T)
            TO=$OPTARG
           ;;
         [?])
             usage
             exit
             ;;
     esac
done

if [ -n "$PROXY_HOST" -a -n "$PROXY_PORT" ]; then
    PROXY="-Dhttp.proxyHost=$PROXY_HOST -Dhttp.proxyPort=$PROXY_PORT"
fi
convert_file $FROM $TO
#convert_dir
