var baseUrl = "https://octopus.bdo.global";

var xhttp = new XMLHttpRequest();

xhttp.onreadystatechange = function () {

}

xhttp.open("GET", baseUrl + "/api/environments/all");
xhttp.setRequestHeader("X-Octopus-ApiKey", "API-ZK8Q0TCGQLSCOZZN1DJHGPLHPFI");
xhttp.send();

VSS.init({
    explicitNotifyLoaded: true,
    usePlatformStyles: true
});

VSS.require("TFS/Dashboards/WidgetHelpers", function (WidgetHelpers) {
    WidgetHelpers.IncludeWidgetStyles();
    VSS.register("OctopusWidget", function () {
        return {
            load: function (widgetSettings) {

                var $title = $('h2.title');
                $title.text('Hello World');

                return WidgetHelpers.WidgetStatusHelper.Success();
            }
        }
    });
    VSS.notifyLoadSucceeded();
});