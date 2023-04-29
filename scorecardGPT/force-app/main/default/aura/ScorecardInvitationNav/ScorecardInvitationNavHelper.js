({
    getInvitations : function(component, event, helper) {
        //alert('In Helper '+scorecardId);
        var idParamValue = helper.getURLParameterValue().scorecard;
        var action = component.get("c.getInvitations");
        action.setParams({ scorecardId: idParamValue });
        action.setCallback(this, function(actionResult) {
            if(actionResult.getState() === 'SUCCESS'){
                component.set("v.Invitations",actionResult.getReturnValue());
            }
        });
        
        $A.enqueueAction(action); 
    },
    
    getURLParameterValue: function() {
        var querystring = location.search.substr(1);
        var paramValue = {};
        querystring.split("&").forEach(function(part) {
            var param = part.split("=");
            paramValue[param[0]] = decodeURIComponent(param[1]);
        });

        console.log('paramValue-' + paramValue);
        return paramValue;
    }
})