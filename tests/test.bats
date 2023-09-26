setup() {
  mkcert -install >/dev/null
  export DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )/.."
  export TESTDIR=$(mktemp -d -t testdynamodb-XXXXXXXXXX)
  export PROJNAME=testdynamodb
  export DDEV_NON_INTERACTIVE=true
  ddev delete -Oy ${PROJNAME} >/dev/null || true
  cd "${TESTDIR}" || exit
  ddev config --project-name=${PROJNAME}
  echo ${PROJNAME}
  ddev start -y >/dev/null
}

teardown() {
  cd ${TESTDIR} || exit
  ddev delete -Oy ${PROJNAME} || true
  [ "${TESTDIR}" != "" ] && rm -rf ${TESTDIR}
}

@test "basic installation" {
  set -o pipefail
  cd ${TESTDIR} || ( printf "# unable to cd to ${TESTDIR}\n" >&3 && false )
  echo "# ddev get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev get ${DIR}
  (ddev restart >/dev/null || (echo "# ddev restart returned exit code=%?" >&3 && false))
  # Verify that dynamodb is up and running.
  ddev exec curl dynamodb:8000 | grep 'MissingAuthenticationToken' >/dev/null
}