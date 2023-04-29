/**
 * Created by cmudd on 2019-05-29.
 */

({

    getUrlVars: function () {
        var vars = {};
        var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function (m, key, value) {
            vars[key] = value;
        });
        return vars;
    },
    callGetRegistrationLabels : function (component) {
        // console.log('in helper');
        var action = component.get("c.getRegistrationLabels");
        action.setCallback(this, function (a) {
            // console.log('in callback');
            // console.log(a.getReturnValue());
            component.set('v.labels', a.getReturnValue());
        });
        $A.enqueueAction(action);
    }
})
;