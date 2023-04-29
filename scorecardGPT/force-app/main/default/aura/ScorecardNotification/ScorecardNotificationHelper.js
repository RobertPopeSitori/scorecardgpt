({
    onDismissModal : function(component) {
        var dismissal = component.getEvent("notificationDismissal");
        dismissal.fire();
    }
})