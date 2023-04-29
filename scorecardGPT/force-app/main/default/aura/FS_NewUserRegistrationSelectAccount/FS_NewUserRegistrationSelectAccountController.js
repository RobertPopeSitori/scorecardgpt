/**
 * Created by cmudd on 2019-05-30.
 */

({
    doInit : function (component, event, helper) {
        var email = component.get('v.workEmail');
        helper.callLookForExistingAccountsWithEmailDomain(component, email);
        // console.log('initializing select account component');
        // console.log(component.get("v.accounts"));
    },

    changeSelection : function (component, event, helper) {
        var accountSelection = component.get('v.accountSelection');
        // console.log(accountSelection);
        if (accountSelection != null && accountSelection !== '') {
            // console.log('account selected set true');
            component.set('v.accountsFound', true);
        } else {
            // console.log('no account selected');
            component.set('v.accountsFound', false);
        }
    }
});