({
	getattendeHelper : function(component) {
        debugger
        var callingclass = component.get("c.getAttende");
        callingclass.setParams({"AttendeID": component.get("v.recordId")});
        callingclass.setCallback(this,function(response){
            debugger
            var state = response.getState();
            if (state === "SUCCESS") {  
                console.log(response.getReturnValue());
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": response.getReturnValue()
                });
                urlEvent.fire();
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                        console.log("Error Line: " + 
                                    errors[0].LineNumber);
                    }
                } else {
                    console.log("Unknown error");
                    alert('Unknown');
                }
            }
        });
        $A.enqueueAction(callingclass);
    }
})