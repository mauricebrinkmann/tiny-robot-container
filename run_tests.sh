#!/bin/sh

HOME=${ROBOT_WORK_DIR}

# No need for the overhead of Pabot if no parallelisation is required
if [ $ROBOT_THREADS -eq 1 ]
then
    robot \
        --outputDir $ROBOT_REPORTS_DIR \
        ${ROBOT_OPTIONS} \
        $ROBOT_TESTS_DIR
else
    pabot \
        --verbose \
        --processes $ROBOT_THREADS \
        ${PABOT_OPTIONS} \
        --outputDir $ROBOT_REPORTS_DIR \
        ${ROBOT_OPTIONS} \
        $ROBOT_TESTS_DIR
fi
