Team Build Preview Custom Tasks
===============================

Custom Build Tasks for [Team Build vNext](http://vsalmdocs.azurewebsites.net/library/vs/alm/build/overview)

These need to be uploaded to your Visual Studio or TFS instance before they can be used. This page will be updated when there's a way to do that!

Note: You can still use [OctoPack](http://docs.octopusdeploy.com/display/OD/Using+OctoPack) as part of your MSBuild task to package and push Nuget packages.

[Create Octopus Release](source/CustomBuildTasks/CreateOctopusRelease)
----------------------
Creates a new Release in Octopus Deploy.

You'll need to set up a Connected Service to Octopus first.
You can use either an API key (in the password field), or your username and password.

Options include:
* Creating release notes from linked checkin comments and work items (currently TFVC only)
* Automatically deploying to an environment when Release has been created
* Any additional octo.exe arguments