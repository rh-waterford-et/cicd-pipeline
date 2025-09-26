#!/bin/bash

set -x

STATUS="success"
TOKEN=""
COMMIT_SHA=""
REPO="https://github.com/rh-waterford-et/p2code_scheduler_operator.git"

STATUS_MSG="failed"
if [ "${STATUS}" == "success" ];
then
  STATUS_MSG="passed"
fi

echo -e "${REPO}"
REPO_NAME=$(echo -e "${REPO}" | rev | cut -d/ -f1 | rev | cut -d. -f1)
OWNER=$(echo -e "${REPO}" | rev | cut -d/ -f2 | rev)
echo -e "${REPO_NAME}"
echo -e "${OWNER}"

curl -L  -X POST   -H "Accept: application/vnd.github+json"   -H "Authorization: Bearer ${TOKEN}"   -H "X-GitHub-Api-Version: 2022-11-28" \
"https://api.github.com/repos/${OWNER}/${REPO_NAME}/statuses/${COMMIT_SHA}"  \
-d '{
      "state":"${STATUS}",
      "target_url":"https://pr-opened-webhook-rh-waterford-et.apps.ocp-rh-ai.waltoninstitute.ie/",
      "description":"The cicd build ${STATUS_MSG}!",
      "context":"openshift-pipelines/cicd"
}'

