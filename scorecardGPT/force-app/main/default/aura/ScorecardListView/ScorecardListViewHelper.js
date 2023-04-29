({
    onInit: function (component) 
    {
        var action = component.get("c.getScorecards");
		action.setCallback(this, function(actionResult) {
            if(actionResult.getState() === 'SUCCESS'){
                var result = actionResult.getReturnValue();
                 if(result !== ""){
                    var data = JSON.parse(result);
                    component.set("v.scorecards", data);
                     //alert(data[0].owner);
                }
            } 
            component.set("v.isLoading", false);
        });
        
        component.set("v.isLoading", true);
        $A.enqueueAction(action); 
    }
});