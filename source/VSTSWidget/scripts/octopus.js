var baseUrl = "https://octopus.bdo.global";


function DoRequest(requestUrl) {
    return $.ajax({
        type: "GET",
        url: baseUrl + requestUrl,
        beforeSend: function (request) {
            request.setRequestHeader("X-Octopus-ApiKey", "API-ZK8Q0TCGQLSCOZZN1DJHGPLHPFI")
        }
    });
}


VSS.init({
    explicitNotifyLoaded: true,
    usePlatformStyles: true
});

VSS.require("TFS/Dashboards/WidgetHelpers", function (WidgetHelpers) {
    WidgetHelpers.IncludeWidgetStyles();
    VSS.register("OctopusWidget", function () {

        var getCurrentDeploymentStatus = function GetCurrentDeploymentStatus(widgetSettings) {
            var settings = JSON.parse(widgetSettings.customSettings.data);
            var project = null;
            var environment = null;
            var lastDeployment = null;
            var release = null;
            var task = null;

            if (settings && settings.projectId) {
                var projectId = settings.projectId;
                var environmentName = "Development";

                $("#environmentName").text(environmentName);

                $.when
                (
                    DoRequest("/api/projects/" + projectId),
                    DoRequest("/api/environments")
                )
                .done(function (getProjectResult, getEnvironmentsResult) {

                    var project = getProjectResult[0];
                    var environment = null;

                    if (getEnvironmentsResult && getEnvironmentsResult[0] && getEnvironmentsResult[0].Items) {
                        var environments = getEnvironmentsResult[0].Items
                        for (var j = 0; j < environments.length; j++) {
                            if (environments[j].Name.toLowerCase() === environmentName.toLowerCase()) {
                                environment = environments[j];
                                break;
                            }
                        }
                    }

                    var lastDeployment = null;
                    var release = null;
                    var task = null;

                    $.when
                    (
                        DoRequest("/api/deployments?projects=" + project.Id + "&environments=" + environment.Id)
                    )
                    .done(function (getDeploymentsResult) {

                        if (getDeploymentsResult && getDeploymentsResult.Items) {
                            lastDeployment = getDeploymentsResult.Items[0];

                            $.when
                            (
                                DoRequest(lastDeployment.Links.Release),
                                DoRequest(lastDeployment.Links.Task
                                )
                            )
                            .done(function (getReleaseResult, getTaskResult) {
                                release = getReleaseResult[0];
                                task = getTaskResult[0];

                                if (task.State === "Success") {
                                    $(".widget").css("background-color", "#339933");
                                    $("#statusIcon").addClass("fa-check");
                                }
                                if (task.State === "Failed") {
                                    $(".widget").css("background-color", "#e60017");
                                    $("#statusIcon").addClass("fa-exclamation-triangle");
                                }
                                if (task.State === "Executing") {
                                    $(".widget").css("background-color", "#009ccc");
                                    $("#statusIcon").addClass("fa-spinner fa-spin");
                                }

                                $("#version").text(release.Version)
                                return WidgetHelpers.WidgetStatusHelper.Success();
                            });
                        }
                    });
                });
            }

            return WidgetHelpers.WidgetStatusHelper.Success();
        }

        return {
            load: function (widgetSettings) {
                return getCurrentDeploymentStatus(widgetSettings);
            },
            reload: function (widgetSettings) {
                return getCurrentDeploymentStatus(widgetSettings);
            }
        }
    });
    VSS.notifyLoadSucceeded();
});