#!/usr/bin/env bash

echo "# Summary"
echo
echo "* [主页](./README.md)"

for PATHMD in $(find -name "*.md" -exec ./.parent_dirs.sh {} \; | sort -n | uniq); do

    # README.md & index.md belongs to current folder
    NAMEMD=${PATHMD##*/}
    if [[ ${NAMEMD} =~ README.*md || ${NAMEMD} == "index.md" || ${NAMEMD} == "SUMMARY.md" ]]; then
        continue
    fi

    # ignore .
    if [[ ${PATHMD} == "." ]]; then
        continue
    fi

    # count indentation # $PATHMD = ./miao/wang/x.md
    TMP1=${PATHMD#./}   # TMP1 = miao/wang/x.md
    TMP2=${TMP1//[^\/]} # TMP2 = //
    INDENT=${#TMP2}     # INDENT = 2

    for (( i=0; i<${INDENT}; i++ )); do
        echo -n "  "
    done

    if [[ -f ${PATHMD} ]]; then
        TITLE=$(head -n 3 "${PATHMD}" | awk '/^# / {$1=""; print substr($0,2); exit;}')
        if [[ -n ${TITLE} ]]; then
            echo "* [${TITLE}](${PATHMD})"
        else
            echo "* [${NAMEMD}](${PATHMD})"
        fi
    elif [[ -f ${PATHMD}/index.md ]]; then
        echo "* [${NAMEMD}](${PATHMD}/index.md)"
    elif [[ -f ${PATHMD}/README.md ]]; then
        echo "* [${NAMEMD}](${PATHMD}/README.md)"
    else
        echo "* [${NAMEMD}]()"
    fi
done
