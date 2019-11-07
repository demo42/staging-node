#!/bin/sh
echo BACKGROUND_COLOR: ${BACKGROUND_COLOR}
echo NODE_VERSION: ${NODE_VERSION}
if [ ""${BACKGROUND_COLOR} = 'red' ]; then
    echo -e "\e[31mERROR: Invalid Color:\e[0m" ${BACKGROUND_COLOR}
    EXIT_CODE=1
fi

exit ${EXIT_CODE}
