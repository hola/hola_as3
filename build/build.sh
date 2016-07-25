#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -z "$FLEXPATH" ]; then
    FLEXPATH=$DIR/sdks/apache-flex-sdk-4.14.1-bin
fi

cd $DIR

VERSION="0.0.14"
OPT="-use-network=false -optimize=true \
    -define=CONFIG::HOLA_AS3_VERSION,"\"$VERSION\"""

function make()
{
    local output=$1 opt=$2
    echo "Compiling $output"
    $FLEXPATH/bin/compc $opt \
        -include-sources ../src/org/hola \
        -output $output \
        -swf-version=15
}

make "../bin/debug/hola_as3_$VERSION.swc" "$OPT -debug=true"
make "../bin/release/hola_as3_$VERSION.swc" "$OPT"
