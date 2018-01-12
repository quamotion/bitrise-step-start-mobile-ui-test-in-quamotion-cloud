#!/bin/bash
set -e

echo "Logging in to Quamotion Cloud"
QUAMOTION_URL=https://cloud.quamotion.mobi
QUAMOTION_ACCESS_TOKEN=`curl -s -d "apiKey=$quamotion_api_key" ${QUAMOTION_URL}/api/login | jq -r '.access_token'`
QUAMOTION_RELATIVE_URL=`curl -s -H "Authorization: Bearer $QUAMOTION_ACCESS_TOKEN" ${QUAMOTION_URL}/api/project | jq -r '.[0].relativeUrl'`
echo "Connected to the Quamotion project at $QUAMOTION_URL$QUAMOTION_RELATIVE_URL"

echo "Scheduling the test run"
echo { } | jq --arg app_os $app_os --arg app_id $app_id --arg app_version $app_version --arg test_package_name $test_package_name --arg test_package_version $test_package_version --arg test_script_parameters "$test_script_parameters" '. + { app: { operatingSystem: $app_os, appId: $app_id, version: $app_version }, testPackage: { name: $test_package_name, version: $test_package_version, testScriptParameters: $test_script_parameters }, deviceGroupId: "57b9dda4-d1e4-423f-89c7-6f523daecb2e" }' > test_run_request.json

QUAMOTION_TEST_RUN=`curl -s -H "Authorization: Bearer $QUAMOTION_ACCESS_TOKEN" -H "Content-Type: application/json" -d @test_run_request.json -X POST ${QUAMOTION_URL}${QUAMOTION_RELATIVE_URL}api/testRun`
echo "Successfully scheduled the test run"
echo ">> Request"
cat test_run_request.json
echo "<<Request"
echo ">> Response"
echo "$QUAMOTION_TEST_RUN"
echo "<< Response"

# This may take a while, so do some polling here.
QUAMOTION_TEST_RUN_ID=`echo $QUAMOTION_TEST_RUN | jq -r '.testRunId'`
QUAMOTION_TEST_JOB="null"

while [ "$QUAMOTION_TEST_JOB" == "null" ]
do
  QUAMOTION_TEST_JOBS=`curl -s -H "Authorization: Bearer $QUAMOTION_ACCESS_TOKEN" ${QUAMOTION_URL}${QUAMOTION_RELATIVE_URL}api/testRun/${QUAMOTION_TEST_RUN_ID}/jobs || exit 0`
  QUAMOTION_TEST_JOB=`echo $QUAMOTION_TEST_JOBS | jq -r '.[0].id'`
  echo "The test job is being queued"
done

# Forward the job output to Bitrise
wget -O - --header "Authorization: Bearer $QUAMOTION_ACCESS_TOKEN" ${QUAMOTION_URL}${QUAMOTION_RELATIVE_URL}api/job/${QUAMOTION_TEST_JOB}/log/live

# Download the artifact zip file
echo "Downloading build artifact to quamotion-artifacts.zip"
curl -s -H "Authorization: Bearer $QUAMOTION_ACCESS_TOKEN" -o quamotion-artifacts.zip ${QUAMOTION_URL}${QUAMOTION_RELATIVE_URL}api/job/${QUAMOTION_TEST_JOB}/artifacts

QUAMOTION_TEST_RESULT=`curl -s -H "Authorization: Bearer $QUAMOTION_ACCESS_TOKEN" -H "Content-Type: application/json" ${QUAMOTION_URL}${QUAMOTION_RELATIVE_URL}api/job/${QUAMOTION_TEST_JOB}`
QUAMOTION_TEST_STATUS=`echo $QUAMOTION_TEST_RESULT | jq -r '.status'`

echo "The build has completed with $QUAMOTION_TEST_STATUS"

if [ "$QUAMOTION_TEST_STATUS" == "success" ]; then
  exit 0
else
  exit -1
fi
