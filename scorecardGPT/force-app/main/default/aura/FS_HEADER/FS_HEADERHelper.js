({
	isUserLogged : function(cmp,helper) {
		// create a one-time use instance of the serverEcho action
        // in the server-side controller
        var action = cmp.get("c.fetchUserType");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                if(! response.getReturnValue()){
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                      "url": '/OLC/s/login/'
                    });
                    urlEvent.fire();
                }
	
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
	}
})