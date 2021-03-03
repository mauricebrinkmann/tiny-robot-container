#!/bin/sh

HOME=${ROBOT_WORK_DIR}
ROBOT_EXIT_CODE=1

# run ore
if [ -n "$PRE_PROCESSING_COMMANDS" ]
then
    bash -c "$PRE_PROCESSING_COMMANDS"
fi

# No need for the overhead of Pabot if no parallelisation is required
if [ $ROBOT_THREADS -eq 1 ]
then
    robot \
        --outputDir $ROBOT_REPORTS_DIR \
        ${ROBOT_OPTIONS} \
        $ROBOT_TESTS_DIR
    ROBOT_EXIT_CODE=$?
else
    pabot \
        --verbose \
        --processes $ROBOT_THREADS \
        ${PABOT_OPTIONS} \
        --outputDir $ROBOT_REPORTS_DIR \
        ${ROBOT_OPTIONS} \
        $ROBOT_TESTS_DIR
    ROBOT_EXIT_CODE=$?
fi

if [ -n "$POST_PROCESSING_COMMANDS" ]
then
    bash -c "$POST_PROCESSING_COMMANDS"
fi

exit $ROBOT_EXIT_CODE