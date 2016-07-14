var baseUrl = "https://octopus.bdo.global";
function DoRequest(requestUrl, successCallback) {
    $.ajax({
        type: "GET",
        url: baseUrl + requestUrl,
        beforeSend: function (request) {
            request.setRequestHeader("X-Octopus-ApiKey", "API-ZK8Q0TCGQLSCOZZN1DJHGPLHPFI")
        },
        success: successCallback
    });
}

VSS.init({
    explicitNotifyLoaded: true,
    usePlatformStyles: true
});

VSS.require("TFS/Dashboards/WidgetHelpers", function (WidgetHelpers) {
    WidgetHelpers.IncludeWidgetConfigurationStyles();
    VSS.register("OctopusWidget.Configuration", function () {

        var projectsDropdown = $("#project-dropdown");

        return {
            load: function (widgetSettings, widgetConfigurationContext) {
                var settings = JSON.parse(widgetSettings.customSettings.data);

                DoRequest("/api/projects", function(getProjectsResult) {
                    if (getProjectsResult && getProjectsResult.Items) {

                        for (var i = 0; i < getProjectsResult.Items.length; i++) {
                            var project = getProjectsResult.Items[i];
                            projectsDropdown.append($("<option></option>").attr("value", project.Id).text(project.Name))
                        }

                        if (settings && settings.projectId) {
                            projectsDropdown.val(settings.projectId);
                        }
                    }

                    return WidgetHelpers.WidgetStatusHelper.Success();
                });

                projectsDropdown.on("change", function () {
                    var customSettings = {
                        data: JSON.stringify({
                            projectId: projectsDropdown.val()
                        })
                    };

                    var eventName = WidgetHelpers.WidgetEvent.ConfigurationChange;
                    var eventArgs = WidgetHelpers.WidgetEvent.Args(customSettings);
                    widgetConfigurationContext.notify(eventName, eventArgs);
                })
            },
            onSave: function () {
                var customSettings = {
                    data: JSON.stringify({
                        projectId: projectsDropdown.val()
                    })
                };
                return WidgetHelpers.WidgetConfigurationSave.Valid(customSettings);
            }
        }
    });
    VSS.notifyLoadSucceeded();
});