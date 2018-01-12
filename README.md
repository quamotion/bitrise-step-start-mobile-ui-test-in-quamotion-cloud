# Start Mobile UI Test in Quamotion Cloud

Quamotion Cloud allows you to test your application on multiple devices - either physical devices or emulators. This step allows you to start a test run, which will execute your test cases one or more devices.

## What this step does

This step runs tests on iOS or Android devices in the [Quamotion Cloud](https://cloud.quamotion.mobi). Before you can run a test,
you first need to [publish your app to Quamotion Cloud](https://github.com/quamotion/bitrise-step-publish-app-to-quamotion-cloud)
and [publish your test package to Quamotion Cloud](https://github.com/quamotion/bitrise-step-publish-test-package-to-quamotion-cloud).

This step takes parameters:
- Your Quamotion API key
- The test package and the version of the test package to run, and any additional parameters you want to pass to your test package.
- The operating system to test on, the app you want to test, and the version of the app you want to test.

## See also

This step is part of a series of Bitrise steps which integrate Quamotion Cloud with Bitrise.

* Use the [Publish app to Quamotion Cloud](https://github.com/quamotion/bitrise-step-publish-app-to-quamotion-cloud) step
  to publish your iOS or Android app to [Quamotion Cloud](https://cloud.quamotion.mobi).
* Use the [Publish test package to Quamotion Cloud](https://github.com/quamotion/bitrise-step-publish-test-package-to-quamotion-cloud/)
  step to publish your Maven or Pester tests to [Quamotion Cloud](https://cloud.quamotion.mobi).
* Use the [Start Mobile UI Test in Quamotion Cloud](https://github.com/quamotion/bitrise-step-start-mobile-ui-test-in-quamotion-cloud)
  step to test your iOS or Android app in [Quamotion Cloud](https://cloud.quamotion.mobi).

## Adding this step to your Bitrise workflow
To use this step, follow these steps:

1. Open your workflow in Bitrise
2. Click on the `bitrise.yml` tab in the upper-right corner of your screen
3. Copy and paste the following code in your Bitrise workflow to add this step:

```
- git::https://github.com/quamotion/bitrise-step-start-mobile-ui-test-in-quamotion-cloud@master:
    title: Run Quamotion tests
    inputs:
    - quamotion_api_key: _YOUR_API_KEY_
    - test_package_name: _YOUR_TEST_PACKAGE_
    - test_package_version: _YOUR_TEST_PACKAGE_VERSION_
    - test_script_parameters: _ADDITIONAL_PARAMETERS_
    - app_os: Android
    - app_id: _YOUR_APP_ID_
    - app_version: _YOUR_APP_VERSION_
```

4. Save your workflow by clicking __CTRL + S__

