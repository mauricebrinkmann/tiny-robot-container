# *Tiny Robot* Framework Docker *Container* _for headless API tests_ using the _Debian-based official Python image_

## What is it?

This project provides you with a [Tiny Robot Framework Docker container image](https://github.com/mauricebrinkmann/tiny-robot-container) containing a simple Robot Framework installation on _python:3.8-slim_.
(If you still prefer Alpine-based images over the Debian-based offical Python image, then you might find [this blog post](https://pythonspeed.com/articles/alpine-docker-python/) helpful.)

It comes with some Robot Framework libraries, but without Web GUI Test support - therefore you might want to use [this expanded docker robot framework container here](https://github.com/mauricebrinkmann/docker-robot-framework).

## Versioning

The versioning of this image follows the one of Robot Framework:

* Major version matches the one of Robot Framework
* Minor and patch versions are specific to this project (allows to update the versions of the other dependencies)

The versions used are:

* [Robot Framework](https://github.com/robotframework/robotframework) 3.2
* [Robot Framework HttpCtrl Library](https://pypi.org/project/robotframework-httpctrl/) 0.1.6
* [Robot Framework Pabot](https://github.com/mkorpela/pabot) 1.8.0
* [Robot Framework Requests](https://github.com/bulkan/robotframework-requests) 0.7.0
* [Robot Framework SSHLibrary](https://github.com/robotframework/SSHLibrary) 3.4.0
* [Robot Framework Datadriver](https://github.com/Snooz82/robotframework-datadriver) 1.0.0
* [openpyxl](https://openpyxl.readthedocs.io/en/stable/index.html) 3.0.6
* [Python XlsxWriter](https://xlsxwriter.readthedocs.io/changes.html) 1.3.7

These default versions are specified via environment variables in the Dockerfile.

## Running the container

This container can be run using the following command:

    docker run \
        -v <local path to the reports' folder>:/opt/robotframework/reports:Z \
        -v <local path to the test suites' folder>:/opt/robotframework/tests:Z \
        mauricebrinkmann/tiny-robot-framework:<version>

### Changing the container's tests and reports directories

It is possible to use different directories to read tests from and to generate reports to. This is useful when using a complex test file structure. To change the defaults, set the following environment variables:

* `ROBOT_REPORTS_DIR` (default: /opt/robotframework/reports)
* `ROBOT_TESTS_DIR` (default: /opt/robotframework/tests)

### Parallelisation

It is possible to parallelise the execution of your test suites. Simply define the `ROBOT_THREADS` environment variable, for example:

    docker run \
        -e ROBOT_THREADS=4 \
        mauricebrinkmann/tiny-robot-framework:latest

By default, there is no parallelisation.

#### Parallelisation options

When using parallelisation, it is possible to pass additional [pabot options](https://github.com/mkorpela/pabot#command-line-options), such as `--testlevelsplit`, `--argumentfile`, `--ordering`, etc. These can be passed by using the `PABOT_OPTIONS` environment variable, for example:

    docker run \
        -e ROBOT_THREADS=4 \
        -e PABOT_OPTIONS="--testlevelsplit" \
        mauricebrinkmann/tiny-robot-framework:latest

### Passing additional options

RobotFramework supports many options such as `--exclude`, `--variable`, `--loglevel`, etc. These can be passed by using the `ROBOT_OPTIONS` environment variable, for example:

    docker run \
        -e ROBOT_OPTIONS="--loglevel DEBUG" \
        mauricebrinkmann/tiny-robot-framework:latest

### Testing emails

This project includes the IMAP library which allows Robot Framework to connect to email servers.

A suggestion to automate email testing is to run a [Mailcatcher instance in Docker which allows IMAP connections](https://github.com/estelora/docker-mailcatcher-imap). This will ensure emails are discarded once the tests have been run.

## Security consideration

By default, containers are implicitly run using `--user=1000:1000`, please remember to adjust that command-line setting accordingly, for example:

    docker run \
        --user=1001:1001 \
        mauricebrinkmann/tiny-robot-framework:latest

Remember that that UID/GID should be allowed to access the mounted volumes in order to read the test suites and to write the output.

Additionally, it is possible to rely on user namespaces to further secure the execution. This is well described in the official container documentation:

* Docker: [Introduction to User Namespaces in Docker Engine](https://success.docker.com/article/introduction-to-user-namespaces-in-docker-engine)
* Podman: [Running rootless Podman as a non-root user](https://www.redhat.com/sysadmin/rootless-podman-makes-sense)

This is a good security practice to make sure containers cannot perform unwanted changes on the host. In that sense, Podman is probably well ahead of Docker by not relying on a root daemon to run its containers.

## Continuous integration

It is possible to run the project from within a Jenkins pipeline by relying on the shell command line directly:

    pipeline {
        agent any
        stages {
            stage('Functional regression tests') {
                steps {
                    sh "docker run --shm-size=1g -v $WORKSPACE/robot-tests:/opt/robotframework/tests:Z -v $WORKSPACE/robot-reports:/opt/robotframework/reports:Z mauricebrinkmann/tiny-robot-framework:latest"
                }
            }
        }
    }

The pipeline stage can also rely on a Docker agent, as shown in the example below:

    pipeline {
        agent none
        stages {
            stage('Functional regression tests') {
                agent { docker {
                    image 'mauricebrinkmann/tiny-robot-framework:latest'
                    args '--shm-size=1g -u root' }
                }
                environment {
                    ROBOT_TESTS_DIR = "$WORKSPACE/robot-tests"
                    ROBOT_REPORTS_DIR = "$WORKSPACE/robot-reports"
                }
                steps {
                    sh '''
                        run_tests.sh
                    '''
                }
            }
        }
    }

## Testing this project

Run tests in a local `test/` folder:

    docker run \
        -v `pwd`/reports:/opt/robotframework/reports:Z \
        -v `pwd`/test:/opt/robotframework/tests:Z \
        mauricebrinkmann/tiny-robot-framework:latest

For Windows users who use **PowerShell**:

    docker run \
        -v ${PWD}/reports:/opt/robotframework/reports:Z \
        -v ${PWD}/test:/opt/robotframework/tests:Z \
        mauricebrinkmann/tiny-robot-framework:latest

## Troubleshooting

### Error: Suite contains no tests

When running tests, an unexpected error sometimes occurs:

> [Error] Suite contains no tests.

There are two main causes to this:
* Either the test folder is not the right one,
* Or the permissions on the test folder/test files are too restrictive.

As there can sometimes be issues as to where the tests are run from, make sure the correct folder is used by trying the following actions:
* Use a full path to the folder instead of a relative one,
* Replace any`` `pwd` ``or `${PWD}` by the full path to the folder.

It is also important to check if Robot Framework is allowed to access the resources it needs, i.e.:
* The folder where the tests are located,
* The test files themselves.