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
     getScorecard: function(component,event,idParamValue) {
        var action = component.get("c.getScorecardId");
        action.setParams({'idParamValue' : idParamValue});
        action.setCallback(this, function(response) {
            debugger
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === "SUCCESS") {
              
                component.set("v.scorecard",result)
                
             }
        });
        $A.enqueueAction(action);	
    }
})