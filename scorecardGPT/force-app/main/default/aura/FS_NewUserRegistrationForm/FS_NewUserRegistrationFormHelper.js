/**
 * Created by cmudd on 2019-06-03.
 */

({
    validatePassword: function (component, password) {

        console.log('password: ' + password);

        var containsAlpha = password.match('[A-Za-z]');
        var containsNum = password.match('[0-9]');

        console.log('checked password');

        if (!containsAlpha || !containsNum || password.length < 8) {
            return false;
        }

        return true;

    },

    getStartUrl : function (cmp, event, helper) {
        var sPageURL = window.location.search.substring(1);
        var sURLVariables = sPageURL.split('&');

        for (var i = 0; i < sURLVariables.length; i++)
        {
            var sParameterName = sURLVariables[i].split('=');
            if (sParameterName[0] === 'startURL')
            {
                return sParameterName[1];
            }
        }
        return '';
    },

    callFinishRegistrationWithPassword: function (component, contactId, password, retUrl) {
        var action = component.get("c.finishRegistration");
        // var urlParams = this.getUrlParams();
        // if (urlParams['startURL'] !== null && urlParams['startURL'] !== undefined) {
        //     var pathname = window.location.pathname;
        //     retUrl = pathname.substring(0, pathname.lastIndexOf('/')) + '/' + urlParams['startURL'];
        // }
        console.log(retUrl);
        console.log(contactId);
        action.setParams(
            {
                contactId: contactId,
                password: password,
                retUrl: retUrl,
                selfRegisterAccountId: null
            }
        );
        
        console.log('set params');
        action.setCallback(this, function (a) {
            console.log('callback started');
            var rtnValue = a.getReturnValue();
            var status = a.getState();
            if (rtnValue !== null) {
                // inform user to check their email. New User Reg should end here for this pathway
                // console.log('into callback');
                component.set("v.errorMessage", 'Thank you for registering!');
                component.set("v.showError", true);
                // document.body.scrollTop = document.documentElement.scrollTop = 0;
                // window.scrollTo(0, 0);
                document.body.scrollTop = document.documentElement.scrollTop = 0;
                // component.set('v.defaultRetUrl', rtnValue);
                // console.log(rtnValue);
                window.location.href = rtnValue;
                // component.set('v.doneRegistration', true);
            } else {
                component.set("v.errorMessage", 'An error occurred while activating your account. Please contact an administrator' +
                    ' to continue registration');
                component.set("v.showError", true);
                document.body.scrollTop = document.documentElement.scrollTop = 0;
            }
            component.set('v.showSpinner', false);
        });
        component.set('v.showSpinner', true);
        $A.enqueueAction(action);
    },
    callCreateNewAccount: function (component, event, email, orgName, adminId, webUrl, type, subType, country, street, city, state, zipCode) {

        var action = component.get('c.createNewAccount');
        action.setParams({
            "params": {
                "contactEmail": email,
                "orgName": orgName,
                "adminId": adminId,
                "webUrl": webUrl,
                "type": type,
                "subType": subType,
                "country": country,
                "street": street,
                "city": city,
                "state": state,
                "zipCode": zipCode
            }
        });
        action.setCallback(this, function (a) {
            console.log('should have inserted account');
            var rtnValue = a.getReturnValue();
            var status = a.getState();
            console.log(status);
            console.log(rtnValue);
            if (rtnValue !== null) {
                component.set('v.accountSelection', rtnValue);
                this.submitForm(component, event);
            } else {
                component.set("v.errorMessage", 'An error occurred while activating your account. Please contact an administrator' +
                    ' to continue registration');
                component.set("v.showError", true);
                document.body.scrollTop = document.documentElement.scrollTop = 0;
            }
        });
        component.set('v.showSpinner', true);
        $A.enqueueAction(action);
    },
    submitForm: function (component, event) {
        // first validate the password and ensure that it is legal
        // var password = component.find('password').get('v.value');
        // var retypePassword = component.find('retypePassword').get('v.value');
        // if (this.validatePasswords(component, password, retypePassword)) {
        // console.log('password' + password);
        console.log('getting fields');
        var fields = event.getParam("fields");
        console.log('getting admin id');
        var adminId = component.get('v.adminId');
        console.log('getting work email');
        var workEmail = component.get('v.workEmail');
        console.log('getting account selection');
        var accountSelection = component.get("v.accountSelection");
        console.log('getting mailing country');
        var mailingCountry = component.find("mailingCountry").get("v.value");
        console.log('getting mailing state');
        var mailingState = component.find("mailingState").get("v.value");
        console.log(adminId);
        if (accountSelection) {
            fields["AccountId"] = component.get("v.accountSelection");
        } else {
            fields["AccountId"] = component.get("v.selfRegisterAccountId");
        }
        fields["OwnerId"] = adminId;
        fields["Email"] = workEmail;
        fields["MailingCountry"] = mailingCountry;
        fields["MailingState"] = mailingState;
        fields["Created_by_USR__c"] = true;
        console.log('submitting form');
        component.find("form").submit(fields);
        console.log('form submitted');
        // }
    },
    getUrlParams: function () {
        var vars = {};
        console.log('getting parameters');
        var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function (m, key, value) {
            console.log(key);
            console.log(value);
            vars[key] = value;
        });
        return vars;
    },
    isFormValid: function (cmp) {
        const requiredFields = cmp.find('required') || [];
        requiredFields.push(cmp.find('mailingCountry'));
        requiredFields.push(cmp.find('mailingState'));
        console.log('required fields:\n' + requiredFields);
        var isValid = true;
        requiredFields.forEach(e => {

            isValid = this.addErrorToElement(cmp, e, isValid);
        });

        return isValid;
    },
    addErrorToElement: function (component, e, isValid) {
        var val = e.get('v.value');
        console.log('during helper: ' + val);
        var divToShow = component.find(e.get('v.fieldName') + 'Error');
        if (val === null || val === undefined || val === '' || val.trim().length === 0) {
            console.log('empty. adding error');
            $A.util.addClass(e, 'slds-has-error');
            $A.util.removeClass(divToShow, 'slds-hide');
            $A.util.addClass(divToShow, 'slds-show');
            // $A.createComponent(
            //     "aura:html",
            //     {
            //         tag: "div",
            //         HTMLAttributes:{"id": "required","class": "alert"}
            //     },
            //     function(compo){
            //         var container = cmp.find("container");
            //         if (container.isValid()) {
            //             var body = container.get("v.body");
            //             body.push(compo);
            //             container.set("v.body", body);
            //         }
            //     }
            // );
            console.log('error added');
            isValid = false;
        } else {
            $A.util.removeClass(e, 'slds-has-error');
            $A.util.addClass(divToShow, 'slds-hide');
            $A.util.removeClass(divToShow, 'slds-show');
        }
        return isValid;
    }
});