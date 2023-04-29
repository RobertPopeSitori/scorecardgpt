/**
 * Created by cmudd on 2019-05-29.
 */

({
    showSpinner : function (component) {
        component.set('v.showSpinner', true);
    },
    hideSpinner : function (component) {
        component.set('v.showSpinner', false);
        // console.log('password rules: ' + component.get('v.passwordRules'));
    },
    doInit : function (component, event, helper) {
        // console.log('getting labels');
        helper.callGetRegistrationLabels(component);
        var labels = component.get('v.labels');

        // console.log(labels.Contact_Found_Message__c);
    },
    redirectAfterRegistration : function (component, event, helper) {
        var retUrl = component.get('v.defaultRetUrl');

        var urlParams = helper.getUrlVars();
        var redirectToUrl = function() {
            window.location.href = component.get('v.defaultRetUrl');
        };
        var redirectUrl = component.get('v.defaultRetUrl');
        var userExists = component.get('v.userFound');
        var conExists = component.get('v.contactFound');
        if (userExists || conExists) {
            redirectToUrl();
        } else if (redirectUrl.indexOf('login') !== -1) {
            setTimeout(redirectToUrl, 5000);
        } else {
            if (urlParams['retUrl'] != null) {
                component.set('v.defaultRetUrl', urlParams['retUrl']);
            } else if (urlParams['startURL'] != null) {
                component.set('v.defaultRetUrl', urlParams['startURL']);
            }
            setTimeout(redirectToUrl, 2500);
        }


        // window.location.href = retUrl;
    },
    addErrorClass : function(component, event, helper) {
        var idToFind = event.getParam("idToFind");
        // console.log('finding id: ' + idToFind);
        var classToAdd = event.getParam("classToAdd");
        // console.log('adding class: ' + classToAdd);
        var cmpTarget = component.find(idToFind);
        $A.util.addClass(cmpTarget, classToAdd);
    }
});