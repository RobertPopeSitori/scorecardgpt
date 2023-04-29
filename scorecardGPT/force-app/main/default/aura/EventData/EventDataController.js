({
    doInit: function(component, event, helper) {
        var action = component.get("c.prodToggle");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("response = " + response.getReturnValue());
                component.set("v.isOrgId", response.getReturnValue());
            }
            else if (state === "ERROR") {
                console.log("Error = " + response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    loadedPage : function(component,event,helper) {
        helper.fireComponentLoadedEvent(component);
    },
    cleanData : function(component,event,helper) {
        helper.cleanData(component);
    },
    openModal : function(component,event,helper) {
        helper.openModal(component);
    },
    closeModal : function(component,event,helper) {
       helper.closeModal(component);
    }
})