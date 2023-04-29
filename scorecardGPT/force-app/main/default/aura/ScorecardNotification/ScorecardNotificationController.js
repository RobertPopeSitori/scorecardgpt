({
    onInit : function(component, event, helper) {
        component.set("v.showModal", false);
    },

    onDismissModal: function(component, event, helper){
        helper.onDismissModal(component);
    },

    onVisibilityChanged: function(component, event, helper){
        var showModal = component.get("v.showNotification");
        component.set("v.showModal", showModal);
    }
})