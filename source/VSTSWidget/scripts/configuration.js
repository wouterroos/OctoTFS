VSS.init({
    explicitNotifyLoaded: true,
    usePlatformStyles: true
});

VSS.require("TFS/Dashboards/WidgetHelpers", function (WidgetHelpers) {
    WidgetHelpers.IncludeWidgetConfigurationStyles();
    VSS.register("OctopusWidget.Configuration", function () {

        var projectsDropdown = $("#project-dropdown");
        var octopusUrlInput = $("#octopusUrl");
        var octopusApiKeyInput = $("#octopusApiKey");

        function getSettings() {
            return {
                octopusUrl: octopusUrlInput.val(),
                octopusApiKey: octopusApiKeyInput.val(),
                projectId: projectsDropdown.val()
            }
        };

        return {
            load: function (widgetSettings, widgetConfigurationContext) {
                var settings = JSON.parse(widgetSettings.customSettings.data);

                if (settings) {
                    if (settings.projectId) {
                        projectsDropdown.val(settings.projectId);
                    }
                    if (settings.octopusApiKey) {
                        octopusApiKeyInput.val(settings.octopusApiKey)
                    }
                    if (settings.octopusUrl) {
                        octopusApiKeyInput.val(settings.octopusUrl)
                    }
                }

                var doRequest = function (requestUrl, successCallback) {
                    if (settings && settings.octopusUrl && settings.octopusApiKey) {
                        $.ajax({
                            type: "GET",
                            url: settings.octopusUrl + requestUrl,
                            beforeSend: function (request) {
                                request.setRequestHeader("X-Octopus-ApiKey", settings.octopusApiKey)
                                request.setRequestHeader("Access-Control-Allow-Origin", "*")
                            },
                            success: successCallback
                        });
                    }
                }

                var getProjects = function () {
                    doRequest("/api/projects", function (getProjectsResult) {
                        if (getProjectsResult && getProjectsResult.Items) {

                            for (var i = 0; i < getProjectsResult.Items.length; i++) {
                                var project = getProjectsResult.Items[i];
                                projectsDropdown.append($("<option></option>").attr("value", project.Id).text(project.Name))
                            }
                        }
                    });
                }

                var updateSettings = function() {
                    settings = getSettings();
                    var eventName = WidgetHelpers.WidgetEvent.ConfigurationChange;
                    var eventArgs = WidgetHelpers.WidgetEvent.Args({ data: JSON.stringify(settings) });
                    widgetConfigurationContext.notify(eventName, eventArgs);
                }

                octopusUrlInput.on("change", function () {
                    updateSettings();
                    getProjects();
                });

                octopusApiKeyInput.on("change", function () {
                    updateSettings();
                    getProjects();
                });

                projectsDropdown.on("change", function () {
                    updateSettings();
                });

                return WidgetHelpers.WidgetStatusHelper.Success();
            },
            onSave: function () {
                return WidgetHelpers.WidgetConfigurationSave.Valid({ data: JSON.stringify(getSettings()) });
            }
        }
    });
    VSS.notifyLoadSucceeded();
});