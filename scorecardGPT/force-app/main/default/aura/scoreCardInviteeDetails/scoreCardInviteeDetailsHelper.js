({
	getURLParameterValue: function() {

        var querystring = location.search.substr(1);
        var paramValue = {};
        querystring.split("&").forEach(function(part) {
            var param = part.split("=");
            paramValue[param[0]] = decodeURIComponent(param[1]);
        });
        return paramValue;
    },
    getInvitation : function(component,event,helper){
        //debugger
        var idParamValue = helper.getURLParameterValue().id;
        var action = component.get("c.getinvite");
        action.setParams({ 'inviteesId' : idParamValue });
        action.setCallback(this, function(response) {
            //debugger
            var state = response.getState();
            if (state === "SUCCESS") {
              component.set('v.InvitaionRecord', response.getReturnValue())
              var sc = component.get('v.InvitaionRecord');
               component.set('v.ScorecardID',sc.Scorecard__r.Id); 
                
              
              
             }
        });
        $A.enqueueAction(action);	
	}
})