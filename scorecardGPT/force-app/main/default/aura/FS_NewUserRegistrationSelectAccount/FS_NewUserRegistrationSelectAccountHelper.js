/**
 * Created by cmudd on 2019-05-30.
 */

({
    callLookForExistingAccountsWithEmailDomain: function (component, email) {
        // console.log('looking for action');
        var action = component.get("c.lookForExistingAccountsWithValidEmailDomain");
        action.setParams(
            {email: email}
        );
        var labels = component.get('v.labels');
        // console.log('got action ' + action);
        action.setCallback(this, function (a) {
            // console.log('into the callback: ');
            var state = a.getState();
            if (state === 'SUCCESS') {
                var records = a.getReturnValue();
                console.log('++++++return records:');
                console.log(records);
                if (records !== null) {
                    // console.log('records: ' + records);
                    // console.log('records length: ' + records.length);
                    if (records.length === 1) {
                        if (records[0].label === labels.Sef_Registration_Account_Name__c) {
                            // place in self-registration bucket
                            component.set('v.selfRegistrationEnabled', true);
                        }
                        // console.log('assigning value from record: ' + records[0].value);
                        component.set('v.accountSelection', records[0].value);
                        component.set('v.accountSelectionName', records[0].label);
                        component.set('v.onlyOneAccount', true);
                    } else {
                        // console.log('setting accounts');
                        // console.log(records);
                        component.set('v.accounts', records);
                        component.set('v.loaded', true);
                        component.set('v.onlyOneAccount', false);
                    }
                    // component.set('v.accountsFound', true);
                } else {
                    component.set('v.selfRegistrationEnabled', true);
                    component.set('v.onlyOneAccount', true);
                }
                component.set('v.accountsFound', true);
                // console.log('accounts found is true');
                // console.log('did it load? : === ' + component.get('v.loaded'));
                // console.log('did it find one acct? : === ' + !component.get('v.onlyOneAccount'));
                // component.set()
            } else {
                component.set('v.errorMessage', labels.Generic_Error_Message__c);
                component.set('v.showError', true);
                document.body.scrollTop = document.documentElement.scrollTop = 0;
            }
            component.set('v.showSpinner', false);

        });
        component.set('v.showSpinner', true);
        $A.enqueueAction(action);
    }
});