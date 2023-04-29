/**
 * Created by cmudd on 2019-05-29.
 */

({
    // validate the email format before checking the database for an existing user with the given email
    validateEmail: function (email) {
        var isValidEmail = false;
        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        if (!$A.util.isEmpty(email)) {
            // console.log(email);
            if (email.match(regExpEmailformat)) {
                isValidEmail = true;
            }
        }
        return isValidEmail;
    },

    callLookForExistingUserHelper: function (component, email) {
        // console.log('verifying email format');
        // console.log(event.getSource().get('v.workEmail'));
        // console.log('event fired. email receieved: ' + email);
        component.set('v.workEmail', email);
        var action = component.get("c.lookForExistingUser");
        action.setParams(
            {email: email}
        );
        var labels = component.get('v.labels');
        action.setCallback(this, function (a) {
            // console.log('return value should be null: ' + a.getReturnValue());
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                
                component.set("v.errorMessage", rtnValue);
                // this.fireAddErrorClassEvent(component, 'errorClass', 'errorAlert');
                component.set("v.showError", true);
                var redirectUrl = labels.Community_Login_Url__c;
                this.setUrl(component, redirectUrl);
                // component.set("v.doneRegistration", true);
                component.set("v.userFound", true);
                component.set("v.showSpinner", false);
            } else {
                // console.log('false');
                //    create action to search for all companies with the supplied email domain and allow user to select which company they would like to use
                //    may have to move this into a second component
                // component.set("v.userNotFoundEmail", email);
                // component.set("v.userNotFound", true);
                this.callLookForExistingContact(component);
            }
        });
        component.set('v.showSpinner', true);
        $A.enqueueAction(action);
    },

    callLookForExistingContact: function (component) {
        // console.log('looking for contact');
        var email = component.get('v.workEmail');
        var action = component.get("c.lookForExistingContact");
        // console.log('work email: ' + email);
        action.setParams(
            {email: email}
        );
        // console.log('set params on action');
        action.setCallback(this, function (a) {
            // console.log('whats going on' + a.getState());
            var record = a.getReturnValue();
            // console.log('contact info if found, null if none: ' + record);
            if (record !== null) {
                // console.log('record: ' + record[0]);
                component.set('v.contactId', record[0].contactId);
                var contactId = record[0].contactId;
                // component.set('v.showSpinnerEmail', true);
                // component.set('v.contactFirstName', record[0].contactFirstName);
                // component.set('v.contactLastName', record[0].contactLastName);
                // component.set('v.contactWorkEmail', record[0].contactWorkEmail);
                // component.set('v.contactEmail', record[0].contactEmail);
                component.set('v.contactFound', true);
                // console.log('finishing registration');
                this.callFinishRegistration(component, contactId);
                // console.log('should be setting contact id and marking contact found true ' + component.get('v.contactFound'));
            } else {
                // console.log('user not found!');
                component.set("v.userNotFoundEmail", email);
                component.set("v.userNotFound", true);
            }
            component.set('v.showSpinner', false);
        });
        // console.log('enqueueing action');
        $A.enqueueAction(action);
    },

    callFinishRegistration: function (component, contactId) {
        // console.log('helper entered');
        var action = component.get("c.finishRegistration");
        var selfRegisterAccountId = component.get('v.selfRegisterAccountId');
        var labels = component.get('v.labels');
        action.setParams(
            {
                contactId: contactId,
                password: null,
                retUrl: 'true',
                selfRegisterAccountId: selfRegisterAccountId
            }
        );
        // var getErrorLabels = component.get('c.getRegistrationLabels');
        // getErrorLabels.setCallback(this, function (a) {
        //     var labels = a.getReturnValue();
        //     component.set("v.errorMessage", labels.Contact_Found_Message__c);
        // });
        // console.log('set params');
        action.setCallback(this, function (a) {
            // console.log('callback started');
            var rtnValue = a.getReturnValue();
            // var status = a.getState();
            // console.log(status);
            // console.log(rtnValue);
            if (rtnValue !== null) {
                // inform user to check their email. New User Reg should end here for this pathway
                // console.log('into callback');
                // $A.enqueueAction(getErrorLabels);
                component.set("v.errorMessage", labels.Contact_Found_Message__c);
                // this.fireAddErrorClassEvent(component, 'errorClass', 'errorAlert');
                component.set("v.showError", true);
                // var redirectUrl = '/LightningMemberPortal/s/login/';
                // this.setUrl(component, redirectUrl);
                var redirectUrl = labels.Community_Login_Url__c;
                this.setUrl(component, redirectUrl);
                // component.set("v.doneRegistration", true);
                component.set("v.userFound", true);
                component.set('v.showSpinner', false);
                // console.log('done');
            } else {
                // console.log('should display error');
                component.set("v.errorMessage", labels.Generic_Error_Message__c);
                // this.fireAddErrorClassEvent(component, 'errorClass', 'errorAlert');
                component.set("v.showError", true);
            }
        });
        $A.enqueueAction(action);
    },
    setUrl : function(component, urlToSet) {
        component.set('v.defaultRetUrl', urlToSet);
    }
    
    // fireAddErrorClassEvent : function(component, idToFind, classToAdd) {
    //     var addErrorClassEvent = component.getEvent('addErrorClassEvent');
    //     addErrorClassEvent.setParam('idToFind', idToFind);
    //     addErrorClassEvent.setParam('classToAdd', classToAdd);
    //     console.log('firing event');
    //     addErrorClassEvent.fire();
    //     console.log('fired event');
    // }
});