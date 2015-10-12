#!/bin/bash
if [ -z "$FLEXPATH" ]; then
    FLEXPATH=sdks/apache-flex-sdk-4.14.1-bin
fi

cd $(dirname $(realpath $0))

VERSION="0.0.3"

_OPT_DEBUG="-use-network=false -debug=true -optimize=true \
    -define=CONFIG::HOLA_AS3_VERSION,"\"$VERSION\"""
OPT_DEBUG="$_OPT_DEBUG -define=CONFIG::HAVE_WORKER,false"
OPT_DEBUG_WORKERS="$_OPT_DEBUG -define=CONFIG::HAVE_WORKER,true"

_OPT_RELEASE="-use-network=false -optimize=true
    -define=CONFIG::HOLA_AS3_VERSION,"\"$VERSION\"""
OPT_RELEASE="$_OPT_RELEASE -define=CONFIG::HAVE_WORKER,false"
OPT_RELEASE_WORKERS="$_OPT_RELEASE -define=CONFIG::HAVE_WORKER,true"

function make()
{
    local output=$1 opt=$2 swf_version=$3
    echo "Compiling $output"
    $FLEXPATH/bin/compc $opt \
        -include-sources ../src/org/hola \
        -output $output \
        -swf-version=$swf_version
}

make "../bin/debug/hola_as3_$VERSION.swc" "$OPT_DEBUG" 15
make "../bin/release/hola_as3_$VERSION.swc" "$OPT_RELEASE" 15
make "../bin/debug/hola_as3_workers_$VERSION.swc" "$OPT_DEBUG_WORKERS" 18
make "../bin/release/hola_as3_workers_$VERSION.swc" "$OPT_RELEASE_WORKERS" 18
