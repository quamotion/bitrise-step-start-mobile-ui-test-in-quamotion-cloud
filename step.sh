#!/bin/bash
set -ex

echo "Logging in to Quamotion Cloud"
QUAMOTION_URL=https://cloud.quamotion.mobi
QUAMOTION_ACCESS_TOKEN=`curl -s -d "apiKey=$quamotion_api_key" ${QUAMOTION_URL}/api/login | jq -r '.access_token'`
QUAMOTION_RELATIVE_URL=`curl -s -H "Authorization: Bearer $QUAMOTION_ACCESS_TOKEN" ${QUAMOTION_URL}/api/project | jq -r '.[0].relativeUrl'`
echo "Connected to the Quamotion project at $QUAMOTION_URL$QUAMOTION_RELATIVE_URL"

echo "Scheduling the test run"
QUAMOTION_TEST_RUN_REQUEST="{ \"app\": { \"operatingSystem\": \"$app_os\", \"appId\": \"$app_id\", \"version\": \"$app_version\" } ,\"testPackage\": { \"name\": \"$test_package_name\", \"version\": \"$test_package_version\" }, \"deviceGroupId\": \"57b9dda4-d1e4-423f-89c7-6f523daecb2e\"}"
QUAMOTION_TEST_RUN=`curl -s -H "Authorization: Bearer $QUAMOTION_ACCESS_TOKEN" -H "Content-Type: application/json" -d "$QUAMOTION_TEST_RUN_REQUEST" -X POST ${QUAMOTION_URL}${QUAMOTION_RELATIVE_URL}api/testRun`
echo "Successfully scheduled the test run"

# This may take a while, so do some polling here.
QUAMOTION_TEST_RUN_ID=`echo $QUAMOTION_TEST_RUN | jq -r '.testRunId'`
QUAMOTION_TEST_JOB="null"

while [ "$QUAMOTION_TEST_JOB" == "null" ]
do
  QUAMOTION_TEST_JOBS=`curl -H "Authorization: Bearer $QUAMOTION_ACCESS_TOKEN" ${QUAMOTION_URL}${QUAMOTION_RELATIVE_URL}api/testRun/${QUAMOTION_TEST_RUN_ID}/jobs || exit 0`
  echo "Test jobs: $QUAMOTION_TEST_JOBS"

  QUAMOTION_TEST_JOB=`echo $QUAMOTION_TEST_JOBS | jq -r '.[0].id'`
  echo "Test job ID: $QUAMOTION_TEST_JOB"
done

# Forward the job output to Bitrise
date

echo "-- build log start --"
curl -H "Authorization: Bearer $QUAMOTION_ACCESS_TOKEN" ${QUAMOTION_URL}${QUAMOTION_RELATIVE_URL}api/job/${QUAMOTION_TEST_JOB}/log/live
curl -H "Authorization: Bearer $QUAMOTION_ACCESS_TOKEN" ${QUAMOTION_URL}${QUAMOTION_RELATIVE_URL}api/job/${QUAMOTION_TEST_JOB}/log/live

echo "-- build log end  --"
date

# Download the artifact zip file
echo "Downloading build artifact to quamotion-artifacts.zip"
curl -s -H "Authorization: Bearer $QUAMOTION_ACCESS_TOKEN" ${QUAMOTION_URL}${QUAMOTION_RELATIVE_URL}api/job/${QUAMOTION_TEST_JOB}/artifacts -O quamotion-artifacts.zip

#
# --- Export Environment Variables for other Steps:
# You can export Environment Variables for other Steps with
#  envman, which is automatically installed by `bitrise setup`.
# A very simple example:
envman add --key EXAMPLE_STEP_OUTPUT --value 'the value you want to share'
# Envman can handle piped inputs, which is useful if the text you want to
# share is complex and you don't want to deal with proper bash escaping:
#  cat file_with_complex_input | envman add --KEY EXAMPLE_STEP_OUTPUT
# You can find more usage examples on envman's GitHub page
#  at: https://github.com/bitrise-io/envman

#
# --- Exit codes:
# The exit code of your Step is very important. If you return
#  with a 0 exit code `bitrise` will register your Step as "successful".
# Any non zero exit code will be registered as "failed" by `bitrise`.
