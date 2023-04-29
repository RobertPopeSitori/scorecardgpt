/**
 * Created by cmudd on 2019-05-31.
 */

({
    showSpinner : function (component) {
        component.set('v.showSpinner', true);
    },

    hideSpinner : function (component) {
        component.set('v.showSpinner', false);
        // console.log('password rules: ' + component.get('v.passwordRules'));
    },
    handleError: function (component, event, helper) {
        cmp.find('notifLib').showToast({
            "title": "An error occurred!",
            "message": event.getParam("message"),
            "variant": "error"
        });
        window.scrollTo(0, 0);
    },
    toggleHasOrg : function(component) {
      component.set('v.hasOrg', !component.get('v.hasOrg'));
    },

    doInit: function (component, event, helper) {
        // console.log('account selected: ' + component.get('v.accountsFound'));
        // component.set('v.loaded', true);
        // console.log('password rules: ' + component.get('v.passwordRules'));
    },

    // handleLoad : function (component, event, helper) {
    //     console.log('handling load');
    //     console.log('account selected: ' + component.get('v.accountsFound'));
    //     // component.set('v.showSpinner', false);
    //     console.log('should have loaded');
    // },
    handleSubmit: function (component, event, helper) {
        event.preventDefault();
        // console.log('beginning create contact method');
        component.set('v.errorMessage', '');
        component.set('v.showError', false);

        // check if an account should be created
        var accountSelection = component.get('v.accountSelection');
        var hasOrg = component.get('v.hasOrg');
        var password = component.find('password').get('v.value');
        var labels = component.get('v.labels');
        // console.log('account selection: ' + accountSelection);
        if (helper.validatePassword(component, password) ) {
            if (helper.isFormValid(component)) {
                // console.log('is valid');
                if (hasOrg && (accountSelection === null || accountSelection === '' || accountSelection === undefined)) {

                    // console.log('making account');
                    var email = component.get('v.workEmail');
                    var adminId = component.get('v.adminId');
                    var orgName = component.find('orgName').get('v.value');
                    var webUrl = component.find('webUrl').get('v.value');
                    var type = component.find('type').get('v.value');
                    var subType = component.find('subType').get('v.value');
                    var country = component.find('country').get('v.value');
                    var street = component.find('street').get('v.value');
                    var city = component.find('city').get('v.value');
                    var state = component.find('state').get('v.value');
                    var zipCode = component.find('zipCode').get('v.value');


                    // console.log('should be calling create new account');
                    helper.callCreateNewAccount(component, event, email, orgName, adminId, webUrl, type, subType, country, street, city, state, zipCode);

                } else {
                    // console.log('submitting form');
                    helper.submitForm(component, event);
                }
            } else {
                component.set('v.errorMessage', labels.Form_Incomplete_Error__c);
                component.set('v.showError', true);
            }
        } else {
            component.set('v.errorMessage', labels.Password_Invalid_Error__c);
            component.set('v.showError', true);
            window.scrollTo(0, 0);
            // console.log('returning false');
            // console.log('Should not submit');
        }


    },
    handleSuccess: function (component, event, helper) {
        // console.log('handling success');
        var record = event.getParam("response");
        var recordId = record.id;
        var password = component.find('password').get('v.value');
        var retUrl = component.get('v.defaultRetUrl');
        var startUrl = helper.getStartUrl();
        if (startUrl !== '') {
            retUrl = startUrl;
        }
        // console.log('calling finish registration. Ret URL after: ' + retUrl);
        helper.callFinishRegistrationWithPassword(component, recordId, password, retUrl);
    },
    callAddErrorToElement : function(component, event, helper) {
        var ele = event.getSource();
        var trg = ele.get('v.value');
        helper.addErrorToElement(component, ele, true);
    },
    callAddErrorToChildElement : function (component, event, helper) {
        // console.log('calling blur function');
        // console.log('event: ' + event);
        var ele = event.relatedTarget.querySelector('inputField');
        // console.log('element: ' + ele);
        var trg = ele.get('v.value');
        helper.addErrorToElement(component, ele, true);
    }
});