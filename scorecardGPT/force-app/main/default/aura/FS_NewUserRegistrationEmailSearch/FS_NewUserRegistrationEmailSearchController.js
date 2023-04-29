/**
 * Created by cmudd on 2019-05-29.
 */

({
    callLookForExistingUser : function(component, event, helper) {
        var email = component.get('v.workEmail');
        component.set('v.showError', false);
        component.set('v.errorMessage', '');
        helper.callLookForExistingUserHelper(component, email);
    },

    setEmailAttr : function(component, event, helper) {
        var email = component.find('emailInput').get('v.value');
        if (helper.validateEmail(email)) {
            component.set('v.showError', false);
            component.set('v.errorMessage', '');
            component.set('v.workEmail', email);
            component.set('v.disableButton', false);
        } else {
            component.set('v.workEmail', '');
            component.set('v.disableButton', true);
        }
    },

    keyCheck : function (component, event, helper) {
        var buttonDisabled = component.get('v.disableButton');
        if (event.which == 13 && !buttonDisabled) {
            var action = component.get('c.callLookForExistingUser');
            action.setParams({
                component:component,
                event:event,
                helper:helper
            });
            action.setCallback(this, function(a) {
            });
            $A.enqueueAction(action);
            // this.callLookForExistingUser(component, event, helper);
        }
    },
    redirectToUrl : function (component) {
        component.set("v.doneRegistration", true);
        var urlEvent = $A.get("e.force:navigateToURL");
			urlEvent.setParams({
      		"url": "https://my.onlinelearningconsortium.org/s/login"
    });
	urlEvent.fire();
    }

    // activateContact : function (component, event, helper) {
    //     component.set('v.showError', false);
    //     component.set('v.errorMessage', '');
    //     var contactId = component.get('v.contactId');
    //     // console.log(contactId);
    //     helper.callFinishRegistration(component, contactId);
    // },
    //
    // createNewUser : function (component) {
    //     component.set('v.showError', false);
    //     component.set('v.errorMessage', '');
    //     var email = component.get('v.workEmail');
    //     component.set("v.userNotFoundEmail", email);
    //     component.set("v.userNotFound", true);
    // }
});