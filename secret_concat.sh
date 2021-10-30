#!/bin/bash

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
PREFIX="secret"

cd $SCRIPTPATH/secret

for dir in */ ; do
    [ -L "${d%/}" ] && continue

    echo "Processing ${dir%/}"

    echo "${dir%/} Passwords" > $PREFIX-${dir%/}
    echo >> $PREFIX-${dir%/}

    for file in $dir* ; do
        [ -L "$file" ] && continue
        [ -d "$file" ] && continue

        echo -n "${file#"$dir"}: " >> $PREFIX-${dir%/}
        cat $file >> $PREFIX-${dir%/}
    done
done
