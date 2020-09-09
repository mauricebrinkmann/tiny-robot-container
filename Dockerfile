FROM python:3.8-slim

MAINTAINER Maurice Brinkmann <mauricebrinkmann@users.noreply.github.com>
LABEL description Tiny Robot Frameworkdocker container for headless API tests using the Debian-based official Python image

# Set the reports directory environment variable
ENV ROBOT_REPORTS_DIR /opt/robotframework/reports

# Set the tests directory environment variable
ENV ROBOT_TESTS_DIR /opt/robotframework/tests

# Set the working directory environment variable
ENV ROBOT_WORK_DIR /opt/robotframework/temp

# Set number of threads for parallel execution
# By default, no parallelisation
ENV ROBOT_THREADS 1

# Define the default user who'll run the tests
ENV ROBOT_UID 1000
ENV ROBOT_GID 1000

# Dependency versions
ENV HTTPCTRL_VERSION 0.1.6
ENV PABOT_VERSION 1.8.0
ENV REQUESTS_VERSION 0.7.0
ENV ROBOT_FRAMEWORK_VERSION 3.2
ENV SSH_LIBRARY_VERSION 3.4.0

# Update system path
ENV PATH=/opt/robotframework/bin:$PATH

# Copy test runner script into bin folder
COPY run-tests.sh /opt/robotframework/bin/

# Install system dependencies
RUN pip install \
    --no-cache-dir \
    robotframework==$ROBOT_FRAMEWORK_VERSION \
    robotframework-httpctrl==$HTTPCTRL_VERSION \
    robotframework-pabot==$PABOT_VERSION \
    robotframework-requests==$REQUESTS_VERSION \
    robotframework-sshlibrary==$SSH_LIBRARY_VERSION\
    PyYAML \
	wheel

# Create the default report and work folders with the default user to avoid runtime issues
# These folders are writeable by anyone, to ensure the user can be changed on the command line.
RUN mkdir -p ${ROBOT_REPORTS_DIR} \
  && mkdir -p ${ROBOT_WORK_DIR} \
  && chown ${ROBOT_UID}:${ROBOT_GID} ${ROBOT_REPORTS_DIR} \
  && chown ${ROBOT_UID}:${ROBOT_GID} ${ROBOT_WORK_DIR} \
  && chmod ugo+w ${ROBOT_REPORTS_DIR} ${ROBOT_WORK_DIR}

# Allow any user to write logs
RUN chmod ugo+w /var/log \
  && chown ${ROBOT_UID}:${ROBOT_GID} /var/log

# Set up a volume for the generated reports
VOLUME ${ROBOT_REPORTS_DIR}

USER ${ROBOT_UID}:${ROBOT_GID}

# A dedicated work folder to allow for the creation of temporary files
WORKDIR ${ROBOT_WORK_DIR}

# Execute all robot tests
CMD ["run-tests.sh"]
