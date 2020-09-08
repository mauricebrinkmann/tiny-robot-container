# *Tiny Robot* Framework Docker *Container* _for headless API tests_ using the _Debian-based official Python image_

## What is it?

This project provides you with a [Tiny Robot Framework Docker container image](https://github.com/mauricebrinkmann/tiny-robot-container) containing a simple Robot Framework installation on _python:3.8-slim_.

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

## Running the container

This container can be run using the following command:

    docker run \
        -v <local path to the reports' folder>:/opt/robotframework/reports:Z \
        -v <local path to the test suites' folder>:/opt/robotframework/tests:Z \
        mauricebrinkmann/tiny-robot-framework:<version>

### Switching browsers

Browsers can be easily switched. It is recommended to define `${BROWSER} %{BROWSER}` in your Robot variables and to use `${BROWSER}` in your test cases. This allows to set the browser in a single place if needed.

When running your tests, simply add `-e BROWSER=chrome` or `-e BROWSER=firefox` to the run command.

### Changing the container's screen resolution

It is possible to define the settings of the virtual screen in which the browser is run by changing several environment variables:

* `SCREEN_COLOUR_DEPTH` (default: 24)
* `SCREEN_HEIGHT` (default: 1080)
* `SCREEN_WIDTH` (default: 1920)

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
                    sh "docker run --shm-size=1g -e BROWSER=firefox -v $WORKSPACE/robot-tests:/opt/robotframework/tests:Z -v $WORKSPACE/robot-reports:/opt/robotframework/reports:Z mauricebrinkmann/tiny-robot-framework:latest"
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
                    BROWSER = 'firefox'
                    ROBOT_TESTS_DIR = "$WORKSPACE/robot-tests"
                    ROBOT_REPORTS_DIR = "$WORKSPACE/robot-reports"
                }
                steps {
                    sh '''
                        /opt/robotframework/run-tests.sh
                    '''
                }
            }
        }
    }

## Testing this project

Not convinced yet? Simple tests have been prepared in the `test/` folder, you can run them using the following commands:

    # Using Chromium
    docker run \
        -v `pwd`/reports:/opt/robotframework/reports:Z \
        -v `pwd`/test:/opt/robotframework/tests:Z \
        -e BROWSER=chrome \
        mauricebrinkmann/tiny-robot-framework:latest

    # Using Firefox
    docker run \
        -v `pwd`/reports:/opt/robotframework/reports:Z \
        -v `pwd`/test:/opt/robotframework/tests:Z \
        -e BROWSER=firefox \
        mauricebrinkmann/tiny-robot-framework:latest

For Windows users who use **PowerShell**, the commands are slightly different:

    # Using Chromium
    docker run \
        -v ${PWD}/reports:/opt/robotframework/reports:Z \
        -v ${PWD}/test:/opt/robotframework/tests:Z \
        -e BROWSER=chrome \
        mauricebrinkmann/tiny-robot-framework:latest

    # Using Firefox
    docker run \
        -v ${PWD}/reports:/opt/robotframework/reports:Z \
        -v ${PWD}/test:/opt/robotframework/tests:Z \
        -e BROWSER=firefox \
        mauricebrinkmann/tiny-robot-framework:latest

Screenshots of the results will be available in the `reports/` folder.

## Troubleshooting

### Chromium is crashing

Chrome drivers might crash due to the small size of `/dev/shm` in the docker container:
> UnknownError: session deleted because of page crash

This is [a known bug of Chromium](https://bugs.chromium.org/p/chromium/issues/detail?id=715363).

To avoid this error, please change the shm size when starting the container by adding the following parameter: `--shm-size=1g` (or any other size more suited to your tests)

### Accessing the logs

In case further investigation is required, the logs can be accessed by mounting their folder. Simply add the following parameter to your `run` command:

* Linux/Mac: ``-v `pwd`/logs:/var/log:Z``
* Windows: ``-v ${PWD}/logs:/var/log:Z``

Chromium allows to set additional environment properties, which can be useful when debugging:

* `webdriver.chrome.verboseLogging=true`: enables the verbose logging mode
* `webdriver.chrome.logfile=/path/to/chromedriver.log`: sets the path to Chromium's log file

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

### Database tests are failing in spite of the DatabaseLibrary being present

As per their official project page, the [Robot Framework DatabaseLibrary](https://github.com/franz-see/Robotframework-Database-Library) contains utilities meant for Robot Framework's usage. This can allow you to query your database after an action has been made to verify the results. This is compatible with any Database API Specification 2.0 module.

It is anyway mandatory to extend the container image to install the specific database module relevant to your tests, such as:
* [MS SQL](https://pymssql.readthedocs.io/en/latest/intro.html): `pip install pymssql`
* [MySQL](https://dev.mysql.com/downloads/connector/python/): `pip install pymysql`
* [Oracle](https://www.oracle.com/uk/database/technologies/appdev/python.html): `pip install py2oracle`
* [PostgreSQL](http://pybrary.net/pg8000/index.html): `pip install pg8000`

## Please contribute to the!

Have you found an issue? Do you have an idea for an improvement? Feel free to contribute by submitting it [here on THIS GitHub project](https://github.com/mauricebrinkmann/tiny-robot-container/issues)

