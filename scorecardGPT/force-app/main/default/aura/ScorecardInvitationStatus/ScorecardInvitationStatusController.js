({
	doInit : function(component, event, helper) {
        debugger
        var idParamValue = helper.getURLParameterValue().id;
        helper.getScorecard(component,event,idParamValue);
        var userId = $A.get("$SObjectType.CurrentUser.Id");
       //var idParamValue = 'a3j7d000000TfE6';
        var action = component.get("c.getinvite");
        action.setParams({ 'idParamValue' : idParamValue,
                          'userId' : userId});
        action.setCallback(this, function(response) {
            debugger
            var state = response.getState();
            var result = response.getReturnValue();
            var scoreid = component.get("v.scorecard");
            if (state === "SUCCESS") {
                if(result == "Already Used"){
                    component.set("v.isOpen",true);
                }else if(result == "User Available"){
                     var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                       "url": "/OLC/s/scorecard-section?scorecard="+scoreid
                    });
                    urlEvent.fire();
                }
                else{
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                       "url": "/OLC/s/invitation?id="+idParamValue
                    });
                    urlEvent.fire();
                }
             }
        });
        $A.enqueueAction(action);	
    },
     redirectScorecard : function(component,event,helper) {
          var scoreid = component.get("v.scorecard");
        var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": "/OLC/s/scorecardapp"
                    });
                    urlEvent.fire();
    }
   
})