({
    onInit: function(component){
        var action = component.get("c.getCommunitySettings");
		action.setCallback(this, function(actionResult) {
            if(actionResult.getState() === 'SUCCESS'){
                var result = actionResult.getReturnValue();
                 if(result !== ""){

                    console.log('RESULT:' + result);
                    var data = JSON.parse(result);
                    component.set("v.networkPath", data.networkPath);
                }
            } 
        });
        
        $A.enqueueAction(action); 
    }
})