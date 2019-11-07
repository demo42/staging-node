#!/bin/sh
echo BACKGROUND_COLOR: ${BACKGROUND_COLOR}
echo NODE_VERSION: ${NODE_VERSION}
if [ ""${BACKGROUND_COLOR} = 'red' ]; then
    echo "Invalid Color:" ${BACKGROUND_COLOR}
    EXIT_CODE=1
fi

exit ${EXIT_CODE}
